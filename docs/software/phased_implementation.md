# Phased Implementation Plan
## MyMantra - Spiritual Practice Application

**Version:** 0.1
**Date:** November 2025
**Status:** Draft
**Application Name:** MyMantra

---

## Document Overview

This document outlines the phased development approach for **MyMantra**, breaking down the project into three major releases. Each phase includes detailed specifications, programming tasks, testing requirements, and deployment steps.

---

## Project Phases Overview

| Phase | Timeline | Key Deliverables | Platforms |
|-------|----------|------------------|-----------|
| **Phase 1.0 - MVP** | Months 1-3 | Core offline features | iOS |
| **Phase 2.0 - Cloud & Audio** | Months 4-5 | Cloud sync, voice recording | iOS, Android, Web |
| **Phase 3.0 - Gamification** | Months 6-7 | Achievements, sharing | All platforms |

---

# Phase 1.0 - Minimum Viable Product (MVP)

**Duration:** 3 months
**Goal:** Deliver core mantra practice experience with offline-first functionality
**Platforms:** iOS 14+, Android 8.0+

---

## Phase 1.0: Specification (Week 1-2)

### 1.1 Requirements Finalization
- [x] Product Requirements Document (PRD) approved
- [x] Software Requirements Specification (SRS) approved
- [x] Software Architecture Document (SAD) approved
- [ ] UI/UX wireframes completed (all 5 core screens)
- [ ] Database schema finalized (Isar collections)
- [ ] API contracts defined (repository interfaces)

### 1.2 Design Deliverables
**Week 1:**
- [ ] Design system created:
  - Color palette (light/dark themes)
  - Typography scale
  - Component library (buttons, cards, inputs)
  - Icon set
- [ ] High-fidelity mockups:
  - Home screen (Mantra list)
  - Mantra detail screen
  - Session screen (active counting)
  - Progress dashboard
  - Settings screen

**Week 2:**
- [ ] Prototype created in Figma/Adobe XD
- [ ] User flow diagrams:
  - First-time onboarding
  - Create mantra → Set reminder → Complete session
  - View progress and stats
- [ ] Accessibility audit (color contrast, font sizes)
- [ ] Design review with stakeholders

### 1.3 Technical Specification
- [ ] Project structure defined (feature-based modules)
- [ ] Dependency list compiled:
  - Flutter SDK 3.16+
  - Riverpod 2.5+
  - Isar 3.1+
  - go_router 14.0+
  - flutter_local_notifications 17.0+
- [ ] Development environment setup guide
- [ ] Git branching strategy defined (Git Flow)
- [ ] Code style guide (Dart linter rules)

**Deliverable:** Specification document approved, ready for development

---

## Phase 1.0: Programming (Week 3-10)

### Sprint 1: Project Setup & Core Infrastructure (Week 3-4)

#### Week 3: Project Initialization
**Tasks:**
1. [ ] Create Flutter project: `flutter create mymantra`
2. [ ] Configure project structure:
   ```
   lib/
   ├── app/
   ├── core/
   ├── features/
   │   ├── mantras/
   │   ├── session/
   │   ├── reminders/
   │   ├── progress/
   │   └── settings/
   └── shared/
   ```
3. [ ] Setup Riverpod providers root
4. [ ] Configure go_router for navigation
5. [ ] Setup Isar database:
   - Install isar dependencies
   - Create base database service
   - Configure code generation
6. [ ] Implement theme system (light/dark)
7. [ ] Create reusable UI components:
   - AppButton
   - AppTextField
   - AppCard
   - LoadingIndicator

**Deliverable:** Buildable app with navigation and theming

#### Week 4: Domain Layer (Entities & Use Cases)
**Tasks:**
1. [ ] Create domain entities:
   - `Mantra` (mantra.dart)
   - `Reminder` (reminder.dart)
   - `Session` (session.dart)
   - `Progress` (progress.dart)
2. [ ] Define repository interfaces:
   - `MantraRepository`
   - `ReminderRepository`
   - `SessionRepository`
   - `ProgressRepository`
3. [ ] Implement use cases:
   - `CreateMantra`
   - `UpdateMantra`
   - `DeleteMantra`
   - `GetAllMantras`
   - `StartSession`
   - `CompleteSession`
   - `CalculateStreak`
4. [ ] Setup error handling (Failure classes, Either type)

**Deliverable:** Complete domain layer, testable business logic

---

### Sprint 2: Data Layer (Week 5-6)

#### Week 5: Database Implementation
**Tasks:**
1. [ ] Create Isar models:
   - `MantraModel` with annotations
   - `ReminderModel`
   - `SessionModel`
   - `ProgressModel`
2. [ ] Add indexes for performance:
   - uuid indexes on all models
   - timestamp index on SessionModel
   - mantraUuid indexes for relationships
3. [ ] Run code generation: `flutter pub run build_runner build`
4. [ ] Implement data sources:
   - `LocalMantraDataSource`
   - `LocalReminderDataSource`
   - `LocalSessionDataSource`
   - `LocalProgressDataSource`
5. [ ] Create mappers (Model ↔ Entity)
6. [ ] Write data layer unit tests

**Deliverable:** Working database with CRUD operations

#### Week 6: Repository Implementation
**Tasks:**
1. [ ] Implement repositories:
   - `MantraRepositoryImpl`
   - `ReminderRepositoryImpl`
   - `SessionRepositoryImpl`
   - `ProgressRepositoryImpl`
2. [ ] Add stream watchers for reactive updates
3. [ ] Implement transaction handling for complex operations
4. [ ] Test repository error handling
5. [ ] Integration tests for database operations

**Deliverable:** Fully functional data layer with tests

---

### Sprint 3: Mantra Management Feature (Week 7)

**Tasks:**
1. [ ] Create Mantra List Screen:
   - Riverpod provider for mantra list
   - ListView.builder with lazy loading
   - Search functionality
   - Empty state UI
   - Pull-to-refresh
2. [ ] Create Mantra Card widget:
   - Display title, text preview (50 chars)
   - Show target repetitions
   - Reminder count indicator
3. [ ] Create Mantra Detail Screen:
   - Full text display
   - Edit button
   - Delete button (with confirmation dialog)
   - Reminders list
   - Recent sessions list
   - "Start Session" button
4. [ ] Create/Edit Mantra Form:
   - Title input validation (1-100 chars)
   - Text input (multi-line, Unicode support)
   - Target repetitions picker
   - Save/Cancel actions
5. [ ] Implement navigation between screens
6. [ ] Widget tests for all components

**Deliverable:** Complete mantra management UI

---

### Sprint 4: Notification & Reminders (Week 8)

**Tasks:**
1. [ ] Setup flutter_local_notifications:
   - Android: Configure channels, icons
   - iOS: Request permissions, configure sounds
2. [ ] Create `NotificationService`:
   - `scheduleNotification()`
   - `cancelNotification()`
   - `onNotificationTap` stream
3. [ ] Implement `ScheduleReminder` use case:
   - Calculate next occurrence for each day
   - Generate unique notification IDs
   - Handle timezone conversions
4. [ ] Create Reminder UI:
   - Time picker (24-hour format)
   - Days of week selector
   - Sound selection dropdown
   - Enable/disable toggle
5. [ ] Add reminder to Mantra Detail screen:
   - List existing reminders
   - Add/Edit/Delete actions
   - Visual indicators
6. [ ] Deep link handling:
   - Parse notification payload
   - Navigate to Session screen with mantra ID
7. [ ] Test notification delivery on both platforms

**Deliverable:** Working notification system

---

### Sprint 5: Session Experience (Week 9)

**Tasks:**
1. [ ] Create Session Screen UI:
   - Full-screen layout
   - Mantra text display (large, readable font)
   - Counter display (huge, prominent)
   - Progress bar
   - Timer display
   - Pause/Resume buttons
   - Complete/Cancel buttons
2. [ ] Implement `SessionNotifier` (Riverpod StateNotifier):
   - State: counter, isActive, isPaused, duration
   - `incrementCounter()` method
   - `pauseSession()` / `resumeSession()`
   - `completeSession()` / `cancelSession()`
3. [ ] Add haptic feedback on tap:
   - Setup `HapticService`
   - Trigger medium impact on each count
4. [ ] Implement tap-to-count gesture:
   - GestureDetector on full screen
   - Debounce to prevent double-counts (100ms)
   - Visual feedback (ripple animation)
5. [ ] Add session timer:
   - Track active duration (exclude paused time)
   - Update UI every second
6. [ ] Implement screen wake lock (keep screen on during session)
7. [ ] Auto-complete when target reached:
   - Show celebration animation
   - Save session automatically
8. [ ] Test rapid tapping (stress test: 10 taps/second)

**Deliverable:** Fully functional session screen

---

### Sprint 6: Progress & Settings (Week 10)

#### Progress Dashboard (Days 1-3)
**Tasks:**
1. [ ] Create `CalculateStreak` use case:
   - Implement streak algorithm (today/yesterday/older logic)
   - Update on each session completion
   - Handle timezone edge cases
2. [ ] Create Progress Screen UI:
   - Current streak (large, prominent)
   - 7-day calendar visualization
   - Longest streak stat
   - Total sessions stat
   - Total repetitions stat
   - Last session date
3. [ ] Add Session History list:
   - Grouped by date
   - Show mantra name, reps, duration
   - Pagination (50 at a time)
4. [ ] Create progress providers (Riverpod)

#### Settings (Days 4-5)
**Tasks:**
1. [ ] Create Settings Screen:
   - Theme selection (Light/Dark/System)
   - Notification master toggle
   - Default target repetitions
   - About section (version, license)
2. [ ] Implement settings persistence (shared_preferences)
3. [ ] Add theme switching (instant apply, no restart)
4. [ ] Notification settings:
   - Permission request flow
   - Sound selection
   - Vibration toggle

**Deliverable:** Complete MVP feature set

---

## Phase 1.0: Testing (Week 11)

### 11.1 Unit Testing (Days 1-2)
**Coverage Target:** 70%+

**Tasks:**
1. [ ] Test all use cases:
   - CreateMantra (validation, success, failure)
   - CompleteSession (session creation, progress update)
   - CalculateStreak (all scenarios: today, yesterday, older)
2. [ ] Test repositories (with mocked data sources)
3. [ ] Test streak calculations with edge cases
4. [ ] Test mapper functions (Entity ↔ Model)
5. [ ] Run coverage report: `flutter test --coverage`

### 11.2 Widget Testing (Days 3-4)
**Tasks:**
1. [ ] Test MantraCard rendering
2. [ ] Test Session screen counter interactions
3. [ ] Test form validations
4. [ ] Test navigation flows
5. [ ] Test theme switching
6. [ ] Snapshot tests for UI consistency

### 11.3 Integration Testing (Day 5)
**Tasks:**
1. [ ] Test complete user flows:
   - Create mantra → Start session → Complete → View streak
   - Set reminder → Receive notification → Start session
2. [ ] Test database persistence after app restart
3. [ ] Test offline functionality (disable network)
4. [ ] Run on both iOS and Android simulators

### 11.4 Manual Testing (Week 12 - Days 1-3)
**Test Scenarios:**
1. [ ] First-time user onboarding
2. [ ] Create 10+ mantras (test list performance)
3. [ ] Complete session with rapid taps (stress test)
4. [ ] Set reminders for all days, verify notifications
5. [ ] Test dark/light theme consistency
6. [ ] Test on physical devices (iPhone, Android phone)
7. [ ] Accessibility testing:
   - VoiceOver (iOS)
   - TalkBack (Android)
   - Large text sizes
8. [ ] Edge cases:
   - Empty states (no mantras, no history)
   - Long mantra text (5000 chars)
   - Unicode rendering (Sanskrit, Hebrew, Arabic)

### 11.5 Bug Fixes (Week 12 - Days 4-5)
**Tasks:**
1. [ ] Triage bugs (Critical, High, Medium, Low)
2. [ ] Fix all Critical and High priority bugs
3. [ ] Regression testing after fixes
4. [ ] Update documentation if needed

**Deliverable:** Stable, tested MVP ready for deployment

---

## Phase 1.0: Deployment (Week 12)

### 12.1 iOS Deployment (Days 1-2)

**Pre-requisites:**
- [ ] Apple Developer Account ($99/year)
- [ ] App ID registered
- [ ] App icons prepared (all sizes)
- [ ] Screenshots prepared (all device sizes)

**Tasks:**
1. [ ] Configure app signing:
   - Create production certificates
   - Create provisioning profiles
   - Configure in Xcode
2. [ ] Update Info.plist:
   - Permission descriptions (notifications)
   - Version number (1.0.0)
   - Bundle ID
3. [ ] Build release: `flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols`
4. [ ] Archive in Xcode
5. [ ] Upload to App Store Connect
6. [ ] Create App Store listing:
   - Title: "MyMantra - Practice & Reminders"
   - Description (compelling, SEO-optimized)
   - Keywords
   - Screenshots (5-10 per device size)
   - Preview video (optional)
   - Privacy policy URL
   - Support URL
7. [ ] Submit for review
8. [ ] Respond to review feedback if needed

**Timeline:** 1-3 days for Apple review

### 12.2 Android Deployment (Days 3-4)

**Pre-requisites:**
- [ ] Google Play Console account ($25 one-time)
- [ ] Signing key generated
- [ ] App icons prepared
- [ ] Screenshots prepared

**Tasks:**
1. [ ] Configure signing:
   - Generate keystore: `keytool -genkey -v -keystore mymantra-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mymantra`
   - Update `android/key.properties`
   - Configure `android/app/build.gradle`
2. [ ] Update AndroidManifest.xml:
   - Permissions (notifications, vibration)
   - Version code (1)
   - Version name (1.0.0)
3. [ ] Build release: `flutter build appbundle --release --obfuscate --split-debug-info=build/android/symbols`
4. [ ] Test AAB on internal testing track
5. [ ] Create Play Store listing:
   - App title
   - Short description (80 chars)
   - Full description (4000 chars)
   - Icon (512x512)
   - Feature graphic (1024x500)
   - Screenshots (2-8 per device type)
   - Privacy policy URL
6. [ ] Complete Content Rating questionnaire
7. [ ] Set pricing (free)
8. [ ] Submit for review

**Timeline:** 1-2 days for Google review

### 12.3 Post-Deployment (Day 5)

**Tasks:**
1. [ ] Monitor crash reports (Firebase Crashlytics)
2. [ ] Monitor app store reviews
3. [ ] Respond to user feedback
4. [ ] Prepare hotfix process for critical bugs
5. [ ] Document known issues for next phase
6. [ ] Celebrate MVP launch! 🎉

**Deliverable:** Phase 1.0 live on App Store & Play Store

---

# Phase 2.0 - Cloud Sync & Audio Features

**Duration:** 2 months (Months 4-5)
**Goal:** Enable cross-device sync and voice recording capabilities
**Platforms:** iOS, Android, + macOS, Web

---

## Phase 2.0: Specification (Week 13)

### 2.1 Cloud Sync Specification
**Tasks:**
1. [ ] Define cloud storage strategy:
   - Google Drive: App-specific folder, JSON file
   - iCloud: CloudKit container, document storage
2. [ ] Design sync protocol:
   - Data format (JSON schema)
   - Conflict resolution (last-write-wins)
   - Merge algorithm
3. [ ] OAuth integration design:
   - Google Sign-In flow
   - Apple Sign-In flow
4. [ ] Error handling scenarios:
   - Network failures
   - Authentication errors
   - Quota limits

### 2.2 Audio Feature Specification
**Tasks:**
1. [ ] Define audio requirements:
   - Recording format: AAC, 64kbps, 44.1kHz
   - Max duration: 5 minutes
   - Storage location: app documents directory
2. [ ] Design recording UI:
   - Waveform visualization
   - Timer display
   - Record/Stop controls
   - Playback preview
3. [ ] Session audio mode design:
   - Looping playback
   - Pause/resume controls
   - Volume adjustment
4. [ ] Free vs. Premium tier:
   - Free: 3 recordings max
   - Premium: Unlimited (future IAP)

### 2.3 Platform Expansion Specification
**Tasks:**
1. [ ] macOS app requirements:
   - Menu bar integration
   - Keyboard shortcuts
   - Native notifications
2. [ ] Web app requirements:
   - Responsive design (desktop/tablet)
   - PWA capabilities (offline, install prompt)
   - Browser compatibility (Chrome 90+, Safari 14+)
3. [ ] Update design system for desktop:
   - Larger breakpoints
   - Mouse hover states
   - Context menus

**Deliverable:** Detailed Phase 2.0 spec approved

---

## Phase 2.0: Programming (Week 14-19)

### Sprint 7: Cloud Authentication (Week 14)

**Google Sign-In (Days 1-3):**
1. [ ] Add dependencies:
   - `google_sign_in`
   - `googleapis`
   - `extension_google_sign_in_as_googleapis_auth`
2. [ ] Setup Google Cloud project:
   - Create OAuth 2.0 credentials (Android, iOS, Web)
   - Enable Google Drive API
3. [ ] Implement `GoogleAuthService`:
   - `signIn()` method
   - `signOut()` method
   - `isAuthenticated` getter
   - Token refresh logic
4. [ ] Create Sign-In UI screen
5. [ ] Test OAuth flow on all platforms

**Apple Sign-In (Days 4-5):**
1. [ ] Add `sign_in_with_apple` dependency
2. [ ] Configure Apple Developer account:
   - Enable Sign In with Apple capability
   - Configure service ID
3. [ ] Implement `AppleAuthService`
4. [ ] Add "Sign in with Apple" button (required for iOS)
5. [ ] Test on iOS/macOS

**Deliverable:** Working authentication for both providers

---

### Sprint 8: Cloud Sync Implementation (Week 15-16)

**Week 15: Google Drive Sync**
1. [ ] Create `GoogleDriveSync` service:
   - `uploadBackup()` - Upload JSON to Drive
   - `downloadBackup()` - Download JSON from Drive
   - `getLastSyncTime()` - Check file metadata
2. [ ] Implement app folder management:
   - Create "MyMantra" folder if not exists
   - Check for existing backup file
3. [ ] Handle API errors:
   - Network timeouts
   - Quota exceeded
   - Permission denied
4. [ ] Add progress indicators for upload/download
5. [ ] Test with large data sets (1000+ sessions)

**Week 16: iCloud Sync + Merge Logic**
1. [ ] Create iOS native bridge (MethodChannel):
   - Swift code for CloudKit operations
   - Upload to iCloud Drive
   - Download from iCloud Drive
2. [ ] Implement `ICloudSync` service (calls native channel)
3. [ ] Create `SyncData` use case:
   - Gather local data
   - Download cloud data
   - Merge with conflict resolution:
     - Mantras: Last-write-wins (compare `updatedAt`)
     - Sessions: Append unique (no conflicts)
     - Progress: Take maximum values
   - Update local DB
   - Upload merged data
4. [ ] Implement `AutoSyncService`:
   - Timer-based sync (every 15 minutes)
   - Connectivity check
   - Pause when offline
5. [ ] Add sync status UI:
   - Indicator in settings (Syncing/Synced/Offline/Error)
   - Last sync time display
   - Manual sync button
6. [ ] Test multi-device scenarios:
   - Create mantra on Device A → Appears on Device B
   - Offline edits on both devices → Merge correctly

**Deliverable:** Working cloud sync across all platforms

---

### Sprint 9: Audio Recording (Week 17)

**Tasks:**
1. [ ] Add dependencies:
   - `record` (for recording)
   - `audioplayers` (for playback)
   - `path_provider` (for file storage)
2. [ ] Create `AudioService`:
   - `requestMicrophonePermission()`
   - `startRecording()` - Save to `recordings/[uuid].aac`
   - `stopRecording()` - Returns file path
   - `playAudio(path)` - Play recording
   - `pauseAudio()` / `stopAudio()`
   - `getAudioDuration(path)`
3. [ ] Create Recording UI Screen:
   - Waveform animation (using `audio_waveforms` package)
   - Timer (00:00 / 05:00)
   - Record button (tap to start, release to stop)
   - Play/Pause preview buttons
   - Save/Cancel actions
4. [ ] Integrate with Mantra:
   - Add "Record Voice" option in Mantra settings
   - Update `MantraModel` with `voiceRecordingPath`
   - Show microphone icon on mantras with recordings
5. [ ] Add recording management screen (Settings):
   - List all recordings
   - Show duration, file size
   - Preview playback
   - Delete recording (confirmation dialog)
6. [ ] Implement recording limit (Free tier: 3 max):
   - Check count before allowing new recording
   - Show upgrade prompt if limit reached
7. [ ] Test audio quality on devices

**Deliverable:** Working voice recording feature

---

### Sprint 10: Audio Playback in Session (Week 18)

**Tasks:**
1. [ ] Update `SessionNotifier` for audio mode:
   - Check if mantra has recording on session start
   - If yes: `audioService.playAudio()` in loop
   - Listen to playback position for loop restart
2. [ ] Add audio controls to Session screen:
   - Play/Pause button (overlay)
   - Volume slider
   - "Audio Mode" toggle (optional: count manually or auto-count)
3. [ ] Implement background audio:
   - Configure audio session (iOS: AVAudioSession)
   - Handle interruptions (phone call, alarm)
   - Show notification with playback controls
4. [ ] Add seamless looping:
   - Detect when audio ends
   - Restart immediately (no gap)
5. [ ] Sync counter with audio (optional mode):
   - Detect beats or recitations (advanced, v3.0+)
   - For now: Manual counting while audio plays
6. [ ] Test battery usage during long sessions

**Deliverable:** Audio playback integrated into sessions

---

### Sprint 11: macOS & Web Apps (Week 19)

**macOS App (Days 1-2):**
1. [ ] Enable macOS platform: `flutter create --platforms=macos .`
2. [ ] Update macos/Runner/Info.plist:
   - Microphone permission description
   - Network client entitlement
3. [ ] Test all features on macOS:
   - Notifications (NSUserNotification)
   - iCloud sync
   - Audio recording/playback
4. [ ] Add macOS-specific UI:
   - Menu bar icon (optional)
   - Keyboard shortcuts (Cmd+N for new mantra)
5. [ ] Build and test: `flutter build macos --release`

**Web App (Days 3-5):**
1. [ ] Enable web platform: `flutter create --platforms=web .`
2. [ ] Configure web app manifest (PWA):
   - icons, name, theme color
   - Service worker for offline caching
3. [ ] Handle web limitations:
   - Notifications: Web Push API (limited)
   - Audio recording: MediaRecorder API
   - No iCloud sync (use Google Drive only)
4. [ ] Responsive design adjustments:
   - Desktop breakpoints (1024px+)
   - Mouse hover states
   - Scrollbars
5. [ ] Deploy to Firebase Hosting or Netlify:
   - Build: `flutter build web --release`
   - Deploy with CI/CD
6. [ ] Test on browsers:
   - Chrome 90+
   - Safari 14+
   - Firefox 88+
   - Edge 91+

**Deliverable:** macOS and Web apps functional

---

## Phase 2.0: Testing (Week 20)

### 20.1 Cloud Sync Testing (Days 1-2)
**Scenarios:**
1. [ ] Create data on Device A → Verify appears on Device B
2. [ ] Offline edits on both devices → Merge correctly
3. [ ] Delete mantra on Device A → Syncs to Device B
4. [ ] Large data sync (1000+ sessions) completes in <60s
5. [ ] Network interruption mid-sync → Recovers gracefully
6. [ ] Sign out → Data remains local, no sync
7. [ ] Sign in on new device → All data downloads

### 20.2 Audio Testing (Days 3-4)
**Scenarios:**
1. [ ] Record 5-minute audio → File size <5MB
2. [ ] Playback in session → Loops seamlessly
3. [ ] Pause/resume playback → No audio glitches
4. [ ] Background audio → Continues during screen lock
5. [ ] Phone call interruption → Audio pauses, resumes after
6. [ ] Delete recording → File removed from storage
7. [ ] Free tier limit → Cannot record 4th mantra

### 20.3 Platform-Specific Testing (Day 5)
**macOS:**
- [ ] Notifications appear in Notification Center
- [ ] iCloud sync works
- [ ] Keyboard shortcuts functional

**Web:**
- [ ] PWA install prompt works
- [ ] Offline mode (service worker)
- [ ] Google Drive sync works
- [ ] Responsive on desktop/tablet

### 20.4 Regression Testing (Week 21 - Days 1-2)
- [ ] All Phase 1.0 features still work
- [ ] No performance regressions
- [ ] Database migrations successful (if schema changed)

**Deliverable:** Phase 2.0 tested and stable

---

## Phase 2.0: Deployment (Week 21)

### 21.1 App Updates (Days 3-4)
**iOS (v2.0.0):**
1. [ ] Update version in Xcode (2.0.0, build 2)
2. [ ] Add "What's New" in App Store Connect:
   - Cloud sync across devices
   - Voice recording for mantras
   - macOS app now available
3. [ ] Submit update for review

**Android (v2.0.0):**
1. [ ] Update versionCode (2), versionName (2.0.0)
2. [ ] Update Play Store listing (new features)
3. [ ] Submit update

**macOS (v2.0.0 - New):**
1. [ ] Create macOS App Store listing
2. [ ] Prepare macOS-specific screenshots
3. [ ] Submit for review

**Web (v2.0.0):**
1. [ ] Deploy to hosting: `firebase deploy` or `netlify deploy`
2. [ ] Configure custom domain (optional)
3. [ ] Add to app store listing as "Also available on web"

### 21.2 Post-Deployment (Day 5)
- [ ] Monitor cloud API usage (Google Drive API quotas)
- [ ] Monitor sync error rates
- [ ] Track audio storage usage
- [ ] User feedback collection
- [ ] Hotfix plan ready

**Deliverable:** Phase 2.0 live on all platforms

---

# Phase 3.0 - Gamification & Engagement

**Duration:** 2 months (Months 6-7)
**Goal:** Add achievements, points, and shareable content
**Platforms:** All (iOS, Android, macOS, Web)

---

## Phase 3.0: Specification (Week 22)

### 3.1 Achievement System Design
**Tasks:**
1. [ ] Define 14+ achievements:
   - Session-based (First Steps)
   - Streak-based (3, 7, 30, 60, 180, 365 days)
   - Volume-based (1K, 5K, 10K, 100K reps)
   - Time-based (Early Bird)
   - Milestone-based (Centurion - 100 sessions)
2. [ ] Design achievement badges (icons):
   - Commission or design 14 vector icons
   - Export in multiple sizes (SVG, PNG @2x, @3x)
3. [ ] Design achievement notification:
   - Popup animation (confetti, badge reveal)
   - Sound effect
   - Dismiss behavior
4. [ ] Design achievement gallery screen:
   - Grid layout
   - Locked (grayscale) vs. Unlocked (color)
   - Progress indicators
   - Filter/sort options

### 3.2 Shareable Content Design
**Tasks:**
1. [ ] Design achievement card templates (Figma):
   - Instagram Stories (1080x1920)
   - Square (1080x1080)
   - Landscape (1200x630)
2. [ ] Choose design elements:
   - Branded background
   - Badge placement
   - Stats overlay (e.g., "7-Day Streak Achieved!")
   - App watermark
3. [ ] Privacy check: No personal identifiers

### 3.3 Points System (Optional)
**Tasks:**
1. [ ] Define point values:
   - 10 points per repetition
   - Streak multipliers (7-day = 1.5×, 30-day = 2×)
   - Bonus for completing target
2. [ ] Design points display:
   - Total points in profile
   - Points earned per session
   - Leaderboard (future, privacy-respecting)

**Deliverable:** Phase 3.0 spec and designs approved

---

## Phase 3.0: Programming (Week 23-27)

### Sprint 12: Achievement System (Week 23-24)

**Week 23: Achievement Logic**
1. [ ] Create `Achievement` entity:
   ```dart
   class Achievement {
     String id;          // "ACH-001"
     String title;       // "First Steps"
     String description; // "Complete your first session"
     String iconPath;    // "assets/icons/first_steps.svg"
     AchievementType type;
     dynamic condition;  // e.g., sessions >= 1
     int rarity;         // 1-5 (how rare it is)
   }
   ```
2. [ ] Add `AchievementModel` to Isar:
   - Fields: id, unlockedAt (DateTime?)
   - Index on id
3. [ ] Create `CheckAchievements` use case:
   - Runs after session completion
   - Checks all achievement conditions
   - Returns newly unlocked achievements
4. [ ] Implement achievement conditions:
   - `SessionCountCondition` (e.g., >= 1, >= 100)
   - `StreakCondition` (e.g., currentStreak >= 7)
   - `RepetitionCondition` (e.g., totalReps >= 1000)
   - `TimeOfDayCondition` (e.g., hour < 7 for Early Bird)
5. [ ] Update `CompleteSession` use case:
   - Call `CheckAchievements` after saving session
   - Store newly unlocked achievements
   - Trigger notification

**Week 24: Achievement UI**
1. [ ] Create achievement icons (commission artist or design):
   - All 14+ icons in SVG format
   - Add to assets folder
2. [ ] Create Achievement Notification widget:
   - Animated popup (slide from top or center scale)
   - Badge icon + title
   - Sound effect: `AudioCache().play('achievement_unlock.mp3')`
   - Auto-dismiss after 3 seconds or on tap
3. [ ] Create Achievement Gallery screen:
   - Grid layout (2 columns on mobile, 4 on tablet/desktop)
   - `AchievementCard` widget:
     - Locked: Grayscale icon, "???" title, progress bar
     - Unlocked: Color icon, title, unlock date
   - Filter: All / Unlocked / Locked
   - Sort: Rarity / Date unlocked
4. [ ] Add achievements to Progress screen:
   - Show recently unlocked (top 3)
   - "View All" button
5. [ ] Test achievement unlocking flow end-to-end

**Deliverable:** Full achievement system

---

### Sprint 13: Points System (Week 25)

**Tasks:**
1. [ ] Add points to `ProgressModel`:
   - `totalPoints` field
   - `pointsHistory` (optional: list of daily totals)
2. [ ] Implement point calculation:
   - Base: 10 points × repetitions
   - Streak bonus:
     - 3-day: 1.2× multiplier
     - 7-day: 1.5×
     - 30-day: 2.0×
     - 60-day: 2.5×
     - 365-day: 5.0×
   - Target bonus: +50 points if target reached
3. [ ] Update `CompleteSession` use case:
   - Calculate points
   - Add to totalPoints
   - Store in session record (pointsEarned field)
4. [ ] Add points display to Session Summary:
   - "You earned 1,620 points!"
   - Show calculation breakdown (optional)
5. [ ] Add total points to Progress screen:
   - Large number display
   - Next milestone progress bar
6. [ ] Add points earned to Session History:
   - Show per session
   - Daily totals

**Deliverable:** Points system integrated

---

### Sprint 14: Shareable Content (Week 26)

**Tasks:**
1. [ ] Add `flutter_svg` for vector rendering
2. [ ] Add `image` package for image generation
3. [ ] Create `ShareableImageGenerator` service:
   - `generateAchievementImage(achievement, userStats)`:
     - Render template (Canvas or predefined image)
     - Overlay badge icon (SVG → PNG)
     - Add text: Title, stats (e.g., "7-Day Streak!")
     - Add app watermark/branding
     - Return as PNG bytes
4. [ ] Create shareable templates:
   - Instagram Story template (1080x1920)
   - Square template (1080x1080)
   - Use brand colors, gradient backgrounds
5. [ ] Add "Share" button to Achievement Detail:
   - Tap → Generate image
   - Show preview
   - Open native share sheet (share_plus package)
   - Destinations: Instagram, Facebook, Twitter, Save to Photos
6. [ ] Privacy validation:
   - No username or email
   - Only stats (streak count, total reps, etc.)
   - Clear branding (app name/logo)
7. [ ] Test sharing on all platforms:
   - iOS: UIActivityViewController
   - Android: Intent.ACTION_SEND
   - Web: Web Share API (if supported) or download button
   - macOS: NSSharingService

**Deliverable:** Shareable achievement images

---

### Sprint 15: Polish & Enhancements (Week 27)

**Tasks:**
1. [ ] Add milestone celebration animations:
   - Confetti particle effect (lottie_flutter)
   - Trigger for major achievements (30-day, 10K reps)
   - Haptic pattern (rhythm: light-medium-heavy)
2. [ ] Add achievement progress indicators:
   - Show "50% to Committed Streak" on Progress screen
   - Countdown: "3 more days to unlock!"
3. [ ] Add rarity statistics:
   - Calculate % of users who unlocked each achievement
   - Display on achievement card ("Unlocked by 12% of users")
   - Update weekly (cloud function or manual)
4. [ ] Add achievement hints:
   - Locked achievements show subtle hint
   - "Complete sessions for 7 consecutive days"
5. [ ] Optimize achievement check performance:
   - Cache achievement states
   - Only check relevant conditions (don't check all 14 every time)
6. [ ] Add achievement sounds:
   - Different sounds for different rarities
   - Common: Simple chime
   - Rare: Triumphant fanfare
7. [ ] Add "Recent Achievements" widget on Home screen

**Deliverable:** Polished gamification experience

---

## Phase 3.0: Testing (Week 28)

### 28.1 Achievement Testing (Days 1-2)
**Scenarios:**
1. [ ] Complete first session → "First Steps" unlocked
2. [ ] Reach 3-day streak → "Dedicated" unlocked
3. [ ] Reach 7-day streak → "Committed" unlocked
4. [ ] Complete 1000 reps total → "Novice" unlocked
5. [ ] Session before 7 AM → "Early Bird" unlocked
6. [ ] 100th session → "Centurion" unlocked
7. [ ] Multiple achievements in one session → All notifications show
8. [ ] Achievement already unlocked → No duplicate

### 28.2 Points Testing (Day 3)
**Scenarios:**
1. [ ] Complete 108 reps, no streak → 1,080 points
2. [ ] Complete 108 reps, 7-day streak → 1,620 points (1.5× multiplier)
3. [ ] Verify points persist after app restart
4. [ ] Verify points display correctly on all screens

### 28.3 Sharing Testing (Day 4)
**Scenarios:**
1. [ ] Generate achievement image → Renders correctly
2. [ ] Share to Instagram Stories → Image posts successfully
3. [ ] Share to Photos → Saves to camera roll
4. [ ] Web: Share or download → Works on all browsers

### 28.4 Regression Testing (Day 5)
- [ ] All Phase 1.0 and 2.0 features still work
- [ ] Cloud sync includes achievements and points
- [ ] No performance regressions

**Deliverable:** Phase 3.0 stable and tested

---

## Phase 3.0: Deployment (Week 29)

### 29.1 App Updates (Days 1-3)
**All Platforms (v3.0.0):**
1. [ ] Update version numbers
2. [ ] Update App Store / Play Store listings:
   - "What's New":
     - Unlock 14+ achievements
     - Earn points for your practice
     - Share your milestones
   - New screenshots (show achievement gallery)
3. [ ] Submit for review

### 29.2 Marketing Push (Days 4-5)
**Tasks:**
1. [ ] Blog post: "Introducing Achievements" (if blog exists)
2. [ ] Social media posts:
   - Twitter/X: Feature announcement
   - Instagram: Video demo of achievement unlock
   - Reddit: Post in r/meditation, r/Buddhism, etc.
3. [ ] Email existing users (if list exists):
   - "New gamification features"
   - Encourage update
4. [ ] App Store Optimization (ASO):
   - Update keywords (add "achievement", "streak", "habit tracker")
   - A/B test new icon or screenshots
5. [ ] Request reviews:
   - In-app review prompt (after unlocking achievement)
   - Target satisfied users (7-day streak or higher)

### 29.3 Post-Launch Monitoring (Ongoing)
**Metrics to Track:**
1. [ ] Achievement unlock rates (are they too easy/hard?)
2. [ ] Share feature usage (% of users who share)
3. [ ] User retention (does gamification help?)
4. [ ] App store ratings (target: maintain 4.5+)
5. [ ] User feedback (feature requests, bugs)

**Deliverable:** Phase 3.0 live, marketing in progress

---

# Post-Phase 3.0: Maintenance & Future Planning

## Ongoing Tasks (Month 8+)

### Maintenance
1. **Monthly:**
   - [ ] Review crash reports, fix critical bugs
   - [ ] Update dependencies for security patches
   - [ ] Monitor cloud API costs (Google Drive quotas)
   - [ ] Respond to app store reviews

2. **Quarterly:**
   - [ ] Performance audit (app size, load times)
   - [ ] Accessibility audit (new OS features)
   - [ ] User survey for feature requests
   - [ ] Competitive analysis

### Future Features (Phase 4.0+)
**Potential Roadmap:**
1. **Windows & Linux Apps** (Month 9-10)
   - Complete cross-platform coverage
   - Desktop-specific features (tray icon, global shortcuts)

2. **Built-in Mantra Library** (Month 11)
   - 20+ curated mantras (Hindu, Buddhist, Sikh)
   - Cultural context and translations
   - Community contributions (moderated)

3. **Meditation Journal** (Month 12)
   - Text notes after sessions
   - Mood tracking
   - Insights over time

4. **Breath Work Integration** (Month 13)
   - Pranayama timer modes
   - Guided breathing exercises
   - Sync with mantra practice

5. **Apple Watch & Wear OS Apps** (Month 14-15)
   - Counter on wrist
   - Haptic feedback
   - Quick session start from watch face

6. **Health App Integration** (Month 16)
   - Export mindfulness minutes to Apple Health / Google Fit
   - Correlate practice with sleep, activity data

7. **Premium Features** (Month 17+)
   - One-time IAP or optional donation tier
   - Unlimited voice recordings
   - Advanced statistics
   - Custom themes
   - Priority support

---

## Success Metrics by Phase

### Phase 1.0 Success Criteria
- [ ] 1,000+ downloads in first month
- [ ] 4.0+ star rating on both stores
- [ ] <0.5% crash rate
- [ ] 30%+ DAU/MAU ratio

### Phase 2.0 Success Criteria
- [ ] 50%+ users enable cloud sync
- [ ] 20%+ users create voice recordings
- [ ] 5,000+ total users across all platforms

### Phase 3.0 Success Criteria
- [ ] 25%+ users unlock 7-day streak achievement
- [ ] 5%+ users share achievement images
- [ ] 10,000+ total users
- [ ] Featured on App Store (goal)

---

## Risk Mitigation

### Technical Risks
| Risk | Mitigation |
|------|-----------|
| Cloud sync data loss | Weekly cloud backups, local export option |
| API quota exceeded | Monitor usage, graceful degradation, user notification |
| Platform policy changes | Stay updated on store guidelines, have alternative ready |
| Performance degradation | Regular profiling, performance budget, optimize images |

### Business Risks
| Risk | Mitigation |
|------|-----------|
| Low user adoption | Marketing plan, SEO/ASO, community engagement |
| Negative reviews | Responsive support, fast bug fixes, feature polish |
| Competitor copying features | Focus on execution quality, user experience, open-source ethos |
| Burnout (solo dev) | Sustainable pace, community contributions, modular architecture |

---

## Resource Requirements

### Development Team
**Phase 1.0:**
- 1× Flutter Developer (full-time)
- 1× UI/UX Designer (part-time, weeks 1-2)
- 1× QA Tester (part-time, week 11-12)

**Phase 2.0:**
- Same as Phase 1.0
- +1× Backend/Cloud Engineer (part-time, weeks 14-16)

**Phase 3.0:**
- Same as Phase 1.0
- +1× Graphic Designer (achievements, week 22-23)

### Tools & Services
- **Free:**
  - Flutter SDK
  - Visual Studio Code
  - Git/GitHub
  - Figma (free tier)

- **Paid:**
  - Apple Developer ($99/year)
  - Google Play Console ($25 one-time)
  - Google Cloud (Drive API: free tier likely sufficient)
  - Domain name for web app ($12/year, optional)
  - Firebase Hosting (free tier)

**Total Estimated Cost:** ~$150 first year

---

## Conclusion

This phased implementation plan provides a structured approach to delivering the Mantra Practice Application across three major releases over 7 months. Each phase builds upon the previous, ensuring a solid foundation before adding complexity.

**Key Takeaways:**
1. **Start small** (Phase 1.0): Prove the core concept works
2. **Add value** (Phase 2.0): Enable cross-device use and personalization
3. **Engage users** (Phase 3.0): Motivate long-term practice through gamification

By following this plan, the team can deliver a high-quality, user-loved application while maintaining sustainable development pace and managing technical risks.

**Next Steps:**
1. Review and approve this plan with stakeholders
2. Begin Phase 1.0 Specification (Week 1)
3. Set up project tracking (Jira, Trello, or GitHub Projects)
4. Kick off development! 🚀

---

**Document Version Control:**

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-24 | Initial phased plan | Product Team |

**Approval:**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | | | |
| Engineering Lead | | | |
| Project Manager | | | |
