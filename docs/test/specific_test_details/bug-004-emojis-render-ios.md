# BUG-004 Test Detail: Emoji Rendering on iOS

## Goal
Verify that emoji glyphs render correctly on iOS screens where emoji are required by product design.

This test is unique because pass/fail is determined on the host side using screenshot analysis, not only by in-app widget assertions.

## Coverage
- Mantra library screen
- Progress screen
- Session completion screen

## Test Artifacts and Ownership
- App-side test flow: `integration_test/emoji_screenshot_integration_test.dart`
- Host-side Flutter driver: `test/driver/integration_test_driver.dart`
- Host-side wrapper: `test/driver/emoji_test.sh`
- Host-side Python validator: `test/driver/emoji_screenshots_test.py`
- Python dependencies: `test/driver/python_requirements.txt`
- Runtime screenshots: `tmp/*.png`

## Execution Model
1. App-side integration code drives UI and requests screenshots with stable names.
2. Host driver receives screenshot bytes in `onScreenshot`.
3. Host driver writes each image under `tmp/`.
4. Host driver executes Python validator for each checkpoint.
5. Python validator runs OCR checks and exits with code 0 (pass) or non-zero (fail).
6. Driver returns the result back to `flutter drive`, which marks the test run as pass/fail.

## Preconditions
- iOS simulator is available and bootable.
- `tesseract` is installed on host.
- Python venv is created and requirements from `test/driver/python_requirements.txt` are installed.

## How to Run
Preferred wrapper:

```bash
./test/driver/emoji_test.sh --device-id "iphone 17"
```

Direct command equivalent:

```bash
flutter drive \
  --driver=test/driver/integration_test_driver.dart \
  --target=integration_test/emoji_screenshot_integration_test.dart \
  --device-id "iphone 17"
```

## Pass Criteria
- Driver logs show screenshot save and validator pass for all checkpoints.
- Python validator reports all expected emoji present for each screen.
- Command exits with code 0.

## Fail Signals
- Missing expected emoji in OCR result for any checkpoint.
- Python validator exits non-zero.
- `flutter drive` exits non-zero due to failed `onScreenshot` callback.

## Notes
- OCR-based checks are intentionally host-side to keep platform-specific rendering verification outside app logic.
- This test should remain deterministic: stable seeds, stable screen names, stable screenshot timing.
