#!/bin/bash
# Run icon placement integration tests via flutter drive.
#
# Usage: ./test/driver/icon_placement_test.sh [--device-id <id>]
set -e

DEVICE_ID=${2:-""}  # optional: pass --device-id <id> as args

DRIVER="test/driver/integration_test_driver.dart"
TARGET="integration_test/icon_placement_integration_test.dart"

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
