# Test Strategy
## MyMantra – Spiritual Practice Application

**Version:** 0.1
**Date:** 2026-03-07
**Status:** Draft
**Scope:** Phase 1.0 MVP + platform-specific navigation

---

## 1. Goals

| Goal | Detail |
|------|--------|
| Catch regressions early | Tests run locally and progressively in CI (Linux-first rollout) |
| Verify cross-platform nav | Confirm back-button/escape behaviour on macOS & Android |
| Cover core business logic | Streak calculation, session counting, achievement unlocking |
| Keep friction low | Every suite must run in <60 s on a developer laptop |
| Define target ownership clearly | Each integration suite declares Device, Native, and Web applicability |

---

## 2. Platforms in Scope

| Platform | Test Level | Notes |
|----------|-----------|-------|
| macOS (primary) | Unit + Widget + Integration | Developer machine — no device needed for unit/widget |
| Android | Unit + Widget | Emulator via `make run TARGET=android` |
| iOS | Unit + Widget | Simulator via `make run TARGET=ios` |
| Web | Unit + Widget | Chrome via `flutter test -d chrome` (future) |

> **For this stage, macOS is the primary integration test target.** A passing macOS integration
> suite is a sufficient gate before shipping to iOS/Android.

### 2.1 Integration Target Types

Integration suites are grouped by target type:

| Target Type | Targets | Rule |
|-------------|---------|------|
| Device | iOS simulator, Android emulator | Runs on emulated/simulated mobile targets |
| Native | macOS, Linux, Windows | Runs only when host OS matches target OS |
| Web | Chrome/Web runtime | Runs in browser runtime with web-compatible test code |

### 2.2 Environment Assumptions

| Environment | Host OS | Notes |
|-------------|---------|-------|
| Developer workstation | macOS | Primary local development and iOS simulator runs |
| CI | Linux | Native Linux integration, plus emulator-based Android runs (iOS simulator is TODO) |

### 2.3 Integration Coverage Manifest

- Source of truth: `integration_test/targets_matrix.yaml`
- The manifest declares, per integration suite:
  - whether it is implemented
  - which targets it can run on
  - where it is mandatory to pass
  - CI TODO items for missing target automation

---

## 3. Test Levels

### 3.1 Unit Tests (`test/unit/`)

- Pure Dart, zero Flutter dependency, zero device
- Run: `flutter test test/unit/`
- Speed: <5 s total
- Target coverage: **>80%** for all business-logic classes

### 3.2 Widget Tests (`test/widget/`)

- Use `WidgetTester` — virtual Flutter environment, no device
- Run: `flutter test test/widget/`
- Speed: <30 s total
- Target coverage: **>60%** for all screen widgets

### 3.3 Integration Tests (`integration_test/`)

- Functional flows: `flutter test integration_test/ -d $(TARGET)`
- Rendering checks: `flutter drive --driver=test/driver/integration_test_driver.dart --target=integration_test/emoji_screenshot_integration_test.dart`
- Speed: <120 s per suite
- Scope: user-visible flows, platform-specific navigation, and visual correctness
- Target declaration: every suite must define Device, Native, and Web applicability in `docs/test/test_cases.md` and `integration_test/targets_matrix.yaml`


#### Rendering Regression Strategy (NEW)

For rendering issues (emoji fallback, missing glyphs, clipped text, font artifacts), we use a host-driven integration pipeline.

**Device/App side (Flutter integration target)**

- The integration test drives the UI to deterministic states and calls screenshot capture for each named checkpoint.
- Each checkpoint name is treated as a test contract (for example, `mantra_library`, `progress`, `session_complete`).

**Host/Driver side (source of truth for pass/fail)**

- `integration_test_driver.dart` receives screenshot bytes through `onScreenshot`.
- The driver writes each image under `tmp/` on the host machine.
- The driver then executes a host validator command (Python today; bash wrapper optional) and waits for exit code.
- Exit code contract: `0` = rendering check passed, non-zero = failed checkpoint and failed integration run.

**Host orchestration options**

- Direct command: run `flutter drive` with the custom driver.
- Wrapper command: run the bash script, which invokes `flutter drive` and centralizes target/device flags.
- Python validator: analyzes the saved screenshot (OCR/image rules) and reports missing glyphs or rendering anomalies.

**Why this is the strategy**

- Widget assertions cannot reliably detect pixel-level or glyph-rendering failures.
- Keeping image analysis on the host decouples heavy dependencies (OCR/image libs, external binaries) from app runtime.
- The same host driver contract can support future validators (Python, shell tools, or additional scripts) without changing app-side test logic.

---

## 4. What We Are NOT Testing (Yet)

| Excluded | Reason |
|----------|--------|
| Cloud sync | Phase 2.0, requires network mocks |
| Push notifications | Requires device + OS permission flow |
| Voice recording | Phase 2.0, requires microphone |
| Social sharing | Phase 3.0 |
| iOS simulator integration in CI | TODO: requires macOS CI runners/device boot orchestration |

---

## 5. Test Tooling

| Tool | Purpose |
|------|---------|
| `flutter analyze` | Static analysis (run before any test suite) |
| `flutter test` | Unit + Widget |
| `flutter test integration_test/ -d <target>` | Functional integration suites |
| `flutter drive --driver=test/driver/integration_test_driver.dart --target=integration_test/emoji_screenshot_integration_test.dart` | Rendering integration with host-side screenshot validation |
| `test/driver/emoji_test.sh [--device-id <id>]` | Bash wrapper to run rendering checks with consistent flags |
| `test/driver/integration_test_driver.dart` | Host driver: saves screenshots and launches host validators |
| `python3 test/driver/emoji_screenshots_test.py <screen_name> <image_path>` | Rendering validator (OCR/image analysis, exit-code based) |
| `pytesseract` + system `tesseract` | OCR engine used by Python validator |
| `lcov` + `genhtml` | Coverage HTML report (optional) |

Rendering flow (host-oriented):
```bash
./test/driver/emoji_test.sh --device-id <id>
```

Equivalent direct command:
```bash
flutter drive \
  --driver=test/driver/integration_test_driver.dart \
  --target=integration_test/emoji_screenshot_integration_test.dart \
  --device-id <id>
```

Generate coverage report:
``` bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 6. Test Folders

```
docs/
  test/
    test_cases.md
    test_strategy.md
    specific_test_details/
      bug-004-emoji_rendering-ios.md

integration_test/
  app_flow_test.dart
  emoji_screenshot_integration_test.dart

test/
  driver/
    integration_test_driver.dart
    emoji_test.sh
    emoji_screenshots_test.py
  unit/
    ... unit test files
  widget/
    ... widget test files

tmp/
  *.png (runtime screenshot artifacts written by host driver)
```

---

## 7. Entry Criteria for Each Level

| Level | Entry Criteria |
|-------|---------------|
| Unit | `flutter analyze` passes with 0 errors |
| Widget | All unit tests green |
| Integration | All widget tests green + macOS target booted |

---

**Change Log**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-03-07 | Engineering | Initial draft |
| 0.2 | 2026-03-14 | Copilot | Added general visual regression strategy (Python + external tools) section |
