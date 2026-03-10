#!/usr/bin/env python3
"""
enrich_mantras.py — Enrich deduped mantras with content via per-field assignments.

For each mantra:
  Step 1: DDG search → 5 URLs → fetch with trafilatura
  Step 2: For each assignment (abstract, tags, tradition, ...):
            - Each student model answers the focused task
            - Grader scores each answer (task + answer → 0-100)
            - Best-scoring answer wins
  Step 3: Save merged entry

All LLM calls run sequentially (one model at a time) to avoid Ollama swapping.
Translation is handled by stage 3 (translate_n_dedup.py).
Output: tmp/enriched_mantras.json  (resumable)
"""

import asyncio
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

import litellm
import trafilatura
from ddgs import DDGS
from tqdm import tqdm

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ollama, llm_kwargs, parse_fenced_json

litellm.set_verbose = False

_ROOT = Path(__file__).parent.parent.parent
_ecfg = cfg()["enrich_mantras"]

DEDUPED = root_path("enrich_mantras", "input")
MANTRAS_FILE = _ROOT / "assets" / "data" / "mantras.json"
OUTPUT = root_path("enrich_mantras", "output")

# ── models ────────────────────────────────────────────────────────────────────
STUDENT_MODELS = [ollama(e) for e in _ecfg["llm_engines"]]
MODEL_GRADER = ollama(_ecfg["llm_grader"])
LLM_TIMEOUT = int(_ecfg.get("llm_timeout", 120))
GRADER_KWARGS = llm_kwargs("enrich_mantras", "grader_options")

# ── assignments from settings.yml ─────────────────────────────────────────────
SYSTEM_PROMPT = _ecfg["system"].strip()
ASSIGNMENTS: dict[str, dict] = _ecfg["assignments"]

_SEP = "#" * 79
MAX_SOURCE_CHARS = int(_ecfg["max_source_chars"])
HTTP_TIMEOUT = int(_ecfg["http_timeout"])


def _banner(title: str, body_lines: list) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)


# ─────────────────────────────────────────────────────────────────────────────
# DDG search
# ─────────────────────────────────────────────────────────────────────────────


def ddg_search(phrase: str) -> list[dict]:
    query = f"practicing mantra '{phrase}' - origin and impact"
    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=5))
        return [
            {"url": r.get("href", ""), "title": r.get("title", ""), "snippet": r.get("body", "")}
            for r in results if r.get("href")
        ]
    except Exception:
        return []


# ─────────────────────────────────────────────────────────────────────────────
# Source fetching  (trafilatura, shares cache with stage 2)
# ─────────────────────────────────────────────────────────────────────────────

CACHE_DIR = _ROOT / cfg()["extract_mantra"]["cache_dir"]

_CURL_CMD = [
    "curl", "-L", "-s", "--max-time", str(HTTP_TIMEOUT),
    "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "-H", "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "-H", "Accept-Encoding: identity",
]


def _cache_path(url: str) -> str:
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"{hashlib.md5(url.encode()).hexdigest()}.html")


def _fetch_html(url: str) -> str | None:
    cp = _cache_path(url)
    if os.path.exists(cp):
        with open(cp, encoding="utf-8") as f:
            content = f.read()
        return None if content.startswith("ERROR:") else content
    try:
        r = subprocess.run(_CURL_CMD + [url], capture_output=True, timeout=60)
        if r.returncode == 0 and len(r.stdout) > 200:
            html = r.stdout.decode("utf-8", errors="replace")
            with open(cp, "w", encoding="utf-8") as f:
                f.write(html)
            return html
    except Exception:
        pass
    with open(cp, "w") as f:
        f.write(f"ERROR: {url}")
    return None


def fetch_source(url: str) -> str:
    html = _fetch_html(url)
    if not html:
        return ""
    extracted = trafilatura.extract(html, include_comments=False, include_tables=True, no_fallback=False)
    if extracted and extracted.strip():
        return extracted.strip()[:MAX_SOURCE_CHARS]
    text = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", html, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text[:MAX_SOURCE_CHARS]


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
# Build source context string (shared across all assignments for one mantra)
# ─────────────────────────────────────────────────────────────────────────────


def build_context(mantra: dict, source_texts: list[str], search_results: list[dict], existing: dict | None) -> str:
    """Build the source context block that gets prepended to every assignment."""
    lines = [
        f"Mantra phrase: {mantra['phrase']}",
        f"Language(s): {', '.join(mantra['language'])}",
    ]
    if existing:
        lines += ["", "Existing entry:", json.dumps(existing, ensure_ascii=False)]
    for i, text in enumerate(source_texts, 1):
        if text:
            lines += ["", f"--- Source {i} ---", text]
    if search_results:
        lines += ["", "--- Web search snippets ---"]
        for r in search_results:
            lines.append(f"[{r['title']}] {r['snippet']}")
    return "\n".join(lines)


def _parse_answer_grounding(raw: str) -> tuple[str, str]:
    """Split 'Answer: ... Grounding: ...' format. Returns (answer, full_response)."""
    # Try to extract the Answer portion; keep full response for the grader
    answer_match = re.search(r"(?i)^answer:\s*", raw, re.MULTILINE)
    grounding_match = re.search(r"(?i)^grounding:\s*", raw, re.MULTILINE)
    if answer_match and grounding_match and grounding_match.start() > answer_match.start():
        answer = raw[answer_match.end():grounding_match.start()].strip()
    elif answer_match:
        answer = raw[answer_match.end():].strip()
    else:
        answer = raw  # fallback: model didn't follow format
    return answer, raw


# ─────────────────────────────────────────────────────────────────────────────
# Student call  (one assignment at a time)
# ─────────────────────────────────────────────────────────────────────────────


async def call_student(model: str, context: str, task: str, temperature: float, num_ctx: int) -> tuple[str, str]:
    """Ask a student model to complete one assignment. Returns (answer, full_response)."""
    ollama_opts = {"num_ctx": num_ctx}
    kwargs = {"temperature": temperature, "extra_body": {"options": ollama_opts}}
    response = await litellm.acompletion(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"{context}\n\n--- Assignment ---\n{task}"},
        ],
        timeout=LLM_TIMEOUT,
        **kwargs,
    )
    raw = (response.choices[0].message.content or "").strip()
    return _parse_answer_grounding(raw)


# ─────────────────────────────────────────────────────────────────────────────
# Grader call  (scores one student answer against the task)
# ─────────────────────────────────────────────────────────────────────────────


async def grade_answer(phrase: str, context: str, task: str, answer: str) -> tuple[int, str]:
    """Grade one student answer. Returns (score 0-100, reason)."""
    prompt = f"""Mantra: {phrase}

{context}

Assignment:
{task}

Student answer:
{answer}

Grade the student's answer on a scale of 0-100.
- Does the answer correctly and completely address the assignment?
- Is it accurate and grounded in the provided sources (not fabricated)?
- Is it well-written and specific to this mantra?

Return ONLY valid JSON: {{"score": <0-100>, "reason": "<one sentence>"}}"""

    try:
        response = await litellm.acompletion(
            model=MODEL_GRADER,
            messages=[{"role": "user", "content": prompt}],
            timeout=LLM_TIMEOUT,
            **GRADER_KWARGS,
        )
        raw = (response.choices[0].message.content or "").strip()
        data = parse_fenced_json(raw)
        return max(0, min(100, int(data.get("score", 0)))), data.get("reason", "")
    except Exception:
        return 0, "grading failed"


# ─────────────────────────────────────────────────────────────────────────────
# Scatter plot
# ─────────────────────────────────────────────────────────────────────────────

PLOT_OUTPUT = root_path("enrich_mantras", "output").parent / "score_scatter.png"
_PALETTE = ["#4e8ef7", "#f76b4e", "#4ecf7a", "#f7c44e", "#b04ef7", "#4ef7e8"]
_MARKERS = ["o", "s", "^", "D", "P", "X"]


def plot_scores(results: dict) -> None:
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not installed — skipping plot.")
        return

    series: dict[str, dict[str, list]] = {}
    for entry in results.values():
        scores = entry.get("_scores", {})
        for model_name, model_data in scores.items():
            if model_name not in series:
                series[model_name] = {"speed": [], "score": []}
            series[model_name]["speed"].append(model_data.get("total_speed_s", 0))
            series[model_name]["score"].append(model_data.get("weighted_score", 0))

    if not series:
        print("No eval data to plot.")
        return

    fig, ax = plt.subplots(figsize=(10, 6))
    for i, (model_name, data) in enumerate(series.items()):
        label = model_name.split("/")[-1]
        ax.scatter(
            data["speed"], data["score"],
            label=label,
            color=_PALETTE[i % len(_PALETTE)],
            marker=_MARKERS[i % len(_MARKERS)],
            alpha=0.75, s=65, edgecolors="white", linewidths=0.5,
        )
    ax.set_xlabel("Speed — total LLM time per mantra (seconds)", fontsize=12)
    ax.set_ylabel("Weighted Score (0–100)", fontsize=12)
    ax.set_title("Student Models — Speed vs Score per Mantra", fontsize=14)
    ax.legend(title="Model")
    ax.grid(True, linestyle="--", alpha=0.4)
    fig.tight_layout()
    fig.savefig(PLOT_OUTPUT, dpi=150)
    print(f"Scatter plot saved to {PLOT_OUTPUT}")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────


async def main() -> None:
    if not DEDUPED.exists():
        sys.exit(f"Error: {DEDUPED} not found — run translate_n_dedup.py first.")

    deduped: dict[str, dict] = json.loads(DEDUPED.read_text())
    mantras = list(deduped.values())
    total = len(mantras)

    assignment_names = list(ASSIGNMENTS.keys())
    total_grade_weight = sum(a["grade"] for a in ASSIGNMENTS.values())

    _banner(
        "Stage 4: enrich_mantras",
        [
            f"###   Input:           {DEDUPED}  ({total} phrases)",
            f"###   Output:          {OUTPUT}",
            f"###   Student models:  {', '.join(STUDENT_MODELS)}",
            f"###   Grader model:    {MODEL_GRADER}",
            f"###   Assignments:     {', '.join(assignment_names)}",
            f"###   Grade weights:   {total_grade_weight} total",
            f"###   llm_timeout:     {LLM_TIMEOUT} s",
        ],
    )
    print()

    # Resume from existing output
    results: dict[str, dict] = {}
    if OUTPUT.exists():
        results = json.loads(OUTPUT.read_text())
        print(f"Resuming: {len(results)} entries already done, {total - len(results)} remaining.")

    existing = load_existing()

    with tqdm(total=total, desc="Enriching mantras", unit="mantra") as pbar:
        for mantra in mantras:
            phrase = mantra["phrase"]

            if phrase in results and "_scores" in results[phrase]:
                pbar.update(1)
                continue

            t0 = time.time()

            # ── Step 1: DDG search + fetch sources ───────────────────────────
            pbar.set_postfix_str(f"'{phrase[:30]}' search")

            search_results = await asyncio.to_thread(ddg_search, phrase)

            urls_to_fetch: list[str] = [r["url"] for r in search_results]
            for src in mantra.get("sources", []):
                if src["url"] not in urls_to_fetch:
                    urls_to_fetch.append(src["url"])
            urls_to_fetch = urls_to_fetch[:5]

            # Fetch sources (interleave with student calls below)
            source_texts: list[str] = []
            for url in urls_to_fetch:
                text = await asyncio.to_thread(fetch_source, url)
                if text:
                    source_texts.append(text)
                if len(source_texts) == 1:
                    break  # start assignments as soon as we have 1 source

            existing_match = find_match(phrase, existing)
            context = build_context(mantra, source_texts, search_results, existing_match)

            # Collect DDG-derived sources for the entry
            sources = [{"url": r["url"], "title": r["title"]} for r in search_results]
            seen_urls = {s["url"] for s in sources}
            for src in mantra.get("sources", []):
                if src["url"] not in seen_urls:
                    sources.append(src)

            # ── Step 2: Assignments (per-field, per-student, graded) ─────────
            entry: dict = {
                "name": phrase,
                "original": phrase,
                "sources": sources,
            }
            model_scores: dict[str, dict] = {m: {"fields": {}, "total_speed_s": 0.0, "weighted_score": 0.0} for m in STUDENT_MODELS}
            remaining_urls = urls_to_fetch[len(source_texts):]
            fetch_idx = 0

            for field_name, field_cfg in ASSIGNMENTS.items():
                task = field_cfg["task"].strip()
                grade_weight = field_cfg["grade"]
                temperature = field_cfg.get("temperature", 0)
                num_ctx = field_cfg.get("num_ctx", 2048)

                pbar.set_postfix_str(f"'{phrase[:30]}' {field_name}")

                best_answer = ""
                best_score = -1
                best_model = ""

                for model in STUDENT_MODELS:
                    # Between calls, try to fetch another source
                    if fetch_idx < len(remaining_urls):
                        extra = await asyncio.to_thread(fetch_source, remaining_urls[fetch_idx])
                        if extra:
                            source_texts.append(extra)
                            context = build_context(mantra, source_texts, search_results, existing_match)
                        fetch_idx += 1

                    # Student answers
                    t = time.time()
                    try:
                        answer, _full = await call_student(model, context, task, temperature, num_ctx)
                    except Exception as exc:
                        answer = f"[error: {exc}]"
                    speed = time.time() - t

                    # Grade the answer (clean answer only, grounding is discarded)
                    score, reason = await grade_answer(phrase, context, task, answer)

                    model_scores[model]["fields"][field_name] = {
                        "answer": answer,
                        "score": score,
                        "reason": reason,
                        "speed_s": round(speed, 2),
                    }
                    model_scores[model]["total_speed_s"] += speed
                    model_scores[model]["weighted_score"] += score * grade_weight / total_grade_weight

                    if score > best_score:
                        best_score = score
                        best_answer = answer
                        best_model = model

                # Store the winning answer
                entry[field_name] = best_answer
                entry.setdefault("_best_models", {})[field_name] = best_model

            entry["_scores"] = model_scores
            results[phrase] = entry

            OUTPUT.write_text(json.dumps(results, indent=2, ensure_ascii=False))

            elapsed = time.time() - t0
            pbar.set_postfix_str(f"'{phrase[:30]}' done {elapsed:.0f}s")
            pbar.update(1)

    print(f"\nDone. {len(results)}/{total} entries written to {OUTPUT}")
    _banner(
        "Results: enrich_mantras",
        [
            f"###   Done:     {len(results)}/{total} entries written",
            f"###   Written:  {OUTPUT}",
        ],
    )
    plot_scores(results)


if __name__ == "__main__":
    asyncio.run(main())
