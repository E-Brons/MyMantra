#!/usr/bin/env bash
# make/build.sh — build release artifacts for active targets
# Requires make/prerequisites.yaml (run: make install first).
#
# Usage: bash make/build.sh [--target <name>]
#   --target  build only for the specified target (default: all build=true)

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── args ──────────────────────────────────────────────────────────────────────

SPECIFIED_TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target) SPECIFIED_TARGET="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

check_prereqs

# ── resolve Dart deps once ────────────────────────────────────────────────────

echo "==> build: flutter pub get"
(cd "$REPO_ROOT" && $FLUTTER pub get)

# ── build each target ─────────────────────────────────────────────────────────

while IFS='|' read -r name _device debug; do
    echo ""
    echo "==> build: $name"

    [[ "$debug" == "true" ]] && MODE="--debug" || MODE="--release"

    case "$name" in

        ios)
            (cd "$REPO_ROOT" && $FLUTTER build ios $MODE)
            ;;

        android)
            (cd "$REPO_ROOT" && $FLUTTER build appbundle $MODE)
            ;;

        macos)
            (cd "$REPO_ROOT" && $FLUTTER build macos $MODE)
            ;;

        web)
            (cd "$REPO_ROOT" && $FLUTTER build web $MODE)
            ;;

        # ── future targets ────────────────────────────────────────────────────
        # python)
        #     (cd "$REPO_ROOT/services" && uv build)
        #     ;;

        *)
            echo "warning: unknown target '$name' — skipping" >&2
            ;;

    esac
done < <(resolve_build_targets "$SPECIFIED_TARGET")

echo ""
echo "build complete."
