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
| Catch regressions early | No CI/CD required — tests run locally with `flutter test` |
| Verify cross-platform nav | Confirm back-button/escape behaviour on macOS & Android |
| Cover core business logic | Streak calculation, session counting, achievement unlocking |
| Keep friction low | Every suite must run in <60 s on a developer laptop |

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

- Run on a real target (macOS preferred)
- `flutter test integration_test/ -d macos`
- Speed: <120 s per suite
- Scope: user-visible flows and platform-specific navigation

---

## 4. What We Are NOT Testing (Yet)

| Excluded | Reason |
|----------|--------|
| Cloud sync | Phase 2.0, requires network mocks |
| Push notifications | Requires device + OS permission flow |
| Voice recording | Phase 2.0, requires microphone |
| Social sharing | Phase 3.0 |
| CI pipeline | Infrastructure not set up; all tests run manually |

---

## 5. Known Bug Targeted by Tests

### BUG-001: macOS — MantraDetailScreen navigation blocked

**Symptom:** On macOS, tapping the back arrow on `/mantras/:id` does nothing (cannot leave
the screen). The route sits outside the `ShellRoute` and `context.pop()` has no parent entry
in go_router's history when the user arrives from a cold launch or direct URL.

**Related screens:** `MantraDetailScreen`, `CreateMantraScreen`, `SessionScreen`

**Affected platform:** macOS (confirmed). May also affect Web deep-link entry.

**Likely cause:** The route outside `ShellRoute` has no predecessor on the Navigator stack
when entered directly. `context.canPop()` returns `false`; the button still calls
`context.pop()` which is a no-op.

**Fix approach (not implemented yet):** Wrap the back action in
`if (context.canPop()) context.pop() else context.go('/')`. Also consider `PopScope`
for consistent behaviour across all back sources.

---

### BUG-002: Android — hardware back button not wired to session confirmation

**Symptom:** Pressing the Android hardware/gesture back during an active session (counter > 0)
dismisses the screen without the "Discard session?" confirmation dialog defined in SR-3.5.

**Affected screen:** `SessionScreen`

**Likely cause:** `WillPopScope` / `PopScope` is not used; only the visible Cancel button
shows the confirmation dialog.

**Fix approach (not implemented yet):** Add `PopScope(onPopInvoked: ...)` to
`SessionScreen` to intercept the system back event.

---

## 6. Test Tooling

| Tool | Purpose |
|------|---------|
| `flutter test` | Unit + Widget |
| `flutter test integration_test/ -d macos` | macOS integration |
| `flutter test integration_test/ -d emulator-*` | Android emulator |
| `flutter analyze` | Static analysis (run before any test suite) |
| `lcov` + `genhtml` | Coverage HTML report (optional) |

Generate coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 7. Test File Layout (Target Structure)

```
test/
  unit/
    models/
      mantra_model_test.dart
      session_model_test.dart
      progress_model_test.dart
      reminder_model_test.dart
    logic/
      streak_calculation_test.dart
      achievement_unlock_test.dart
      session_timer_test.dart
    services/
      storage_service_test.dart
      mantra_library_service_test.dart

  widget/
    home_screen_test.dart
    mantra_detail_screen_test.dart
    create_mantra_screen_test.dart
    session_screen_test.dart
    progress_screen_test.dart
    library_screen_test.dart
    back_navigation_widget_test.dart

integration_test/
  full_session_flow_test.dart
  mantra_crud_flow_test.dart
  back_navigation_macos_test.dart
  back_navigation_android_test.dart
  counter_stress_test.dart
```

---

## 8. Entry Criteria for Each Level

| Level | Entry Criteria |
|-------|---------------|
| Unit | `flutter analyze` passes with 0 errors |
| Widget | All unit tests green |
| Integration | All widget tests green + macOS target booted |

---

## 9. Open Questions

1. Should the integration tests run on Android emulator in addition to macOS, or defer to a
   future CI stage?
2. Should `flutter_test` golden files be added for key screens (session counter, progress
   dashboard)?
3. Are mutation tests (`stryker`-equivalent) worth the overhead for the streak algorithm?

---

**Change Log**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-03-07 | Engineering | Initial draft |
