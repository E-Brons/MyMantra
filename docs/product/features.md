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
| FR-3.12 | Session target selection sheet | P0 | ✅ | Choose user default / mantra target / custom before session starts; daily/weekly accumulated reps shown as remaining |
| FR-3.13 | Tap rate limiter (1 s minimum between counts) | P1 | ✅ | `limitClickRate` setting enforced in session; default on; taps < 1 s apart are silently dropped |

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
| FR-5.3 | Font size (Small / Medium / Large) | P1 | 🐛 | BUG-003: setting is persisted but never applied — all font sizes are hard-coded; UI fonts and mantra fonts unaffected |
| FR-5.4 | Default target repetitions | P1 | ✅ | |
| FR-5.5 | About screen (version, license) | P1 | ✅ | |
| FR-5.6 | Default repetition cycle (Session / Daily / Weekly) | P1 | ✅ | `defaultRepetitionCycle` on `Settings`; dropdown in Practice section |
| FR-5.7 | Tap rate limit toggle | P1 | ✅ | `limitClickRate` on `Settings`; toggle in Practice section; enforced in session screen (1 s min) |

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

## Phase 2.0 — Usage Analytics & Mantra Feedback (Epic)

All analytics are **opt-in only**, disclosed upfront, collect no PII, and default to off.

### Crash & Error Telemetry

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.1 | Opt-in crash reporting | P0 | 📋 | Captures unhandled exceptions + stack traces; anonymised; sent on next launch with user consent |
| FR-11.2 | Non-fatal error logging | P1 | 📋 | Records caught errors (e.g. storage read failure) with context; batched, anonymised |
| FR-11.3 | App start / version / OS metadata | P1 | 📋 | Flutter version, platform, OS version, device class (phone/tablet); no device ID |

### Feature Usage Telemetry

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.4 | Screen view events | P1 | 📋 | Which screens are visited and how frequently; no content, no timing below 1 s |
| FR-11.5 | Feature adoption tracking | P1 | 📋 | Boolean flags: reminders used, library used, achievements viewed, cloud sync enabled |
| FR-11.6 | Settings preference distribution | P2 | 📋 | Aggregate counts of theme / font-size / rep-cycle / rate-limit choices; helps prioritise UI work |
| FR-11.7 | Notification tap-through rate | P1 | 📋 | Reminder fired vs. session started within 5 min; measures reminder effectiveness |

### Session Quality Signals

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.8 | Session start / completion funnel | P0 | 📋 | Count sessions started, completed, cancelled at each step; identifies drop-off |
| FR-11.9 | Session abandonment point | P1 | 📋 | At what % of target reps do users cancel; buckets: <25 %, 25–50 %, 50–75 %, >75 % |
| FR-11.10 | Session duration distribution | P2 | 📋 | Bucketed durations (< 1 min, 1–5 min, 5–15 min, > 15 min); no raw timestamps |
| FR-11.11 | Tap-rate limiter effectiveness | P2 | 📋 | % of sessions where limiter fired ≥ 1 time; informs whether default should stay on |

### Mantra Content Feedback

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.12 | Library mantra like / dislike | P1 | 📋 | User stores thumbs-up or thumbs-down per library mantra locally; influences library sort order |
| FR-11.13 | Translation / transliteration quality rating | P2 | 📋 | One-tap 1–3 star rating per language variant; stored locally; optionally submitted |
| FR-11.14 | Mantra content issue report | P1 | 📋 | User flags a content error (wrong text, mistranslation, cultural concern, offensive content); pre-filled email / GitHub issue template opens in browser |
| FR-11.15 | Per-mantra usage stats | P2 | 📋 | Sessions started / completed and total reps per library mantra; derived locally from session history; shown on library mantra detail |

### User Satisfaction

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.16 | In-app review prompt (NPS-lite) | P1 | 📋 | After 7th completed session, prompt "Enjoying MyMantra?" → Yes → OS review sheet; No → in-app feedback form |
| FR-11.17 | In-app feature request / upvote | P2 | 📋 | Minimal text field; submissions batched and optionally sent; helps surface unsolicited feature ideas |

### Analytics Consent & Privacy

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-11.18 | Analytics opt-in consent screen | P0 | 📋 | Shown once on first launch; clear description of what is collected; off by default |
| FR-11.19 | Analytics settings toggle | P0 | 📋 | Re-accessible from Settings → Privacy; user can withdraw consent and delete queued data at any time |
| FR-11.20 | Local-only analytics mode | P1 | 📋 | All analytics computed and stored locally even when submission is off; user can view their own stats |

---

## Phase 3.0 — Gamification

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-9.1 | Achievement system (34 badges across 6 chains) | P1 | ✅ | Streak×10, Reps×8, Sessions×8, Special×2, Platform×5, Creator×1 |
| FR-9.2 | Achievement gallery screen | P1 | ✅ | |
| FR-9.3 | Achievement unlock notification | P1 | ✅ | |
| FR-9.4 | Point system with streak multiplier | P2 | 📋 | |
| FR-9.5 | Progressive achievement visibility | P1 | 📋 | Chain heads always shown (locked); successors hidden until predecessor unlocked; `never` items hidden until earned |
| FR-9.6 | 10-tier rarity system with animated Divine | P1 | 📋 | Common→Uncommon→Rare→Super Rare→Epic→Heroic→Exotic→Mythic→Legendary→Divine (rainbow) |
| FR-10.1 | Shareable achievement images | P2 | 📋 | 1080×1920, no PII |
| FR-10.2 | Milestone celebrations (confetti/haptics) | P2 | 📋 | 30-day, 10K reps, 100 sessions |

---

## Phase 4.0 — Guru-Guided Mantra Creation (Epic)

A conversational "guru" guides the user through a structured dialogue to discover or
compose their own personal mantra. The specific methodologies driving the dialogue will
be provided and documented separately; this epic describes the container, UX, and
integration framework.

### Methodology Framework

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-12.1 | Pluggable methodology registry | P0 | 📋 | Each methodology is a self-contained conversation script; new ones can be added without code changes to the engine |
| FR-12.2 | Methodology selection screen | P1 | 📋 | User picks a methodology (or guru recommends one based on a brief intake); methodology descriptions shown |
| FR-12.3 | Methodology content (TBD) | P0 | 📋 | **Specific methodologies to be provided by product owner**; placeholder names: Intention-Based, Tradition-Based, Sound & Vibration, Affirmation-Based |

### Guru Conversation Engine

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-12.4 | Conversational UI (chat / card Q&A) | P0 | 📋 | Sequential guru messages with user responses via free text, tappable chips, or sliders; adapts to screen size |
| FR-12.5 | Intention & theme intake | P0 | 📋 | Opening questions: purpose, tradition, language preference, life context; answers seed the methodology |
| FR-12.6 | Adaptive question sequencing | P1 | 📋 | Each answer influences the next question; branching logic defined per methodology |
| FR-12.7 | Guru persona & tone settings | P2 | 📋 | User can choose guru voice: Neutral, Vedic, Buddhist, Modern Wellness; affects language and framing of questions |
| FR-12.8 | Offline scripted guru | P0 | 📋 | Fully deterministic decision-tree guru; no network required; works on Phase 1.0 devices |
| FR-12.9 | AI-powered guru (opt-in) | P2 | 📋 | LLM-backed guru for open-ended conversation; requires network; explicit privacy disclosure before activation |

### Mantra Generation & Refinement

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-12.10 | Mantra candidate generation | P0 | 📋 | Produces 1–3 mantra candidates from the conversation; each shown with its rationale |
| FR-12.11 | Candidate review screen | P0 | 📋 | User sees candidates side-by-side or sequentially; can play audio preview (Phase 2.0+) |
| FR-12.12 | Refinement loop | P1 | 📋 | User can request variations (shorter/longer, different language, different emphasis) up to 3 iterations |
| FR-12.13 | Mantra explanation card | P1 | 📋 | Each candidate shows: meaning, tradition context, sound qualities, why it matches the user's answers |

### Save & Integration

| ID | Feature | Priority | Status | Notes |
|----|---------|----------|--------|-------|
| FR-12.14 | Save to personal collection | P0 | 📋 | One-tap save; fields pre-filled from conversation (text, title, target reps, tradition tag); user can edit before confirming |
| FR-12.15 | Conversation log linked to mantra | P1 | 📋 | Full guru conversation saved and viewable from the mantra's detail screen |
| FR-12.16 | Resume interrupted conversation | P1 | 📋 | If user exits mid-session, the conversation is preserved and resumable from the home screen |
| FR-12.17 | Created-by-guru badge on mantra card | P2 | 📋 | Subtle indicator on home screen and detail view distinguishing guru-created from manually entered mantras |

---



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
| 0.4 | 2026-03-07 | Engineering | Step 3 complete: create/edit screen — cycle picker (Session/Daily/Weekly chips); wired to save |
| 0.5 | 2026-03-07 | Engineering | FR-5.3 downgraded to 🐛 (BUG-003: font size setting not applied); added FR-11.x epic (Usage Analytics & Mantra Feedback, 20 features across crash telemetry, feature usage, session signals, content feedback, user satisfaction, consent) |
| 0.6 | 2026-03-07 | Engineering | Step 4 complete: FR-3.12 ✅ — session target sheet (Your default / Mantra's target / Custom) with daily/weekly accumulated-reps support; pumpSession helper updated; 5 new widget tests |
| 0.7 | 2026-03-07 | Engineering | Step 5 complete: FR-5.6 ✅ FR-5.7 🚧 — Default cycle dropdown + Limit tap rate toggle in Settings Practice section; 3 widget tests; enforcement pending (step 6) |
| 0.8 | 2026-03-07 | Engineering | Step 6 complete: FR-3.13 ✅ FR-5.7 ✅ — tap rate limiter enforced in SessionScreen; _lastTapTime guard; 2 widget tests |
| 0.9 | 2026-03-16 | Engineering | FR-9.1 expanded to 34 achievements; FR-9.5 progressive visibility 📋; FR-9.6 10-tier rarity 📋 |

# 🐛 BUG: Emoji Rendering on iOS
| ID | Bug | Priority | Status | Notes |
|----|-----|----------|--------|-------|
| BUG-004 | Emoji icons (Progress, Achievements) show '?' placeholder on iOS | P0 | 🚧 | (🔥, ⭐, 🧘, 🙏, 🔒) render <br/>Affects: Progress screen, Achievements, session overlay, home empty state
