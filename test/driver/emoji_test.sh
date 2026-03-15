#!/bin/bash
# Run emoji screenshot integration tests via flutter drive.
# Screenshots are taken on device, OCR validation runs on this host.
#
# Usage: ./test/emoji/run_emoji_check.sh [--device-id <id>]
set -e

DEVICE_ID=${2:-""}  # optional: pass --device-id <id> as args

DRIVER="test/driver/integration_test_driver.dart"
TARGET="integration_test/emoji_screenshot_integration_test.dart"

if [[ -n "$DEVICE_ID" ]]; then
  flutter drive \
    --driver="$DRIVER" \
    --target="$TARGET" \
    --device-id="$DEVICE_ID"
else
  flutter drive \
    --driver="$DRIVER" \
    --target="$TARGET"
fi
