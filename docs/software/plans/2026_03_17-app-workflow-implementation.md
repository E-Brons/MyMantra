# Implementation Plan — App Workflow (app_flowchart.md)
**Date:** 2026-03-17
**Branch:** `feat/2026_03_17-app-workflow`
**Skill:** implement-feature

---

## 0. Pre-flight

- Branch off `main` (current HEAD `4b0174e`)
- Source of truth: `docs/product/app_flowchart.md` v0.3 (flows) + `docs/product/screens/*.yaml` (UI elements)
- Current state: functional MVP with different UX structure than spec

---

## 1. Gap Analysis (current vs. spec)

### Screen inventory

| Screen ID | YAML | Current file | Status |
|-----------|------|-------------|--------|
| 1 Welcome | `welcome.yaml` | — | New |
| 1a Sign In | `sign_in.yaml` | — | New (stub) |
| 1b Expectations | `expectations.yaml` | — | New |
| 2 Library | `library.yaml` | `library_screen.dart` | Rework |
| 2b Create Mantra | `create_mantra.yaml` | `create_mantra_screen.dart` | Rework — remove practice-settings fields, add Save→PracticePlan navigation |
| 3 Practice Plan | `practice_plan.yaml` | — | **New** — see §1.1 |
| 3b Delete Mantra | `delete_mantra.yaml` | Dialog in code | Promote to overlay widget |
| 4 MyPractice | `mypractice.yaml` | `home_screen.dart` | Rework |
| 5 Progress | `progress.yaml` | `progress_screen.dart` | Update stats + achievement gallery |
| 6 User Settings | `user_settings.yaml` | `settings_screen.dart` | Rework — add Account/Language/About |
| 6b User Feedback | `user_feedback.yaml` | — | New |
| 7 Practice | `practice.yaml` | `session_screen.dart` | Rework |
| 7b Celebration | `celebration.yaml` | Inline in session | Promote to standalone overlay |

### 1.1 Key architectural clarification — two-screen flow vs. flowchart

The flowchart narrative (Flow 3 / 4 / 7) describes a single "Mantra Settings Screen".
The screen YAMLs define **two distinct screens**:
- **2b Create Mantra** — content entry (title, text, transliteration, translation, tradition)
- **3 Practice Plan** — settings configuration (target reps, cycle, practice mode, reminders); shows mantra content as read-only; context-aware (add-from-library / post-create / edit)

The YAML spec is more detailed and recent for individual screens. **This plan follows the two-screen model** from the YAMLs. The flowchart's "Mantra Settings Screen" is shorthand for the 2b → 3 pair.

Navigation:
```
Library tap mantra → Practice Plan (3, add-from-library mode) → Add → MyPractice
Library FAB / Onboarding → Create Mantra (2b) → Save → Practice Plan (3, post-create mode) → Add → MyPractice
Practice Edit button → Practice Plan (3, edit mode) → Save → Practice
Practice Plan delete → Delete overlay (3b) → confirm → MyPractice
```

### 1.2 Data model gaps

| Addition | Where | Notes |
|----------|-------|-------|
| `Session` suspended state (ongoing = not completed) | `session.dart` | Required for this plan |
| Per-mantra suspended-session lookup | `app_provider.dart` | Required for this plan |
| First-launch flag | `storage_service.dart` | Required for this plan |
| `Mantra.history`, `Mantra.benefits`, `Mantra.tags` | `mantra.dart` | **Deferred** — will be added as part of the library-enrichment feature (FR-8.1). Any display code that references these fields must use null-safe fallbacks (`?? ''` / `?? []`). Do not add these fields to the model in this branch. |

### 1.3 Navigation architecture change

| Current | Spec |
|---------|------|
| 4-tab ShellRoute: Home / Library / Progress / Settings | 3-tab: Library (small) / MyPractice (center, dominant) / Progress (small); Settings via gear icon on MyPractice only |

### 1.4 Library category chips (from library.yaml)

Chip items: All | Popular | Yogic Philosophy | Buddhist | Hebrew | Christian | Secular
(Note: different from flowchart text which listed different items — YAML is authoritative)
Default on first-open from onboarding: Popular pre-selected.

### 1.5 Practice screen (from practice.yaml)

- `nav: none` — no system nav bar shown
- `note: "no timer"` — confirmed, timer UI must be removed
- Back action: `suspend-session → navigate → MyPractice`
- Edit action: `navigate → Practice Plan (3)` — not a unified settings screen

### 1.6 Celebration overlay (from celebration.yaml)

- Type: `overlay` (not a full screen, not a route push)
- Tap-anywhere to dismiss, or auto-dismiss after a few seconds
- Shows: achievement icon (full color), title, description, rarity badge (animated for Exotic+, rainbow for Divine)

### 1.7 Sign In stub (from sign_in.yaml)

3 buttons: Continue with Google, Continue with Apple, Sign in with Email — all stubs.

---

## 2. Scope

### In scope
All 10 flows, 13 screens (as YAMLs + flowchart define them), session suspension model, settings inheritance chain, mantra limit warning, celebration overlay, user feedback.

### Out of scope
Sign-in / cloud sync, audio practice modes, analytics opt-in (FR-11.x), library mantra JSON content (FR-8.1).

---

## 3. Commit Sequence (with sub-agent parallelization)

```
W0   — docs: update PRD + features.md + SRS

W1   — feat(data): Session suspended state + storage_service hasLaunched flag
W1t  — test(data): suspended-session state transitions unit tests

W2   — feat(nav): 3-tab AppScaffold + router update (new routes for all screens)

┌────────────────────────────────────────────────────────────────────────────┐
│  PARALLEL WAVE 3 — 3 sub-agents, no file overlap except router.dart       │
│                                                                             │
│  Agent A (onboarding)       Agent B (mypractice)       Agent C (settings) │
│  ─────────────────────      ─────────────────────      ─────────────────  │
│  new: welcome_screen        rework: home_screen         rework: settings   │
│  new: sign_in_screen        app_provider helper         new: feedback      │
│  new: expectations_screen   (ongoing-session lookup)    screen             │
│  storage_service (read)     home_screen.dart only       settings + router  │
│  app.dart (initial route)                               /feedback route    │
│  router.dart (top section)                              router (bottom)    │
│                                                                             │
│  Agent A touches: app.dart, storage_service.dart*, router.dart (top)      │
│  Agent B touches: home_screen.dart, app_provider.dart (addenda)           │
│  Agent C touches: settings_screen.dart, feedback_screen.dart, router.dart │
│                                                                             │
│  * storage_service.dart: Agent A only reads it (hasLaunched already added │
│    in W1); no conflict with W1.                                             │
│                                                                             │
│  router.dart conflict: Agent A adds onboarding routes (top); Agent C adds │
│  /feedback route (bottom). Main agent merges manually after both finish.  │
└────────────────────────────────────────────────────────────────────────────┘

Merge W3   — merge: integrate Wave 3 — onboarding, mypractice, settings+feedback

W4   — feat(session): Practice screen redesign
        (no timer, Back=suspend, layout per practice.yaml,
         Edit→/mantras/:id/plan?mode=edit,
         Celebration overlay widget, Done→achievement check→overlay→MyPractice)
W4t  — test(session): session screen widget tests

W5   — feat(create-mantra): rework — remove settings fields, Save → navigate to Practice Plan
W5t  — test(create-mantra): create mantra form widget tests

W6   — feat(practice-plan): new PracticePlanScreen (3) — three contexts,
        settings inheritance chain display, Delete Mantra overlay (3b)
W6t  — test(practice-plan): widget tests — all three contexts + delete overlay

W7   — feat(library): category chips (from library.yaml), Popular default,
        mantra card fields per spec (signature-badge, short-title, source, difficulty,
        primary-text, translation, tags), FAB top-right for create
W7t  — test(library): library screen widget tests

W8   — feat(progress): stats section (current/longest streak, total sessions, reps,
        member-since) + achievement gallery (progressive visibility + rarity tiers)
W8t  — test(progress): progress screen widget tests

W9   — docs: update features.md — in review
```

---

## 4. Sub-agent Delegation Detail

### Wave 3A — Onboarding sub-agent

**Input files to read:**
- `docs/product/app_flowchart.md` Flow 1
- `docs/product/screens/welcome.yaml`
- `docs/product/screens/sign_in.yaml`
- `docs/product/screens/expectations.yaml`
- `lib/src/core/services/storage_service.dart` (read-only — hasLaunched already exists from W1)
- `lib/src/app/app.dart`

**Files to create/modify:**
- `lib/src/features/onboarding/screens/welcome_screen.dart` (new)
  - Elements per `welcome.yaml`: logo top-center, philosophy quote + subtitle, language-selector icon top-right, Sign In button (→ `/signin`), Continue Offline button (→ `/expectations`), caption note at bottom
- `lib/src/features/onboarding/screens/sign_in_screen.dart` (new, stub)
  - Elements per `sign_in.yaml`: title, 3 stub buttons (Google, Apple, Email), back arrow
  - All buttons show a "Coming soon" SnackBar when tapped; each navigates to `/expectations`
- `lib/src/features/onboarding/screens/expectations_screen.dart` (new)
  - Elements per `expectations.yaml`: intro-text body, primary "Start from library" button (→ `/library?fromOnboarding=true`), secondary "Create your own" button (→ `/mantras/new`)
- `lib/src/app/app.dart` — read `hasLaunched` from storage; if false, `initialLocation = '/welcome'`; after onboarding completes call `storage.markLaunched()`
- `lib/src/app/router.dart` — **add at top of routes list** (before ShellRoute):
  ```dart
  GoRoute(path: '/welcome', ...)
  GoRoute(path: '/signin', ...)
  GoRoute(path: '/expectations', ...)
  ```

**Commits:**
```
feat(onboard): welcome screen — logo, quote, language selector, CTA buttons
feat(onboard): sign-in stub screen (3 buttons, all show coming-soon)
feat(onboard): expectations screen — intro text, library/create CTAs
feat(onboard): first-launch routing — hasLaunched flag gates initial route
test(onboard): widget tests for welcome and expectations screens
```

---

### Wave 3B — MyPractice sub-agent

**Input files to read:**
- `docs/product/app_flowchart.md` Flow 5 + Flow 2 (resume prompt)
- `docs/product/screens/mypractice.yaml`
- `lib/src/features/mantras/screens/home_screen.dart`
- `lib/src/core/providers/app_provider.dart`
- `lib/src/core/models/session.dart` (to understand suspended field added in W1)

**Files to modify:**
- `lib/src/features/mantras/screens/home_screen.dart` — full rework:
  - Remove search bar + search state
  - 3-tab aware: remove any settings-tab behavior (settings now via gear icon)
  - Gear icon top-right → navigates to `/settings`
  - Mantra list in user-added order
  - Each `MantraCard` shows:
    - `original-title` (large, prominent)
    - `translated-title` (smaller, faded)
    - `dynamic-badge` per spec:
      - **idle** (no suspended session, no streak): prayer icon
      - **ongoing** (has suspended session): mini-ring at suspended-session progress %, same visual language as practice ring
      - **streak** (streak ≥ 1 day, no ongoing session): weightlifting/energy icon
  - Tap on card with ongoing session → show dialog "Resume or start a new session?" with two buttons
  - Tap on card without ongoing session → navigate to `/mantras/:id/session` (passing sessionMode)
  - Empty state: "No Mantras to practice yet. To Start — select one from Library or Create your own."
  - Mantra limit warning: when `state.mantras.length >= 5` and user tries to add a 6th → show dismissible dialog (note: this is triggered from navigation, not from this screen directly — but the guard should live here or in the router)
- `lib/src/core/providers/app_provider.dart` — add helper:
  ```dart
  Session? suspendedSessionFor(String mantraId) =>
    state.sessions.where((s) => s.mantraId == mantraId && !s.completed).lastOrNull;
  ```

**Commits:**
```
feat(mypractice): dynamic mantra card badges — idle, ongoing (mini-ring), streak
feat(mypractice): empty state, settings gear icon, user-added order
feat(mypractice): resume-or-new session prompt dialog
test(mypractice): widget tests — three badge states, empty state, resume dialog
```

---

### Wave 3C — Settings + Feedback sub-agent

**Input files to read:**
- `docs/product/app_flowchart.md` Flow 9 + Flow 10
- `docs/product/screens/user_settings.yaml`
- `docs/product/screens/user_feedback.yaml`
- `lib/src/features/settings/screens/settings_screen.dart`
- `lib/src/core/models/settings.dart`

**Files to modify/create:**
- `lib/src/features/settings/screens/settings_screen.dart` — rework to match `user_settings.yaml`:
  - **Account section**: "Offline mode" label, caption "Sign in to sync... (coming soon)", Sign In stub button (→ `/signin`)
  - **Language section**: UI Language dropdown (stub — shows current locale, saves to settings, no actual i18n yet)
  - **Appearance section**: Theme chip-group (Dark/Light/System) + Font Size chip-group (Small/Medium/Large)
    - Font Size: UI is present and persists the setting, but has **zero effect on actual rendered font sizes** — all sizes remain hard-coded (BUG-003 is pre-existing; this plan adds the UI as a non-harming placeholder). The section shows a greyed caption: *"Font size adjustment coming soon."* This follows the existing pattern documented in FR-5.3.
  - **Practice Defaults section**: default-reps chips (27/54/108/216), default-cycle chips (Session/Daily/Weekly), default-practice-mode chips (Tap to count / Listen† / AI listens†), haptic-feedback toggle, limit-tap-rate toggle
  - **Notifications section**: Enable notifications master toggle
  - **About section**: "MyMantra" label, dynamic version, philosophy quote italic
  - **Feedback button** at very bottom → navigates to `/feedback`
  - All changes saved immediately (no Save button)
- `lib/src/features/settings/screens/feedback_screen.dart` (new):
  - Title "Feedback" heading
  - 4 list tiles per `user_feedback.yaml`: Bug Report, Feature Request, Mantra Info Request, General Feedback (each with description subtitle)
  - Tapping any tile opens email compose via `url_launcher`:
    - To: `support@mymantra.app` (configurable in `assets/data/config.yml`)
    - Subject: `[MyMantra] {category label}`
    - Body: pre-filled with `App version, Platform, OS version\n\n[Your message here]`
  - Back arrow → returns to Settings
- `lib/src/app/router.dart` — **add at bottom of routes list**:
  ```dart
  GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
  ```

**Dependency note:** `url_launcher` package must be present in `pubspec.yaml`. Check and add if missing.

**Commits:**
```
feat(settings): account, language, notifications, about sections
feat(settings): practice-defaults section — reps, cycle, mode, haptic, tap-limit chips
feat(feedback): user feedback screen — 4 categories, email compose
test(settings): settings screen section widget tests
test(feedback): feedback screen widget tests
```

---

## 5. Merge Point (before W4)

Main agent:
1. Merges Wave 3 branch outputs
2. Manually reconciles `router.dart` (Agent A routes at top + Agent C route at bottom, no line overlap expected)
3. Runs `make test` — all green before W4
4. Commit: `merge: integrate Wave 3 — onboarding, mypractice, settings+feedback`

---

## 6. Wave 4 — Practice Screen Redesign (main agent)

**File:** `lib/src/features/session/screens/session_screen.dart`

**Changes:**

| Remove | Add/Keep |
|--------|---------|
| Timer display (FR-3.4 was ✅ but spec says no timer) | Keep timer as private `_duration` int for future analytics — just don't show it in UI |
| Pause / Resume buttons | — |
| Cancel button + confirmation | — |
| Confusing exit paths | — |

**Layout (per `practice.yaml`):**
- Top-left: Back button (small, muted, icon + text "Back")
- Top-right: Edit button (small, muted, icon + text "Edit")
- Center: Large tap-circle (counter + progress ring)
- Bottom: Done button (bold, primary color, full-width)

**Back action:** saves suspended session (`completed = false`, `repsCompleted = _count`) via `appProvider.suspendSession(...)` → navigates to MyPractice (`context.go('/')`)

**Done action (+ auto-complete):**
1. Call `appProvider.completeSession(...)` (marks `completed = true`)
2. Check for newly unlocked achievements (`_newAchievements`)
3. If any → show `CelebrationOverlay` widget (animated, tap-anywhere or 3s auto-dismiss)
4. Then `context.go('/')`

**Edit button:** navigates to `/mantras/:id/plan?mode=edit`

**Celebration overlay widget** (inline or in `shared/widgets/celebration_overlay.dart`):
- Per `celebration.yaml`: achievement-card at center showing icon/title/description/rarity-badge
- Rarity badge: Exotic+ use animated gradient text, Divine uses rainbow animation (reuse `achievement_gradient_text.dart`)
- Dismiss: tap-anywhere OR 3 second auto-dismiss Timer
- After dismiss: navigate to MyPractice

**Commits:**
```
feat(session): layout redesign per practice.yaml — Back/Edit top, Done bottom, circle center
feat(session): remove timer display, pause/cancel; Back = suspend semantics
feat(session): celebration overlay widget with auto-dismiss and rarity animations
test(session): session screen widget tests — layout, suspend, done, celebration
```

---

## 7. Wave 5 — Create Mantra Screen Update (main agent)

**File:** `lib/src/features/mantras/screens/create_mantra_screen.dart`

**Changes (per `create_mantra.yaml`):**
- Remove any practice-settings fields (target reps, cycle) — those now belong exclusively in Practice Plan
- Keep existing fields: title (required), text (required), transliteration (optional), translation (optional), tradition (optional)
- **Note:** `history`, `benefits`, and `tags` fields from `create_mantra.yaml` are deferred to the library-enrichment feature (FR-8.1). The screen does not show them yet.
- Save button action: save draft mantra → navigate to `/mantras/:id/plan?mode=postCreate`
- Rename secondary action to "Discard" (currently may be "Cancel") → navigate back to Library

**Commits:**
```
feat(create-mantra): rework — remove settings fields, Save → navigate to Practice Plan
test(create-mantra): create mantra form widget test
```

---

## 8. Wave 6 — Practice Plan Screen (main agent) — NEW

**File:** `lib/src/features/mantras/screens/practice_plan_screen.dart` (new)

**Three contexts** (passed as query param `?mode=addFromLibrary|postCreate|edit`):

| Context | Entry | Mantra fields | Primary action | Back target |
|---------|-------|--------------|----------------|-------------|
| `addFromLibrary` | Library tap mantra card | Read-only | "Add to MyPractice" → MyPractice | Library |
| `postCreate` | Create Mantra → Save | Read-only | "Add to MyPractice" → MyPractice | Library |
| `edit` | Practice → Edit button | Read-only | "Save Changes" → Practice screen | Practice screen |

**Layout (per `practice_plan.yaml`):**
- **Mantra details section** (top, read-only): original-text, transliteration, translation
- **Practice Settings section** (center, editable):
  - `target-reps` number-picker: options 27/54/108/216
  - `cycle` chip-group: Session / Daily / Weekly
  - `practice-mode` chip-group: Tap to count (enabled) / Listen (greyed, "future") / AI listens (greyed, "future")
  - `reminders` reminder-list: add/edit/delete individual reminders
- **Primary action button** (bottom): label varies by context
- **Delete Mantra button** (bottom, destructive red): visible in `edit` context only → shows `DeleteMantraOverlay`

**Settings inheritance chain** (per `practice_plan.yaml`):
```
User explicit selection → User global defaults → Library recommendation (if library-sourced)
```
Display logic:
- If user has NOT explicitly set a value AND mantra is library-sourced AND library has recommendation → show `108 (recommended)` as placeholder/label
- Else if user has NOT explicitly set AND user Settings has a non-default → show `108 (your default)`
- Else (user explicitly set) → show `108` with no label

**Delete Mantra overlay** (3b, per `delete_mantra.yaml`):
- Shown as `showDialog(...)` modal on top of Practice Plan
- Warning icon (destructive), "Are you sure?" heading, message about cascade deletion
- Delete button → `appProvider.deleteMantra(id)` → navigate to MyPractice
- Cancel button → dismiss overlay → stay on Practice Plan

**Router additions:**
```dart
GoRoute(path: '/mantras/:id/plan', builder: (_, state) =>
  PracticePlanScreen(
    id: state.pathParameters['id']!,
    mode: PracticePlanMode.values.byName(state.uri.queryParameters['mode'] ?? 'addFromLibrary'),
  ),
),
```

**Commits:**
```
feat(practice-plan): PracticePlanScreen — three contexts per practice_plan.yaml
feat(practice-plan): settings inheritance chain display (recommended / your default / explicit)
feat(practice-plan): Delete Mantra overlay (3b) — warning, cascade note, confirm/cancel
test(practice-plan): widget tests — addFromLibrary, postCreate, edit contexts
test(practice-plan): delete overlay widget test
```

---

## 9. Wave 7 — Library Screen Update (main agent)

**File:** `lib/src/features/library/screens/library_screen.dart`

**Changes (per `library.yaml`):**

- Search bar: placeholder "Search by title, tradition...", filters list in real-time
- **Category chips** (horizontal scroll, from `library.yaml` — authoritative):
  `All | Popular | Yogic Philosophy | Buddhist | Hebrew | Christian | Secular`
  - Active chip: filled/colored, shows × to remove
  - When opened from onboarding (`?fromOnboarding=true`): Popular pre-selected
  - Otherwise: All pre-selected
  - Category data lives in `assets/data/library_categories.yml` (data-file rule from INSTRUCTIONS.md)
- **Mantra cards** show (per `library.yaml` item-elements): signature-badge, short-title, source, difficulty, primary-text, translation, tags
- Tap mantra card → `/mantras/:id/plan?mode=addFromLibrary`
- **FAB** (top-right, circle with `+`, no text): → `/mantras/new`

**Commits:**
```
feat(library): category chips from library_categories.yml + Popular/All default logic
feat(library): mantra card fields per library.yaml spec (badge, short-title, source, etc.)
feat(library): FAB top-right for create, tap-card → Practice Plan
test(library): library screen — chip filter, FAB, card tap navigation
```

---

## 10. Wave 8 — Progress Screen Update (main agent)

**File:** `lib/src/features/progress/screens/progress_screen.dart`

**Changes (per `progress.yaml`):**

- **Stats summary section** (top): current-streak (days), longest-streak (days), total-sessions, total-reps (compact format: 1.2K / 50K / 1M), member-since (date)
- **Achievement gallery** (2-col grid, display-only — no tap action):
  - Visibility logic (progressive): unlocked = full color; locked-teaser (next in chain) = greyed + lock icon + title; hidden (further down chain) = not rendered
  - Rarity tiers per `progress.yaml`: Common → Divine (10 tiers)
  - Exotic+ animated gradient text; Divine rainbow animation (reuse `achievement_gradient_text.dart`)
  - Categories per spec: streak (10 milestones), reps (8), sessions (9), time-of-day (2), platform (5), special (1)

**Commits:**
```
feat(progress): stats summary section — 5 stats with compact formatting
feat(progress): achievement gallery — progressive visibility + 10-tier rarity animations
test(progress): progress screen widget tests — stats formatting, gallery visibility
```

---

## 11. Test Plan Summary

| Layer | Scope | Files |
|-------|-------|-------|
| Unit | Session suspension model state transitions | `test/core/models/session_test.dart` |
| Unit | `suspendedSessionFor` provider helper | `test/core/providers/app_provider_test.dart` |
| Unit | Mantra model serialization (new fields) | `test/core/models/mantra_test.dart` |
| Widget | Welcome: logo, quote, 2 CTAs, language icon | `test/features/onboarding/welcome_screen_test.dart` |
| Widget | Expectations: 2 CTAs, intro text | `test/features/onboarding/expectations_screen_test.dart` |
| Widget | MyPractice: 3 badge states, empty state, resume dialog | `test/features/mantras/home_screen_test.dart` |
| Widget | Practice: layout positions, Back=suspend, Done flow | `test/features/session/session_screen_test.dart` |
| Widget | Celebration overlay: auto-dismiss, rarity badge | (same file) |
| Widget | Create Mantra: fields, Save→PracticePlan, Discard nav | `test/features/mantras/create_mantra_screen_test.dart` |
| Widget | Practice Plan: 3 contexts, inheritance labels, delete overlay | `test/features/mantras/practice_plan_screen_test.dart` |
| Widget | Library: chip filtering, Popular default, card fields, FAB | `test/features/library/library_screen_test.dart` |
| Widget | Settings: all sections present | `test/features/settings/settings_screen_test.dart` |
| Widget | Feedback: 4 categories visible | `test/features/settings/feedback_screen_test.dart` |
| Widget | Progress: stats + achievement gallery visibility rules | `test/features/progress/progress_screen_test.dart` |
| Integration | Flow 1: first-launch → welcome → expectations → library → add → MyPractice | `integration_test/flow_first_launch_test.dart` |
| Integration | Flow 2: tap mantra → practice → Done → celebration → MyPractice | `integration_test/flow_practice_test.dart` |

---

## 12. Documentation Updates (after implementation)

- `docs/product/features.md`: update FR statuses to ✅ or In Review
- `docs/software/software_requirements.md`: add SR entries for session suspension, settings inheritance chain, practice plan screen
- `docs/product/product_requirements.md`: confirm Phase 1.0 section matches all 10 flows

---

## 13. Conflict Map Summary

| File | W1 | W2 | W3A | W3B | W3C | W4 | W5 | W6 | W7 | W8 |
|------|----|----|-----|-----|-----|----|----|----|----|----|
| `mantra.dart` | ✏ | — | — | — | — | — | — | — | — | — |
| `session.dart` | ✏ | — | — | — | — | — | — | — | — | — |
| `storage_service.dart` | ✏ | — | read | — | — | — | — | — | — | — |
| `router.dart` | — | ✏ | ✏ top | — | ✏ bottom | — | — | ✏ | — | — |
| `app.dart` | — | — | ✏ | — | — | — | — | — | — | — |
| `app_scaffold.dart` | — | ✏ | — | — | — | — | — | — | — | — |
| `app_provider.dart` | — | — | — | ✏ | — | — | — | — | — | — |
| `home_screen.dart` | — | — | — | ✏ | — | — | — | — | — | — |
| `settings_screen.dart` | — | — | — | — | ✏ | — | — | — | — | — |
| `session_screen.dart` | — | — | — | — | — | ✏ | — | — | — | — |
| `create_mantra_screen.dart` | — | — | — | — | — | — | ✏ | — | — | — |
| `library_screen.dart` | — | — | — | — | — | — | — | — | ✏ | — |
| `progress_screen.dart` | — | — | — | — | — | — | — | — | — | ✏ |

Parallel agents W3A / W3B / W3C have **no overlap except `router.dart`**, resolved by section (top vs. bottom). All other files are exclusive per wave.

---

## 14. PR Description (template)

**What:** Implements the full app workflow from `docs/product/app_flowchart.md` v0.2 — all 10 flows, 13 screens.

**Requirements satisfied:** FR-1.x, FR-3.x, FR-4.x, FR-5.x (see features.md for individual statuses).

**How to verify:**
1. Delete app data → fresh install → Welcome screen appears
2. Continue Offline → Expectations → Start from library → Popular chips pre-selected → tap mantra → Practice Plan (add-from-library mode) → inheritance labels show `(recommended)` → Add to MyPractice
3. Tap mantra → Practice screen (no timer, circle center, Done bottom, Back/Edit top) → count reps → Back → mini-ring badge on card
4. Tap same mantra → "Resume or New Session?" prompt → Resume → continue → Done → celebration overlay if achievement unlocked → MyPractice
5. Gear icon → Settings → all 6 sections present → Feedback button → 4 categories → email compose opens
6. Library FAB → Create Mantra form → fill title + text → Save → Practice Plan (post-create mode) → inheritance shows `(your default)` → Add → MyPractice

---

*Plan created: 2026-03-17*
*Status: Awaiting user approval before branch creation*
