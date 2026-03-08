#!/usr/bin/env python3
"""
merge_mantras.py — Merge enriched mantras into assets/data/mantras.json

Reads tmp/enriched_mantras.json (produced by enrich_mantras.py) and merges
every valid entry into assets/data/mantras.json — a single versioned library
file that the Flutter app can load directly.

Merge behaviour:
  - Entries are matched by transliteration (case-insensitive) or phrase key.
  - New entries: quality-gated (missing fields, short abstract, too few tags,
    unknown tradition are all rejected with a warning).
  - Existing entries: fill-blanks for scalars; union for lists/dicts.
    Abstract is updated only when the existing one is a stub (shorter than
    min_abstract_chars) AND the incoming one is longer.
  - Entries with _error present are always skipped.
  - Patch version is incremented on every run (--bump-minor increments minor).
  - Pipeline metadata is recorded in the output envelope.

Output envelope:
  {
    "version":  "0.1.1",
    "released": "2026-03-08",
    "notes":    "Pipeline run: 18 added, 12 updated",
    "count":    166,
    "pipeline": { ... },
    "mantras":  [ ... ]
  }

Usage:
    python3 make/mantra-db/merge_mantras.py
    python3 make/mantra-db/merge_mantras.py --dry-run
    python3 make/mantra-db/merge_mantras.py --notes "Hand-curated batch 2"
    python3 make/mantra-db/merge_mantras.py --bump-minor
"""

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from settings import cfg, root_path

_ROOT = Path(__file__).parent.parent.parent  # make/mantra-db -> make -> project root
ENRICHED = root_path("merge_mantras", "input")
OUTPUT = root_path("merge_mantras", "output")

_SEP = "#" * 79


def _banner(title: str, body_lines: list) -> None:
    print(_SEP)
    print(f"### {title}")
    print(_SEP)
    for line in body_lines:
        print(line)
    print(_SEP)

REQUIRED = {"name", "english", "transliteration", "abstract", "tradition"}

TRADITION_PREFIX = {
    "hindu": "hindu",
    "buddhist": "buddhist",
    "christian": "christian",
    "islamic": "islamic",
    "muslim": "islamic",
    "jewish": "jewish",
    "sikh": "sikh",
    "jain": "jain",
    "taoist": "taoist",
    "universal": "universal",
    "western": "affirmation",
    "affirmation": "affirmation",
    "growth": "growth",
}

EMPTY_ENTRY = {
    "id": "",
    "name": "",
    "english": "",
    "original": "",
    "transliteration": "",
    "abstract": "",
    "tags": [],
    "tradition": "",
    "category": "",
    "difficulty": "beginner",
    "targetRepetitions": 108,
    "supportedLanguages": ["en"],
    "translations": {"en": "", "zh": "", "es": ""},
    "sources": [],
    "audioUrl": None,
}


# ─────────────────────────────────────────────────────────────────────────────
# Version helpers
# ─────────────────────────────────────────────────────────────────────────────


def bump_version(version: str, minor: bool = False) -> str:
    """Increment patch (Z) or minor (Y) of an X.Y.Z version string."""
    parts = version.split(".")
    if len(parts) != 3:
        return version
    x, y, z = int(parts[0]), int(parts[1]), int(parts[2])
    if minor:
        return f"{x}.{y + 1}.0"
    return f"{x}.{y}.{z + 1}"


# ─────────────────────────────────────────────────────────────────────────────
# Library I/O
# ─────────────────────────────────────────────────────────────────────────────


def load_existing_library() -> tuple[dict, list[dict]]:
    """Load the versioned envelope and mantra array from OUTPUT.

    Returns (envelope_meta, mantras_list).  envelope_meta contains all fields
    except 'mantras' so callers can reconstruct it.
    """
    if not OUTPUT.exists():
        return {
            "version": "0.1.0",
            "released": date.today().isoformat(),
            "notes": "",
            "count": 0,
        }, []

    raw = json.loads(OUTPUT.read_text())

    if isinstance(raw, list):
        # Legacy: plain array (pre-envelope format)
        return {
            "version": "0.1.0",
            "released": date.today().isoformat(),
            "notes": "",
            "count": len(raw),
        }, raw

    mantras = raw.get("mantras", [])
    meta = {k: v for k, v in raw.items() if k != "mantras"}
    return meta, mantras


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────


def normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip().lower()


def find_existing(entry: dict, library: list[dict]) -> dict | None:
    key = normalize(entry.get("transliteration", "") or entry.get("name", ""))
    for lib_entry in library:
        for field in ("transliteration", "name", "original"):
            if normalize(lib_entry.get(field, "")) == key:
                return lib_entry
    return None


def make_id(entry: dict, existing_ids: set[str]) -> str:
    tradition = entry.get("tradition", "other").lower()
    prefix = TRADITION_PREFIX.get(tradition, tradition[:8])
    n = 1
    while True:
        candidate = f"{prefix}_{n:03d}"
        if candidate not in existing_ids:
            return candidate
        n += 1


def merge_fields(base: dict, incoming: dict, min_abstract_chars: int) -> dict:
    """Return base updated with non-empty fields from incoming.

    For scalars: fill-blanks rule (do not overwrite non-empty existing values),
    with one exception: abstract is updated when the existing value is a stub
    (shorter than min_abstract_chars) AND the incoming value is longer.

    For lists: union, preserving order.
    For dicts: per-key fill-blanks.
    """
    result = dict(base)
    for key, value in incoming.items():
        if key.startswith("_"):  # skip metadata fields
            continue
        if key not in result:
            result[key] = value
        elif key == "abstract":
            # Conservative abstract update: only replace a stub
            existing_abstract = result.get("abstract", "")
            if (
                isinstance(value, str)
                and value
                and isinstance(existing_abstract, str)
                and len(existing_abstract) < min_abstract_chars
                and len(value) > len(existing_abstract)
            ):
                result[key] = value
        elif isinstance(value, list) and value:
            if isinstance(result[key], list):
                # Union, preserve order
                seen = set(map(str, result[key]))
                for item in value:
                    if str(item) not in seen:
                        result[key].append(item)
                        seen.add(str(item))
            else:
                result[key] = value
        elif isinstance(value, dict) and value:
            if isinstance(result[key], dict):
                merged = dict(result[key])
                for k, v in value.items():
                    if v and not merged.get(k):
                        merged[k] = v
                result[key] = merged
            else:
                result[key] = value
        elif value and not result[key]:
            result[key] = value
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Quality gates
# ─────────────────────────────────────────────────────────────────────────────


def gate_new_entry(
    phrase: str, entry: dict, min_abstract_chars: int, min_tags: int
) -> str | None:
    """Return a rejection reason string, or None if the entry passes."""
    missing = REQUIRED - set(entry.keys())
    if missing:
        return f"missing fields {missing}"

    abstract = entry.get("abstract", "")
    if len(abstract) < min_abstract_chars:
        return f"abstract too short ({len(abstract)} < {min_abstract_chars} chars)"

    tags = entry.get("tags", [])
    if len(tags) < min_tags:
        return f"too few tags ({len(tags)} < {min_tags})"

    tradition = entry.get("tradition", "").lower()
    if tradition not in TRADITION_PREFIX:
        return f"unknown tradition {entry.get('tradition')!r}"

    return None


# ─────────────────────────────────────────────────────────────────────────────
# Pipeline metadata helpers
# ─────────────────────────────────────────────────────────────────────────────


def count_urls_crawled() -> int | None:
    urls_file = _ROOT / cfg()["search_web"]["output"]
    if not urls_file.exists():
        return None
    return sum(1 for line in urls_file.read_text().splitlines() if line.strip())


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run", action="store_true", help="Print stats without writing output"
    )
    parser.add_argument(
        "--notes", default="", help="Human release note written into the envelope"
    )
    parser.add_argument(
        "--bump-minor",
        action="store_true",
        help="Increment minor version instead of patch",
    )
    args = parser.parse_args()

    merge_cfg = cfg().get("merge_mantras", {})
    min_abstract = int(merge_cfg.get("min_abstract_chars", 300))
    min_tags = int(merge_cfg.get("min_tags", 3))

    if not ENRICHED.exists():
        sys.exit(f"Error: {ENRICHED} not found — run enrich_mantras.py first.")

    enriched: dict[str, dict] = json.loads(ENRICHED.read_text())
    meta, library = load_existing_library()
    existing_ids = {e.get("id", "") for e in library}

    new_version = bump_version(meta.get("version", "0.1.0"), minor=args.bump_minor)

    _banner(
        "Stage 5: merge_mantras",
        [
            f"###   Input:              {ENRICHED}  ({len(enriched)} entries)",
            f"###   Output:             {OUTPUT}",
            f"###   min_abstract_chars: {min_abstract}",
            f"###   min_tags:           {min_tags}",
            f"###   version:            {meta.get('version', '?')} → {new_version}",
            f"###   dry_run:            {args.dry_run}",
        ],
    )
    print()

    stats = {"updated": 0, "added": 0, "skipped": 0}

    for phrase, incoming in enriched.items():
        # Skip failed entries
        if "_error" in incoming:
            print(f"  skip (parse error): {phrase!r}", file=sys.stderr)
            stats["skipped"] += 1
            continue

        existing = find_existing(incoming, library)

        if existing:
            merged = merge_fields(existing, incoming, min_abstract)
            idx = library.index(existing)
            library[idx] = merged
            stats["updated"] += 1
        else:
            # Quality gate for new entries
            reason = gate_new_entry(phrase, incoming, min_abstract, min_tags)
            if reason:
                print(f"  skip ({reason}): {phrase!r}", file=sys.stderr)
                stats["skipped"] += 1
                continue

            new_entry = merge_fields(dict(EMPTY_ENTRY), incoming, min_abstract)
            new_entry["id"] = make_id(incoming, existing_ids)
            existing_ids.add(new_entry["id"])
            library.append(new_entry)
            stats["added"] += 1

    # Sort by tradition then name
    library.sort(key=lambda e: (e.get("tradition", ""), e.get("name", "")))

    total = len(library)
    _banner(
        "Results: merge_mantras",
        [
            f"###   Version:   {meta.get('version', '?')} → {new_version}",
            f"###   Library:   {total} entries total",
            f"###   Updated:   {stats['updated']}",
            f"###   Added:     {stats['added']}",
            f"###   Skipped:   {stats['skipped']}",
        ],
    )

    if args.dry_run:
        print("Dry run — nothing written.")
        return

    # Build pipeline metadata
    locales_searched = len(cfg().get("search_web", {}).get("cities", []))
    pipeline_meta = {
        "locales_searched": locales_searched,
        "urls_crawled": count_urls_crawled(),
        "mantras_added": stats["added"],
        "mantras_updated": stats["updated"],
        "run_at": date.today().isoformat(),
    }

    notes = (
        args.notes
        or f"Pipeline run: {stats['added']} added, {stats['updated']} updated"
    )

    envelope = {
        "version": new_version,
        "released": date.today().isoformat(),
        "notes": notes,
        "count": total,
        "pipeline": pipeline_meta,
        "mantras": library,
    }

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(envelope, indent=2, ensure_ascii=False))
    print(f"###   Written:   {OUTPUT}")
    print(_SEP)


if __name__ == "__main__":
    main()
