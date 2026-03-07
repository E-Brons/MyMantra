#!/usr/bin/env python3
"""
search_ddg.py — Discover mantra URLs via DuckDuckGo

Searches DuckDuckGo from locales over the world using "mantra" in each local language.
Collects up to 10 URLs per locale, deduplicates across all locales, and
writes the result to scripts/mantra_urls.txt (one URL per line).

Why curl instead of urllib:
    Python's urllib has a distinct TLS fingerprint that DDG detects as a bot
    and serves a CAPTCHA page.  curl uses the system native TLS stack
    (identical to a real browser) and bypasses this check.

Usage:
    python3 scripts/search_ddg.py
    python3 scripts/search_ddg.py --no-cache
    python3 scripts/search_ddg.py --output path/to/urls.txt
    python3 scripts/search_ddg.py --verbose
"""

import argparse
import hashlib
import os
import re
import subprocess
import time
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = os.path.join(HERE, "crawl_cache")
URLS_FILE = os.path.join(HERE, "mantra_urls.txt")
DELAY = 2.0  # seconds between requests (be polite to DDG)
PER_LOCALE = 10  # DDG HTML endpoint returns ~10 results per page

BROWSER_UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/124.0.0.0 Safari/537.36"
)

# locales: (city, DDG kl code, query in local language)
LOCALES = [
    ("New York", "us-en", "mantra"),
    ("Beijing", "cn-zh", "真言"),
    ("London", "uk-en", "mantra"),
    ("Berlin", "de-de", "Mantra"),
    ("Tel Aviv", "il-he", "מנטרה"),
    ("Delhi", "in-hi", "मंत्र"),
    ("Tokyo", "jp-ja", "マントラ"),
    ("Seoul", "kr-ko", "만트라"),
    ("Moscow", "ru-ru", "мантра"),
    ("Dubai", "xa-ar", "مانترا"),
    ("Madrid", "es-es", "mantra"),
    ("Athens", "gr-el", "μάντρα"),
    ("Prague", "cz-cs", "mantra"),
    ("Buenos Aires", "ar-es", "mantra"),
    ("Cape Town", "za-en", "mantra"),
    ("Sydney", "au-en", "mantra"),
    ("Rome", "it-it", "mantra"),
    ("Paris", "fr-fr", "mantra"),
    ("Tokyo", "jp-ja", "マントラ"),
    ("Delhi", "in-hi", "मंत्र"),
    ("Shanghai", "cn-zh", "真言"),
    ("Dhaka", "bd-bn", "মন্ত্র"),
    ("Sao Paulo", "br-pt", "mantra"),
    ("Cairo", "eg-ar", "مانترا"),
    ("Mexico City", "mx-es", "mantra"),
    ("Beijing", "cn-zh", "真言"),
    ("Mumbai", "in-hi", "मंत्र"),
    ("Osaka", "jp-ja", "マントラ"),
    ("Chongqing", "cn-zh", "真言"),
    ("Karachi", "pk-ur", "منتر"),
    ("Kinshasa", "cd-fr", "mantra"),
    ("Lagos", "ng-en", "mantra"),
    ("Istanbul", "tr-tr", "mantra"),
    ("Kolkata", "in-bn", "মন্ত্র"),
    ("Buenos Aires", "ar-es", "mantra"),
    ("Manila", "ph-tl", "mantra"),
    ("Guangzhou", "cn-zh", "真言"),
    ("Lahore", "pk-ur", "منتر"),
    ("Tianjin", "cn-zh", "真言"),
    ("Rio de Janeiro", "br-pt", "mantra"),
    ("Shenzhen", "cn-zh", "真言"),
    ("Bangalore", "in-kn", "ಮಂತ್ರ"),
    ("Moscow", "ru-ru", "мантра"),
    ("Chennai", "in-ta", "மந்திரம்"),
    ("Bogota", "co-es", "mantra"),
    ("Jakarta", "id-id", "mantra"),
    ("Paris", "fr-fr", "mantra"),
    ("Lima", "pe-es", "mantra"),
    ("Bangkok", "th-th", "มนตรา"),
    ("Hyderabad", "in-te", "మంత్రం"),
    ("Seoul", "kr-ko", "만트라"),
    ("Nagoya", "jp-ja", "マントラ"),
    ("London", "uk-en", "mantra"),
    ("Tehran", "ir-fa", "مانترا"),
    ("Chicago", "us-en", "mantra"),
    ("Chengdu", "cn-zh", "真言"),
    ("Nanjing", "cn-zh", "真言"),
    ("Ho Chi Minh City", "vn-vi", "mantra"),
    ("Luanda", "ao-pt", "mantra"),
    ("Wuhan", "cn-zh", "真言"),
    ("Xi-an", "cn-zh", "真言"),
    ("Ahmedabad", "in-gu", "મંત્ર"),
    ("Kuala Lumpur", "my-ms", "mantra"),
    ("New York City", "us-en", "mantra"),
    ("Hangzhou", "cn-zh", "真言"),
    ("Surat", "in-gu", "મંત્ર"),
    ("Suzhou", "cn-zh", "真言"),
    ("Hong Kong", "hk-zh", "真言"),
]

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
        print(f"  curl error: {e}")
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
        print(f"  curl POST error: {e}")
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
        print(f"  {city}: no response from DDG")
        return []

    all_urls, seen = [], set()

    while True:
        for u in _parse_urls(html):
            if u not in seen:
                seen.add(u)
                all_urls.append(u)
                if verbose:
                    print(f"    {u}")
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
        description="Search DuckDuckGo for mantra URLs across 18 locales.",
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

    all_urls = []
    seen = set()

    for city, kl, query in LOCALES:
        print(f'\n[{city}]  kl={kl}  query="{query}"')
        urls = search_locale(city, kl, query, use_cache, args.verbose)
        before = len(seen)
        for u in urls:
            if u not in seen:
                seen.add(u)
                all_urls.append(u)
        new = len(seen) - before
        print(f"  {len(urls)} found, {new} new  (unique total: {len(all_urls)})")
        time.sleep(DELAY)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write("\n".join(all_urls) + "\n")

    print(f"\nDone. {len(all_urls)} unique URLs written to {args.output}")


if __name__ == "__main__":
    main()
