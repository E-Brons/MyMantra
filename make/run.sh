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
        DEVICE="$TARGET_DEVICE"
        if [[ -z "$DEVICE" ]]; then
            echo "error: no target device set for ios in target.json" >&2
            exit 1
        fi

        # Resolve to a UDID — xcrun handles name→UDID and avoids ambiguity when
        # multiple simulators share the same name.
        UDID="$(xcrun simctl list devices available 2>/dev/null \
            | grep -F "$DEVICE (" | head -1 \
            | grep -oE '[A-F0-9-]{36}' || true)"
        if [[ -z "$UDID" ]]; then
            echo "error: no available simulator matching '$DEVICE'" >&2
            echo "  run: xcrun simctl list devices available" >&2
            exit 1
        fi

        # Boot if not already running
        STATE="$(xcrun simctl list devices 2>/dev/null \
            | grep "$UDID" | grep -oE '\(Booted\)|\(Shutdown\)' || true)"
        if [[ "$STATE" != "(Booted)" ]]; then
            echo "  booting simulator: $DEVICE ($UDID)"
            xcrun simctl boot "$UDID"
        fi
        open -a Simulator --args -CurrentDeviceUDID "$UDID" 2>/dev/null || true

        # iOS simulator only supports debug mode; --release/--profile require a physical device.
        (cd "$REPO_ROOT" && $FLUTTER run -d "$UDID")
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

            # Verify the AVD exists before trying to launch it
            if ! "$EMULATOR" -list-avds 2>/dev/null | grep -qx "$AVD"; then
                echo "error: avd '$AVD' not found" >&2
                echo "  available: $("$EMULATOR" -list-avds 2>/dev/null | tr '\n' ' ' || echo '(none)')" >&2
                echo "  run: make install TARGET=android" >&2
                exit 1
            fi

            echo "  starting emulator: $AVD"
            EMULATOR_LOG="$(mktemp /tmp/emulator-XXXXXX.log)"
            "$EMULATOR" -avd "$AVD" >"$EMULATOR_LOG" 2>&1 &
            EMULATOR_PID=$!

            echo "  waiting for emulator to boot (pid $EMULATOR_PID, log: $EMULATOR_LOG)..."
            BOOT_TIMEOUT=120
            ELAPSED=0
            adb wait-for-device &
            ADB_WAIT_PID=$!
            while kill -0 "$ADB_WAIT_PID" 2>/dev/null; do
                if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
                    echo "error: emulator process exited unexpectedly — last log lines:" >&2
                    tail -20 "$EMULATOR_LOG" >&2
                    exit 1
                fi
                if (( ELAPSED >= BOOT_TIMEOUT )); then
                    echo "error: timed out waiting for emulator after ${BOOT_TIMEOUT}s" >&2
                    tail -20 "$EMULATOR_LOG" >&2
                    kill "$EMULATOR_PID" 2>/dev/null || true
                    exit 1
                fi
                sleep 2
                (( ELAPSED += 2 ))
            done
            wait "$ADB_WAIT_PID" 2>/dev/null || true

            echo "  device visible, waiting for boot to complete..."
            while true; do
                BOOT="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
                if [[ "$BOOT" == "1" ]]; then break; fi
                if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
                    echo "error: emulator exited during boot — last log lines:" >&2
                    tail -20 "$EMULATOR_LOG" >&2
                    exit 1
                fi
                if (( ELAPSED >= BOOT_TIMEOUT )); then
                    echo "error: timed out waiting for boot_completed after ${BOOT_TIMEOUT}s" >&2
                    tail -20 "$EMULATOR_LOG" >&2
                    exit 1
                fi
                sleep 2
                (( ELAPSED += 2 ))
            done

            echo "  emulator ready"
            RUNNING="$(adb devices 2>/dev/null | awk '/emulator.*device$/{print $1}' | head -1 || echo emulator-5554)"
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

    linux)
        (cd "$REPO_ROOT" && $FLUTTER run -d linux $FLUTTER_MODE)
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
