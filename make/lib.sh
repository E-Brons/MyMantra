#!/usr/bin/env bash
# make/lib.sh — shared variables and target.json helpers
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MAKE_DIR/.." && pwd)"
TARGET_JSON="$REPO_ROOT/target.json"
PREREQ_YAML="$MAKE_DIR/prerequisites.yaml"
FLUTTER="flutter --suppress-analytics"
FONTS_DIR="$REPO_ROOT/assets/fonts"
GF="https://raw.githubusercontent.com/google/fonts/main/ofl"
AC="https://devimages-cdn.apple.com/design/resources/download"

# ── guards ────────────────────────────────────────────────────────────────────

check_prereqs() {
    if [[ ! -f "$PREREQ_YAML" ]]; then
        echo "error: environment not set up — run: make install" >&2
        exit 1
    fi
}

# ── target.json resolution ────────────────────────────────────────────────────

# resolve_build_targets [specified_target]
# Prints "name|device|debug" for targets to build.
# No argument  → all targets where build=true.
# With argument → just that target (errors if missing).
resolve_build_targets() {
    local specified="${1:-}"
    python3 - "$TARGET_JSON" "$specified" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
specified = sys.argv[2]
results = []
for name, cfg in data.items():
    if specified:
        if name == specified:
            results.append((name, cfg.get("target", ""), str(cfg.get("debug", True)).lower()))
    elif cfg.get("build", True):
        results.append((name, cfg.get("target", ""), str(cfg.get("debug", True)).lower()))
if not results:
    msg = (f"error: target '{specified}' not found in target.json"
           if specified else "error: no targets with build=true in target.json")
    print(msg, file=sys.stderr)
    sys.exit(1)
for name, tgt, dbg in results:
    print(f"{name}|{tgt}|{dbg}")
PYEOF
}

# resolve_run_target <mode> [specified_target]
# mode: "build" (for make run — selects build=true targets)
#       "debug" (for make debug — selects debug=true targets)
# Prints single "name|device" line; exits 1 if ambiguous or missing.
resolve_run_target() {
    local mode="$1"
    local specified="${2:-}"
    python3 - "$TARGET_JSON" "$mode" "$specified" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
mode, specified = sys.argv[2], sys.argv[3]
matches = [
    (name, cfg.get("target", ""))
    for name, cfg in data.items()
    if cfg.get(mode, True)
]
if specified:
    found = [(n, t) for n, t in matches if n == specified]
    if not found:
        print(f"error: target '{specified}' not found or not enabled for '{mode}'", file=sys.stderr)
        sys.exit(1)
    print(f"{found[0][0]}|{found[0][1]}")
elif len(matches) == 1:
    print(f"{matches[0][0]}|{matches[0][1]}")
elif len(matches) == 0:
    print(f"error: no targets with {mode}=true in target.json", file=sys.stderr)
    sys.exit(1)
else:
    names = ", ".join(n for n, _ in matches)
    print(f"error: multiple targets enabled for '{mode}' — specify: make {mode.replace('build','run')} TARGET=<name>", file=sys.stderr)
    print(f"  available: {names}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# all_target_names — prints every name in target.json regardless of flags
all_target_names() {
    python3 - "$TARGET_JSON" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for name in data:
    print(name)
PYEOF
}
