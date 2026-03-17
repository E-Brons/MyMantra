#!/usr/bin/env bash
# make/clean.sh — remove all build artifacts
# Cleans flutter output, then per-platform build directories.
# Add new target cases below as the project grows.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

echo "==> clean: flutter"
(cd "$REPO_ROOT" && $FLUTTER clean)

echo ""
echo "==> clean: platform build artifacts"

while IFS= read -r name; do
    case "$name" in

        ios)
            dir="$REPO_ROOT/ios/build"
            [[ -d "$dir" ]] && { echo "  ios/build/"; rm -rf "$dir"; } || echo "  ios/build/ (already clean)"
            ;;

        android)
            for d in android/build android/app/build android/.gradle; do
                [[ -d "$REPO_ROOT/$d" ]] && { echo "  $d/"; rm -rf "$REPO_ROOT/$d"; }
            done
            if [[ -f "$REPO_ROOT/android/gradlew" ]]; then
                echo "  android (gradlew clean)"
                (cd "$REPO_ROOT/android" && ./gradlew clean --quiet 2>/dev/null || true)
            fi
            ;;

        macos)
            dir="$REPO_ROOT/macos/build"
            [[ -d "$dir" ]] && { echo "  macos/build/"; rm -rf "$dir"; } || echo "  macos/build/ (already clean)"
            ;;

        windows)
            dir="$REPO_ROOT/windows/build"
            [[ -d "$dir" ]] && { echo "  windows/build/"; rm -rf "$dir"; } || echo "  windows/build/ (already clean)"
            ;;

        web)
            # build/web/ is covered by flutter clean above
            ;;

        # ── future targets ────────────────────────────────────────────────────
        # python)
        #     rm -rf "$REPO_ROOT/services/dist" "$REPO_ROOT/services/__pycache__"
        #     find "$REPO_ROOT/services" -name "*.pyc" -delete
        #     ;;

    esac
done < <(all_target_names)

echo ""
echo "clean complete."
