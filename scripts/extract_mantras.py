#!/usr/bin/env python3
"""
extract_mantras.py — Extract mantras from a URL list using a local LLM

Reads scripts/mantra_urls.txt (produced by search_ddg.py), fetches each page
with curl, converts HTML to plain text, then asks a local Ollama model (via
litellm) to extract mantra phrases with their language and tags.

Results are appended to scripts/mantra_index.json as a JSON array.
Duplicates are intentionally allowed at this stage — a separate AI agent
handles deduplication and library curation.

Requirements:
    pip install litellm
    ollama pull qwen2.5:32b

Usage:
    python3 scripts/extract_mantras.py
    python3 scripts/extract_mantras.py --limit 5
    python3 scripts/extract_mantras.py --verbose
    python3 scripts/extract_mantras.py --input path/to/urls.txt
    python3 scripts/extract_mantras.py --model ollama/qwen2.5:7b
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import time
from datetime import date
from typing import Dict, List

from litellm import completion

HERE = os.path.dirname(os.path.abspath(__file__))
URLS_FILE = os.path.join(HERE, "mantra_urls.txt")
INDEX_FILE = os.path.join(HERE, "mantra_index.json")
CACHE_DIR = os.path.join(HERE, "crawl_cache")
TODAY = str(date.today())
DELAY = 2.0
MAX_CHARS = 25000  # truncate page text to stay within model context
DEFAULT_MODEL = "ollama/qwen2.5:32b"
OLLAMA_BASE = "http://localhost:11434"

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

# ── HTML fetching (with cache shared with search_ddg.py) ─────────────────────


def _cache_path(url):
    h = hashlib.md5(url.encode()).hexdigest()
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"{h}.html")


def fetch_html(url):
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
        print(f"  fetch error: {e}")
    with open(cp, "w") as f:
        f.write(f"ERROR: {url}")
    return None


# ── HTML → plain text ─────────────────────────────────────────────────────────


def html_to_text(html: str) -> str:
    """Strip HTML tags and boilerplate, return readable plain text."""
    # Remove non-content blocks entirely
    html = re.sub(
        r"<(script|style|nav|footer|header|aside|form|iframe)[^>]*>.*?</\1>",
        " ",
        html,
        flags=re.DOTALL | re.IGNORECASE,
    )
    html = re.sub(r"<!--.*?-->", " ", html, flags=re.DOTALL)
    # Strip remaining tags
    text = re.sub(r"<[^>]+>", " ", html)
    # Decode common HTML entities
    for ent, ch in [
        ("&amp;", "&"),
        ("&lt;", "<"),
        ("&gt;", ">"),
        ("&nbsp;", " "),
        ("&#39;", "'"),
        ("&quot;", '"'),
        ("&rsquo;", "'"),
        ("&lsquo;", "'"),
        ("&ldquo;", '"'),
        ("&rdquo;", '"'),
        ("&ndash;", "–"),
        ("&mdash;", "—"),
    ]:
        text = text.replace(ent, ch)
    # Collapse whitespace
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
You are a proffesional sociology researcher, interested in Meditation traditions.

Given the text of a web page, extract every mantra, sacred phrase, chant, or \
spiritual affirmation you can find. The sentances should be meant for out-reading \
and repeating for learning, concentrating, inspiring, meditation or sacred warship.

For each mantra return:
  phrase    — The exact text of the mantra
              For consistency replace phrases with "Om" with an "Ohm".
  language  — the script or language, e.g. "Sanskrit", "English", "Arabic",
               "Hebrew", "Hindi", "Tibetan", "Chinese", "Japanese", "Korean",
               "Tamil", "Russian", etc.
  tags      — a list chosen from:
               healing, meditation, devotion, peace, courage, gratitude,
               liberation, growth, affirmation, joy, vedic, buddhist, hindu,
               islamic, sikh, jewish, taoist, yoga, popular, ancient,
               universal, shakti, shiva, vishnu, ganesha, abundance, wisdom,
               prayer, chant

Return ONLY a valid JSON — an array of objects with keys:
    "phrase", "language", "tags", "source_url", "source_title", "fetched_at".
If no mantras are found, return an empty array [].
Do not include any explanation, markdown fences, or text outside the JSON.\
"""


def extract_with_llm(
    url: str,
    title: str,
    text: str,
    model: str,
    verbose: bool,
) -> List[Dict]:
    """Call the LLM and return a list of {phrase, language, tags} dicts."""
    truncated = text[:MAX_CHARS]
    if len(text) > MAX_CHARS:
        truncated += "\n... [truncated]"

    user_msg = f"URL: {url}\nTitle: {title}\n\n{truncated}"

    try:
        rsp = completion(
            model=model,
            api_base=OLLAMA_BASE,
            messages=[
                {"role": "system", "content": _SYSTEM_PROMPT},
                {"role": "user", "content": user_msg},
            ],
            max_tokens=2048,
        )
        raw = rsp.choices[0].message.content.strip()
    except Exception as e:
        print(f"  LLM error: {e}")
        return []

    # Strip markdown fences that some models add despite instructions
    raw = re.sub(r"^```(?:json)?\s*", "", raw)
    raw = re.sub(r"\s*```$", "", raw.rstrip())

    try:
        entries = json.loads(raw)
        if isinstance(entries, list):
            return entries
    except json.JSONDecodeError:
        if verbose:
            print(f"  LLM returned non-JSON: {raw[:200]}")
    return []


# ── Index I/O ─────────────────────────────────────────────────────────────────


def load_index() -> List[Dict]:
    if not os.path.exists(INDEX_FILE):
        return []
    with open(INDEX_FILE, encoding="utf-8") as f:
        return json.load(f)


def save_index(entries: List[Dict]) -> None:
    with open(INDEX_FILE, "w", encoding="utf-8") as f:
        json.dump(entries, f, ensure_ascii=False, indent=2)


# ── Main ──────────────────────────────────────────────────────────────────────


def main():
    p = argparse.ArgumentParser(
        description="Extract mantras from a URL list using a local Ollama LLM.",
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
        default=DEFAULT_MODEL,
        help=f"LLM model string (default: {DEFAULT_MODEL})",
    )
    p.add_argument(
        "--verbose",
        action="store_true",
        help="Print each extracted mantra",
    )
    args = p.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: URL file not found: {args.input}")
        print("Run search_ddg.py first to generate the URL list.")
        return

    with open(args.input, encoding="utf-8") as f:
        urls = [line.strip() for line in f if line.strip()]

    if args.limit:
        urls = urls[: args.limit]

    print(f"Processing {len(urls)} URLs")
    print(f"Model:  {args.model}")
    print(f"Output: {args.output}\n")

    index = load_index()
    total_new = 0

    for i, url in enumerate(urls, 1):
        print(f"[{i:3d}/{len(urls)}] {url[:80]}")

        html = fetch_html(url)
        if not html:
            print("           fetch failed, skipping")
            continue

        title = page_title(html)
        text = html_to_text(html)
        entries = extract_with_llm(url, title, text, args.model, args.verbose)

        if not entries:
            print("           0 mantras found")
        else:
            for e in entries:
                phrase = e.get("phrase", "").strip()
                if not phrase:
                    continue
                record = {
                    "phrase": phrase,
                    "language": e.get("language", "Unknown"),
                    "tags": sorted(set(e.get("tags", []))),
                    "source_url": url,
                    "source_title": title,
                    "fetched_at": TODAY,
                }
                index.append(record)
                total_new += 1
                if args.verbose:
                    print(f"  [{record['language']:10s}] {phrase[:70]}")
            print(f"           {len(entries)} mantras extracted")

        save_index(index)
        time.sleep(DELAY)

    print(f"\nDone.")
    print(f"  Mantras extracted this run: {total_new}")
    print(f"  Total entries in index:     {len(index)}")
    print(f"  Saved to: {args.output}")


if __name__ == "__main__":
    main()
