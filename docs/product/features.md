# Feature List
## MyMantra — All Features by Phase & Priority

**Version:** 0.1
**Date:** 2026-03-07
**Source of truth:** PRD + SRS + active development

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Implemented (current build) |
| 🚧 | In progress |
| 📋 | Planned — not started |
| 🐛 | Known bug — fix planned |
| ❌ | Explicitly out of scope |

## Priority Legend

| Code | Meaning |
|------|---------|
| P0 | Must have — blocker for ship |
| P1 | Should have — ship without, but soon after |
| P2 | Nice to have — post-launch |

---

## Phase 1.0 — Core MVP

### Mantra Management

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-1.1 | Custom mantra creation | P0 | ✅ | Title, text, target reps, Unicode |
| FR-1.2 | Mantra list with search | P0 | ✅ | Sort by updated, search by title/text |
| FR-1.3 | Mantra detail view | P0 | ✅ | Full text, reminders, session history |
| FR-1.4 | Edit mantra | P0 | ✅ | Pre-filled form |
| FR-1.5 | Delete mantra (with confirmation) | P0 | ✅ | Cascade-deletes reminders + sessions |
| FR-1.6 | Per-mantra repetition cycle (Session / Daily / Weekly) | P1 | ✅ | `targetCycle` field on `Mantra`; `recommendedCycle?` on `LibraryMantra` |

### Reminders / Notifications

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-2.1 | Create scheduled reminder | P0 | ✅ | Time, days-of-week, enable/disable |
| FR-2.2 | Edit reminder | P0 | ✅ | |
| FR-2.3 | Delete reminder | P0 | ✅ | |
| FR-2.4 | Enable/disable reminder toggle | P0 | ✅ | |
| FR-2.5 | Deep-link from notification to session | P0 | 📋 | |

### Session Experience

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-3.1 | Full-screen tap-to-count session | P0 | ✅ | |
| FR-3.2 | Haptic feedback on tap | P0 | ✅ | |
| FR-3.3 | Progress bar | P0 | ✅ | |
| FR-3.4 | Session timer (active time only) | P0 | ✅ | Paused time excluded |
| FR-3.5 | Auto-complete at target | P0 | ✅ | |
| FR-3.6 | Manual complete button | P0 | ✅ | |
| FR-3.7 | Pause / resume | P0 | ✅ | |
| FR-3.8 | Reset counter (with confirmation) | P0 | ✅ | |
| FR-3.9 | Cancel session (with confirmation if count > 0) | P0 | ✅ | Dialog only on visible Cancel button |
| FR-3.10 | Screen wake lock | P0 | 📋 | Prevents sleep during session |
| FR-3.11 | Back-button cancel (Android hardware back) | P0 | ✅ | Fixed: `PopScope` wraps `SessionScreen` |
| FR-3.12 | Session target selection sheet | P0 | 📋 | Choose user default / mantra target / custom before session starts |
| FR-3.13 | Tap rate limiter (1 s minimum between counts) | P1 | 📋 | User setting, default on; prevents accidental double-counts |

### Progress Tracking

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-4.1 | Streak calculation | P0 | ✅ | Timezone-aware |
| FR-4.2 | Progress / stats dashboard | P0 | ✅ | |
| FR-4.3 | 7-day visual streak calendar | P0 | ✅ | |
| FR-4.4 | Session history list | P0 | ✅ | |

### Settings

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-5.1 | Notification preferences (master on/off, sound, vibration) | P1 | ✅ | |
| FR-5.2 | Theme (Light / Dark / System) | P1 | ✅ | |
| FR-5.3 | Font size (Small / Medium / Large) | P1 | ✅ | |
| FR-5.4 | Default target repetitions | P1 | ✅ | |
| FR-5.5 | About screen (version, license) | P1 | ✅ | |
| FR-5.6 | Default repetition cycle (Session / Daily / Weekly) | P1 | ✅ | `defaultRepetitionCycle` on `Settings`; UI pending |
| FR-5.7 | Tap rate limit toggle | P1 | ✅ | `limitClickRate` on `Settings`; UI + enforcement pending |

### Navigation & Platform Behaviour

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-NAV-1 | Back navigation: MantraDetail → Home (all platforms) | P0 | ✅ | Fixed: `canPop()` guard + `context.go('/')` fallback |
| FR-NAV-2 | Back navigation: Android hardware back button | P0 | ✅ | Fixed: `PopScope` on SessionScreen + CreateMantraScreen |
| FR-NAV-3 | macOS ESC key closes modal / navigates back | P0 | 📋 | Not implemented |
| FR-NAV-4 | Unsaved-changes guard on CreateMantraScreen | P1 | 📋 | "Discard changes?" dialog |

---

## Phase 2.0 — Cloud & Audio

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-6.1 | Record personal mantra audio (AAC) | P1 | 📋 | Max 5 min, 3 free / unlimited Pro |
| FR-6.2 | Attach recording to mantra | P1 | 📋 | |
| FR-6.3 | Audio playback during session (loop) | P1 | 📋 | Background audio |
| FR-7.1 | Google / Apple sign-in (OAuth2) | P0 | 📋 | |
| FR-7.2 | Cloud sync (Google Drive / iCloud) | P0 | 📋 | Last-write-wins |
| FR-7.3 | Multi-device support | P0 | 📋 | ≤15 min propagation |
| FR-7.4 | Data export (JSON) | P1 | 📋 | |
| FR-7.5 | Data import from JSON | P1 | 📋 | |
| FR-8.1 | Built-in mantra library (375+ mantras) | P1 | 🚧 | Background agent writing JSON |

---

## Phase 3.0 — Gamification

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-9.1 | Achievement system (14 badges) | P1 | ✅ | Model exists; UI partial |
| FR-9.2 | Achievement gallery screen | P1 | ✅ | |
| FR-9.3 | Achievement unlock notification | P1 | ✅ | |
| FR-9.4 | Point system with streak multiplier | P2 | 📋 | |
| FR-10.1 | Shareable achievement images | P2 | 📋 | 1080×1920, no PII |
| FR-10.2 | Milestone celebrations (confetti/haptics) | P2 | 📋 | 30-day, 10K reps, 100 sessions |

---

## Quality & Testing

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| QA-1 | Unit test suite (streak, models, services) | P0 | 📋 | See docs/test/test_cases.md |
| QA-2 | Widget test suite (all screens) | P0 | 📋 | |
| QA-3 | Integration test suite (macOS target) | P0 | 📋 | |
| QA-4 | BUG-001 regression test | P0 | 📋 | Back nav on macOS — fix applied, test pending |
| QA-5 | BUG-002 regression test | P0 | 📋 | Android back in session — fix applied, test pending |

---

## Explicitly Out of Scope

| ID | Feature | Reason |
|----|---------|--------|
| ❌ | Social / community features | Privacy concerns |
| ❌ | Text-to-speech during session | High complexity |
| ❌ | Wear OS / watchOS | Separate project |
| ❌ | Offline speech recognition (auto-count) | High complexity |
| ❌ | Paid subscription / ads | Never |
| ❌ | Crash analytics without consent | Privacy-first |

---

**Change Log**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-03-07 | Engineering | Initial draft from PRD/SRS + current build state |
| 0.2 | 2026-03-07 | Engineering | Add FR-1.6, FR-3.12, FR-3.13, FR-5.6, FR-5.7; update FR-5.4 max reps to 999; step 1 complete (data models) |
| 0.3 | 2026-03-07 | Engineering | Step 2 complete: provider — createMantra/updateMantra/completeSession carry targetCycle; getAccumulatedReps added |
