"""
web_cache.py — Shared URL fetching and text extraction with file-per-URL cache.

Cache layout (under cache_dir from settings.yml):
  <md5>.html   — raw HTML (curl fetch)
  <md5>.txt    — extracted plain text (trafilatura)
  _index.csv   — url, hash, timestamp, html_bytes, text_chars

Usage:
    from web_cache import fetch_text, fetch_html, extract_text, page_title

    text = fetch_text(url)           # full pipeline: cache → HTML → text
    html = fetch_html(url)           # HTML only (cache-aware)
    text = extract_text(html)        # trafilatura extraction
    title = page_title(html)         # <title> tag extraction
"""

import hashlib
import os
import re
import subprocess
import time
from pathlib import Path

import trafilatura

_dir = Path(__file__).parent
import sys
sys.path.insert(0, str(_dir))
from settings import cfg, ROOT
from log import get_logger

_log = get_logger("web_cache")

# ── Config ────────────────────────────────────────────────────────────────────

CACHE_DIR = ROOT / cfg()["cache_dir"]
_http_timeout = int(cfg().get("enrich_mantras", {}).get("http_timeout", 30))

_CURL_CMD = [
    "curl", "-L", "-s", "--max-time", str(_http_timeout),
    "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
          "AppleWebKit/537.36 (KHTML, like Gecko) "
          "Chrome/124.0.0.0 Safari/537.36",
    "-H", "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "-H", "Accept-Language: en-US,en;q=0.9",
    "-H", "Accept-Encoding: identity",
    "-H", "Connection: keep-alive",
]

_INDEX_HEADER = "url,hash,timestamp,html_bytes,text_chars\n"


# ── Helpers ───────────────────────────────────────────────────────────────────


def url_hash(url: str) -> str:
    """MD5 hash of URL, used as cache filename prefix."""
    return hashlib.md5(url.encode()).hexdigest()


def _ensure_cache_dir() -> None:
    os.makedirs(CACHE_DIR, exist_ok=True)


def _append_index(url: str, h: str, html_bytes: int, text_chars: int) -> None:
    """Append one row to the CSV index."""
    _ensure_cache_dir()
    index_path = CACHE_DIR / "_index.csv"
    write_header = not index_path.exists()
    with open(index_path, "a", encoding="utf-8") as f:
        if write_header:
            f.write(_INDEX_HEADER)
        ts = time.strftime("%Y-%m-%dT%H:%M:%S")
        f.write(f"{url},{h},{ts},{html_bytes},{text_chars}\n")


# ── HTML fetching ─────────────────────────────────────────────────────────────


def fetch_html(url: str) -> str | None:
    """Fetch URL with curl, caching the raw HTML.

    Returns HTML string or None on failure. Failed fetches are cached
    as "ERROR: <url>" to avoid re-fetching.
    """
    h = url_hash(url)
    cp = CACHE_DIR / f"{h}.html"
    _ensure_cache_dir()

    if cp.exists():
        content = cp.read_text(encoding="utf-8")
        if content.startswith("ERROR:"):
            _log.debug("html cache hit (error): %s", url)
            return None
        _log.debug("html cache hit: %s  (%d bytes)", url, len(content))
        return content

    _log.debug("fetching: %s", url)
    try:
        r = subprocess.run(_CURL_CMD + [url], capture_output=True, timeout=60)
        if r.returncode == 0 and len(r.stdout) > 200:
            html = r.stdout.decode("utf-8", errors="replace")
            cp.write_text(html, encoding="utf-8")
            _log.debug("fetched: %s  (%d bytes)", url, len(html))
            return html
    except Exception as e:
        _log.warning("fetch failed for %s: %s", url, e)

    cp.write_text(f"ERROR: {url}", encoding="utf-8")
    return None


# ── Text extraction ──────────────────────────────────────────────────────────


def extract_text(html: str) -> str:
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
    """Extract the <title> text from HTML."""
    m = re.search(r"<title[^>]*>(.*?)</title>", html, re.IGNORECASE | re.DOTALL)
    if not m:
        return ""
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", m.group(1))).strip()


# ── Combined fetch + extract ─────────────────────────────────────────────────


def fetch_text(url: str) -> str:
    """Fetch URL, extract text via trafilatura, cache both HTML and text.

    Returns the extracted plain text (empty string on failure).
    This is the main entry point — handles the full cache pipeline:
      1. Check <md5>.txt cache → return immediately
      2. Check/fetch <md5>.html → extract text → cache .txt → return
    """
    h = url_hash(url)
    txt_path = CACHE_DIR / f"{h}.txt"
    _ensure_cache_dir()

    # Text cache hit
    if txt_path.exists():
        text = txt_path.read_text(encoding="utf-8")
        if text:
            _log.debug("text cache hit: %s  (%d chars)", url, len(text))
        return text

    html = fetch_html(url)
    if not html:
        txt_path.write_text("", encoding="utf-8")
        _append_index(url, h, 0, 0)
        return ""

    text = extract_text(html)
    txt_path.write_text(text, encoding="utf-8")
    _append_index(url, h, len(html), len(text))
    return text
