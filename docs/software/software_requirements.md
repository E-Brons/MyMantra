# Software Requirements Specification (SRS)
## MyMantra - Spiritual Practice Application

**Version:** 0.1
**Date:** November 2025
**Status:** Draft
**Application Name:** MyMantra

---

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for **MyMantra**, a cross-platform application for managing spiritual practice with reminders, repetition tracking, and progress visualization.

### 1.2 Scope
The system shall provide:
- Local mantra storage and management
- Scheduled notification reminders
- Interactive repetition counting with haptic feedback
- Progress tracking and gamification
- Optional cloud synchronization (Phase 2)
- Cross-platform support (iOS, Android, Web, Desktop)

### 1.3 Definitions and Acronyms
- **Mantra**: A text-based spiritual recitation or affirmation
- **Session**: A single practice instance with start time, duration, and repetition count
- **Streak**: Consecutive days with at least one completed session
- **MVP**: Minimum Viable Product
- **NFR**: Non-Functional Requirement
- **API**: Application Programming Interface
- **CRUD**: Create, Read, Update, Delete
- **UUID**: Universally Unique Identifier

### 1.4 References
- Product Requirements Document (PRD) v1.0
- Flutter Documentation: https://docs.flutter.dev
- Isar Database Documentation: https://isar.dev
- Material Design Guidelines: https://m3.material.io

---

## 2. System Overview

### 2.1 System Context
```
┌─────────────────────────────────────────────┐
│                                             │
│              MyMantra                       │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ UI Layer │  │ Business │  │   Data   │   │
│  │ (Flutter)│◄─┤  Logic   │◄─┤  Layer   │   │
│  └──────────┘  └──────────┘  └──────────┘   │
│                                  │          │
└──────────────────────────────────┼──────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
            ┌───────▼────────┐         ┌─────────▼────────┐
            │  Local Storage │         │ Cloud Storage    │
            │  (Isar DB)     │         │ (Phase 2)        │
            └────────────────┘         │ - Google Drive   │
                                       │ - iCloud         │
                                       └──────────────────┘
```

### 2.2 User Characteristics
- **Skill Level**: Basic to intermediate smartphone users
- **Age Range**: 7-65+
- **Usage Patterns**: Daily, multiple short sessions (2-10 minutes)
- **Device Types**: Smartphones (primary), tablets, desktop (Phase 2+)

---

## 3. Functional Requirements

### 3.1 Mantra Management Module

#### SR-1.1: Create Mantra
**Priority**: High
**Description**: User shall be able to create a new mantra entry.

**Input**:
- Title: String, 1-100 characters, required
- Text: String, 1-5000 characters, required, multi-line, Unicode
- Target Repetitions: Integer, 1-10000, default 108

**Process**:
1. Validate input fields
2. Generate unique UUID for mantra
3. Set created_at and updated_at timestamps
4. Store in local database
5. Return to mantra list view

**Output**:
- Success: Mantra added to list, confirmation message
- Failure: Error message with specific validation issue

**Acceptance Criteria**:
- Mantra saved persists after app restart
- Unicode characters (Hebrew, Sanskrit, etc.) display correctly
- Duplicate titles are allowed
- Empty text field shows error before submission

---

#### SR-1.2: Read Mantra List
**Priority**: High
**Description**: Display all stored mantras in a scrollable list.

**Input**: None (or optional search query)

**Process**:
1. Query local database for all mantras
2. Sort by updated_at (most recent first)
3. Apply search filter if provided
4. Render list with pagination/lazy loading

**Output**:
- List of mantra cards showing: title, preview of text (first 50 chars), target repetitions
- Empty state if no mantras exist

**Acceptance Criteria**:
- List loads in <500ms for 100 mantras
- Search filters in real-time
- Pull-to-refresh updates list
- Tapping a mantra opens detail view

---

#### SR-1.3: Update Mantra
**Priority**: High
**Description**: User shall be able to edit existing mantra details.

**Input**: Same as SR-1.1 (with pre-filled existing values)

**Process**:
1. Load existing mantra data
2. Allow editing of title, text, target repetitions
3. Validate changes
4. Update updated_at timestamp
5. Save to database

**Output**: Success/failure message, return to mantra list

**Acceptance Criteria**:
- Changes persist after app restart
- Associated reminders and sessions remain linked
- Undo option available for 5 seconds after save

---

#### SR-1.4: Delete Mantra
**Priority**: Medium
**Description**: User shall be able to delete a mantra with confirmation.

**Input**: Mantra UUID

**Process**:
1. Show confirmation dialog: "Delete [mantra title]? This will also delete all reminders and session history."
2. If confirmed:
   - Delete mantra record
   - Delete associated reminders (cascade)
   - Delete associated session records (cascade)
3. Update UI

**Output**: Mantra removed from list

**Acceptance Criteria**:
- Requires explicit confirmation
- Cannot be undone after confirmation
- All related data deleted (orphan prevention)

---

#### SR-1.5: Search Mantras
**Priority**: Low
**Description**: Filter mantra list by text search.

**Input**: Search query string

**Process**:
1. Search in title and text fields (case-insensitive)
2. Return matching mantras
3. Highlight matching text

**Output**: Filtered list of mantras

**Acceptance Criteria**:
- Search updates as user types (debounced 300ms)
- Supports Unicode search
- Clear button to reset search

---

### 3.2 Reminder Management Module

#### SR-2.1: Create Reminder
**Priority**: High
**Description**: User shall be able to schedule notifications for a mantra.

**Input**:
- Mantra UUID (required)
- Time: HH:MM in 24-hour format (required)
- Days of week: Array of integers 0-6 (0=Sunday)
- Enabled: Boolean, default true
- Notification sound: String (sound ID)

**Process**:
1. Validate time format
2. Generate reminder UUID
3. Schedule local notifications with OS
4. Store reminder in database

**Output**: Reminder added, visible in mantra detail view

**Acceptance Criteria**:
- Multiple reminders per mantra allowed
- Notification appears at scheduled time (±1 minute tolerance)
- Notification includes mantra title
- Deep link to mantra session when tapped

---

#### SR-2.2: Update Reminder
**Priority**: Medium
**Description**: Modify existing reminder parameters.

**Input**: Same as SR-2.1

**Process**:
1. Cancel existing scheduled notifications
2. Update database record
3. Reschedule notifications if enabled

**Output**: Confirmation message

**Acceptance Criteria**:
- Changes take effect immediately
- No duplicate notifications

---

#### SR-2.3: Delete Reminder
**Priority**: Medium
**Description**: Remove a scheduled reminder.

**Input**: Reminder UUID

**Process**:
1. Cancel scheduled notifications
2. Delete from database

**Output**: Reminder removed from list

**Acceptance Criteria**:
- No confirmation required (non-destructive, can recreate)
- Notifications no longer appear

---

#### SR-2.4: Enable/Disable Reminder
**Priority**: High
**Description**: Toggle reminder without deleting.

**Input**: Reminder UUID, new state (boolean)

**Process**:
1. Update enabled field in database
2. If disabled: cancel notifications
3. If enabled: schedule notifications

**Output**: Visual toggle state change

**Acceptance Criteria**:
- Toggle responds instantly
- State persists after app restart

---

### 3.3 Session Module

#### SR-3.1: Start Session
**Priority**: High
**Description**: Begin a counting session for a mantra.

**Input**: Mantra UUID, wasFromReminder (boolean)

**Process**:
1. Load mantra details
2. Initialize counter to 0
3. Start session timer
4. Enter full-screen reading mode
5. Register tap gesture listener

**Output**: Session UI displayed

**Acceptance Criteria**:
- Enters full-screen mode (hides status bar on mobile)
- Screen stays awake during session
- Text is clearly readable (minimum 16sp font)

---

#### SR-3.2: Increment Counter
**Priority**: High
**Description**: Count each repetition with tap interaction.

**Input**: User tap anywhere on screen

**Process**:
1. Increment counter by 1
2. Trigger haptic feedback (medium impact)
3. Update counter display
4. Update progress bar
5. If counter == target: trigger auto-complete (SR-3.4)

**Output**: Counter incremented, visual/haptic feedback

**Acceptance Criteria**:
- Response time <50ms
- Haptic feedback on every tap
- No accidental double-counts (debounce 100ms)
- Accurate count even with rapid taps (stress test: 10 taps/second)

---

#### SR-3.3: Pause/Resume Session
**Priority**: Medium
**Description**: Temporarily pause counting.

**Input**: Pause/Resume button tap

**Process**:
1. If pausing: stop timer, disable counter
2. If resuming: restart timer, enable counter

**Output**: UI reflects paused/active state

**Acceptance Criteria**:
- Timer accurately tracks active time (excludes paused duration)
- Counter disabled during pause (taps ignored)

---

#### SR-3.4: Complete Session
**Priority**: High
**Description**: Finish session and save to history.

**Input**: Complete button tap OR auto-complete when target reached

**Process**:
1. Stop timer
2. Create session record:
   - Session UUID
   - Mantra UUID
   - Timestamp (start time)
   - Repetitions completed (counter value)
   - Duration (seconds, excluding paused time)
   - Was from reminder (boolean)
3. Save to database
4. Update progress (streak, totals)
5. Check for new achievements
6. Show celebration animation
7. Return to home screen

**Output**: Session saved, progress updated

**Acceptance Criteria**:
- Session data persists even if app crashes immediately after
- Progress updates are atomic (all-or-nothing)
- Celebration animation plays for 2-3 seconds
- Achievement notification shown if unlocked

---

#### SR-3.5: Cancel Session
**Priority**: Low
**Description**: Exit session without saving.

**Input**: Cancel/Back button

**Process**:
1. Show confirmation: "Discard session? Progress will not be saved."
2. If confirmed: exit to home, no database changes
3. If cancelled: return to session

**Output**: Return to previous screen

**Acceptance Criteria**:
- Requires confirmation if counter > 0
- No confirmation if counter == 0

---

#### SR-3.6: Reset Counter
**Priority**: Low
**Description**: Reset counter to 0 during session.

**Input**: Reset button tap

**Process**:
1. Show confirmation
2. If confirmed: set counter to 0, timer continues

**Output**: Counter reset

**Acceptance Criteria**:
- Requires confirmation
- Does not end session

---

### 3.4 Progress Tracking Module

#### SR-4.1: Calculate Streak
**Priority**: High
**Description**: Track consecutive days with completed sessions.

**Algorithm**:
```
current_streak = 0
last_session_date = get_last_session_date()

if last_session_date == today:
  current_streak = existing_streak
elif last_session_date == yesterday:
  current_streak = existing_streak + 1
else:
  current_streak = 1  // streak broken

if current_streak > longest_streak:
  longest_streak = current_streak
```

**Process**:
1. On session complete, check last session date
2. If today: no change
3. If yesterday: increment streak
4. If older: reset to 1
5. Update longest streak if exceeded

**Output**: Updated streak values

**Acceptance Criteria**:
- Streak increments once per day (multiple sessions don't multiply)
- Streak breaks if no session for ≥2 days
- Timezone handled correctly (user's local date)

---

#### SR-4.2: Display Progress Dashboard
**Priority**: Medium
**Description**: Show user's overall progress statistics.

**Input**: None

**Process**:
1. Query database for:
   - Current streak
   - Longest streak
   - Total sessions
   - Total repetitions
   - Last session date
2. Render dashboard with visualizations

**Output**: Progress screen with stats

**Acceptance Criteria**:
- Stats update immediately after session
- Visual streak calendar (7-day or 30-day view)
- Large, prominent streak number

---

#### SR-4.3: List Session History
**Priority**: Low
**Description**: Show past sessions in chronological order.

**Input**: Optional filters (date range, mantra)

**Process**:
1. Query sessions from database
2. Sort by timestamp (newest first)
3. Group by date
4. Display with mantra name, repetitions, duration

**Output**: Scrollable list of sessions

**Acceptance Criteria**:
- Loads last 100 sessions initially
- Infinite scroll for older sessions
- Each entry tappable for details

---

### 3.5 Gamification Module

#### SR-5.1: Unlock Achievement
**Priority**: Medium
**Description**: Grant badge when milestone reached.

**Achievements**:
| ID | Title | Condition | Icon |
|----|-------|-----------|------|
| ACH-001 | First Steps | Complete first session | 🙏 |
| ACH-002 | Dedicated | 3-day streak | 🔥 |
| ACH-003 | Committed | 7-day streak | ⭐ |
| ACH-004 | Devoted | 30-day streak | 🏆 |
| ACH-005 | Centurion | 100 total sessions | 💯 |
| ACH-006 | Master | 10,000 total repetitions | 🎖️ |

**Process**:
1. After session complete or streak update:
2. Check all achievement conditions
3. If any newly met:
   - Mark achievement as unlocked
   - Show notification popup
   - Play sound effect
   - Add to user's achievement list

**Output**: Achievement notification

**Acceptance Criteria**:
- Each achievement unlocked only once
- Notification dismisses after 5 seconds or user tap
- Achievements visible in profile/progress screen

---

#### SR-5.2: Display Achievements
**Priority**: Low
**Description**: Show all achievements (locked/unlocked).

**Input**: None

**Process**:
1. Load all achievement definitions
2. Check user's unlocked achievements
3. Render grid with:
   - Unlocked: full color, date earned
   - Locked: grayscale, progress toward unlock

**Output**: Achievement gallery screen

**Acceptance Criteria**:
- Locked achievements show hint of unlock condition
- Earned achievements show date

---

### 3.6 Settings Module

#### SR-6.1: Theme Selection
**Priority**: Medium
**Description**: User can choose app color theme.

**Input**: Theme option (Light, Dark, System)

**Process**:
1. Update theme preference in storage
2. Apply theme immediately (no restart)

**Output**: UI updates to selected theme

**Acceptance Criteria**:
- Theme persists across sessions
- System option follows device setting

---

#### SR-6.2: Notification Settings
**Priority**: High
**Description**: Configure notification behavior.

**Input**:
- Enable/disable all notifications (master switch)
- Sound selection
- Vibration enable/disable

**Process**:
1. Request notification permission if not granted
2. Update notification preferences
3. Apply to all future notifications

**Output**: Settings saved

**Acceptance Criteria**:
- Changes take effect on next notification
- OS permission respected (if denied, show explanation)

---

#### SR-6.3: Default Target Repetitions
**Priority**: Low
**Description**: Set default value for new mantras.

**Input**: Integer, 1-10000

**Process**:
1. Validate input
2. Save to preferences
3. Apply to future mantra creation

**Output**: Setting saved

**Acceptance Criteria**:
- Does not affect existing mantras
- Pre-fills field in create mantra form

---

#### SR-6.4: About & Donations
**Priority**: Low
**Description**: Display app information and donation options.

**Input**: None

**Process**:
1. Show app version, license
2. Display donation links (external)

**Output**: About screen

**Acceptance Criteria**:
- Links open in external browser
- No in-app payment required

---

### 3.7 Cloud Synchronization Module (Phase 2.0)

#### SR-7.1: User Authentication
**Priority**: High (Phase 2.0)
**Description**: User shall authenticate with their cloud storage provider.

**Input**: Selected provider (Google or Apple)

**Process**:
1. Display provider selection (Google/Apple)
2. Initiate OAuth2 flow
3. Request necessary permissions (Drive API / CloudKit)
4. Store authentication token securely
5. Initialize cloud sync service

**Output**: Authenticated state, sync enabled

**Acceptance Criteria**:
- OAuth flow completes without errors
- Token stored in secure storage (Keychain/KeyStore)
- Automatic token refresh when expired
- User can sign out and clear credentials

---

#### SR-7.2: Automatic Data Sync
**Priority**: High (Phase 2.0)
**Description**: App shall automatically sync data to user's cloud storage.

**Input**: None (background process)

**Process**:
1. Detect network connectivity
2. Check last sync timestamp
3. Gather local data changes since last sync
4. Download cloud backup file
5. Merge with conflict resolution (last-write-wins)
6. Update local database
7. Upload merged data to cloud
8. Update last sync timestamp

**Output**: Synced state indicator

**Acceptance Criteria**:
- Sync completes within 30 seconds for typical data (<100 mantras, <1000 sessions)
- Runs in background every 15 minutes when connected
- No data loss during sync conflicts
- Offline changes queued and synced when connectivity restored
- Sync indicator shows: Syncing / Synced / Offline / Error states

---

#### SR-7.3: Manual Sync Trigger
**Priority**: Medium (Phase 2.0)
**Description**: User can manually trigger sync from settings.

**Input**: Sync button tap

**Process**:
1. Validate authentication status
2. Execute sync process (SR-7.2)
3. Show progress indicator
4. Display result (success/failure message)

**Output**: Confirmation message, updated last sync time

**Acceptance Criteria**:
- Sync completes or fails within 60 seconds
- Clear error messages if sync fails
- Pull-to-refresh gesture supported

---

#### SR-7.4: Data Export
**Priority**: Medium (Phase 2.0)
**Description**: User can export all data as JSON file.

**Input**: Export button tap

**Process**:
1. Gather all data (mantras, reminders, sessions, progress)
2. Serialize to JSON
3. Generate file: `mantra_backup_[date].json`
4. Trigger system share sheet

**Output**: JSON file saved to user-selected location

**Acceptance Criteria**:
- File readable as valid JSON
- Import-compatible with cloud backup format
- Includes all user data

---

#### SR-7.5: Data Import
**Priority**: Low (Phase 2.0)
**Description**: User can import data from JSON file.

**Input**: JSON file selection

**Process**:
1. Validate JSON structure
2. Show preview of data to import
3. Confirm import action
4. Merge with existing data or replace
5. Update database

**Output**: Imported data visible in app

**Acceptance Criteria**:
- Invalid files show clear error message
- User can choose merge or replace strategy
- Confirmation dialog before overwriting data

---

#### SR-7.6: Multi-Device Sync
**Priority**: High (Phase 2.0)
**Description**: Changes on one device appear on all devices.

**Input**: None (automatic)

**Process**:
1. Device A makes change → auto-sync to cloud
2. Device B opens app → detects newer cloud data
3. Device B downloads and merges
4. Both devices show consistent data

**Output**: Consistent state across devices

**Acceptance Criteria**:
- New device shows data within 1 minute of sign-in
- Changes propagate to other devices within 15 minutes
- Streak calculations consistent across devices (timezone-aware)

---

### 3.8 Audio Recording Module (Phase 2.0)

#### SR-8.1: Record Mantra Audio
**Priority**: High (Phase 2.0)
**Description**: User can record their own voice reciting a mantra.

**Input**: Microphone permission, record button tap

**Process**:
1. Request microphone permission
2. Display recording UI (waveform, timer)
3. Start recording on button press
4. Stop recording on button release or max duration (5 minutes)
5. Save as AAC file (64kbps, 44.1kHz)
6. Generate unique filename
7. Store in app documents directory

**Output**: Audio file path

**Acceptance Criteria**:
- Clear audio quality
- File size <5MB for 5-minute recording
- Recording stops at 5-minute limit
- User can playback immediately after recording
- Option to re-record before saving

---

#### SR-8.2: Attach Recording to Mantra
**Priority**: High (Phase 2.0)
**Description**: Link audio recording to mantra for playback during sessions.

**Input**: Mantra ID, recording file path

**Process**:
1. Validate audio file exists
2. Update mantra record with file path
3. Optionally upload to cloud sync (if enabled)

**Output**: Mantra updated, recording attached

**Acceptance Criteria**:
- Recording persists after app restart
- Visible indicator on mantra card (🎤 icon)
- Option to delete or replace recording

---

#### SR-8.3: Audio Playback During Session
**Priority**: High (Phase 2.0 - Premium Feature)
**Description**: Play user's recording during mantra session.

**Input**: Session start with mantra having recording

**Process**:
1. Load audio file
2. Start playback on session start
3. Loop audio continuously
4. Display playback controls (pause/resume)
5. Sync counter with playback (optional mode)
6. Stop audio on session end

**Output**: Audio playing during session

**Acceptance Criteria**:
- Seamless looping (no gaps between loops)
- Audio continues during screen lock (background playback)
- Pause/resume without audio glitches
- Audio stops when session cancelled or completed

---

#### SR-8.4: Recording Management
**Priority**: Medium (Phase 2.0)
**Description**: User can manage (view, delete) their recordings.

**Input**: None

**Process**:
1. List all recordings in settings
2. Show: Mantra name, duration, file size, date created
3. Allow playback preview
4. Delete recording (with confirmation)

**Output**: Recordings list screen

**Acceptance Criteria**:
- Shows storage used by recordings
- Playback works from management screen
- Delete removes file from storage and cloud sync

---

#### SR-8.5: Recording Limits (Free vs. Premium)
**Priority**: Low (Phase 2.0)
**Description**: Enforce recording limits based on tier.

**Input**: None (automatic check)

**Process**:
1. Count existing recordings
2. If free tier: limit to 3 recordings
3. If premium: unlimited
4. Show upgrade prompt when limit reached

**Output**: Limit enforcement

**Acceptance Criteria**:
- Free users can record max 3 mantras
- Clear message when limit reached
- Existing recordings work after downgrade

---

### 3.9 Achievements Module (Phase 3.0)

#### SR-9.1: Achievement Unlocking
**Priority**: High (Phase 3.0)
**Description**: Grant achievements when conditions met.

**Input**: Session completion, progress update

**Process**:
1. Check all achievement conditions
2. If newly met:
   - Mark as unlocked in database
   - Show notification popup (2-3 seconds)
   - Play sound effect (optional)
   - Add to unlocked achievements list

**Output**: Achievement notification

**Acceptance Criteria**:
- Each achievement unlocks only once
- Notification dismisses automatically or on tap
- Achievement visible in gallery immediately

---

#### SR-9.2: Achievement Types
**Priority**: High (Phase 3.0)
**Description**: Support multiple achievement categories.

**Achievement Definitions**:
1. **Session-Based:**
   - First Steps: Complete 1 session

2. **Streak-Based:**
   - Dedicated: 3-day streak
   - Committed: 7-day streak
   - Devoted: 30-day streak
   - Unwavering: 60-day streak
   - Transcendent: 180-day streak
   - Enlightened: 365-day streak

3. **Volume-Based:**
   - Novice: 1,000 total repetitions
   - Adept: 5,000 total repetitions
   - Master: 10,000 total repetitions
   - Guru: 100,000 total repetitions

4. **Time-Based:**
   - Early Bird: Complete session before 7:00 AM

5. **Milestone-Based:**
   - Centurion: 100 total sessions

**Acceptance Criteria**:
- All 14+ achievements unlockable
- Progress toward locked achievements visible
- Unlock date stored for each achievement

---

#### SR-9.3: Shareable Achievement Images
**Priority**: Medium (Phase 3.0)
**Description**: Generate shareable images for achievements.

**Input**: Achievement ID, user stats

**Process**:
1. Render achievement badge
2. Add user's relevant stats (streak count, total reps, etc.)
3. Apply branded design template
4. Generate PNG/JPEG image
5. Trigger share sheet (Instagram, Facebook, etc.)

**Output**: Shareable image

**Acceptance Criteria**:
- Image dimensions: 1080x1920 (Instagram Stories optimal)
- No personal identifiers (privacy-first)
- High-quality graphics (vector-based icons)
- Share to all major social platforms

---

## 4. Data Requirements

### 4.1 Data Models

#### Mantra
```dart
class Mantra {
  String id;                    // UUID
  String title;                 // 1-100 chars
  String text;                  // 1-5000 chars, Unicode
  int targetRepetitions;        // 1-10000
  DateTime createdAt;
  DateTime updatedAt;
  bool isCustom;                // false for built-in mantras
  String? voiceRecordingPath;   // Phase 2.0: Path to AAC audio file
}
```

#### Reminder
```dart
class Reminder {
  String id;              // UUID
  String mantraId;        // Foreign key
  String time;            // "HH:MM" 24-hour
  List<int> daysOfWeek;   // [0-6], 0=Sunday
  bool isEnabled;
  String notificationSound;
}
```

#### Session
```dart
class Session {
  String id;                  // UUID
  String mantraId;            // Foreign key
  DateTime timestamp;         // Session start time
  int repetitionsCompleted;
  int durationSeconds;        // Active time, excludes pauses
  bool wasFromReminder;
}
```

#### Progress
```dart
class Progress {
  String id;                  // "singleton"
  int currentStreak;
  int longestStreak;
  DateTime? lastSessionDate;
  int totalSessions;
  int totalRepetitions;
  List<String> unlockedAchievements;  // Achievement IDs
  DateTime updatedAt;
}
```

### 4.2 Data Relationships
```
Mantra (1) ──< (N) Reminder
Mantra (1) ──< (N) Session
```

### 4.3 Data Persistence
- **Primary Storage**: Isar embedded database
- **Location**: App's documents directory
- **Backup**: JSON export to user's cloud storage (Phase 2)
- **Encryption**: Device-level (OS managed)

### 4.4 Data Retention
- Mantras: Indefinite (user-managed)
- Reminders: Indefinite (user-managed)
- Sessions: Indefinite (future: optional auto-cleanup after 1 year)
- Progress: Indefinite

---

## 5. External Interface Requirements

### 5.1 User Interface Requirements

#### UI-1: Responsive Design
- Mobile: 320px - 768px width
- Tablet: 768px - 1024px width
- Desktop: 1024px+ width (Phase 2)

#### UI-2: Accessibility
- Minimum touch target: 44x44 dp
- Color contrast ratio: ≥4.5:1 (WCAG AA)
- Screen reader support
- Dynamic font sizing

#### UI-3: Design System
- Material Design 3 guidelines
- Custom color palette (spiritual theme)
- Consistent spacing (8dp grid)

### 5.2 Hardware Interface Requirements

#### HW-1: Haptic Engine
- Required for counter feedback
- Fallback: visual-only feedback

#### HW-2: Notification Support
- Local notification scheduling via OS APIs
- Sound playback via system mixer

### 5.3 Software Interface Requirements

#### SW-1: Operating System APIs
- **iOS**: UIKit, UserNotifications, CloudKit (Phase 2)
- **Android**: Android SDK, WorkManager, Google Drive API (Phase 2)

#### SW-2: Database Interface
- Isar database v3.x
- Dart FFI for native performance

#### SW-3: Cloud Storage APIs (Phase 2)
- Google Drive API v3
- iCloud Drive API (CloudKit)

---

## 6. Non-Functional Requirements

### 6.1 Performance Requirements

#### PERF-1: Response Time
- Counter tap: <50ms
- Screen navigation: <300ms
- Database query: <100ms (typical)
- App launch: <2s (cold start)

#### PERF-2: Resource Usage
- RAM: <200MB typical, <500MB peak
- Storage: <50MB app size, <100MB user data (for 10K sessions)
- Battery: <5% drain per hour of active use

#### PERF-3: Scalability
- Support 1,000 mantras
- Support 10,000 sessions
- Notification scheduling: up to 100 active reminders

### 6.2 Reliability Requirements

#### REL-1: Availability
- Offline functionality: 100% (no internet required for core features)
- Crash-free rate: >99.9%

#### REL-2: Data Integrity
- Database transactions: ACID compliant
- No data loss on unexpected termination
- Automatic backup on major updates (Phase 2)

#### REL-3: Fault Tolerance
- Graceful degradation if haptic unavailable
- Notification fallback if permission denied
- Cloud sync retry with exponential backoff (Phase 2)

### 6.3 Security Requirements

#### SEC-1: Data Protection
- Local data encrypted at rest (OS managed)
- No sensitive data logged
- Secure OAuth2 for cloud authentication (Phase 2)

#### SEC-2: Privacy
- No analytics without consent
- No personal data collected on servers
- GDPR-compliant data export/deletion

### 6.4 Maintainability Requirements

#### MAINT-1: Code Quality
- Code coverage: >70% (unit tests)
- Static analysis: 0 errors, <10 warnings
- Consistent code style (Dart linter)

#### MAINT-2: Documentation
- Inline code comments for complex logic
- API documentation for all public methods
- Architecture decision records (ADRs)

### 6.5 Portability Requirements

#### PORT-1: Cross-Platform
- Single codebase for iOS, Android
- Platform-specific code isolated in abstractions
- Conditional compilation for platform features

---

## 7. Quality Attributes

### 7.1 Usability
- Onboarding completion rate: >80%
- Task success rate: >90% (create mantra, set reminder, complete session)
- User satisfaction: >4.0/5.0 (from reviews)

### 7.2 Efficiency
- Network data usage: 0 MB (Phase 1), <1 MB/day for sync (Phase 2)
- Storage efficiency: <100 KB per mantra + session

### 7.3 Flexibility
- Pluggable storage backends (Isar → Drift possible)
- Themeable UI
- Extensible achievement system

---

## 8. Constraints

### 8.1 Technical Constraints
- Flutter SDK version: ≥3.16
- Dart version: ≥3.2
- Minimum OS: iOS 14, Android 8.0

### 8.2 Regulatory Constraints
- App Store Review Guidelines compliance
- Google Play Store policies compliance
- GDPR, CCPA compliance

### 8.3 Business Constraints
- Zero budget for infrastructure
- No paid third-party services
- Open-source license (MIT)

---

## 9. Acceptance Criteria (System-Level)

### Phase 1 MVP Acceptance
- [ ] All SR-1.x (Mantra Management) requirements met
- [ ] All SR-2.x (Reminder Management) requirements met
- [ ] All SR-3.x (Session) requirements met
- [ ] All SR-4.x (Progress) requirements met
- [ ] All SR-5.x (Gamification) requirements met
- [ ] All SR-6.x (Settings) requirements met
- [ ] All PERF, REL, SEC requirements met
- [ ] Manual testing passed on iOS and Android
- [ ] Beta testing completed (10+ users, 7+ days)
- [ ] Zero critical bugs, <5 high-priority bugs

---

## 10. Appendices

### Appendix A: Notification Payload Schema
```json
{
  "title": "Time to practice",
  "body": "[Mantra Title]",
  "data": {
    "mantraId": "uuid-string",
    "reminderId": "uuid-string",
    "deepLink": "mymantra://session/[mantraId]"
  }
}
```

### Appendix B: Cloud Backup JSON Format (Phase 2)
```json
{
  "version": "1.0",
  "exportedAt": "2025-11-23T10:30:00Z",
  "mantras": [...],
  "reminders": [...],
  "sessions": [...],
  "progress": {...}
}
```

---

**Document Approval**

| Role | Name | Date |
|------|------|------|
| Requirements Engineer | [TBD] | |
| Technical Architect | [TBD] | |
| QA Lead | [TBD] | |
