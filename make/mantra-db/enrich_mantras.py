#!/usr/bin/env python3
"""
enrich_mantras.py — Enrich deduped mantras with background, benefits, tags, etc.

Four-step pipeline:
  Step 0 — Context filter:  chunk source texts → filter with lightweight LLM
                             → one concatenated relevant-text per mantra (fast)
  Step 1 — Students:        for each model (batched) × mantra × assignment
                             → answer + wall time  (grounding discarded)
  Step 2 — Grader:          single grader model scores each student answer
                             → Answer (integer 0–100) + Grounding
  Step 3 — Combine:         pick best per field, scatter plot (subplot per
                             assignment, series per student), log table stats

All LLM calls use dynamic num_ctx sized to actual input + 4K output reserve.
Context filtering (step 0) runs once per mantra; students + grader share the
pre-filtered text.

Output: tmp/enriched_mantras.json  (resumable via tmp/enrich_answers.json)
"""

import asyncio
import json
import re
import sys
import time
from pathlib import Path

import litellm
from tqdm import tqdm

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ollama
from log import get_logger, Timer
from web_cache import fetch_text, url_hash, CACHE_DIR

_log = get_logger("enrich_mantras")

litellm.set_verbose = False

_ROOT = Path(__file__).parent.parent.parent
_ecfg = cfg()["enrich_mantras"]

DEDUPED = root_path("enrich_mantras", "input")
MANTRAS_FILE = _ROOT / "assets" / "data" / "mantras.json"
OUTPUT = root_path("enrich_mantras", "output")

# ── Config: context filter (step 0) ──────────────────────────────────────────
_filter_cfg = _ecfg["context_filter"]
FILTER_MODEL = ollama(_filter_cfg["llm_filter"])
FILTER_SYSTEM = _filter_cfg["system"].strip()
FILTER_TIMEOUT = int(_filter_cfg.get("llm_timeout", 30))
FILTER_TEMPERATURE = float(_filter_cfg.get("llm_temperature", 0))
MIN_CHUNK_LEN = int(_filter_cfg.get("min_chunk_len", 100))
MAX_CHUNK_LEN = int(_filter_cfg.get("max_chunk_len", 2000))

# ── Config: student assignments (step 1) ─────────────────────────────────────
_assign_cfg = _ecfg["assignments"]
STUDENT_MODELS = [ollama(e) for e in _assign_cfg["llm_students"]]
STUDENT_SYSTEM = _assign_cfg["system"].strip()
_NON_ASSIGNMENT_KEYS = {"llm_students", "system"}
ASSIGNMENTS: dict[str, dict] = {
    k: v for k, v in _assign_cfg.items()
    if k not in _NON_ASSIGNMENT_KEYS and isinstance(v, dict)
}

# ── Config: grader (step 2) ──────────────────────────────────────────────────
_grader_cfg = _ecfg["grader_options"]
MODEL_GRADER = ollama(_grader_cfg["llm_grader"])
GRADER_SYSTEM = _grader_cfg["system"].strip()
GRADER_TEMPERATURE = float(_grader_cfg.get("llm_temperature", 0))
GRADE_WEIGHTS: dict[str, int] = _grader_cfg["weights"]

HTTP_TIMEOUT = int(_ecfg.get("http_timeout", 10))
_LLM_TIMEOUT = int(_ecfg.get("llm_timeout", 600))

_SEP = "#" * 79


def _banner(title: str, body_lines: list) -> None:
    _log.info(_SEP)
    _log.info("### %s", title)
    _log.info(_SEP)
    for line in body_lines:
        _log.info(line)
    _log.info(_SEP)


def _model_short(model: str) -> str:
    """'ollama/phi3:14b' -> 'phi3:14b'"""
    return model.split("/")[-1]


async def _warmup(model: str) -> None:
    """Send a trivial request to ensure the model is loaded in Ollama VRAM."""
    short = _model_short(model)
    _log.info("  Warming up %s ...", short)
    try:
        await litellm.acompletion(
            model=model,
            messages=[{"role": "user", "content": "hi"}],
            max_tokens=1,
            temperature=0,
        )
        _log.info("  %s ready.", short)
    except Exception as e:
        _log.warning("  warmup failed for %s: %s", short, e)


MAX_RETRIES = 2
RETRY_PAUSE = 5  # seconds


async def _llm_call_with_retry(call_fn, label: str):
    """Retry an async LLM call up to MAX_RETRIES times with a pause between attempts."""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            return await call_fn()
        except Exception as e:
            if attempt < MAX_RETRIES:
                _log.warning("  retry %d/%d for %s: %s",
                             attempt, MAX_RETRIES, label, e)
                await asyncio.sleep(RETRY_PAUSE)
            else:
                raise


def _expand_task(field_cfg: dict) -> str:
    """Substitute {key} placeholders in task text from field config values."""
    task = field_cfg["task"].strip()
    for key, val in field_cfg.items():
        if key != "task":
            task = task.replace(f"{{{key}}}", str(val))
    return task


# ─────────────────────────────────────────────────────────────────────────────
# Existing-entry index
# ─────────────────────────────────────────────────────────────────────────────


def load_existing() -> dict[str, dict]:
    idx: dict[str, dict] = {}
    if not MANTRAS_FILE.exists():
        return idx
    data = json.loads(MANTRAS_FILE.read_text())
    items = data.get("mantras", []) if isinstance(data, dict) else data
    for item in items:
        for field in ("transliteration", "name", "original"):
            key = item.get(field, "").strip().lower()
            if key:
                idx.setdefault(key, item)
    return idx


def find_match(phrase: str, existing: dict[str, dict]) -> dict | None:
    key = phrase.strip().lower()
    if key in existing:
        return existing[key]
    for k, v in existing.items():
        if key in k or k in key:
            return v
    return None


# ─────────────────────────────────────────────────────────────────────────────
# Dynamic num_ctx + response parsing
# ─────────────────────────────────────────────────────────────────────────────

_CHARS_PER_TOKEN = 3.5
_OUTPUT_RESERVE = 4096


def estimate_num_ctx(system: str, user_message: str) -> int:
    """Smallest num_ctx that fits the full prompt + output reserve, rounded to 256."""
    total_chars = len(system) + len(user_message)
    input_tokens = int(total_chars / _CHARS_PER_TOKEN) + 1
    raw = input_tokens + _OUTPUT_RESERVE
    return ((raw + 255) // 256) * 256


def _parse_answer(raw: str) -> str:
    """Extract the Answer portion from 'Answer: ... Grounding: ...' format."""
    answer_match = re.search(r"(?i)^answer:\s*", raw, re.MULTILINE)
    grounding_match = re.search(r"(?i)^grounding:\s*", raw, re.MULTILINE)
    if answer_match and grounding_match and grounding_match.start() > answer_match.start():
        return raw[answer_match.end():grounding_match.start()].strip()
    if answer_match:
        return raw[answer_match.end():].strip()
    return raw.strip()


# ─────────────────────────────────────────────────────────────────────────────
# Fetch source texts via shared web_cache module
# ─────────────────────────────────────────────────────────────────────────────


def fetch_all_sources(
    mantras: list[dict], existing_idx: dict[str, dict],
) -> dict[str, dict]:
    """Fetch + extract text for every source URL per mantra.

    Returns {phrase: {"source_texts": [...], "existing_match": ...}}.
    """
    url_set: set[str] = set()
    for m in mantras:
        for src in m.get("sources", []):
            url_set.add(src["url"])
    all_urls = sorted(url_set)

    uncached = [u for u in all_urls if not (CACHE_DIR / f"{url_hash(u)}.txt").exists()]
    _log.info("  %d unique source URLs, %d cached, %d to extract.",
              len(all_urls), len(all_urls) - len(uncached), len(uncached))

    if uncached:
        with tqdm(uncached, desc="  Extracting text", unit="url") as pbar:
            for url in pbar:
                pbar.set_postfix_str(url[:50])
                fetch_text(url)

    result: dict[str, dict] = {}
    for mantra in mantras:
        phrase = mantra["phrase"]
        source_texts = [
            text for src in mantra.get("sources", [])
            if (text := fetch_text(src["url"]))
        ]
        result[phrase] = {
            "source_texts": source_texts,
            "existing_match": find_match(phrase, existing_idx),
        }
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Step 0 — Context filter  (chunk -> filter with lightweight LLM -> concatenate)
# ─────────────────────────────────────────────────────────────────────────────


def _chunk_text(text: str) -> list[str]:
    """Split text into paragraph-aligned chunks, respecting min/max chunk length.

    Paragraphs longer than MAX_CHUNK_LEN are force-split at sentence
    boundaries (or hard-cut if no sentence boundary is found).
    """
    paragraphs = re.split(r"\n{2,}", text)
    chunks: list[str] = []
    buf = ""

    def _flush(b: str) -> None:
        if len(b) >= MIN_CHUNK_LEN:
            chunks.append(b)

    def _split_long(block: str) -> list[str]:
        """Split a block longer than MAX_CHUNK_LEN at sentence boundaries."""
        pieces: list[str] = []
        while len(block) > MAX_CHUNK_LEN:
            # Try to break at a sentence boundary within the chunk
            cut = block.rfind(". ", 0, MAX_CHUNK_LEN)
            if cut < MAX_CHUNK_LEN // 2:
                cut = MAX_CHUNK_LEN  # hard-cut if no good sentence boundary
            else:
                cut += 1  # include the period
            pieces.append(block[:cut].strip())
            block = block[cut:].strip()
        if block:
            pieces.append(block)
        return pieces

    for para in paragraphs:
        para = para.strip()
        if not para:
            continue
        # Force-split oversized paragraphs first
        if len(para) > MAX_CHUNK_LEN:
            if buf:
                _flush(buf)
                buf = ""
            for piece in _split_long(para):
                _flush(piece)
            continue
        if buf and len(buf) + len(para) + 2 > MAX_CHUNK_LEN:
            _flush(buf)
            buf = para
        else:
            buf = f"{buf}\n\n{para}" if buf else para
    if buf:
        _flush(buf)
    return chunks


async def _filter_chunk(phrase: str, chunk: str) -> bool:
    """Ask the filter model if a chunk is relevant to the mantra phrase."""
    user = f"<mantra phrase>{phrase}</mantra phrase>\n\n<text>{chunk}</text>"
    num_ctx = estimate_num_ctx(FILTER_SYSTEM, user)

    async def _call():
        response = await litellm.acompletion(
            model=FILTER_MODEL,
            messages=[
                {"role": "system", "content": FILTER_SYSTEM},
                {"role": "user", "content": user},
            ],
            timeout=FILTER_TIMEOUT,
            max_tokens=8,
            temperature=FILTER_TEMPERATURE,
            extra_body={"options": {"num_ctx": num_ctx}},
        )
        raw = (response.choices[0].message.content or "").strip()
        return raw.lower().startswith("true")

    try:
        return await _llm_call_with_retry(_call, f"filter '{phrase[:30]}' ({len(chunk)} chars)")
    except Exception as e:
        _log.warning("filter failed for chunk (%d chars): %s", len(chunk), e)
        return False  # discard on failure — keeping it would cascade timeouts downstream



async def filter_all_contexts(
    mantras: list[dict], sources: dict[str, dict],
) -> dict[str, str]:
    """Run context filter for every mantra. Returns {phrase: filtered_text}."""
    # Pre-compute all chunks so tqdm tracks per-chunk progress
    mantra_chunks: list[tuple[str, list[str]]] = []  # (phrase, chunks)
    total_chunks = 0
    for mantra in mantras:
        phrase = mantra["phrase"]
        source_texts = sources.get(phrase, {}).get("source_texts", [])
        chunks: list[str] = []
        for text in source_texts:
            chunks.extend(_chunk_text(text))
        mantra_chunks.append((phrase, chunks))
        total_chunks += len(chunks)

    contexts: dict[str, str] = {}
    kept_chunks = 0

    with tqdm(total=total_chunks, desc="  Context filter", unit="chunk") as pbar:
        for phrase, chunks in mantra_chunks:
            kept: list[str] = []
            for chunk in chunks:
                pbar.set_postfix_str(f"'{phrase[:30]}' ({len(chunk)} chars)")
                if await _filter_chunk(phrase, chunk):
                    kept.append(chunk)
                pbar.update(1)

            contexts[phrase] = "\n\n".join(kept)
            kept_chunks += len(kept)
            _log.debug("filter '%s': %d/%d chunks kept",
                       phrase[:30], len(kept), len(chunks))

    _log.info("  Chunks: %d total, %d kept (%.0f%% filtered out).",
              total_chunks, kept_chunks,
              100 * (1 - kept_chunks / total_chunks) if total_chunks else 0)
    return contexts


# ─────────────────────────────────────────────────────────────────────────────
# Step 1 — Student assignments (batched by model)
# ─────────────────────────────────────────────────────────────────────────────

_AnswerKey = tuple[str, str, str]  # (phrase, field_name, model)


async def call_student(
    model: str, phrase: str, filtered_context: str,
    existing_match: dict | None, task: str,
    temperature: float,
) -> str:
    """Call a student model with pre-filtered context. Returns answer only."""
    header = f"<mantra phrase>{phrase}</mantra phrase>"
    if existing_match:
        header += f"\n\nExisting entry:\n{json.dumps(existing_match, ensure_ascii=False)}"

    context = f"{header}\n\n{filtered_context}" if filtered_context else header
    user_message = (
        f"<source material>\n{context}\n</source material>\n\n"
        f"<assignment>\n{task}\n</assignment>"
    )
    num_ctx = estimate_num_ctx(STUDENT_SYSTEM, user_message)
    _log.debug("student  model=%s  phrase='%s'  ctx=%d chars  num_ctx=%d",
               _model_short(model), phrase[:30], len(context), num_ctx)

    async def _call():
        response = await litellm.acompletion(
            model=model,
            messages=[
                {"role": "system", "content": STUDENT_SYSTEM},
                {"role": "user", "content": user_message},
            ],
            timeout=_LLM_TIMEOUT,
            temperature=temperature,
            extra_body={"options": {"num_ctx": num_ctx}},
        )
        raw = (response.choices[0].message.content or "").strip()
        _log.debug("student response  model=%s  len=%d:\n%s",
                   _model_short(model), len(raw), raw[:500])
        return _parse_answer(raw)

    return await _llm_call_with_retry(
        _call, f"student {_model_short(model)} '{phrase[:30]}'")

async def run_students(
    mantras: list[dict],
    sources: dict[str, dict],
    contexts: dict[str, str],
    answers: dict[_AnswerKey, dict],
    pbar: tqdm,
) -> None:
    """Step 1: all student calls, batched by model to avoid Ollama swapping."""
    for model in STUDENT_MODELS:
        short = _model_short(model)
        await _warmup(model)
        for mantra in mantras:
            phrase = mantra["phrase"]
            existing_match = sources.get(phrase, {}).get("existing_match")
            filtered_context = contexts.get(phrase, "")

            for field_name, field_cfg in ASSIGNMENTS.items():
                key = (phrase, field_name, model)
                if key in answers:
                    pbar.update(1)
                    continue

                task = _expand_task(field_cfg)
                temperature = float(field_cfg.get("llm_temperature", 0))

                pbar.set_postfix_str(f"'{phrase[:20]}' {field_name} ({short})")

                t0 = time.perf_counter()
                try:
                    answer = await call_student(
                        model, phrase, filtered_context, existing_match,
                        task, temperature,
                    )
                except Exception as exc:
                    _log.warning("student %s failed '%s' %s: %s",
                                 short, phrase[:40], field_name, exc)
                    answer = ""
                speed = time.perf_counter() - t0

                answers[key] = {"answer": answer, "speed_s": round(speed, 2)}
                pbar.update(1)


# ─────────────────────────────────────────────────────────────────────────────
# Step 2 — Grader (single model, Answer/Grounding format -> integer score)
# ─────────────────────────────────────────────────────────────────────────────


async def grade_answer(
    phrase: str, filtered_context: str, task: str, answer: str,
) -> tuple[int, str]:
    """Grade a student answer. Returns (score 0-100, grounding)."""
    user_message = (
        f"<source material>\n{filtered_context}\n</source material>\n\n"
        f"<mantra phrase>{phrase}</mantra phrase>\n\n"
        f"<assignment>\n{task}\n</assignment>\n\n"
        f"<student answer>\n{answer}\n</student answer>"
    )
    num_ctx = estimate_num_ctx(GRADER_SYSTEM, user_message)
    _log.debug("grader  phrase='%s'  prompt=%d chars  num_ctx=%d",
               phrase[:30], len(user_message), num_ctx)

    async def _call():
        response = await litellm.acompletion(
            model=MODEL_GRADER,
            messages=[
                {"role": "system", "content": GRADER_SYSTEM},
                {"role": "user", "content": user_message},
            ],
            timeout=_LLM_TIMEOUT,
            temperature=GRADER_TEMPERATURE,
            extra_body={"options": {"num_ctx": num_ctx}},
        )
        raw = (response.choices[0].message.content or "").strip()
        _log.debug("grader response  phrase='%s':\n%s", phrase[:30], raw[:500])
        answer_text = _parse_answer(raw)
        score_match = re.search(r"\d+", answer_text)
        score = max(0, min(100, int(score_match.group()))) if score_match else 0
        return score, raw

    try:
        return await _llm_call_with_retry(_call, f"grader '{phrase[:30]}'")
    except Exception as e:
        _log.warning("grading failed '%s': %s", phrase[:50], e)
        return 0, "grading failed"


async def run_grader(
    mantras: list[dict],
    contexts: dict[str, str],
    answers: dict[_AnswerKey, dict],
    pbar: tqdm,
) -> None:
    """Step 2: grade all student answers with the grader model (loaded once)."""
    for mantra in mantras:
        phrase = mantra["phrase"]
        filtered_context = contexts.get(phrase, "")

        for field_name, field_cfg in ASSIGNMENTS.items():
            task = _expand_task(field_cfg)
            for model in STUDENT_MODELS:
                key = (phrase, field_name, model)
                entry = answers.get(key)
                if not entry or "score" in entry:
                    pbar.update(1)
                    continue

                short = _model_short(model)
                pbar.set_postfix_str(f"grade '{phrase[:20]}' {field_name} ({short})")

                if not entry["answer"]:
                    entry["score"] = 0
                    entry["reason"] = "empty answer"
                else:
                    score, reason = await grade_answer(
                        phrase, filtered_context, task, entry["answer"],
                    )
                    entry["score"] = score
                    entry["reason"] = reason

                pbar.update(1)


# ─────────────────────────────────────────────────────────────────────────────
# Step 3 — Combine results, statistics table, scatter plot
# ─────────────────────────────────────────────────────────────────────────────


def pick_winners(
    mantras: list[dict],
    sources: dict[str, dict],
    answers: dict[_AnswerKey, dict],
) -> dict[str, dict]:
    """Pick best-scoring model per (mantra, field). Build results dict."""
    total_weight = sum(GRADE_WEIGHTS.values())
    results: dict[str, dict] = {}

    for mantra in mantras:
        phrase = mantra["phrase"]
        entry: dict = {
            "name": phrase,
            "original": phrase,
            "sources": list(mantra.get("sources", [])),
        }
        model_scores: dict[str, dict] = {
            m: {"fields": {}, "total_speed_s": 0.0, "weighted_score": 0.0}
            for m in STUDENT_MODELS
        }

        for field_name in ASSIGNMENTS:
            weight = GRADE_WEIGHTS.get(field_name, 0)
            best_answer, best_score, best_model = "", -1, ""

            for model in STUDENT_MODELS:
                key = (phrase, field_name, model)
                a = answers.get(key, {})
                answer = a.get("answer", "")
                score = a.get("score", 0)
                speed = a.get("speed_s", 0.0)

                model_scores[model]["fields"][field_name] = {
                    "answer": answer, "score": score, "speed_s": speed,
                }
                model_scores[model]["total_speed_s"] += speed
                model_scores[model]["weighted_score"] += score * weight / total_weight

                if score > best_score:
                    best_score = score
                    best_answer = answer
                    best_model = model

            entry[field_name] = best_answer
            entry.setdefault("_best_models", {})[field_name] = best_model

        entry["_scores"] = model_scores
        results[phrase] = entry

    return results


def log_statistics(answers: dict[_AnswerKey, dict]) -> None:
    """Log a summary table: per assignment x model -> avg score, avg time, count."""
    # Collect: {field: {model: {"scores": [], "times": []}}}
    table: dict[str, dict[str, dict[str, list]]] = {}
    for (phrase, field, model), entry in answers.items():
        table.setdefault(field, {}).setdefault(model, {"scores": [], "times": []})
        table[field][model]["scores"].append(entry.get("score", 0))
        table[field][model]["times"].append(entry.get("speed_s", 0.0))

    if not table:
        return

    shorts = [_model_short(m) for m in STUDENT_MODELS]
    col_w = max(20, max(len(s) for s in shorts) + 2)

    # Header
    header = f"{'Assignment':<20}"
    for s in shorts:
        header += f" | {s:^{col_w}}"
    _log.info("")
    _log.info(header)

    # Separator
    sep = f"{'':->20}"
    for _ in shorts:
        sep += f"-+-{'':->{col_w}}"
    _log.info(sep)

    # Sub-header
    sub_h = f"{'':20}"
    for _ in shorts:
        sub_h += f" | {'score':>6} {'time':>6} {'n':>4}"
    _log.info(sub_h)
    _log.info(sep)

    # Data rows
    for field_name in ASSIGNMENTS:
        row = f"{field_name:<20}"
        for model in STUDENT_MODELS:
            data = table.get(field_name, {}).get(model, {"scores": [], "times": []})
            scores, times = data["scores"], data["times"]
            n = len(scores)
            avg_s = sum(scores) / n if n else 0
            avg_t = sum(times) / n if n else 0
            row += f" | {avg_s:6.1f} {avg_t:5.1f}s {n:4d}"
        _log.info(row)

    # Totals row
    _log.info(sep)
    totals_row = f"{'TOTAL':<20}"
    for model in STUDENT_MODELS:
        all_scores = []
        all_times = []
        for field_name in ASSIGNMENTS:
            data = table.get(field_name, {}).get(model, {"scores": [], "times": []})
            all_scores.extend(data["scores"])
            all_times.extend(data["times"])
        n = len(all_scores)
        avg_s = sum(all_scores) / n if n else 0
        avg_t = sum(all_times) / n if n else 0
        totals_row += f" | {avg_s:6.1f} {avg_t:5.1f}s {n:4d}"
    _log.info(totals_row)
    _log.info("")


PLOT_OUTPUT = root_path("enrich_mantras", "output").parent / "score_scatter.png"
_PALETTE = ["#4e8ef7", "#f76b4e", "#4ecf7a", "#f7c44e", "#b04ef7", "#4ef7e8"]
_MARKERS = ["o", "s", "^", "D", "P", "X"]


def plot_scores(answers: dict[_AnswerKey, dict]) -> None:
    """Scatter plot: one subplot per assignment, one series per student model."""
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        _log.warning("matplotlib not installed -- skipping plot.")
        return

    assignment_names = list(ASSIGNMENTS.keys())
    n_assign = len(assignment_names)
    if n_assign == 0:
        return

    ncols = min(3, n_assign)
    nrows = (n_assign + ncols - 1) // ncols
    fig, axes = plt.subplots(nrows, ncols, figsize=(7 * ncols, 5 * nrows), squeeze=False)

    for idx, field_name in enumerate(assignment_names):
        ax = axes[idx // ncols][idx % ncols]
        ax.set_title(field_name, fontsize=13)
        ax.set_xlabel("Time (s)")
        ax.set_ylabel("Score (0-100)")
        ax.grid(True, linestyle="--", alpha=0.4)

        for i, model in enumerate(STUDENT_MODELS):
            short = _model_short(model)
            xs, ys = [], []
            for (phrase, field, m), entry in answers.items():
                if field == field_name and m == model:
                    xs.append(entry.get("speed_s", 0))
                    ys.append(entry.get("score", 0))
            if xs:
                ax.scatter(
                    xs, ys, label=short,
                    color=_PALETTE[i % len(_PALETTE)],
                    marker=_MARKERS[i % len(_MARKERS)],
                    alpha=0.7, s=50, edgecolors="white", linewidths=0.5,
                )
        ax.legend(fontsize=9)

    # Hide empty subplots
    for idx in range(n_assign, nrows * ncols):
        axes[idx // ncols][idx % ncols].set_visible(False)

    fig.suptitle("Student Models: Score vs Time per Assignment", fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig(PLOT_OUTPUT, dpi=150, bbox_inches="tight")
    _log.info("Scatter plot saved to %s", PLOT_OUTPUT)


# ─────────────────────────────────────────────────────────────────────────────
# Main pipeline
# ─────────────────────────────────────────────────────────────────────────────


async def main() -> None:
    if not DEDUPED.exists():
        sys.exit(f"Error: {DEDUPED} not found -- run translate_n_dedup.py first.")

    deduped: dict[str, dict] = json.loads(DEDUPED.read_text())
    mantras = list(deduped.values())
    total = len(mantras)

    assignment_names = list(ASSIGNMENTS.keys())
    n_students = len(STUDENT_MODELS)
    total_student = total * len(ASSIGNMENTS) * n_students
    total_grader = total_student

    _banner(
        "Stage 4: enrich_mantras",
        [
            f"###   Input:           {DEDUPED}  ({total} phrases)",
            f"###   Output:          {OUTPUT}",
            f"###   Filter model:    {_model_short(FILTER_MODEL)}  (timeout {FILTER_TIMEOUT}s)",
            f"###   Student models:  {', '.join(_model_short(m) for m in STUDENT_MODELS)}",
            f"###   Grader model:    {_model_short(MODEL_GRADER)}  (timeout {GRADER_TIMEOUT}s)",
            f"###   Assignments:     {', '.join(assignment_names)}",
            f"###   Total calls:     {total_student} student + {total_grader} grader",
        ],
    )
    _log.info("")

    existing_idx = load_existing()

    # ── Fetch sources ────────────────────────────────────────────────────────
    _log.info("Fetch -- Extract source texts (trafilatura)")
    t = Timer().start()
    sources = fetch_all_sources(mantras, existing_idx)
    t.stop()
    fetched = sum(1 for s in sources.values() if s.get("source_texts"))
    _log.info("  %d/%d mantras have source texts.  (%.1f s)\n",
              fetched, total, t.elapsed)

    # ── Step 0: Context filter ───────────────────────────────────────────────
    _log.info("Step 0 -- Context filter (%s, %d mantras)",
              _model_short(FILTER_MODEL), total)
    await _warmup(FILTER_MODEL)
    t = Timer().start()
    contexts = await filter_all_contexts(mantras, sources)
    t.stop()
    ctx_chars = sum(len(c) for c in contexts.values())
    _log.info("  Done: %d filtered contexts (%d chars total).  (%.1f s)\n",
              len(contexts), ctx_chars, t.elapsed)

    # ── Load answer cache for resume ─────────────────────────────────────────
    answers_cache = OUTPUT.parent / "enrich_answers.json"
    answers: dict[_AnswerKey, dict] = {}
    if answers_cache.exists():
        raw = json.loads(answers_cache.read_text())
        answers = {tuple(k.split("|")): v for k, v in raw.items()}
        _log.info("  Resuming: %d cached answers.\n", len(answers))

    def _save_answers():
        serialisable = {"|".join(k): v for k, v in answers.items()}
        answers_cache.write_text(json.dumps(serialisable, indent=2, ensure_ascii=False))

    # ── Step 1: Students ─────────────────────────────────────────────────────
    _log.info("Step 1 -- Students (%d calls, batched by model)", total_student)
    t = Timer().start()
    with tqdm(total=total_student, desc="  Students", unit="call") as pbar:
        await run_students(mantras, sources, contexts, answers, pbar)
    t.stop()
    _save_answers()
    _log.info("  Done.  (%.1f s)\n", t.elapsed)

    # ── Step 2: Grader ───────────────────────────────────────────────────────
    _log.info("Step 2 -- Grading (%d calls, model: %s)",
              total_grader, _model_short(MODEL_GRADER))
    await _warmup(MODEL_GRADER)
    t = Timer().start()
    with tqdm(total=total_grader, desc="  Grading", unit="call") as pbar:
        await run_grader(mantras, contexts, answers, pbar)
    t.stop()
    _save_answers()
    _log.info("  Done.  (%.1f s)\n", t.elapsed)

    # ── Step 3: Combine + statistics ─────────────────────────────────────────
    _log.info("Step 3 -- Combine results + statistics")
    results = pick_winners(mantras, sources, answers)
    OUTPUT.write_text(json.dumps(results, indent=2, ensure_ascii=False))

    log_statistics(answers)
    plot_scores(answers)

    _log.info("")
    _banner(
        "Results: enrich_mantras",
        [
            f"###   Enriched:  {len(results)}/{total} mantras",
            f"###   Written:   {OUTPUT}",
        ],
    )


if __name__ == "__main__":
    asyncio.run(main())
