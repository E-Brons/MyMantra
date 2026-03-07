# Mantra Discovery Pipeline

Three-stage pipeline for discovering mantras on the internet and improving
the myMantra library.

---

## Stage 1 — `search_ddg.py`

Searches DuckDuckGo from 18 locales using "mantra" in each local language.
Collects ~10 URLs per locale, deduplicates across all locales, and writes
a flat URL list to `mantra_urls.txt`.

```bash
python3 scripts/search_ddg.py               # search all 18 locales
python3 scripts/search_ddg.py --no-cache    # re-fetch (bypass cache)
python3 scripts/search_ddg.py --verbose     # print each URL as found
python3 scripts/search_ddg.py --output path/to/urls.txt
```

Output: `scripts/mantra_urls.txt` — one URL per line, ~100–180 unique URLs.

---

## Stage 2 — `extract_mantras.py`

Reads `mantra_urls.txt`, fetches each page with curl, and asks a local
Ollama LLM to extract every mantra phrase with its language and tags.
Results are appended to `mantra_index.json`. Duplicates are intentional
at this stage — curation happens in Stage 3.

**Requires:**
```bash
pip install litellm
ollama pull qwen2.5:32b
```

```bash
python3 scripts/extract_mantras.py                        # process all URLs
python3 scripts/extract_mantras.py --limit 5 --verbose   # quick test
python3 scripts/extract_mantras.py --model ollama/gemma3:27b
python3 scripts/extract_mantras.py --input path/to/urls.txt
```

Output: `scripts/mantra_index.json` — flat JSON array, one record per
extracted mantra:

```json
{
  "phrase":       "Om Namah Shivaya",
  "language":     "Sanskrit",
  "tags":         ["devotion", "hindu", "popular", "shiva"],
  "source_url":   "https://example.com/hindu-mantras",
  "source_title": "Top 10 Hindu Mantras",
  "fetched_at":   "2026-03-07"
}
```

---

## Stage 3 — AI Agent (manual, no script)

An AI conversation (Claude or similar) that reads `mantra_index.json`
alongside the existing library files in `assets/data/mantras/` and
improves the library one entry at a time:

- Add mantras that are missing from the library
- Enrich existing entries with better tags, descriptions, or sources
- Resolve duplicates across different scripts/transliterations
- Flag low-quality or misidentified entries for review

There is no automation here by design — each change is reviewed before
it goes into the Flutter app.

---

## Shared infrastructure

| Path | Purpose |
|---|---|
| `scripts/mantra_urls.txt` | URL list produced by Stage 1, consumed by Stage 2 |
| `scripts/mantra_index.json` | Raw discovery index produced by Stage 2 |
| `scripts/crawl_cache/` | HTML cache shared by both scripts (avoids re-fetching) |
| `scripts/mantra_sources/` | Legacy text files from the original fetch script |

The cache uses `md5(url)` as filename, so both scripts reuse each other's
cached pages automatically.

---

## Typical workflow

```bash
# 1. Discover URLs (takes ~3 min, mostly polite delays between requests)
python3 scripts/search_ddg.py --verbose

# 2. Extract mantras (takes ~30-60 min depending on URL count and model speed)
python3 scripts/extract_mantras.py --verbose

# 3. Inspect the index
python3 -c "
import json
d = json.load(open('scripts/mantra_index.json'))
print(len(d), 'total entries')
langs = {}
for e in d:
    langs[e['language']] = langs.get(e['language'], 0) + 1
for lang, n in sorted(langs.items(), key=lambda x: -x[1]):
    print(f'  {n:4d}  {lang}')
"

# 4. Hand the index to an AI agent for library curation
```
