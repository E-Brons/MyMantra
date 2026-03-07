# Test Cases
## MyMantra – Phase 1.0 MVP

**Version:** 0.1
**Date:** 2026-03-07
**Status:** Suggested — no implementation yet

Legend: 🟢 should pass today | 🔴 expected to fail (known bug) | 🟡 not yet verifiable

---

## TC-U: Unit Tests

### TC-U-01 — Streak Calculation

File: `test/unit/logic/streak_calculation_test.dart`

| # | Description | Input | Expected | Status |
|---|-------------|-------|----------|--------|
| U-01-1 | First-ever session | lastSessionDate=null | streak=1 | 🟢 |
| U-01-2 | Second session same day | lastDate=today | streak unchanged | 🟢 |
| U-01-3 | Session after one-day gap | lastDate=yesterday | streak+1 | 🟢 |
| U-01-4 | Session after two-day gap | lastDate=2 days ago | streak=1 (broken) | 🟢 |
| U-01-5 | New streak > longest | streak=8, longest=7 | longest=8 | 🟢 |
| U-01-6 | Timezone midnight boundary | session at 23:59 local | counted for correct day | 🟡 |

---

### TC-U-02 — Achievement Unlocking

File: `test/unit/logic/achievement_unlock_test.dart`

| # | Description | Input | Expected | Status |
|---|-------------|-------|----------|--------|
| U-02-1 | First session unlocks ACH-001 | sessions=1 | ACH-001 returned | 🟢 |
| U-02-2 | 3-day streak unlocks ACH-002 | streak=3 | ACH-002 returned | 🟢 |
| U-02-3 | Already-unlocked not returned again | ACH-001 in list, sessions=5 | empty list | 🟢 |
| U-02-4 | 10,000 reps unlocks Master | totalReps=10000 | Master badge | 🟢 |
| U-02-5 | 7 AM check for Early Bird | sessionTime=06:59 | ACH-012 returned | 🟢 |
| U-02-6 | 7:01 AM does not unlock Early Bird | sessionTime=07:01 | not returned | 🟢 |

---

### TC-U-03 — Mantra Model Serialization

File: `test/unit/models/mantra_model_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| U-03-1 | toJson → fromJson round-trip | fields identical | 🟢 |
| U-03-2 | Unicode title preserves Devanagari | "ॐ मणिपद्मे हूँ" survives round-trip | 🟢 |
| U-03-3 | Unicode title preserves Hebrew | "שמע ישראל" survives round-trip | 🟢 |
| U-03-4 | reminders serialise correctly | 2 reminders survive round-trip | 🟢 |
| U-03-5 | createdAt / updatedAt roundtrip | DateTime precision preserved | 🟢 |

---

### TC-U-04 — Session Model

File: `test/unit/models/session_model_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| U-04-1 | Session toJson / fromJson | all fields preserved | 🟢 |
| U-04-2 | duration excludes paused time | activeTime = total – paused | 🟢 |
| U-04-3 | completed flag set on save | completed=true after SR-3.4 | 🟢 |

---

### TC-U-05 — Progress Model

File: `test/unit/models/progress_model_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| U-05-1 | Initial state | streak=0, sessions=0, reps=0 | 🟢 |
| U-05-2 | After session | totalSessions+1, totalReps+count | 🟢 |
| U-05-3 | Serialisation round-trip | all fields preserved | 🟢 |

---

### TC-U-06 — StorageService

File: `test/unit/services/storage_service_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| U-06-1 | save then load returns same state | identity | 🟢 |
| U-06-2 | load on empty storage returns defaults | AppState.initial() | 🟢 |
| U-06-3 | corrupt JSON returns defaults, not crash | graceful fallback | 🟡 |

---

### TC-U-07 — MantraLibraryService

File: `test/unit/services/mantra_library_service_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| U-07-1 | load() returns ≥375 mantras | count ≥ 375 | 🟡 (JSON not written yet) |
| U-07-2 | search("om") returns Om mantra | OM-001 in results | 🟡 |
| U-07-3 | filter by tag "buddhist" | all results have buddhist tag | 🟡 |
| U-07-4 | byId("OM-001") returns correct mantra | name = "Om (Aum)" | 🟡 |
| U-07-5 | tagsWithEmojis has emoji prefix | "🕉️ vedic" format | 🟡 |

---

## TC-W: Widget Tests

### TC-W-01 — Home Screen

File: `test/widget/home_screen_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-01-1 | Renders empty state when no mantras | "No mantras" message shown | 🟢 |
| W-01-2 | Renders mantra list with seed data | 2 mantra cards visible | 🟢 |
| W-01-3 | Search filters list | typing "Om" shows only matching cards | 🟢 |
| W-01-4 | Tapping [+] navigates to create screen | CreateMantraScreen rendered | 🟢 |
| W-01-5 | Tapping mantra card navigates to detail | MantraDetailScreen rendered | 🟢 |

---

### TC-W-02 — Mantra Detail Screen

File: `test/widget/mantra_detail_screen_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-02-1 | Renders mantra title and text | title visible | 🟢 |
| W-02-2 | Back button exists in AppBar | arrow_back icon present | 🟢 |
| W-02-3 | Back button tappable | tap does not throw | 🟢 |
| W-02-4 | Back button calls context.pop() | Navigator pops | 🔴 (BUG-001 on macOS) |
| W-02-5 | "Start Session" button navigates to session | SessionScreen rendered | 🟢 |
| W-02-6 | Delete shows confirmation dialog | AlertDialog shown | 🟢 |

---

### TC-W-03 — Session Screen

File: `test/widget/session_screen_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-03-1 | Counter starts at 0 | "0" displayed | 🟢 |
| W-03-2 | Tap increments counter | counter = 1 | 🟢 |
| W-03-3 | 10 rapid taps → counter = 10 | no missed taps | 🟢 |
| W-03-4 | Progress bar fills proportionally | width matches count/target | 🟢 |
| W-03-5 | Reaching target triggers completion | celebration shown | 🟢 |
| W-03-6 | Cancel with counter=0: no dialog | screen exits immediately | 🟢 |
| W-03-7 | Cancel with counter>0: shows dialog | "Discard session?" shown | 🟢 |
| W-03-8 | Hardware back with counter>0 shows dialog | "Discard session?" shown | 🔴 (BUG-002 Android) |
| W-03-9 | Pause disables tap counting | counter unchanged after tap | 🟢 |

---

### TC-W-04 — Create / Edit Mantra Screen

File: `test/widget/create_mantra_screen_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-04-1 | Empty title blocks submission | error shown, no navigation | 🟢 |
| W-04-2 | Empty text blocks submission | error shown | 🟢 |
| W-04-3 | Valid form saves and navigates back | HomeScreen visible | 🟢 |
| W-04-4 | Edit mode pre-fills existing values | fields show existing data | 🟢 |
| W-04-5 | Back with unsaved changes shows dialog | "Discard changes?" shown | 🟡 (not implemented yet) |

---

### TC-W-05 — Back Navigation (Widget Level)

File: `test/widget/back_navigation_widget_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-05-1 | MantraDetail → back → HomeScreen | HomeScreen rendered | 🔴 (BUG-001) |
| W-05-2 | CreateMantra (new) → back → HomeScreen | HomeScreen rendered | 🟢 |
| W-05-3 | CreateMantra (edit) → back → MantraDetail | MantraDetailScreen rendered | 🟢 |
| W-05-4 | Session (counter=0) → back → MantraDetail | MantraDetailScreen rendered | 🟢 |
| W-05-5 | Session (counter>0) → back → dialog | dialog shown, not navigated | 🔴 (BUG-002) |

---

### TC-W-06 — Progress Screen

File: `test/widget/progress_screen_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| W-06-1 | Shows streak = 0 on fresh install | "0 days" | 🟢 |
| W-06-2 | Shows correct total reps | matches progress.totalRepetitions | 🟢 |
| W-06-3 | Unlocked achievements shown | badge icons visible | 🟢 |
| W-06-4 | Locked achievements shown as dimmed | opacity/greyscale applied | 🟢 |

---

## TC-I: Integration Tests (macOS target)

Run with: `flutter test integration_test/ -d macos`

### TC-I-01 — Full Session Flow

File: `integration_test/full_session_flow_test.dart`

| # | Steps | Expected | Status |
|---|-------|----------|--------|
| I-01-1 | Launch → tap seed mantra → tap "Start Session" → tap 10× → tap "Complete" | Session saved, streak ≥ 1, home visible | 🟢 |
| I-01-2 | Check progress screen after session | totalSessions=1, reps=10 | 🟢 |
| I-01-3 | First-session achievement (ACH-001) unlocked | "First Steps" badge visible | 🟢 |

---

### TC-I-02 — Mantra CRUD Flow

File: `integration_test/mantra_crud_flow_test.dart`

| # | Steps | Expected | Status |
|---|-------|----------|--------|
| I-02-1 | Create mantra with Unicode title | mantra appears in list | 🟢 |
| I-02-2 | Edit title | updated title shows | 🟢 |
| I-02-3 | Delete with confirmation | mantra removed | 🟢 |
| I-02-4 | Delete without confirm (cancel dialog) | mantra remains | 🟢 |

---

### TC-I-03 — Back Navigation (macOS)

File: `integration_test/back_navigation_macos_test.dart`

This suite specifically targets **BUG-001**.

| # | Steps | Expected | Status |
|---|-------|----------|--------|
| I-03-1 | Home → tap mantra → tap back arrow | HomeScreen rendered | 🔴 (BUG-001) |
| I-03-2 | Home → tap mantra → press ESC key | HomeScreen rendered | 🔴 (not implemented) |
| I-03-3 | Home → tap mantra → tap "Start Session" → tap back | MantraDetail rendered | 🔴 (BUG-001 chain) |
| I-03-4 | Home → tap [+] → fill form → tap back | HomeScreen rendered | 🟢 |
| I-03-5 | Cold-launch to /mantras/:id → back | HomeScreen rendered (fallback) | 🔴 (BUG-001) |

---

### TC-I-04 — Back Navigation (Android emulator)

File: `integration_test/back_navigation_android_test.dart`

| # | Steps | Expected | Status |
|---|-------|----------|--------|
| I-04-1 | Home → detail → press hardware back | HomeScreen rendered | 🟢 |
| I-04-2 | Session (counter=0) → hardware back | MantraDetail rendered | 🟢 |
| I-04-3 | Session (counter>0) → hardware back | "Discard session?" dialog | 🔴 (BUG-002) |
| I-04-4 | Session dialog → "Cancel" → counter unchanged | still in session | 🔴 (BUG-002) |
| I-04-5 | Session dialog → "Discard" → home | session NOT saved | 🔴 (BUG-002) |

---

### TC-I-05 — Counter Stress Test

File: `integration_test/counter_stress_test.dart`

| # | Description | Expected | Status |
|---|-------------|----------|--------|
| I-05-1 | 108 rapid taps → counter = 108 | no missed taps | 🟢 |
| I-05-2 | Tap at ≥10 taps/second for 10 seconds | no missed taps, no double-count | 🟢 |
| I-05-3 | Auto-complete fires exactly at 108 | completion screen shown | 🟢 |

---

## Summary

| Category | Total Cases | 🟢 Expected Pass | 🔴 Known Fail | 🟡 Unverifiable |
|----------|------------|-----------------|--------------|-----------------|
| Unit | 34 | 27 | 0 | 7 |
| Widget | 28 | 20 | 5 | 3 |
| Integration | 16 | 8 | 7 | 1 |
| **Total** | **78** | **55** | **12** | **11** |

### Known failures requiring implementation before they can pass

| Bug | Cases affected | Fix needed |
|-----|---------------|------------|
| BUG-001 (macOS back) | W-02-4, W-05-1, I-03-1..5 | `canPop()` guard + `PopScope` |
| BUG-002 (Android back in session) | W-03-8, W-05-5, I-04-3..5 | `PopScope` on SessionScreen |
| Unsaved-changes guard | W-04-5 | Navigation intercept on CreateMantraScreen |

---

**Change Log**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-03-07 | Engineering | Initial draft — no implementation |
