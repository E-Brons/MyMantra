---
name: local-ci
description: >
  Run the full CI pipeline locally on macOS before pushing. Reproduces every CI
  job (analyze → unit → widget → integration) so failures are caught on the
  development host instead of on GitHub Actions. Use when the user says
  "run CI locally", "check before push", "does this pass CI?", "local CI",
  or any time a fix-bug / implement-feature skill ends and code is ready to push.
---

# Local CI

This skill is invoked from **fix-bug** and **implement-feature** at specific
checkpoints. Whether a failure is acceptable depends on the calling context —
see the **Pass / Fail rules** section.

Run this skill **before every `git push`** to ensure the branch will pass all
CI jobs. Each phase mirrors a GitHub Actions job exactly.

---

## Phase 1 — Static Analysis (mirrors CI job: `analyze`)

```bash
flutter pub get
flutter analyze
```

- Zero issues required. `info`-level lint violations are treated as errors (the
  CI job fails on them too — see `analysis_options.yaml`).
- Fix every issue before proceeding.

---

## Phase 2 — Unit Tests (mirrors CI job: `unit-test`)

```bash
flutter test test/unit/ --reporter expanded
```

- All tests must pass.
- If any test fails: stop, diagnose, fix, re-run this phase before moving on.

---

## Phase 3 — Widget Tests (mirrors CI job: `widget-test`)

```bash
flutter test test/widget/ --reporter expanded
```

- All tests must pass.
- Common failure modes:
  - Items off-screen in a `ListView`: use `scrollUntilVisible` + `ensureVisible`.
  - Pending timers after dispose: replace bare `Future.delayed` with a `Timer`
    stored as a field and cancelled in `dispose()`.
- Fix any failure before proceeding.

---

## Phase 4 — Integration Tests: macOS desktop (mirrors CI job: `integration-linux`)

On macOS, use the `macos` target (no `xvfb` needed):

```bash
make test-integration TARGET=macos
```

This runs each file in `integration_test/` as a separate process, same as CI.

---

## Phase 5 — Integration Tests: iOS simulator (screenshots)

Run the iOS-targeted integration suites, including the screenshot capture test
(`icon_placement_integration_test.dart`). This uses `flutter drive` so that
`binding.takeScreenshot()` works — `flutter test -d ios` silently skips it.

### Step 1 — boot a simulator

```bash
# List available simulators
xcrun simctl list devices available | grep -E "iPhone|iPad"

# Boot one (use the UDID or name)
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
```

### Step 2 — run with flutter drive

For each iOS integration test file:

```bash
# Screenshots go to build/screenshots/ by default
flutter drive \
  --driver test/driver/integration_test_driver.dart \
  --target integration_test/icon_placement_integration_test.dart \
  -d "iPhone 17 Pro" \
  --screenshot build/screenshots

# App-flow tests (no screenshots, flutter test is fine here)
flutter test integration_test/app_flow_test.dart -d "iPhone 17 Pro"
```

### Step 3 — inspect screenshots

```bash
open build/screenshots/
```

Verify icons are correctly placed, not clipped, and readable at simulator scale.

### Pre-flight checklist for all integration tests

Before running any integration suite, verify each test's `launchApp()` / `setUp`:

1. Calls `SharedPreferences.setMockInitialValues({})` or `prefs.clear()` — no
   reliance on pre-existing device/simulator state.
2. Navigates to a known shell route (e.g. `/mypractice`) — **not** `go('/')`
   which is not a registered GoRouter route and leaves the app on the welcome
   screen.
3. Seeds any required data (mantras, sessions) programmatically.

---

## Combined shortcuts

Phases 1–3 (no device needed):

```bash
make test
```

Phases 1–4 (full CI equivalent on macOS desktop):

```bash
make test && make test-integration TARGET=macos
```

Full suite including iOS screenshots:

```bash
make test && make test-integration TARGET=macos && \
  flutter drive \
    --driver test/driver/integration_test_driver.dart \
    --target integration_test/icon_placement_integration_test.dart \
    -d "iPhone 17 Pro" \
    --screenshot build/screenshots
```

---

## Pass / Fail rules

Pass/fail requirements differ depending on which workflow called this skill:

| Calling context | Phase 1 (analyze) | Phases 2–3 (unit/widget) | Phase 4–5 (integration) |
|---|---|---|---|
| **After fix-bug RED commit** | Must pass | The **new** test must FAIL; all others must pass | Only run if the test is integration-level; the new test must FAIL |
| **After fix-bug GREEN commit** | Must pass | All tests must pass | Must pass |
| **After each implement-feature step** | Must pass | All tests must pass | Run if app flow was touched; must pass |
| **Before any push** | Must pass | All tests must pass | Must pass |

### Phase 1 is always a hard block

`flutter analyze` must report zero issues regardless of context. `info`-level
violations fail CI — treat them as errors.

### Integration test failure triage

When a Phase 4 or 5 test fails unexpectedly, fill in this table before writing
any code:

| Column | Question |
|---|---|
| **What the test does** | Exact sequence of finders / taps / expects |
| **What the app does** | Actual UI state at failure (route, widget tree, data) |
| **Root cause** | Is the test wrong, or is the app broken? |
| **Decision** | Fix the test (no prod change) **or** fix the app (add regression test) |

Common root causes:
- `appRouter.go('/')` — `/` is not a registered GoRouter route → welcome screen
  stays up → test finds no content. Fix: go to `/mypractice` and seed data.
- `find.text('X')` fails because `X` is in a `ListView` below the fold → use
  `scrollUntilVisible` + `ensureVisible`.
- `find.byType(DropdownButton<T>)` fails after a UI refactor to chips →
  update the finder.
- Pending timer after dispose → `Timer is still pending` assertion → replace
  bare `Future.delayed` with a stored `Timer` cancelled in `dispose()`.
- `flutter test -d ios` silently skips `takeScreenshot` → use `flutter drive`
  for any test that captures screenshots.

---

## Integration test failure: test bug vs app bug

When an integration test fails, fill in this table before writing any code:

| Column | Question |
|---|---|
| **What the test does** | Exact sequence of finders / taps / expects in the test |
| **What the app does** | Actual UI state at the failure point (check route, widget tree, data) |
| **Root cause** | Mismatch: is the test wrong, or is the app broken? |
| **Decision** | Fix the test (no prod change) **or** fix the app (with regression test) |

Common root causes:
- `appRouter.go('/')` — `/` is not a registered GoRouter route → welcome screen stays up → test can't find any content. Fix: navigate to `/mypractice` and seed data.
- `find.text('X')` fails because `X` is in a `ListView` below the fold → use `scrollUntilVisible`.
- `find.byType(DropdownButton<T>)` fails because the UI was refactored to chips/segmented → update the finder.
- Pending timer leaks → `Timer is still pending` assertion → replace `Future.delayed` with a stored `Timer` that is cancelled in `dispose()`.

---

## Commit after a local-CI pass

```bash
git add -A
git commit -m "fix(ci): <short description of what was broken and how it was fixed>"
```

Then suggest the push to the user — do not push automatically.
