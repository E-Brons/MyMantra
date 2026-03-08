"""
Deduplicates mantra_index.json by phrase (case-insensitive + alias normalization).

Alias rules are loaded from phrase_aliases.json:
  - prefix_rules: [["Ohm ", "Om "], ...]  — applied to phrase starts
  - exact_rules:  {"Ohm": "Om", ...}      — full-phrase substitutions

Output format (mantra_index_deduped.json):
{
  "Om Shanti": {
    "phrase": "Om Shanti",
    "language": ["Sanskrit"],
    "tags": ["hindu", "peace", ...],
    "sources": [
      {
        "url": "...",
        "title": "...",
        "fetched_at": "...",
        "original_phrase": "Ohm Shanti"   # only present when different from phrase
      },
      ...
    ]
  },
  ...
}
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from settings import root_path, cfg

_ROOT   = Path(__file__).parent.parent.parent  # make/mantra-db -> make -> project root
INPUT   = root_path("dedup_mantras", "input")
OUTPUT  = root_path("dedup_mantras", "output")
ALIASES = Path(__file__).parent / cfg()["dedup_mantras"]["aliases"]

_SEP = "#" * 79


def _banner(title: str, body_lines: list) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)


def load_aliases() -> tuple[list[tuple[str, str]], dict[str, str]]:
    if not ALIASES.exists():
        return [], {}
    data = json.loads(ALIASES.read_text())
    prefix_rules: list[tuple[str, str]] = [tuple(r) for r in data.get("prefix_rules", [])]
    exact_rules: dict[str, str] = data.get("exact_rules", {})
    return prefix_rules, exact_rules


def canonicalize(phrase: str,
                 prefix_rules: list[tuple[str, str]],
                 exact_rules: dict[str, str]) -> str:
    """Return the canonical form of a phrase per alias rules."""
    if phrase in exact_rules:
        return exact_rules[phrase]
    for prefix, replacement in prefix_rules:
        if phrase.startswith(prefix):
            return replacement + phrase[len(prefix):]
    return phrase


def merge_entries(entries: list[dict]) -> dict:
    """Merge all entries for one canonical phrase into a single record."""
    phrase = entries[0]["_canonical"]

    languages = list(dict.fromkeys(
        e["language"].strip() for e in entries if e.get("language")
    ))

    tags = list(dict.fromkeys(
        tag for e in entries for tag in e.get("tags", [])
    ))

    # Deduplicate sources by URL; record original phrase when it differs
    seen_urls: set[str] = set()
    sources: list[dict] = []
    for e in entries:
        url = e.get("source_url", "").strip()
        if url and url not in seen_urls:
            seen_urls.add(url)
            source: dict = {
                "url":        url,
                "title":      e.get("source_title", "").strip(),
                "fetched_at": e.get("fetched_at", ""),
            }
            if e["_original_phrase"] != phrase:
                source["original_phrase"] = e["_original_phrase"]
            sources.append(source)

    return {
        "phrase":   phrase,
        "language": languages,
        "tags":     tags,
        "sources":  sources,
    }


def main() -> None:
    raw: list[dict] = json.loads(INPUT.read_text())
    prefix_rules, exact_rules = load_aliases()

    _banner(
        "Stage 3: dedup_mantras",
        [
            f"###   Input:    {INPUT}  ({len(raw)} entries)",
            f"###   Output:   {OUTPUT}",
            f"###   Aliases:  {ALIASES}",
        ],
    )
    print()

    # Group entries by canonical phrase (case-insensitive)
    groups: dict[str, list[dict]] = defaultdict(list)
    canonical_for_key: dict[str, str] = {}

    for entry in raw:
        original = entry["phrase"].strip()
        canonical = canonicalize(original, prefix_rules, exact_rules)
        key = canonical.lower()

        # First occurrence of this key sets the canonical casing
        if key not in canonical_for_key:
            canonical_for_key[key] = canonical

        groups[key].append({
            **entry,
            "_original_phrase": original,
            "_canonical":       canonical_for_key[key],
        })

    deduped: dict[str, dict] = {}
    for key, entries in groups.items():
        merged = merge_entries(entries)
        deduped[merged["phrase"]] = merged

    OUTPUT.write_text(json.dumps(deduped, indent=2, ensure_ascii=False))

    total_in  = len(raw)
    total_out = len(deduped)
    removed   = total_in - total_out
    _banner(
        "Results: dedup_mantras",
        [
            f"###   Input:    {total_in} entries",
            f"###   Output:   {total_out} unique phrases  ({removed} duplicates removed)",
            f"###   Written:  {OUTPUT}",
        ],
    )


if __name__ == "__main__":
    main()
