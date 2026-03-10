#!/usr/bin/env python3
"""
extract_mantras.py — Extract mantras from a URL list using local LLMs

Reads tmp/mantra_urls.txt, fetches each page with curl, converts HTML to
plain text, then asks one or more local Ollama models (via litellm) to
extract mantra phrases with language and tags.

Models run sequentially (one at a time) over the same URLs so their
performance can be compared fairly.  Use --limit to benchmark on a small
sample before committing to a full run with the winning model.

Results are merged into tmp/mantra_index.json.
Duplicates are intentional — translate_n_dedup handles them.

Requirements:
    pip install litellm tqdm trafilatura
    ollama pull <model>

Usage:
    python3 extract_mantras.py
    python3 extract_mantras.py --limit 5 --verbose
    python3 extract_mantras.py --model ollama/qwen2.5:7b
    python3 extract_mantras.py --model ollama/qwen2.5:7b,ollama/gemma3:27b
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path
from typing import Dict, List, Optional

import litellm
from tqdm import tqdm
import trafilatura

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ollama, ollama_base, ROOT as _ROOT, llm_kwargs, parse_fenced_json

# ── Config ────────────────────────────────────────────────────────────────────

_ecfg = cfg()["extract_mantra"]
TMP_DIR = str(_ROOT / "tmp")
URLS_FILE = str(root_path("extract_mantra", "input"))
INDEX_FILE = str(root_path("extract_mantra", "output"))
CACHE_DIR = str(_ROOT / _ecfg["cache_dir"])
TODAY = str(date.today())
DELAY = float(_ecfg["delay"])
MAX_CHARS = int(_ecfg["max_page_chars"])
CHUNK_CHARS = int(_ecfg.get("chunk_chars", 10000))
CHUNK_OVERLAP = int(_ecfg.get("chunk_overlap", 500))
MAX_RETRIES = int(_ecfg.get("max_html_retries", "1"))
DEFAULT_MODELS = [ollama(m) for m in _ecfg["llm_engines"]]
OLLAMA_BASE = ollama_base()
LLM_KWARGS = llm_kwargs("extract_mantra")


def call_llm(model: str, messages: list) -> tuple[str, float]:
    """Single completion call.  Returns (content, inference_seconds)."""
    t0 = time.perf_counter()
    response = litellm.completion(
        model=model,
        api_base=OLLAMA_BASE,
        messages=messages,
        max_tokens=2048,
        **LLM_KWARGS,
    )
    elapsed = time.perf_counter() - t0
    return (response.choices[0].message.content or "").strip(), elapsed


# ── HTML helpers ──────────────────────────────────────────────────────────────

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/124.0.0.0 Safari/537.36"
)

_CURL_CMD = [
    "curl",
    "-L",
    "-s",
    "--max-time",
    "30",
    "-A",
    BROWSER_UA,
    "-H",
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "-H",
    "Accept-Language: en-US,en;q=0.9",
    "-H",
    "Accept-Encoding: identity",
    "-H",
    "Connection: keep-alive",
]


def _cache_path(url: str) -> str:
    h = hashlib.md5(url.encode()).hexdigest()
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"{h}.html")


def fetch_html(url: str) -> Optional[str]:
    """Fetch URL using curl (cache-first). Returns HTML string or None."""
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
    except Exception as e:
        tqdm.write(f"  fetch error: {e}")
    with open(cp, "w") as f:
        f.write(f"ERROR: {url}")
    return None


def html_to_text(html: str) -> str:
    """Extract main body text from HTML using trafilatura.

    Falls back to basic tag-stripping if trafilatura finds nothing
    (e.g. single-page apps that render no static text).
    """
    extracted = trafilatura.extract(
        html,
        include_comments=False,
        include_tables=True,
        no_fallback=False,
    )
    if extracted and extracted.strip():
        return extracted.strip()

    # Fallback: strip tags manually
    text = re.sub(
        r"<(script|style|nav|footer|header|aside|form|iframe)[^>]*>.*?</\1>",
        " ", html, flags=re.DOTALL | re.IGNORECASE,
    )
    text = re.sub(r"<!--.*?-->", " ", text, flags=re.DOTALL)
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"[^\S\n]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def page_title(html: str) -> str:
    m = re.search(r"<title[^>]*>(.*?)</title>", html, re.IGNORECASE | re.DOTALL)
    if not m:
        return ""
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", m.group(1))).strip()


# ── LLM extraction ────────────────────────────────────────────────────────────

_SYSTEM_PROMPT = """\
<role>
You are a professional sociology researcher specializing in meditation and \
spiritual traditions worldwide.
</role>

<task>
Given the text of a web page, extract every mantra, sacred phrase, chant, or \
spiritual affirmation meant for recitation, repetition, meditation, or \
devotional practice.
</task>

<rules>
- Extract ONLY actual mantra phrases intended for repetition or chanting.
- Do NOT extract article titles, section headings, questions, descriptions, \
or commentary about mantras.
- If a phrase is a question (e.g. "What is a Mantra?"), a description \
(e.g. "Mantras are sacred sounds"), or an instruction (e.g. "Repeat 108 \
times"), it is NOT a mantra — skip it.
- Preserve the original phrasing of each mantra exactly as written on the page.
- Assign 2–5 tags per mantra chosen ONLY from the allowed list below.
- If no mantras are found on the page, return {"mantras": []}.
</rules>

<allowed_tags>
healing, meditation, devotion, peace, courage, gratitude, liberation, growth, \
affirmation, joy, vedic, buddhist, hindu, islamic, sikh, jewish, taoist, yoga, \
popular, ancient, universal, shakti, shiva, vishnu, ganesha, abundance, wisdom, \
prayer, chant
</allowed_tags>

<output_format>
You may include commentary or reasoning before the JSON.
You MUST wrap your final answer in a ```json``` fenced code block.
Use compact single-line JSON (no pretty-printing). Schema:
{"mantras":[{"phrase":"<exact mantra text>","language":"<Sanskrit | English | Arabic | Hebrew | Hindi | Tibetan | Chinese | Japanese | Korean | Tamil | Russian | ...>","tags":["tag1","tag2"]}]}
</output_format>\
"""

_FEW_SHOT_USER = """\
URL: https://example.com/buddhist-mantras
Title: Popular Buddhist Mantras for Daily Practice

Buddhist mantras are sacred sounds used in meditation. What is a mantra? \
A mantra is a word or phrase repeated during meditation to focus the mind. \
Here are some of the most popular Buddhist mantras:

Om Mani Padme Hum — The most famous Buddhist mantra, the mantra of compassion \
associated with Avalokiteshvara.

Gate Gate Paragate Parasamgate Bodhi Svaha — Known as the Heart Sutra mantra, \
this chant points toward the perfection of wisdom.

Tips for practicing mantras: Find a quiet space, sit comfortably, and repeat \
the mantra 108 times using a mala."""

_FEW_SHOT_ASSISTANT = """\
The page discusses Buddhist mantras. I can identify two actual mantra phrases \
meant for chanting. "What is a mantra?" is a question, not a mantra. \
"Tips for practicing" is an instruction, not a mantra. Skipping those.

```json
{"mantras":[{"phrase":"Om Mani Padme Hum","language":"Sanskrit","tags":["buddhist","meditation","devotion","popular"]},{"phrase":"Gate Gate Paragate Parasamgate Bodhi Svaha","language":"Sanskrit","tags":["buddhist","wisdom","ancient","liberation"]}]}
```\
"""


def _chunk_text(text: str) -> List[str]:
    """Split text into overlapping chunks that fit the LLM context window.

    Tries to break at paragraph boundaries (\n\n) to avoid splitting mantras.
    """
    text = text[:MAX_CHARS]
    if len(text) <= CHUNK_CHARS:
        return [text]

    chunks = []
    start = 0
    while start < len(text):
        end = min(start + CHUNK_CHARS, len(text))

        # Last chunk — take everything remaining
        if end == len(text):
            chunks.append(text[start:])
            break

        # Try to break at a paragraph boundary within the last 20% of the chunk
        search_from = start + CHUNK_CHARS * 4 // 5
        para_break = text.rfind("\n\n", search_from, end)
        if para_break > search_from:
            end = para_break

        chunks.append(text[start:end])

        # Advance with overlap; guarantee forward progress
        next_start = end - CHUNK_OVERLAP
        if next_start <= start:
            next_start = end
        start = next_start

    return chunks


def _call_llm_for_chunk(
    url: str, title: str, chunk: str, chunk_idx: int, total_chunks: int,
    model: str,
) -> tuple[List[Dict], float]:
    """Call the LLM on a single chunk and parse the result."""
    header = f"URL: {url}\nTitle: {title}"
    if total_chunks > 1:
        header += f"\n[Chunk {chunk_idx}/{total_chunks}]"
    user_msg = f"{header}\n\n{chunk}"

    try:
        raw, elapsed = call_llm(
            model=model,
            messages=[
                {"role": "system", "content": _SYSTEM_PROMPT},
                {"role": "user", "content": _FEW_SHOT_USER},
                {"role": "assistant", "content": _FEW_SHOT_ASSISTANT},
                {"role": "user", "content": user_msg},
            ],
        )
    except Exception as e:
        tqdm.write(f"  LLM error: {e}")
        return [], 0.0

    try:
        data = parse_fenced_json(raw)
        if isinstance(data, dict) and "mantras" in data:
            entries = data["mantras"]
        elif isinstance(data, list):
            entries = data
        else:
            entries = []
        return (entries if isinstance(entries, list) else []), elapsed
    except (json.JSONDecodeError, ValueError):
        return [], elapsed


def extract_with_llm(
    url: str,
    title: str,
    text: str,
    model: str,
    verbose: bool,
) -> tuple[List[Dict], float]:
    """Extract mantras from page text, chunking if needed.

    Returns (list of {phrase, language, tags} dicts, total_inference_seconds).
    """
    chunks = _chunk_text(text)
    all_entries: List[Dict] = []
    total_elapsed = 0.0
    seen_phrases: set = set()

    if len(chunks) > 1 and verbose:
        tqdm.write(f"    page split into {len(chunks)} chunks ({len(text)} chars)")

    for i, chunk in enumerate(chunks, 1):
        if verbose:
            tqdm.write(f"    chunk {i}/{len(chunks)}  chars={len(chunk)}  sending to LLM...")
        entries, elapsed = _call_llm_for_chunk(
            url, title, chunk, i, len(chunks), model,
        )
        if verbose:
            tqdm.write(f"    chunk {i}/{len(chunks)}  done in {elapsed:.1f}s  found={len(entries)}")
        total_elapsed += elapsed
        for e in entries:
            if not isinstance(e, dict):
                continue
            phrase = e.get("phrase", "").strip().lower()
            if phrase and phrase not in seen_phrases:
                seen_phrases.add(phrase)
                all_entries.append(e)
                if verbose:
                    tqdm.write(f"    [{e.get('language','?'):10s}] {e.get('phrase','')[:70]}")

    if len(chunks) > 1 and verbose:
        tqdm.write(f"    ({len(chunks)} chunks → {len(all_entries)} mantras)")

    return all_entries, total_elapsed


# ── Per-model stats ───────────────────────────────────────────────────────────


@dataclass
class ModelStats:
    model: str
    urls_attempted: int = 0
    urls_failed: int = 0
    urls_no_mantras: int = 0
    mantras_found: int = 0
    total_llm_secs: float = 0.0
    url_times: List[float] = field(default_factory=list)
    records: List[Dict] = field(default_factory=list)

    @property
    def avg_secs(self) -> float:
        return (self.total_llm_secs / len(self.url_times)) if self.url_times else 0.0

    @property
    def min_secs(self) -> float:
        return min(self.url_times) if self.url_times else 0.0

    @property
    def max_secs(self) -> float:
        return max(self.url_times) if self.url_times else 0.0


# ── Sequential model runner ──────────────────────────────────────────────────


def run_model(
    model: str,
    urls: List[str],
    html_cache: Dict[str, Optional[str]],
    title_cache: Dict[str, str],
    text_cache: Dict[str, str],
    verbose: bool,
    output_path: str,
    processed_urls: set,
    all_records: List[Dict],
) -> ModelStats:
    """Run a single model over all URLs sequentially, writing after each URL."""
    stats = ModelStats(model=model)
    desc = model.split("/")[-1] if "/" in model else model
    with tqdm(total=len(urls), desc=f"  {desc[:38]}", unit="url") as pbar:
        for url in urls:
            if url in processed_urls:
                pbar.update(1)
                continue

            html = html_cache.get(url)
            if not html:
                stats.urls_attempted += 1
                stats.urls_failed += 1
                processed_urls.add(url)
                save_index(processed_urls, all_records, output_path)
                pbar.set_postfix(mantras=stats.mantras_found, t="skip")
                pbar.update(1)
                continue

            stats.urls_attempted += 1
            entries, elapsed = extract_with_llm(
                url, title_cache[url], text_cache[url], model, verbose
            )

            stats.total_llm_secs += elapsed
            stats.url_times.append(elapsed)

            if not entries:
                stats.urls_no_mantras += 1
            else:
                for e in entries:
                    if not isinstance(e, dict):
                        continue
                    phrase = e.get("phrase", "").strip()
                    if not phrase:
                        continue
                    record = {
                        "phrase": phrase,
                        "language": e.get("language", "Unknown"),
                        "tags": sorted(set(e.get("tags", []))),
                        "source_url": url,
                        "source_title": title_cache[url],
                        "fetched_at": TODAY,
                        "extracted_by": model,
                    }
                    stats.records.append(record)
                    all_records.append(record)
                    stats.mantras_found += 1

            processed_urls.add(url)
            save_index(processed_urls, all_records, output_path)

            pbar.set_postfix(mantras=stats.mantras_found, t=f"{elapsed:.1f}s")
            pbar.update(1)
            time.sleep(DELAY)

    return stats


# ── Index I/O ─────────────────────────────────────────────────────────────────


def load_index(path: str) -> tuple[set, List[Dict]]:
    """Load existing output. Returns (processed_urls, mantras)."""
    if not os.path.exists(path):
        return set(), []
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    # Support both old (flat list) and new (envelope) formats
    if isinstance(data, list):
        urls = {r.get("source_url", "") for r in data if r.get("source_url")}
        return urls, data
    return set(data.get("processed_urls", [])), data.get("mantras", [])


def save_index(processed_urls: set, entries: List[Dict], path: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(
            {"processed_urls": sorted(processed_urls), "mantras": entries},
            f, ensure_ascii=False, indent=2,
        )


# ── Print helpers ─────────────────────────────────────────────────────────────

_SEP = "#" * 79


def _stats_table(
    all_stats: List[ModelStats],
    wall_elapsed: float,
    new_records: int,
    index_total: int,
) -> List[str]:
    """Build a compact ASCII table of per-model stats for the end banner."""
    headers = ["Model", "Atmp", "Fail", "Empty", "Mantras", "LLM total", "Avg/URL", "Min–Max"]

    def row_vals(s: ModelStats) -> List[str]:
        min_max = f"{s.min_secs:.1f}–{s.max_secs:.1f} s" if s.url_times else "—"
        return [
            s.model,
            str(s.urls_attempted),
            str(s.urls_failed),
            str(s.urls_no_mantras),
            str(s.mantras_found),
            f"{s.total_llm_secs:.1f} s",
            f"{s.avg_secs:.2f} s",
            min_max,
        ]

    total_atmp    = sum(s.urls_attempted   for s in all_stats)
    total_fail    = sum(s.urls_failed      for s in all_stats)
    total_empty   = sum(s.urls_no_mantras  for s in all_stats)
    total_mantras = sum(s.mantras_found    for s in all_stats)
    total_llm     = sum(s.total_llm_secs   for s in all_stats)
    avg_llm       = (total_llm / total_atmp) if total_atmp else 0.0
    total_row = ["TOTAL", str(total_atmp), str(total_fail), str(total_empty),
                 str(total_mantras), f"{total_llm:.1f} s", f"{avg_llm:.2f} s", ""]

    data_rows = [row_vals(s) for s in all_stats]
    all_rows = [headers] + data_rows + [total_row]
    widths = [max(len(r[i]) for r in all_rows) for i in range(len(headers))]

    def fmt(row: List[str]) -> str:
        parts = [row[0].ljust(widths[0])] + [row[i].rjust(widths[i]) for i in range(1, len(headers))]
        return "###  " + "  ".join(parts)

    def divider() -> str:
        return "###  " + "  ".join("─" * w for w in widths)

    lines = [fmt(headers), divider()]
    for row in data_rows:
        lines.append(fmt(row))
    lines += [
        divider(),
        fmt(total_row),
        "###",
        f"###  Wall-clock: {wall_elapsed:.1f} s  |  New records: {new_records}"
        f"  |  Total in index: {index_total}",
    ]
    return lines


def _banner(title: str, body_lines: List[str]) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)


# ── Main ──────────────────────────────────────────────────────────────────────


def main():
    p = argparse.ArgumentParser(
        description="Extract mantras from a URL list using local Ollama LLMs.",
    )
    p.add_argument(
        "--input",
        default=URLS_FILE,
        help=f"URL list file (default: {URLS_FILE})",
    )
    p.add_argument(
        "--output",
        default=INDEX_FILE,
        help=f"Output index file (default: {INDEX_FILE})",
    )
    p.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Process first N URLs only (0 = all)",
    )
    p.add_argument(
        "--model",
        default=None,
        help="Comma-separated model(s) to use (default: llm_engines from settings.yml)",
    )
    p.add_argument(
        "--verbose",
        action="store_true",
        help="Print each extracted mantra phrase",
    )
    args = p.parse_args()

    models = (
        [m.strip() for m in args.model.split(",") if m.strip()]
        if args.model
        else DEFAULT_MODELS
    )

    if not os.path.exists(args.input):
        print(f"Error: URL file not found: {args.input}")
        print("Run search_ddg.py first to generate the URL list.")
        return

    with open(args.input, encoding="utf-8") as f:
        urls = [line.strip() for line in f if line.strip()]

    if args.limit:
        urls = urls[: args.limit]

    # ── Stage banner ──────────────────────────────────────────────────────────
    _banner(
        "Stage 2: extract_mantras",
        [
            f"###   Input:             {args.input}  ({len(urls)} URLs)",
            f"###   Output:            {args.output}",
            f"###   Models ({len(models)}):       {', '.join(models)}",
            f"###   max_page_chars:    {MAX_CHARS}",
            f"###   chunk_chars:       {CHUNK_CHARS}  (overlap {CHUNK_OVERLAP})",
            f"###   delay:             {DELAY} s",
            f"###   limit:             {args.limit or 'all'}",
            f"###   verbose:           {args.verbose}",
        ],
    )
    print()

    # ── Step 1: Pre-fetch all HTML ───────────────────────────────────────────
    print("Step 1/3 — Fetching HTML")
    html_cache: Dict[str, Optional[str]] = {}
    title_cache: Dict[str, str] = {}
    text_cache: Dict[str, str] = {}
    fetch_failures = 0

    with tqdm(total=len(urls), desc="  fetching", unit="url") as pbar:
        for url in urls:
            title_cache[url] = ""
            text_cache[url] = ""
            for r in range(MAX_RETRIES):
                html = fetch_html(url)
                html_cache[url] = html
                if html:
                    title_cache[url] = page_title(html)
                    text_cache[url] = html_to_text(html)
                    break
                else:
                    fetch_failures += 1
            pbar.update(1)

    print(f"  fetched: {len(title_cache)}/{len(urls)}   failed: {fetch_failures}\n")

    # ── Step 2: Sequential extraction (one model at a time) ────────────────
    print(f"Step 2/3 — Extracting Mantras ({len(models)} model(s), sequential)")
    wall_t0 = time.perf_counter()

    # Resume from existing output
    processed_urls, all_records = load_index(args.output)
    remaining = len([u for u in urls if u not in processed_urls])
    if processed_urls:
        print(f"  Resuming: {len(processed_urls)} URLs already done, {remaining} remaining.")

    def _set_keep_alive(model: str, seconds: int) -> None:
        """Set Ollama keep_alive for a model.  -1 = forever, 0 = unload now."""
        try:
            import requests
            requests.post(
                f"{OLLAMA_BASE}/api/generate",
                json={"model": model.removeprefix("ollama/"), "keep_alive": seconds},
                timeout=10,
            )
        except Exception:
            pass

    all_stats: List[ModelStats] = []
    for model in models:
        print(f"\n  Running: {model}")
        _set_keep_alive(model, -1)  # pin model in memory for entire run
        try:
            stats = run_model(
                model, urls, html_cache, title_cache, text_cache, args.verbose,
                args.output, processed_urls, all_records,
            )
        except Exception as exc:
            print(f"  Model {model} failed: {exc}")
            stats = ModelStats(model=model)
        all_stats.append(stats)
        _set_keep_alive(model, 0)  # unload before loading the next model

    wall_elapsed = time.perf_counter() - wall_t0
    print()

    # ── Step 3: Summary ────────────────────────────────────────────────────
    print("Step 3/3 — Summary")
    all_new_records = [r for s in all_stats for r in s.records]

    if all_records:
        print(f"  {len(all_records)} total records in: {args.output}")
        print(f"  {len(processed_urls)} URLs processed\n")
    else:
        print("  no mantras extracted — output file NOT written (gate: stage failed)\n")
        if os.path.exists(args.output):
            os.remove(args.output)

    # ── End summary (table) ───────────────────────────────────────────────────
    print()
    _banner("Results: extract_mantras", _stats_table(
        all_stats, wall_elapsed, len(all_new_records), len(all_records),
    ))


if __name__ == "__main__":
    main()
