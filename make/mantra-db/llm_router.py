"""
llm_router.py — Unified LLM interface for the mantra-db pipeline.

Routes to Claude CLI or litellm (Ollama / cloud) depending on model prefix:
  - "claude/..."  ->  claude CLI subprocess (stdin for user message)
  - anything else ->  litellm.acompletion / litellm.completion

Drop-in replacement: callers use the same messages/kwargs interface.

Note: Uses asyncio.create_subprocess_exec (not shell exec) for safe,
injection-free subprocess calls with arguments passed as a list.
"""

import asyncio
import json
import shutil
import sys
from typing import Optional

import litellm
from litellm.types.utils import ModelResponse, Choices, Message

from log import get_logger

_log = get_logger("llm_router")

# ── Retryable error types ──────────────────────────────────────────────────


class ClaudeAuthError(RuntimeError):
    """Claude CLI authentication / API key failure. Retryable after reconnect."""
    pass


class OllamaOverloadError(RuntimeError):
    """Ollama connection timeout — likely overloaded with concurrent requests."""
    pass


# ── Retry config ───────────────────────────────────────────────────────────

_MAX_RETRIES = 3
_RETRY_BASE_DELAY = 5      # seconds, doubles each retry
_AUTH_RETRY_DELAY = 60      # seconds — retry forever, give user time to reconnect

# ── Claude CLI detection ────────────────────────────────────────────────────

_CLAUDE_PREFIX = "claude/"

_claude_bin: Optional[str] = None
_claude_checked = False


def _find_claude() -> Optional[str]:
    """Locate the claude CLI binary. Cached after first call."""
    global _claude_bin, _claude_checked
    if not _claude_checked:
        _claude_bin = shutil.which("claude")
        _claude_checked = True
        if _claude_bin:
            _log.debug("Claude CLI found: %s", _claude_bin)
        else:
            _log.warning("Claude CLI not found in PATH")
    return _claude_bin


def is_claude_model(model: str) -> bool:
    return model.startswith(_CLAUDE_PREFIX)


def _claude_model_name(model: str) -> str:
    """'claude/sonnet' -> 'sonnet', 'claude/opus' -> 'opus'."""
    return model[len(_CLAUDE_PREFIX):]


def _strip_ollama_kwargs(kwargs: dict) -> dict:
    """Remove Ollama-specific kwargs that Claude doesn't understand."""
    cleaned = {}
    for k, v in kwargs.items():
        if k == "extra_body":
            continue  # Ollama options (num_ctx etc.)
        if k == "api_base":
            continue  # Ollama base URL
        cleaned[k] = v
    return cleaned


_AUTH_ERROR_PATTERNS = ["apiKeyHelper", "api key", "authentication", "unauthorized"]
_RATE_LIMIT_PATTERNS = ["429", "rate limit", "too many requests", "throttl"]


def _classify_cli_error(stdout: str, stderr: str) -> str:
    """Classify a Claude CLI failure. Returns 'auth', 'rate_limit', or 'unknown'."""
    combined = (stdout + " " + stderr).lower()
    for pat in _AUTH_ERROR_PATTERNS:
        if pat.lower() in combined:
            return "auth"
    for pat in _RATE_LIMIT_PATTERNS:
        if pat.lower() in combined:
            return "rate_limit"
    return "unknown"


# ── Claude CLI call ─────────────────────────────────────────────────────────


async def _claude_cli_call(
    model: str,
    messages: list[dict],
    timeout: Optional[int] = None,
    max_tokens: Optional[int] = None,
    **kwargs,
) -> ModelResponse:
    """Call Claude via the CLI subprocess.

    System message -> --system-prompt flag.
    User message -> piped via stdin.
    Uses asyncio.create_subprocess with PIPE (safe, no shell).
    """
    claude_bin = _find_claude()
    if not claude_bin:
        raise RuntimeError("Claude CLI not found in PATH")

    # Extract system and user content from messages
    system_parts = []
    user_parts = []
    for msg in messages:
        role = msg.get("role", "")
        content = msg.get("content", "")
        if role == "system":
            system_parts.append(content)
        elif role == "user":
            user_parts.append(content)
        elif role == "assistant":
            # Fold prior assistant turns into user context
            user_parts.append(f"[Previous response]\n{content}")

    user_text = "\n\n".join(user_parts)
    model_name = _claude_model_name(model)

    cmd = [
        claude_bin,
        "-p",
        "--output-format", "json",
        "--model", model_name,
        "--tools", "",         # no tool use -- pure completion
    ]
    if system_parts:
        cmd.extend(["--system-prompt", "\n\n".join(system_parts)])
    if max_tokens:
        cmd.extend(["--max-tokens", str(max_tokens)])

    _log.debug("claude CLI call  model=%s  stdin=%d chars", model_name, len(user_text))

    attempt = 0
    while True:
        attempt += 1
        # Safe subprocess: no shell, args as list, user content via stdin pipe
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        timeout_s = timeout or 600
        try:
            stdout, stderr = await asyncio.wait_for(
                proc.communicate(input=user_text.encode()),
                timeout=timeout_s,
            )
        except asyncio.TimeoutError:
            proc.kill()
            raise TimeoutError(f"Claude CLI timed out after {timeout_s}s")

        raw_output = stdout.decode().strip()
        err_output = stderr.decode().strip()

        if proc.returncode != 0:
            error_type = _classify_cli_error(raw_output, err_output)

            if error_type == "auth":
                sys.stderr.write("\a")
                sys.stderr.flush()
                _log.warning("  Claude auth error (attempt %d), "
                             "retrying in %ds — reconnect Claude CLI ...",
                             attempt, _AUTH_RETRY_DELAY)
                await asyncio.sleep(_AUTH_RETRY_DELAY)
                continue

            if error_type == "rate_limit" and attempt <= _MAX_RETRIES:
                delay = _RETRY_BASE_DELAY * (2 ** (attempt - 1))
                _log.warning("  rate-limited (attempt %d/%d), retrying in %ds ...",
                             attempt, _MAX_RETRIES, delay)
                await asyncio.sleep(delay)
                continue

            raise RuntimeError(f"Claude CLI failed (rc={proc.returncode}): {err_output}")

        break  # success

    # Parse JSON response
    raw_output = stdout.decode().strip()
    try:
        result = json.loads(raw_output)
    except json.JSONDecodeError:
        raise RuntimeError(f"Claude CLI returned non-JSON: {raw_output[:500]}")

    if result.get("is_error"):
        raise RuntimeError(f"Claude CLI error: {result.get('result', raw_output[:500])}")

    content = result.get("result", "")
    cost = result.get("cost_usd", 0)
    duration_ms = result.get("duration_ms", 0)

    _log.debug("claude CLI response  model=%s  len=%d  cost=$%.4f  time=%dms",
               model_name, len(content), cost, duration_ms)

    return ModelResponse(
        choices=[Choices(
            message=Message(role="assistant", content=content),
            finish_reason="stop",
            index=0,
        )],
        model=model,
    )


# ── Public interface ────────────────────────────────────────────────────────


async def acompletion(
    model: str,
    messages: list[dict],
    timeout: Optional[int] = None,
    max_tokens: Optional[int] = None,
    **kwargs,
) -> ModelResponse:
    """Async completion -- routes to Claude CLI or litellm.

    Raises:
        ClaudeAuthError: Claude CLI auth failure (retryable after reconnect)
        OllamaOverloadError: Ollama connection timeout (reduce concurrency)
    """
    if is_claude_model(model):
        return await _claude_cli_call(
            model, messages,
            timeout=timeout,
            max_tokens=max_tokens,
            **_strip_ollama_kwargs(kwargs),
        )

    try:
        return await litellm.acompletion(
            model=model,
            messages=messages,
            timeout=timeout,
            max_tokens=max_tokens,
            **kwargs,
        )
    except (litellm.Timeout, litellm.APIConnectionError) as e:
        err_str = str(e).lower()
        if "timeout" in err_str or "connection" in err_str:
            raise OllamaOverloadError(
                f"Ollama timeout for {model} — server may be overloaded "
                f"(consider reducing ollama_concurrency): {e}"
            ) from e
        raise


def completion(
    model: str,
    messages: list[dict],
    timeout: Optional[int] = None,
    max_tokens: Optional[int] = None,
    **kwargs,
) -> ModelResponse:
    """Sync completion -- routes to Claude CLI or litellm."""
    if is_claude_model(model):
        return asyncio.run(_claude_cli_call(
            model, messages,
            timeout=timeout,
            max_tokens=max_tokens,
            **_strip_ollama_kwargs(kwargs),
        ))

    try:
        return litellm.completion(
            model=model,
            messages=messages,
            timeout=timeout,
            max_tokens=max_tokens,
            **kwargs,
        )
    except (litellm.Timeout, litellm.APIConnectionError) as e:
        err_str = str(e).lower()
        if "timeout" in err_str or "connection" in err_str:
            raise OllamaOverloadError(
                f"Ollama timeout for {model} — server may be overloaded "
                f"(consider reducing ollama_concurrency): {e}"
            ) from e
        raise
