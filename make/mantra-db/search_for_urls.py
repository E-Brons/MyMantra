#!/usr/bin/env python3
"""
search_for_urls.py — Stage 1: Discover mantra URLs via Search Engine

Searches Web from locales over the world using "mantra" in each local
language.  Collects up to N URLs per locale, deduplicates across all locales,
and writes the result to tmp/mantra_urls.txt (one URL per line).

Why curl instead of urllib:
    Python's urllib has a distinct TLS fingerprint that DDG detects as a bot
    and serves a CAPTCHA page.  curl uses the system native TLS stack
    (identical to a real browser) and bypasses this check.

Usage:
    python3 make/mantra-db/search_for_urls.py
    python3 make/mantra-db/search_for_urls.py --no-cache
    python3 make/mantra-db/search_for_urls.py --output path/to/urls.txt
    python3 make/mantra-db/search_for_urls.py --verbose
"""

import argparse
import hashlib
import os
import re
import subprocess
import sys
import time
import urllib.parse
from pathlib import Path

from tqdm import tqdm

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg, ROOT as _ROOT

_fcfg = cfg()["search_web"]
HERE = os.path.dirname(os.path.abspath(__file__))
TMP_DIR = str(_ROOT / "tmp")
CACHE_DIR = str(_ROOT / _fcfg["cache_dir"])
URLS_FILE = str(root_path("search_web", "output"))
DELAY = float(_fcfg["delay"])
PER_LOCALE = int(_fcfg["results_per_locale"])

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/124.0.0.0 Safari/537.36"
)

# locales: (city, DDG kl code, query in local language) — sourced from settings.yml
LOCALES = [(c["name"], c["locale"], c["mantra"]) for c in _fcfg["cities"]]

# ── curl helpers ──────────────────────────────────────────────────────────────

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


def _cache_path(url):
    h = hashlib.md5(url.encode()).hexdigest()
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"{h}.html")


def _curl_get(url):
    try:
        r = subprocess.run(_CURL_CMD + [url], capture_output=True, timeout=60)
        if r.returncode == 0 and len(r.stdout) > 200:
            return r.stdout.decode("utf-8", errors="replace")
    except Exception as e:
        tqdm.write(f"  curl error: {e}")
    return None


def _curl_post(url, data):
    try:
        r = subprocess.run(
            _CURL_CMD
            + [
                "-X",
                "POST",
                "-H",
                "Content-Type: application/x-www-form-urlencoded",
                "-H",
                f"Referer: {url}",
                "--data-raw",
                data,
                url,
            ],
            capture_output=True,
            timeout=60,
        )
        if r.returncode == 0 and len(r.stdout) > 200:
            return r.stdout.decode("utf-8", errors="replace")
    except Exception as e:
        tqdm.write(f"  curl POST error: {e}")
    return None


def fetch(url, use_cache):
    cp = _cache_path(url)
    if use_cache and os.path.exists(cp):
        with open(cp, encoding="utf-8") as f:
            content = f.read()
        return None if content.startswith("ERROR:") else content
    html = _curl_get(url)
    if html:
        with open(cp, "w", encoding="utf-8") as f:
            f.write(html)
        return html
    with open(cp, "w") as f:
        f.write(f"ERROR: {url}")
    return None


# ── DDG result parsing ────────────────────────────────────────────────────────

_RESULT_RE = re.compile(r'href="//duckduckgo\.com/l/\?uddg=([^"&]+)')
_FORM_RE = re.compile(
    r'<form[^>]*method=["\']post["\'][^>]*>(.*?)</form>',
    re.DOTALL | re.IGNORECASE,
)
_INPUT_RE = re.compile(r'<input[^>]+name="([^"]*)"[^>]*value="([^"]*)"', re.IGNORECASE)


def _parse_urls(html):
    urls = []
    for m in _RESULT_RE.finditer(html):
        u = urllib.parse.unquote(m.group(1))
        if u.startswith("http") and "duckduckgo.com" not in u:
            urls.append(u)
    return list(dict.fromkeys(urls))  # deduplicate, preserve order


def _next_form(html):
    fm = _FORM_RE.search(html)
    if not fm:
        return None
    fields = {m.group(1): m.group(2) for m in _INPUT_RE.finditer(fm.group(1))}
    return fields or None


def search_locale(city, kl, query, use_cache, verbose):
    """Return up to PER_LOCALE unique URLs from DDG for this locale."""
    first_url = "https://html.duckduckgo.com/html/?" + urllib.parse.urlencode(
        {"q": query, "kl": kl}
    )
    html = fetch(first_url, use_cache)
    if not html:
        tqdm.write(f"  {city}: no response from DDG")
        return []

    all_urls, seen = [], set()

    while True:
        for u in _parse_urls(html):
            if u not in seen:
                seen.add(u)
                all_urls.append(u)
                if verbose:
                    tqdm.write(f"    {u}")
        if len(all_urls) >= PER_LOCALE:
            break
        form = _next_form(html)
        if not form:
            break
        time.sleep(DELAY)
        html = _curl_post(
            "https://html.duckduckgo.com/html/",
            urllib.parse.urlencode(form),
        )
        if not html:
            break

    return all_urls[:PER_LOCALE]


# ── Main ──────────────────────────────────────────────────────────────────────


def main():
    p = argparse.ArgumentParser(
        description="Search DuckDuckGo for mantra URLs across locales.",
    )
    p.add_argument("--no-cache", action="store_true", help="Bypass HTML cache")
    p.add_argument(
        "--output",
        default=URLS_FILE,
        help=f"Output file (default: {URLS_FILE})",
    )
    p.add_argument(
        "--verbose", action="store_true", help="Print each URL as discovered"
    )
    args = p.parse_args()
    use_cache = not args.no_cache

    # ── stage banner ──────────────────────────────────────────────────────────
    SEP = "#" * 79
    locale_names = ", ".join(c for c, _, _ in LOCALES)
    print(SEP)
    print("# Stage 1  —  search_for_urls")
    print(SEP)
    print(f"#  engine:             {_fcfg.get('engine', 'DuckDuckGo')}")
    print(f"#  output:             {args.output}")
    print(f"#  locales:            {len(LOCALES)}  ({locale_names})")
    print(f"#  results_per_locale: {PER_LOCALE}")
    print(f"#  delay:              {DELAY} s")
    print(f"#  cache_dir:          {CACHE_DIR}")
    print(f"#  use_cache:          {use_cache}")
    print(f"#  verbose:            {args.verbose}")
    print(SEP)

    all_urls = []
    seen = set()

    with tqdm(LOCALES, unit="locale", ncols=80) as pbar:
        for city, kl, query in pbar:
            pbar.set_description(f"{city}")
            urls = search_locale(city, kl, query, use_cache, args.verbose)
            before = len(seen)
            for u in urls:
                if u not in seen:
                    seen.add(u)
                    all_urls.append(u)
            new = len(seen) - before
            tqdm.write(
                f'  [{city}]  kl={kl}  query="{query}"'
                f"  →  {len(urls)} found, {new} new"
            )
            pbar.set_postfix({"urls": len(all_urls)})
            time.sleep(DELAY)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write("\n".join(all_urls) + "\n")

    print(f"\nDone. {len(all_urls)} unique URLs written to {args.output}")


if __name__ == "__main__":
    main()
