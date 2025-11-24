# Application Goals Document
## MyMantra - Spiritual Practice Application

**Version:** 0.1
**Date:** November 2025
**Status:** Draft
**Application Name:** MyMantra

---

## Overview

This document captures the original vision and goals for the **MyMantra** application as specified by the product owner. It serves as the foundation for all subsequent planning, design, and implementation documents.

---

## 1. Core Application Description

### 1.1 Platform Vision
Build a **multi-platform software** that enables Mantra notifications and reading on:
- iPhone
- macOS
- Android
- Windows
- Web

### 1.2 Guiding Principles
1. **Privacy-First**: Offline-first approach with user-controlled cloud storage
2. **User-Owned Data**: All rewards and data stored on user's own cloud account (iCloud / Google Drive)
3. **Open & Accessible**: Easy to copy data is acceptable - this is NOT a premium gate-keeping feature
4. **Cross-Platform Consistency**: Single codebase, consistent experience across all platforms

---

## 2. Main Features

### 2.1 Mantra Settings & Configuration
Each mantra may include:
- **Number of repetitions** (target count for practice)
- **Time of day to practice** or **finish the practice**
- **Voice recording** (user's own recording)
- **Text in multiple languages:**
  - Sanskrit (original)
  - English (translation)
  - Other languages as needed

**Note:** Built-in Mantras Library is planned for **version 2.0**

---

### 2.2 Mantra Usage Modes

When a Mantra is being used, practitioners can:

#### A. Audio Playback (Premium Feature)
- **Use the app to read it aloud** for them
- Options:
  - English text-to-speech
  - Self-recorded audio playback
- **Tier:** Premium feature

#### B. Counter Mode (Core Feature)
- **Use the App to count** repetitions for them
- Interactive tap-to-count interface
- **Tier:** Core/Free feature

#### C. Guided Audio (Future - Version 2.0)
- **Listen to the app reading it** (English only)
- Pre-recorded professional narration
- **Tier:** Premium feature
- **Timeline:** Version 2.0

---

## 3. Gamification & Achievements (Version 3.0)

### 3.1 Accomplishments & Rewards
Points and shareable rewards are planned for **version 3.0**

### 3.2 Achievement Categories

#### Session-Based Achievements
**A. Full Session**
- Complete a session reaching the target repetition count

#### Streak Achievements
**B. Consistency Streaks**
- 3-day streak
- 7-day streak
- 30-day streak
- 60-day streak
- 180-day streak
- 365-day streak

#### Volume Achievements
**C. Total Repetitions Milestones**
- 1,000 total repetitions
- 5,000 total repetitions
- 10,000 total repetitions
- 100,000 total repetitions

#### Special Time-Based Achievement
**D. Early Bird**
- Finish a practice session before 7:00 AM

### 3.3 Reward Storage Philosophy
- **All rewards encoded on user's cloud storage** (iCloud / Google Drive)
- Even if rewards are easy to copy - **that's not an issue**
- This is **NOT a premium feature** requiring verification
- Emphasis on personal tracking, not competition or verification

---

## 4. User Registration & Account System

### 4.1 Account Integration
The app registration involves using one's **existing cloud account**:
- **iCloud** (for Apple ecosystem users)
- **Google Drive** (for Android/cross-platform users)

### 4.2 No Custom Backend
- No proprietary servers
- No username/password system
- Use existing OAuth authentication for cloud providers

---

## 5. Application Screens

### A. Mantras Management
- List of all user's mantras
- Create, edit, delete mantras
- Search and filter capabilities

### B. Mantra Settings
- Configure individual mantra properties:
  - Title and text
  - Target repetitions
  - Voice recording attachment
  - Language selections
  - Notification schedules

### C. User Settings
- **Notifications:** Enable/disable, sound, vibration
- **Account:** Cloud sync configuration (iCloud/Google Drive)
- **Appearance:** Theme, font size
- **Defaults:** Default repetition count, etc.

### D. User Achievements and Statistics
- Current streak display
- Longest streak
- Total sessions
- Total repetitions
- Achievement gallery (locked/unlocked)
- Progress toward next milestones

### E-X. Actual Mantra Usage Screens
Multiple scenarios to support:
1. **Reading Mode:** Display mantra text prominently
2. **Counter Mode:** Tap-anywhere to increment counter
3. **Audio Playback Mode:** Play user's recording or TTS
4. **Session Summary:** Results after completion
5. **Pause/Resume States:** Mid-session controls

---

## 6. Gamification Strategy

### 6.1 Core Gamification Elements
- **Achievements/Badges:** Visual rewards for milestones
- **Streaks:** Daily consistency tracking with visual indicators
- **Points System:** Quantifiable progress (Version 3.0)
- **Shareable Content:** Achievement cards for social sharing
- **Progress Visualization:** Charts, calendars, progress bars

### 6.2 Motivation Design
- **Intrinsic Motivation:** Personal growth, spiritual progress
- **Extrinsic Rewards:** Badges, titles, unlockables
- **Social Proof (Optional):** Shareable achievements (user-initiated only)
- **Habit Formation:** Streak mechanics encourage daily practice

---

## 7. Architectural Philosophy

### 7.1 Offline-First Approach
**Primary Principle:** The app must work fully without internet connection

**Implementation:**
- All core features functional offline
- Local database as source of truth
- Background sync when internet available
- No degraded experience when offline

### 7.2 Cloud Synchronization
**User's Cloud Account (Google Drive / Apple iCloud):**
- Sync all mantras
- Sync all sessions and history
- Sync progress and achievements
- Sync voice recordings (optional, due to size)

**Sync Strategy:**
- Automatic background sync every 15 minutes
- Manual sync trigger available
- Conflict resolution: Last-write-wins
- Offline changes queued for later sync

### 7.3 Data Ownership
- User owns 100% of their data
- Stored in their personal cloud storage
- Exportable as JSON at any time
- No vendor lock-in

---

## 8. Version Roadmap Summary

### Version 1.0 - Core Experience (MVP)
- Custom mantra creation and editing
- Notification reminders
- Counter mode (tap-to-count)
- Basic progress tracking (streak, totals)
- Offline-first functionality
- iOS + Android apps

### Version 2.0 - Enhanced Features
- Built-in Mantra Library (curated collection)
- Voice recording and playback
- Audio playback during session (Option A)
- Guided audio listening (Option C - English only)
- Cloud synchronization (iCloud / Google Drive)
- macOS + Web platform support

### Version 3.0 - Gamification & Social
- Full achievements system
- Points and scoring
- Shareable reward images
- Enhanced statistics and visualizations
- Windows platform support (optional)

---

## 9. Success Criteria

### 9.1 User Experience Goals
- **Frictionless Practice:** User can start a session in <3 taps from notification
- **Reliable Counting:** Zero missed taps, accurate counter
- **Motivating Progress:** Visible streaks and achievements encourage daily use
- **Privacy Respected:** All data local or in user's cloud, no tracking

### 9.2 Technical Goals
- **100% Offline Functionality:** Core features never require internet
- **Cross-Platform Parity:** Feature consistency across iOS, Android, macOS, Web
- **Fast Performance:** <50ms counter response, <2s app launch
- **Data Safety:** No data loss during sync conflicts or app crashes

### 9.3 Business Goals
- **User Retention:** 40% MAU at 3 months
- **User Satisfaction:** 4.5+ star rating on app stores
- **Community Building:** Foundation for future growth
- **Zero Infrastructure Cost:** No servers, no hosting fees

---

## 10. Key Differentiators

### 10.1 Competitive Advantages
1. **Privacy-First:** No central database, no user tracking
2. **Offline-First:** Works anywhere, anytime (airplane, retreat, no signal)
3. **User Data Ownership:** Your cloud, your data
4. **No Subscription:** Free core features, premium as one-time purchase (future)
5. **Spiritual Focus:** Purpose-built for mantra practice, not generic meditation
6. **Open Ethos:** Easy data export, no lock-in

### 10.2 Target Market Positioning
- **Primary:** Serious spiritual practitioners (Hindu, Buddhist, etc.)
- **Secondary:** Wellness seekers using affirmations
- **Tertiary:** Anyone building a daily practice habit

---

## 11. Constraints & Boundaries

### 11.1 What This App IS
- A **personal spiritual practice tool**
- A **habit tracker** for mantra meditation
- A **progress journal** with gamification
- A **notification reminder system** for daily practice
- A **counter utility** with context (mantras)

### 11.2 What This App IS NOT
- A **social network** (no friends, no feed, no public leaderboards)
- A **meditation course platform** (no lessons, no instructors)
- A **streaming audio service** (audio is user-recorded or TTS only)
- A **subscription service** (free core, optional one-time premium)
- A **data collection tool** (no analytics, no tracking)

---

## 12. Design Philosophy

### 12.1 User Interface Principles
- **Simplicity:** Clean, uncluttered screens
- **Readability:** Large fonts for mantra text, high contrast
- **Accessibility:** Support for screen readers, large text, color blind modes
- **Beauty:** Spiritual aesthetic, calming colors, smooth animations
- **Functionality First:** No decoration that hinders usability

### 12.2 Interaction Design
- **Haptic Feedback:** Physical response to every interaction
- **Immediate Response:** <50ms for all taps
- **Forgiving:** Undo options, confirmations for destructive actions
- **Discoverable:** Features visible without hunting
- **Progressive Disclosure:** Advanced features don't clutter beginner experience

---

## 13. Future Possibilities (Beyond v3.0)

### Potential Features to Explore
- **Meditation Journal:** Text notes per session
- **Breath Work Integration:** Pranayama timers
- **Community Library:** User-contributed mantras (curated)
- **Wear OS / WatchOS:** Smartwatch counter apps
- **Health App Integration:** Apple Health, Google Fit sync
- **Translation Expansion:** More language support beyond English/Sanskrit
- **Audio Quality Upgrade:** Professional mantra recordings (licensed)

### Explicitly Out of Scope
- **Live Streaming:** No live group sessions
- **Video Content:** No guided video meditations
- **Chat/Messaging:** No communication between users
- **E-Commerce:** No selling of physical products
- **Advertising:** Never

---

## Appendix: Core User Journey Example

### Scenario: New User's First Week

**Day 1 - Sunday Morning:**
1. Downloads app from App Store
2. Skips onboarding tutorial
3. Taps "Create Mantra"
4. Enters: Title "Om Mani Padme Hum", Text in Sanskrit, Target: 108
5. Saves mantra
6. Taps "Add Reminder" → Sets daily 7:00 AM notification
7. Closes app

**Day 2 - Monday 7:00 AM:**
1. Receives notification: "Time to practice - Om Mani Padme Hum"
2. Taps notification
3. App opens to full-screen session
4. Begins tapping screen, feels haptic feedback
5. Completes 108 repetitions in 6 minutes
6. Sees celebration animation
7. Unlocks achievement: "First Steps" and "2-Day Streak"
8. Returns to home screen, sees "🔥 2-day streak"

**Day 3-7 - Tuesday-Saturday:**
- Continues daily practice from notifications
- By Day 7, sees "🔥 7-day streak"
- Unlocks "Committed" badge
- Total: 756 repetitions across 7 sessions
- Progress bar toward 1,000 reps visible

**Day 8 - Sunday:**
- Decides to add second mantra (Gayatri Mantra)
- Sets reminder for evenings (8:00 PM)
- Now practicing twice daily
- Feels motivated by visible progress

**Week 4:**
- Hits 30-day streak → "Devoted" badge unlocked
- Crosses 5,000 total repetitions → "Adept" badge unlocked
- Shares achievement image on Instagram Stories
- Continues consistent practice...

---

**This journey exemplifies:**
- Ease of onboarding
- Notification-driven habit formation
- Gamification motivation
- Multiple mantras support
- Long-term engagement

---

## Document Metadata

**Original Requirements Provided By:** Product Owner
**Date:** November 24, 2025
**Document Type:** Vision & Goals
**Related Documents:**
- Product Requirements Document (PRD)
- Software Requirements Specification (SRS)
- Software Architecture Document (SAD)
- Phased Implementation Plan

---

**Document Status:** ✅ Approved as Foundation

This document serves as the **source of truth** for the application's purpose, scope, and vision. All subsequent documents should align with the goals and constraints defined here.
