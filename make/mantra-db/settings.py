"""
Shared settings loader for the mantra-db pipeline.

Usage in any pipeline script:
    from settings import cfg, root_path, ROOT

    URLS_FILE = root_path("search_web", "output")   # → absolute Path
    MODELS    = cfg()["enrich_mantras"]["llm_engines"]
"""

from pathlib import Path

_SELF = Path(__file__).parent
ROOT = _SELF.parent.parent  # make/mantra-db/ → make/ → project root
_SETTINGS = _SELF / "settings.yml"

_cache: dict | None = None


def cfg() -> dict:
    """Return the parsed settings.yml (cached after first load)."""
    global _cache
    if _cache is None:
        try:
            import yaml
        except ImportError:
            raise ImportError("pyyaml is required — run: pip install pyyaml")
        _cache = yaml.safe_load(_SETTINGS.read_text())
    return _cache


def root_path(section: str, key: str = "output") -> Path:
    """Return the absolute Path for a file key in settings.yml."""
    return ROOT / cfg()[section][key]


def ollama_base() -> str:
    """Return the Ollama server base URL from settings (e.g. http://localhost:11434)."""
    oc = cfg().get("ollama", {})
    host = oc.get("host", "http://localhost").rstrip("/")
    port = oc.get("port", 11434)
    return f"{host}:{port}"


def ollama(model: str) -> str:
    """Prefix a bare model name with 'ollama/' for litellm."""
    return model if model.startswith("ollama/") else f"ollama/{model}"


# Parameters passed directly to litellm.completion vs Ollama-specific options
# (Ollama options must go through extra_body={"options": {...}})
_LITELLM_PARAMS = {"temperature", "top_p", "max_tokens", "stop", "seed"}


def llm_kwargs(section: str, options_key: str = "llm_options") -> dict:
    """Return litellm.completion kwargs for a pipeline section's options.

    Args:
        section: top-level YAML key (e.g. "extract_mantra", "enrich_mantras")
        options_key: which options block to read (default "llm_options";
                     use "grader_options", "translator_options", etc.)

    Standard litellm params (temperature, top_p, …) are returned as top-level
    keys.  Ollama-specific options (num_ctx, top_k, …) are nested under
    extra_body={"options": {…}}.
    """
    opts = cfg().get(section, {}).get(options_key, {})
    kwargs: dict = {}
    ollama_opts: dict = {}
    for k, v in opts.items():
        if k in _LITELLM_PARAMS:
            kwargs[k] = v
        else:
            ollama_opts[k] = v
    if ollama_opts:
        kwargs["extra_body"] = {"options": ollama_opts}
    return kwargs


def all_models() -> list[str]:
    """Return every unique Ollama model name referenced in settings.yml."""
    seen: set[str] = set()
    result: list[str] = []
    for section in cfg().values():
        if not isinstance(section, dict):
            continue
        for key in ("llm_engines", "llm_combine"):
            val = section.get(key)
            if isinstance(val, list):
                for m in val:
                    if m and m not in seen:
                        seen.add(m)
                        result.append(m)
            elif isinstance(val, str) and val and val not in seen:
                seen.add(val)
                result.append(val)
    return result


import json as _json
import re as _re

def parse_fenced_json(text: str):
    """Extract and parse JSON from a ```json``` fenced block in LLM output.

    Returns the parsed object (dict or list).
    Raises ValueError if no fenced JSON block is found.
    Raises json.JSONDecodeError if the block is not valid JSON.
    """
    m = _re.search(r"```json\s*\n?(.*?)```", text, _re.DOTALL)
    if m:
        return _json.loads(m.group(1).strip())
    # Fallback: try parsing the entire text as JSON (model skipped fences)
    stripped = text.strip()
    if stripped.startswith(("{", "[")):
        return _json.loads(stripped)
    raise ValueError("No ```json``` block found in LLM output")
