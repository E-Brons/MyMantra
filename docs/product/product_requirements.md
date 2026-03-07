# Product Requirements Document (PRD)
## MyMantra - Spiritual Practice Application

**Version:** 0.1
**Date:** November 2025
**Status:** Draft
**Document Owner:** Product Team
**Application Name:** MyMantra

---

## 1. Executive Summary

### 1.1 Product Vision
A cross-platform spiritual practice companion that enables users to maintain consistent mantra meditation through intelligent reminders, seamless counting, and motivating progress tracking - all while respecting privacy through an offline-first, cloud-synced approach.

**Product Name:** MyMantra

### 1.2 Product Mission
Empower individuals on their spiritual journey by removing friction from daily mantra practice, fostering habit formation through gamification, and providing a private, reliable tool that works anywhere, anytime.

### 1.3 Target Platforms
- **Phase 1.0**: iOS, Android
- **Phase 2.0**: macOS, Web
- **Phase 3.0**: Windows, Linux

---

## 2. Market Analysis

### 2.1 Target Users
**Primary Personas:**

1. **Spiritual Practitioner Sarah** (Age 28-45)
   - Daily meditation practice
   - Uses mantras for mindfulness
   - Values privacy and simplicity
   - Moderate tech literacy

2. **Traditional Devotee David** (Age 45-65)
   - Religious mantra recitation (Hindu, Buddhist)
   - Needs reminder system for prayer times
   - Wants to track devotional progress
   - Basic tech literacy

3. **Wellness Seeker Maya** (Age 22-35)
   - Uses affirmations and mantras for mental health
   - Motivated by gamification
   - High tech literacy
   - Social sharing interest (future)

### 2.2 Market Opportunity
- Global meditation app market: $2.1B (2024)
- Growing interest in mindfulness and spiritual wellness
- Gap: No focused mantra apps with offline-first approach
- Differentiation: Privacy-focused, no subscription, cloud sync via user's storage

### 2.3 Competitive Analysis

| Competitor | Strengths | Weaknesses | Our Advantage |
|-----------|-----------|------------|---------------|
| Insight Timer | Large library, community | Cluttered, subscription | Focused, free, offline |
| Calm | Polished UI, content | Expensive, online-required | Free, works offline |
| Generic counters | Simple | No context, no reminders | Full mantra workflow |

---

## 3. Product Goals & Success Metrics

### 3.1 Business Goals
1. **User Acquisition**: 10K downloads in first 6 months
2. **User Retention**: 40% MAU (Monthly Active Users) at 3 months
3. **User Satisfaction**: 4.5+ star average (App Store/Play Store)
4. **Community Building**: Foundation for future premium features

### 3.2 Key Performance Indicators (KPIs)

| Metric | Target (6 months) | Measurement |
|--------|------------------|-------------|
| Total Downloads | 10,000 | App analytics |
| DAU/MAU Ratio | 30% | Firebase/internal |
| Session Completion Rate | 70% | Internal analytics |
| 7-Day Streak Achievement | 25% of users | Achievement tracking |
| App Store Rating | 4.5/5.0 | Store reviews |
| Crash-Free Rate | 99.5% | Crashlytics |

### 3.3 User Goals
1. **Consistency**: Complete daily practice with minimal friction
2. **Tracking**: Visualize progress and streaks
3. **Customization**: Personalize mantras and schedules
4. **Motivation**: Feel encouraged by achievements
5. **Privacy**: Keep spiritual practice personal and secure

---

## 4. Feature Requirements by Version

## Phase 1.0 - Core Experience (MVP)

### 4.1 Mantra Management
**Priority: P0 (Must Have)**

#### FR-1.1: Custom Mantra Creation
- Users can create unlimited custom mantras
- Fields:
  - Title (required, 1-100 characters)
  - Text (required, 1-5000 characters, multi-line, Unicode support)
  - Target repetitions (default: 108, range: 1-10,000)
- Support for multiple languages (Sanskrit, English, Hebrew, Arabic, etc.)
- Edit and delete capabilities

#### FR-1.2: Mantra Library
- Browse custom mantras in list view
- Search by title or text content
- Sort options: Recently updated, Alphabetical
- Card preview: Title, text snippet (50 chars), target count

**Success Criteria:**
- User can create a mantra in <30 seconds
- Search returns results in <500ms for 100+ mantras
- Unicode rendering works for all supported languages

---

### 4.2 Intelligent Reminders
**Priority: P0 (Must Have)**

#### FR-2.1: Scheduled Notifications
- Create multiple reminders per mantra
- Configuration:
  - Time of day (24-hour format)
  - Days of week selection (any combination)
  - Enable/disable toggle
  - Notification sound selection
- OS-level notification integration
- Deep link from notification to session screen

#### FR-2.2: Reminder Management
- View all reminders in mantra detail screen
- Edit reminder time/days
- Delete reminders
- Master notification toggle in settings

**Success Criteria:**
- Notification appears within 1 minute of scheduled time
- Tapping notification opens session screen with correct mantra
- Reminders persist after app restart and device reboot

---

### 4.3 Session Experience
**Priority: P0 (Must Have)**

#### FR-3.1: Interactive Counting (Option B)
- Full-screen reading mode
  - Mantra text displayed prominently (18-24sp font)
  - Current count displayed (48sp+ font)
  - Target count and progress bar visible
- **Tap-to-count interaction:**
  - Tap anywhere on screen to increment
  - Haptic feedback on each tap (medium impact)
  - Visual feedback (subtle animation)
  - Accurate counting even with rapid taps (10/second stress test)
- Auto-complete when target reached
- Manual complete button
- Pause/resume functionality
- Reset counter option (with confirmation)
- Screen wake lock (prevents sleep during session)

#### FR-3.2: Session Timer
- Track active practice duration
- Exclude paused time from total
- Display duration in session summary

#### FR-3.3: Session Completion
- Save session to history:
  - Mantra reference
  - Timestamp (start time)
  - Repetitions completed
  - Duration (seconds)
  - Source (manual start vs. reminder)
- Celebration animation (2-3 seconds)
- Achievement notification (if earned)
- Return to home screen

**Success Criteria:**
- Tap response time <50ms
- No missed taps during stress testing
- Session data persists even if app crashes
- Users complete 70%+ of started sessions

---

### 4.4 Progress Tracking
**Priority: P0 (Must Have)**

#### FR-4.1: Streak Calculation
- **Current Streak:** Consecutive days with ≥1 completed session
- **Longest Streak:** All-time maximum streak
- Algorithm:
  - Today's session: Maintain current streak
  - Yesterday's session: Increment streak
  - Older than yesterday: Reset to 1
- Timezone-aware date calculations
- Visible on home screen and progress dashboard

#### FR-4.2: Statistics Dashboard
- **Key Metrics:**
  - Current streak (days)
  - Longest streak (days)
  - Total sessions completed
  - Total repetitions across all sessions
  - Last session date
- **Visualizations:**
  - 7-day streak calendar (checkmarks on active days)
  - Total reps milestone progress bar
  - Session frequency chart (future enhancement)

#### FR-4.3: Session History
- Chronological list of past sessions
- Grouped by date
- Details: Mantra name, reps, duration
- Filter by date range (future)
- Pagination (load 50 at a time)

**Success Criteria:**
- Streak updates immediately after session
- Statistics accurate across all mantras
- History loads in <300ms

---

### 4.5 User Settings
**Priority: P1 (Should Have)**

#### FR-5.1: Notification Preferences
- Master notification enable/disable
- Default notification sound selection
- Vibration enable/disable
- Permission request flow (iOS/Android)

#### FR-5.2: Appearance
- Theme selection: Light, Dark, System
- Font size adjustment (accessibility)

#### FR-5.3: Default Values
- Default target repetitions for new mantras

#### FR-5.4: About & Support
- App version display
- Open-source license (MIT)
- Donation links (external, optional)
- Privacy policy
- Contact/support email

**Success Criteria:**
- Settings persist across sessions
- Theme changes apply instantly (no restart)

---

## Phase 2.0 - Enhanced Features

### 4.6 Voice Recording
**Priority: P1 (Premium Feature)**

#### FR-6.1: Record Personal Mantra Audio
- Record mantra recitation in-app
- Max duration: 5 minutes per recording
- Audio format: AAC, 64kbps (compressed)
- Storage: Local device + cloud sync
- Attach recording to mantra

#### FR-6.2: Audio Playback During Session (Option A)
- Play recording on loop during session
- Background playback support
- Pause/resume controls
- Volume adjustment
- Playback count synchronized with manual count (optional)

**Premium Limitation:**
- Max 3 custom recordings (Free)
- Unlimited recordings (Pro - future IAP)

**Success Criteria:**
- Recording quality is clear and audible
- Playback is seamless (no gaps when looping)
- Audio file size <5MB for 5-minute recording

---

### 4.7 Cloud Synchronization
**Priority: P0 (Phase 2.0)**

#### FR-7.1: User Account Integration
- **No custom backend required**
- Authentication via:
  - Sign in with Google (Android focus)
  - Sign in with Apple (iOS focus)
- OAuth2 token management
- Secure credential storage

#### FR-7.2: Cloud Storage Sync
- **Storage Backends:**
  - Google Drive (Android users)
  - iCloud Drive (iOS users)
- **Synced Data:**
  - All mantras (including custom)
  - All reminders
  - All sessions (full history)
  - Progress statistics
  - Voice recordings (optional, bandwidth consideration)
- **Sync Strategy:**
  - Offline-first: Local DB is source of truth
  - Background sync every 15 minutes (when connected)
  - Manual sync trigger
  - Conflict resolution: Last-write-wins (timestamp)
- **Data Format:** Encrypted JSON file in user's cloud storage
- **File Location:**
  - Google Drive: `/MyMantra/backup.json` (app-specific folder)
  - iCloud: `MyMantra` container

#### FR-7.3: Multi-Device Support
- Automatic sync when app opens
- Sync indicator in UI (syncing/synced/offline)
- Restore from cloud on new device
- Data export (JSON download)
- Data import from file

**Success Criteria:**
- Data syncs within 30 seconds of change
- No data loss during network interruptions
- Conflict resolution preserves most recent data
- User can access data on new device within 1 minute

---

### 4.8 Mantra Library (Built-in)
**Priority: P2 (Nice to Have - Phase 2.0+)**

The full curated mantra collection — content, translations, cultural context, JSON metadata, and licensing notes — is maintained in:

**[product/builtin_mantras_library.md](builtin_mantras_library.md)**

#### FR-8.1: Curated Mantra Collection

**Signature Mantra:** Yoga Sutra I.12 (abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ)
- Sanskrit (Devanagari): अभ्यासवैराग्याभ्यां तन्निरोधः॥
- English: "Through steady practice and dispassion, the mind is stilled"
- Hebrew: בהתמדה ובאי-היקשרות — הנפש שקטה
- **Why:** Embodies the app's philosophy of consistent practice without attachment

Additional traditions: Hindu (Om, Gayatri, Mahamrityunjaya), Buddhist (Om Mani Padme Hum, Heart Sutra), Sikh (Mul Mantra), universal affirmations. See reference doc for full details.

**Success Criteria:**
- 1 signature mantra at launch (Yoga Sutra I.12)
- 20+ high-quality mantras by v2.0
- Users can easily distinguish custom vs. library mantras

---

## Phase 3.0 - Gamification & Community

### 4.9 Achievements System
**Priority: P1 (Phase 3.0)**

#### FR-9.1: Achievement Definitions
| ID | Achievement | Unlock Condition | Reward |
|----|-------------|-----------------|--------|
| ACH-001 | First Steps | Complete 1 session | Badge icon |
| ACH-002 | Dedicated | 3-day streak | Badge + title |
| ACH-003 | Committed | 7-day streak | Badge + title |
| ACH-004 | Devoted | 30-day streak | Badge + title |
| ACH-005 | Unwavering | 60-day streak | Badge + title |
| ACH-006 | Transcendent | 180-day streak | Badge + title |
| ACH-007 | Enlightened | 365-day streak | Badge + title |
| ACH-008 | Novice | 1,000 total reps | Badge |
| ACH-009 | Adept | 5,000 total reps | Badge |
| ACH-010 | Master | 10,000 total reps | Badge |
| ACH-011 | Guru | 100,000 total reps | Badge + special animation |
| ACH-012 | Early Bird | Session completed before 7 AM | Badge |
| ACH-013 | Night Owl | Session completed after 10 PM | Badge |
| ACH-014 | Centurion | 100 total sessions | Badge |

#### FR-9.2: Achievement UI
- Achievement gallery screen
- Locked achievements show silhouette + progress
- Unlocked achievements show:
  - Full-color badge/icon
  - Title
  - Description
  - Unlock date
  - Rarity percentage (% of users who unlocked)
- Unlock notification:
  - Popup animation
  - Sound effect (optional)
  - Shareable image (Phase 3.0+)

#### FR-9.3: Point System (Future)
- Earn points for sessions (10 points × reps completed)
- Streak multiplier (e.g., 7-day streak = 1.5× points)
- Leaderboard (optional, privacy-respecting)

**Success Criteria:**
- 25% of users unlock 7-day streak within 3 months
- Achievement notification drives 10%+ return sessions
- Users report achievements as motivating (survey)

---

### 4.10 Shareable Rewards
**Priority: P2 (Phase 3.0)**

#### FR-10.1: Achievement Sharing
- Generate shareable image:
  - Achievement badge
  - User's stats (streak, total reps)
  - Inspirational quote
  - No personal identifiers (privacy-first)
- Share destinations:
  - Save to photos
  - Instagram Stories
  - Facebook
  - Twitter/X
  - Generic share sheet
- **Privacy:** User-initiated only, no automatic posting

#### FR-10.2: Milestone Celebrations
- Special animations for major milestones:
  - 30-day streak
  - 10,000 repetitions
  - 100 sessions
- Optional confetti/particle effects
- Haptic celebration sequence

**Success Criteria:**
- 5%+ users share at least one achievement
- Shared content drives app awareness (trackable via referral)

---

## 5. User Experience Requirements

### 5.1 User Flows

#### UF-1: First-Time User Onboarding
```
1. Launch app (first time)
   ↓
2. Welcome screen (skip option)
   ↓
3. Notification permission request
   ↓
4. Empty state: "Create your first mantra"
   ↓
5. Create mantra screen (guided)
   ↓
6. Success: View mantra card
   ↓
7. Tooltip: "Tap to start a session" or "Add a reminder"
```

**Design Notes:**
- Keep onboarding minimal (<30 seconds)
- Allow skip for experienced users
- Use progressive disclosure for advanced features

---

#### UF-2: Daily Practice Flow (From Notification)
```
1. Receive notification at scheduled time
   ↓
2. Tap notification
   ↓
3. App opens to session screen (full-screen)
   ↓
4. [Mantra text + counter displayed]
   ↓
5. User taps screen to count each repetition
   ↓
6. Haptic + visual feedback on each tap
   ↓
7. Progress bar fills toward target
   ↓
8. Reach target OR tap "Complete"
   ↓
9. Celebration animation
   ↓
10. Achievement notification (if earned)
   ↓
11. Return to home with updated streak
```

---

#### UF-3: Browse & Start Session (Manual)
```
1. Open app → Home screen (mantra list)
   ↓
2. Browse mantras OR search
   ↓
3. Tap mantra card
   ↓
4. Mantra detail view:
   - Full text
   - Reminders list
   - Recent session history
   - "Start Session" button
   ↓
5. Tap "Start Session"
   ↓
6. [Same as UF-2 from step 3]
```

---

#### UF-4: Platform Back Navigation

Every screen reachable via forward navigation must be dismissible via the platform's
standard back gesture or control. Users must never feel trapped on a screen.

```
Screen                  │ Back Destination    │ Confirmation Required?
────────────────────────┼─────────────────────┼──────────────────────
MantraDetail            │ Home                │ No
CreateMantra (new)      │ Home                │ Yes — if unsaved changes
CreateMantra (edit)     │ MantraDetail        │ Yes — if unsaved changes
Session (counter = 0)   │ MantraDetail        │ No
Session (counter > 0)   │ Stay in session     │ Yes — "Discard session?"
```

**Platform back controls:**

| Platform | Controls that must trigger back |
|----------|---------------------------------|
| iOS | Swipe-from-left-edge; back arrow in nav bar |
| Android | Hardware back button; system gesture (swipe edge) |
| macOS | Back arrow in toolbar; **Escape key**; Cmd+[ |
| Web | Browser back button |

**Known issues (v0.1):**

- **BUG-001 (macOS):** Back navigation from `MantraDetail` (and other routes outside the
  `ShellRoute`) is blocked. `context.pop()` is a no-op when the route has no predecessor
  on the Navigator stack. Fix: guard with `context.canPop()`, fall back to `context.go('/')`.
- **BUG-002 (Android):** Hardware back inside `SessionScreen` with `counter > 0` bypasses
  the "Discard session?" confirmation. Fix: add `PopScope` to `SessionScreen`.

Both bugs are **P0 blockers** for Phase 1.0 ship to production.

---

### 5.2 Screen Wireframes (High-Level)

#### Screen 1: Home (Mantra List)
```
┌─────────────────────────────────┐
│  ☰  My Mantras          [+]     │ ← Header
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │ Om Mani Padme Hum       │   │ ← Mantra Card
│  │ ॐ मणिपद्मे हूँ...       │   │
│  │ Target: 108  🔔 2       │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Gayatri Mantra          │   │
│  │ ॐ भूर्भुवः स्वः...      │   │
│  │ Target: 108  🔔 1       │   │
│  └─────────────────────────┘   │
│                                 │
│  [Search mantras...]            │
│                                 │
├─────────────────────────────────┤
│  🔥 7-day streak  |  📊 Stats   │ ← Footer
└─────────────────────────────────┘
```

#### Screen 2: Mantra Detail
```
┌─────────────────────────────────┐
│  ←  Om Mani Padme Hum      ⋮    │ ← Header (Back, Menu)
├─────────────────────────────────┤
│                                 │
│  ॐ मणिपद्मे हूँ                 │ ← Full text (scrollable)
│  Om Mani Padme Hum              │
│                                 │
│  Target: 108 repetitions        │
│                                 │
│  ┌──────────────────────────┐  │
│  │  [▶ Start Session]       │  │ ← Primary CTA
│  └──────────────────────────┘  │
│                                 │
│  ── Reminders ──                │
│  🔔 Daily at 7:00 AM  [Toggle]  │
│  🔔 Mon/Wed/Fri at 8:00 PM      │
│  [+ Add Reminder]               │
│                                 │
│  ── Recent Sessions ──          │
│  Today: 108 reps (5m 32s)       │
│  Yesterday: 54 reps (2m 18s)    │
│  [View All History]             │
│                                 │
└─────────────────────────────────┘
```

#### Screen 3: Session Screen (Active)
```
┌─────────────────────────────────┐
│  [X]                    [⏸]     │ ← Exit, Pause (small)
│                                 │
│                                 │
│       ॐ मणिपद्मे हूँ            │ ← Mantra text (large)
│                                 │
│                                 │
│            72                   │ ← Counter (huge)
│                                 │
│  ▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱  72/108      │ ← Progress bar
│                                 │
│                                 │
│       [Tap to count]            │ ← Instruction (fades)
│                                 │
│                                 │
│  ⏱ 4:35                         │ ← Timer
│  [Complete] [Reset]             │ ← Actions (small)
│                                 │
└─────────────────────────────────┘
```

#### Screen 4: Progress Dashboard
```
┌─────────────────────────────────┐
│  ←  Progress                    │
├─────────────────────────────────┤
│                                 │
│  🔥 Current Streak              │
│      7 days                     │ ← Large, prominent
│                                 │
│  ☀ M  T  W  T  F  S  S          │ ← Week calendar
│     ✓  ✓  ✓  ✓  ✓  ✓  ✓         │
│                                 │
│  ── All-Time Stats ──           │
│  🏆 Longest streak: 14 days     │
│  📝 Total sessions: 42          │
│  🙏 Total repetitions: 4,536    │
│  📅 Member since: Jan 15, 2025  │
│                                 │
│  ── Achievements (3/14) ──      │
│  🏅 First Steps                 │
│  ⭐ 7-Day Streak                │
│  💯 Centurion                   │
│  [View All Achievements]        │
│                                 │
└─────────────────────────────────┘
```

#### Screen 5: Settings
```
┌─────────────────────────────────┐
│  ←  Settings                    │
├─────────────────────────────────┤
│                                 │
│  ── Account ──                  │
│  📧 Signed in: user@gmail.com   │
│  [Sync Now]  Last: 2m ago       │
│                                 │
│  ── Notifications ──            │
│  🔔 Enable notifications  [ON]  │
│  🔊 Sound: Singing Bowl         │
│  📳 Vibration  [ON]             │
│                                 │
│  ── Appearance ──               │
│  🎨 Theme: Dark                 │
│  📏 Font size: Medium           │
│                                 │
│  ── Defaults ──                 │
│  🔢 Target repetitions: 108     │
│                                 │
│  ── About ──                    │
│  ℹ️ Version 1.0.0               │
│  📄 Privacy Policy              │
│  💖 Support Development         │
│                                 │
└─────────────────────────────────┘
```

---

### 5.3 Accessibility Requirements

#### ACC-1: Visual Accessibility
- Color contrast: WCAG AA compliant (4.5:1 minimum)
- Support for system font sizes (Dynamic Type on iOS, Large Text on Android)
- No critical information conveyed by color alone
- Focus indicators for keyboard navigation (desktop)

#### ACC-2: Screen Reader Support
- All interactive elements have labels
- Semantic HTML for web version
- Announce counter increments (optional setting)
- Haptic alternatives for visual feedback

#### ACC-3: Motor Accessibility
- Touch targets ≥44×44 dp
- No gesture-only actions (alternatives provided)
- Adjustable tap sensitivity (future)

---

## 6. Technical Requirements

### 6.1 Platform Support

| Platform | Version 1.0 | Version 2.0 | Version 3.0 |
|----------|------------|------------|------------|
| iOS | 14.0+ | 14.0+ | 14.0+ |
| Android | 8.0+ (API 26) | 8.0+ | 8.0+ |
| Web | - | Chrome 90+, Safari 14+ | All modern browsers |
| macOS | - | 11.0+ | 11.0+ |
| Windows | - | - | 10+ |

### 6.2 Technology Stack
- **Framework:** Flutter 3.16+
- **Language:** Dart 3.2+
- **Database:** Isar 3.1+ (embedded NoSQL)
- **State Management:** Riverpod 2.5+
- **Routing:** go_router 14.0+
- **Notifications:** flutter_local_notifications 17.0+
- **Cloud Storage:**
  - Google Drive API v3 (via googleapis package)
  - iCloud (via native iOS SDK bridge)

### 6.3 Performance Targets
- App launch: <2 seconds (cold start)
- Screen transitions: <300ms
- Counter tap response: <50ms
- Database queries: <100ms (typical)
- RAM usage: <200MB (typical)
- App size: <30MB (iOS/Android)

### 6.4 Offline-First Architecture
- **Principle:** App is fully functional without internet
- **Local Database:** Source of truth for all data
- **Cloud Sync:** Background synchronization when connected
- **Conflict Resolution:** Last-write-wins (timestamp-based)
- **Network Requirements:** Zero for Phase 1.0, optional for Phase 2.0+

---

## 7. Data & Privacy Requirements

### 7.1 Data Storage
- **Local:** All data stored in device's app-specific directory
- **Cloud (Phase 2.0):** User's own Google Drive or iCloud
- **No central servers:** Zero proprietary backend infrastructure

### 7.2 Privacy Policy
- **Data Collection:** None (no analytics without opt-in)
- **Third-Party Services:**
  - Google Drive API (user-consented, Phase 2.0)
  - Apple iCloud (user-consented, Phase 2.0)
- **GDPR/CCPA Compliance:**
  - Data export (JSON download)
  - Data deletion (delete app + cloud file)
  - No tracking cookies (web version)

### 7.3 Security
- **At Rest:** Device-level encryption (iOS Data Protection, Android FDE)
- **In Transit:** HTTPS only for cloud sync
- **Authentication:** OAuth2 (never store passwords)
- **Code Obfuscation:** Release builds obfuscated

---

## 8. Constraints & Assumptions

### 8.1 Technical Constraints
- Flutter SDK compatibility (3.16+)
- Minimum OS versions (iOS 14, Android 8.0)
- Local storage limits (assume ≥100MB available)
- Notification scheduling limits (OS-dependent)

### 8.2 Business Constraints
- **Budget:** $0 for infrastructure (no servers)
- **Team:** Solo developer or small team
- **Timeline:**
  - Phase 1.0: 3 months
  - Phase 2.0: +2 months
  - Phase 3.0: +2 months
- **Monetization:** None initially, potential future:
  - Pro features (unlimited voice recordings)
  - Donation/tip jar
  - No ads (ever)

### 8.3 Assumptions
- Users have smartphones with iOS 14+ or Android 8.0+
- Users willing to grant notification permissions
- Users have Google/Apple accounts for cloud sync (Phase 2.0)
- Internet available intermittently for syncing (not required for core use)
- Users understand basic spiritual/mantra concepts

---

## 9. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Low user adoption | Medium | High | Targeted marketing to meditation communities, influencer partnerships |
| Cloud sync data loss | Low | High | Implement local backup export, versioned cloud files, user education |
| OS notification limits | Medium | Medium | Document limits, provide in-app warnings, allow 100+ reminders |
| Competition from funded apps | High | Medium | Differentiate on privacy, offline-first, open-source ethos |
| Unicode rendering issues | Low | Medium | Extensive testing across languages, fallback fonts |
| User data privacy breach | Low | Critical | No central server = no breach target; educate on cloud security |

---

## 10. Out of Scope (Future Considerations)

### 10.1 Explicitly Excluded from Phase 1.0-3.0
- **Social features:** Friends, groups, leaderboards (privacy concerns)
- **Live audio guidance:** Text-to-speech during session (high complexity)
- **Wear OS / WatchOS apps:** Smartwatch versions
- **Offline speech recognition:** Automatic counting via mic
- **Video content:** Guided meditation videos
- **Paid subscription model:** All features free (donations only)
- **Ads:** Never

### 10.2 Potential Phase 4.0+ Features
- Meditation journal (text entries per session)
- Breath work integration (timer-based pranayama)
- Community-contributed mantra library
- Teacher/student mode (guided practice plans)
- Integration with health apps (Apple Health, Google Fit)

---

## 11. Release Roadmap

### Phase 1.0 - Core MVP (Months 1-3)
**Focus:** Offline-first, local-only, essential features

- Mantra management (create, edit, delete, search)
- Notification reminders (schedule, manage)
- Session experience (tap-to-count, timer, save)
- Progress tracking (streak, stats, history)
- Basic settings (theme, notifications, defaults)
- iOS + Android apps

**Milestone:** App Store + Play Store submission

---

### Phase 2.0 - Cloud & Audio (Months 4-5)
**Focus:** Cross-device sync, voice recordings

- User authentication (Google/Apple sign-in)
- Cloud synchronization (Google Drive, iCloud)
- Voice recording (record, attach to mantra)
- Audio playback during session
- macOS + Web apps (responsive design)
- Enhanced mantra library (20+ curated mantras)

**Milestone:** Multi-platform availability

---

### Phase 3.0 - Gamification (Months 6-7)
**Focus:** Motivation, engagement, community

- Achievements system (14+ badges)
- Point system with multipliers
- Shareable achievement images
- Milestone celebrations (animations, haptics)
- Expanded achievement definitions

**Milestone:** User engagement boost

---

## 12. Acceptance Criteria (Product-Level)

### Phase 1.0 MVP Acceptance
- [ ] User can complete full workflow: Create mantra → Set reminder → Receive notification → Complete session → View updated streak
- [ ] App works 100% offline (no internet required)
- [ ] Counter accuracy: 0% missed taps in 10 taps/second stress test
- [ ] Streak calculation: Correct across timezone changes and date boundaries
- [ ] **BUG-001 resolved:** Back navigation works on macOS from all routes outside ShellRoute
- [ ] **BUG-002 resolved:** Android hardware back button shows "Discard session?" when counter > 0
- [ ] Back navigation verified on all 4 platforms (iOS, Android, macOS, Web)
- [ ] App Store approval (iOS)
- [ ] Play Store approval (Android)
- [ ] Beta testing: 10+ users, 7+ days, <5 high-priority bugs
- [ ] App rating: Target 4.5+ stars
- [ ] Crash-free rate: >99.5%

### Phase 2.0 Acceptance
- [ ] Cloud sync: Data appears on second device within 1 minute
- [ ] Voice recording: Audio quality acceptable, playback seamless
- [ ] Conflict resolution: No data loss in simulated sync conflicts
- [ ] Web app: Feature parity with mobile (except voice recording)

### Phase 3.0 Acceptance
- [ ] 25% of users unlock 7-day streak achievement
- [ ] Achievement notification shown within 2 seconds of unlock
- [ ] Shareable images render correctly on social platforms

---

## 13. Appendices

### Appendix A: Glossary
- **Mantra:** Sacred word, phrase, or sound used in meditation
- **Session:** Single practice instance with start/end time
- **Streak:** Consecutive days with at least one completed session
- **Mala:** Traditional prayer beads (108 beads), hence common target of 108 repetitions
- **Offline-first:** Architecture where local data is primary, sync is secondary

### Appendix B: Reference Mantras (for Built-in Library)

See [product/builtin_mantras_library.md](builtin_mantras_library.md) for the full curated list with texts, transliterations, translations, and cultural context.

### Appendix C: Notification Sound Library
- Singing Bowl (default)
- Temple Bell
- Chime
- Silent (vibration only)
- System Default

---

**Document Approval**

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | [TBD] | | |
| Engineering Lead | [TBD] | | |
| Design Lead | [TBD] | | |
| Stakeholder | [TBD] | | |

---

**Change Log**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-XX | Product Team | Initial draft |
| 2.0 | 2025-11-24 | Product Team | Updated with cloud sync, gamification, phased approach |
| 2.1 | 2026-03-07 | Engineering | Added UF-4 (back navigation), BUG-001/002, back-nav acceptance criteria |
