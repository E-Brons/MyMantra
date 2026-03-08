#!/usr/bin/env python3
"""
consolidate_mantras.py — One-time migration: merge per-tradition JSON files
into a single versioned assets/data/mantras.json.

Reads all assets/data/mantras/*.json files, flattens them into one array
sorted by tradition then name, and writes the versioned envelope format:

    {
      "version":  "0.1.0",
      "released": "YYYY-MM-DD",
      "notes":    "Initial curated set — consolidated from N tradition files",
      "count":    148,
      "mantras":  [ ... ]
    }

After writing, the per-tradition files and their directory are deleted.

Usage:
    python3 make/mantra-db/consolidate_mantras.py
    python3 make/mantra-db/consolidate_mantras.py --dry-run   # preview only
"""

import argparse
import json
import shutil
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from settings import ROOT

MANTRAS_DIR = ROOT / "assets" / "data" / "mantras"
OUTPUT      = ROOT / "assets" / "data" / "mantras.json"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview stats without writing or deleting anything")
    args = parser.parse_args()

    if not MANTRAS_DIR.is_dir():
        sys.exit(f"Error: {MANTRAS_DIR} not found — nothing to consolidate.")

    tradition_files = sorted(MANTRAS_DIR.glob("*.json"))
    if not tradition_files:
        sys.exit(f"Error: No JSON files found in {MANTRAS_DIR}.")

    mantras: list[dict] = []
    for path in tradition_files:
        items = json.loads(path.read_text())
        if isinstance(items, dict):
            # Support both {"mantras": [...]} envelope and plain dict-of-entries
            items = items.get("mantras", list(items.values()))
        mantras.extend(items)
        print(f"  loaded {len(items):3d} entries from {path.name}")

    # Sort by tradition then name for deterministic output
    mantras.sort(key=lambda e: (e.get("tradition", ""), e.get("name", "")))

    count = len(mantras)
    n_files = len(tradition_files)
    print(f"\n{count} mantras from {n_files} tradition files")

    if OUTPUT.exists():
        print(f"Warning: {OUTPUT} already exists — would be overwritten.", file=sys.stderr)

    envelope = {
        "version":  "0.1.0",
        "released": date.today().isoformat(),
        "notes":    f"Initial curated set — consolidated from {n_files} tradition files",
        "count":    count,
        "mantras":  mantras,
    }

    if args.dry_run:
        print("Dry run — nothing written or deleted.")
        return

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(envelope, indent=2, ensure_ascii=False))
    print(f"Written: {OUTPUT}")

    # Remove per-tradition files and directory
    shutil.rmtree(MANTRAS_DIR)
    print(f"Deleted: {MANTRAS_DIR}/")


if __name__ == "__main__":
    main()
