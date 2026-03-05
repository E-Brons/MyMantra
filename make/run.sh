#!/usr/bin/env bash
# make/run.sh — run or debug the app on a target
# Requires make/prerequisites.yaml (run: make install first).
#
# Usage:
#   bash make/run.sh             [--target <name>]   # run (release)
#   bash make/run.sh --debug     [--target <name>]   # debug (hot reload)
#
# Target selection:
#   make run   → targets where build=true  in target.json
#   make debug → targets where debug=true in target.json
#   In both cases TARGET is required if more than one target qualifies.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── args ──────────────────────────────────────────────────────────────────────

DEBUG=false
SPECIFIED_TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --debug)  DEBUG=true; shift ;;
        --target) SPECIFIED_TARGET="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

check_prereqs

# ── resolve single target ─────────────────────────────────────────────────────

# make run  → filter on build=true  field
# make debug → filter on debug=true field
if [[ "$DEBUG" == "true" ]]; then
    MODE_FIELD="debug"
    FLUTTER_MODE=""          # flutter run default = debug (hot reload)
else
    MODE_FIELD="build"
    FLUTTER_MODE="--release"
fi

LINE="$(resolve_run_target "$MODE_FIELD" "$SPECIFIED_TARGET")"
TARGET_NAME="${LINE%%|*}"
TARGET_DEVICE="${LINE##*|}"

echo "==> $( [[ $DEBUG == true ]] && echo debug || echo run ): $TARGET_NAME"

# ── device flag and platform-specific launch ──────────────────────────────────

case "$TARGET_NAME" in

    ios)
        DEVICE="${TARGET_DEVICE:-iPhone 17}"
        (cd "$REPO_ROOT" && $FLUTTER run -d "$DEVICE" $FLUTTER_MODE)
        ;;

    android)
        ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
        EMULATOR="$ANDROID_SDK/emulator/emulator"
        AVD="${TARGET_DEVICE:-}"

        # Boot emulator if none running
        RUNNING="$(adb devices 2>/dev/null | awk '/emulator.*device$/{print $1}' | head -1 || true)"
        if [[ -z "$RUNNING" ]]; then
            if [[ -z "$AVD" ]]; then
                AVD="$("$EMULATOR" -list-avds 2>/dev/null | head -1 || true)"
            fi
            if [[ -z "$AVD" ]]; then
                echo "error: no android avd found — run: make install TARGET=android" >&2
                exit 1
            fi
            echo "  starting emulator: $AVD"
            "$EMULATOR" -avd "$AVD" &>/dev/null &
            echo "  waiting for emulator to boot..."
            adb wait-for-device
            adb shell 'while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ]; do sleep 2; done'
            echo "  emulator ready"
            RUNNING="emulator-5554"
        fi
        (cd "$REPO_ROOT" && $FLUTTER run -d "$RUNNING" $FLUTTER_MODE)
        ;;

    macos)
        (cd "$REPO_ROOT" && $FLUTTER run -d macos $FLUTTER_MODE)
        ;;

    web)
        # Web always runs on Chrome; debug field is ignored for device selection
        (cd "$REPO_ROOT" && $FLUTTER run -d chrome $FLUTTER_MODE)
        ;;

    # ── future targets ────────────────────────────────────────────────────────
    # python)
    #     (cd "$REPO_ROOT/services" && uv run python -m app)
    #     ;;

    *)
        echo "error: unknown target '$TARGET_NAME'" >&2
        exit 1
        ;;

esac
