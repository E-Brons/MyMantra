# MyMantra Documentation Index

**Application Name:** MyMantra
**Version:** 0.1 (All Documents)
**Last Updated:** November 2025

---

## Document Overview

This folder contains the complete documentation suite for the **MyMantra** spiritual practice application. All documents have been aligned to use consistent terminology and the official application name "MyMantra."

---

## Setup Guides

### S1. VS Code Setup (`vscode-setup.md`)
**Status:** ✅ Updated for Flutter
**Purpose:** Configure Visual Studio Code for Flutter/Dart development

**Key Content:**
- Required extensions (Flutter, Dart, Pubspec Assist)
- Running and debugging with hot reload
- Code generation workflow

---

### S2. Flutter Build Environment (`flutter-build-environment.md`)
**Status:** ✅ Flutter stack
**Purpose:** Environment setup for all target platforms

**Key Content:**
- Flutter SDK and Dart installation
- iOS (Xcode), Android (Android Studio), macOS, Web setup
- Build and run commands for each platform
- Useful Flutter CLI reference

---

## Core Documents

### 1. Application Goals (`application_goals.md`)
**Status:** ✅ Aligned
**Purpose:** Foundation document capturing the original vision and requirements

**Key Content:**
- Multi-platform vision (iOS, Android, macOS, Windows, Web)
- Core features and user modes
- Gamification strategy (achievements, streaks)
- Cloud sync architecture (user-owned storage)
- Version roadmap (1.0, 2.0, 3.0)

**Application Name References:** Updated to "MyMantra"

---

### 2. Product Requirements Document (`product_requirements.md`)
**Status:** ✅ Aligned
**Purpose:** Comprehensive product specifications and market analysis

**Key Content:**
- Executive summary and product vision
- Market analysis and competitive positioning
- Detailed feature requirements by phase
- User experience flows and wireframes
- Success metrics and KPIs
- Technical requirements
- Built-in Mantras Library (featuring Yoga Sutra I.12)
- 60+ pages of specifications

**Application Name References:** Updated to "MyMantra"
**Bundle ID Convention:** `com.mymantra.*`
**Cloud Folder Names:** `/MyMantra/` (Google Drive), `MyMantra` (iCloud)
**Deep Link Scheme:** `mymantra://`
**Signature Mantra:** Yoga Sutra I.12 (abhyāsa-vairāgya)

---

### 3. Software Architecture Document (`mantra_architecture.md`)
**Status:** ✅ Aligned
**Purpose:** Technical architecture and design patterns

**Key Content:**
- Clean Architecture implementation
- Cloud sync service architecture (Google Drive, iCloud)
- Audio recording and playback service
- Database schema (Isar)
- Technology stack
- Cross-cutting concerns
- Use case flows

**Application Name References:** Updated to "MyMantra"
**Method Channel:** `com.mymantra/icloud`
**Package Identifiers:** Consistent with MyMantra branding

---

### 4. Software Requirements Specification (`mantra_srs.md`)
**Status:** ✅ Aligned
**Purpose:** Detailed functional and non-functional requirements

**Key Content:**
- 60+ specific requirements (SR-1.1 through SR-9.3)
- Mantra management module
- Reminder and notification system
- Session experience requirements
- Progress tracking and streaks
- Cloud synchronization (Phase 2.0)
- Audio recording features (Phase 2.0)
- Achievements system (Phase 3.0)
- Data models and acceptance criteria

**Application Name References:** Updated to "MyMantra"
**System Context Diagram:** Shows "MyMantra" as central component
**Deep Link Format:** `mymantra://session/[mantraId]`

---

### 5. Phased Implementation Plan (`phased_implementation.md`)
**Status:** ✅ Aligned
**Purpose:** Week-by-week development roadmap with tasks

**Key Content:**
- **Phase 1.0** (Months 1-3): MVP - Offline features
- **Phase 2.0** (Months 4-5): Cloud sync + Audio + macOS/Web
- **Phase 3.0** (Months 6-7): Achievements + Gamification
- Detailed sprint breakdowns (15+ sprints)
- Testing procedures for each phase
- Deployment checklists (App Store, Play Store)
- Resource requirements and risk mitigation

**Application Name References:** Updated to "MyMantra"
**Project Name:** `flutter create mymantra`
**App Store Title:** "MyMantra - Practice & Reminders"
**Signing Keys:** `mymantra-release-key.jks`
**Cloud Folders:** "MyMantra" folder in Drive/iCloud

---

### 6. Built-in Mantras Library (`builtin_mantras_library.md`)
**Status:** ✅ Initial Collection
**Purpose:** Curated collection of traditional mantras with multi-language support

**Key Content:**
- **Signature Mantra:** Yoga Sutra I.12 (Patanjali)
  - Sanskrit (Devanagari): अभ्यासवैराग्याभ्यां तन्निरोधः॥
  - Sanskrit (IAST): abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ
  - English: "Through steady practice and dispassion, the mind is stilled"
  - Hebrew: בהתמדה ובאי-היקשרות — הנפש שקטה
- Cultural context and pronunciation guides
- In-app metadata (JSON format)
- Integration with MyMantra philosophy
- Future mantras planned (Om, Gayatri, Om Mani Padme Hum, etc.)

**Why Yoga Sutra I.12:**
This sutra embodies the MyMantra philosophy:
- **Abhyāsa (practice):** Encouraged through reminders and streaks
- **Vairāgya (dispassion):** Privacy-first, no social comparison
- **Nirodhaḥ (stillness):** The ultimate goal of the app

---

## Document Consistency Checklist

### Application Name
- [x] All documents use "MyMantra" as the official name
- [x] Headers updated to "MyMantra - Spiritual Practice Application"
- [x] Version 2.0 across all documents (except goals = 1.0)

### Technical Identifiers
- [x] Bundle ID pattern: `com.mymantra.*`
- [x] Deep link scheme: `mymantra://`
- [x] Cloud folder: `/MyMantra/` (Google Drive), `MyMantra` (iCloud)
- [x] Method channels: `com.mymantra/*`
- [x] Flutter project: `mymantra`
- [x] Keystore: `mymantra-release-key.jks`

### Terminology Consistency
- [x] "MyMantra" (not "Mantra App", "MantraApp", or "Mantra Practice App")
- [x] "Spiritual Practice Application" as subtitle
- [x] "Session" (not "practice session" or "meditation session")
- [x] "Streak" (not "daily streak" unless specifying)
- [x] "Cloud sync" (not "cloud synchronization" in casual references)

### Version Alignment
- [x] Product Requirements: v0.1
- [x] Architecture Document: v0.1
- [x] SRS: v0.1
- [x] Implementation Plan: v0.1
- [x] Application Goals: v0.1
- [x] Built-in Mantras Library: v0.1

### Platform Naming
All documents consistently reference:
- iOS 14+
- Android 8.0+ (API 26+)
- macOS 11.0+ (Phase 2.0)
- Web (Chrome 90+, Safari 14+) (Phase 2.0)
- Windows 10+ (Phase 3.0+)

### Feature Phase Alignment
All documents agree on phase breakdown:
- **Phase 1.0**: Offline MVP (mantra management, sessions, reminders, progress)
- **Phase 2.0**: Cloud sync (Google/iCloud), voice recording, macOS/Web
- **Phase 3.0**: Achievements (14+ badges), points, shareable images

---

## Cross-References

### Application Goals → PRD
- Vision statement aligns with PRD Executive Summary
- Phase roadmap matches PRD feature phases
- Gamification details elaborated in PRD Section 4.9-4.10

### PRD → Architecture
- Technical requirements (Section 6) implemented in Architecture
- Cloud sync strategy (FR-7.2) detailed in Architecture Section 5.2
- Audio features (FR-8.x) detailed in Architecture Section 5.3

### Architecture → SRS
- Component design maps to functional requirements
- Data models in Architecture match SRS Section 4.1
- Use cases in Architecture satisfy requirements in SRS Section 3

### SRS → Implementation Plan
- Each SR-x.x requirement has corresponding task(s) in sprints
- Acceptance criteria in SRS tested in Phase testing sections
- Data models implemented in Sprint 2 (Week 5-6)

---

## Document Update Log

| Date | Documents Updated | Changes |
|------|------------------|---------|
| 2025-11-24 | All (6 docs) | Initial creation - v0.1 draft |
| 2025-11-24 | All (6 docs) | Updated to use "MyMantra" branding |
| 2025-11-24 | All (6 docs) | Aligned technical identifiers (bundle IDs, deep links) |
| 2026-03-04 | Setup guides | Migrated from React Native to Flutter stack; replaced ios-build-environment.md with flutter-build-environment.md; updated vscode-setup.md and folder_structure.md |

---

## Next Steps for Team

### Before Starting Development
1. [ ] Review all 5 documents as a team
2. [ ] Approve naming conventions and branding
3. [ ] Reserve bundle IDs:
   - iOS: `com.mymantra.ios` (or your choice)
   - Android: `com.mymantra.android`
   - macOS: `com.mymantra.macos`
   - Web: `mymantra.app` domain (optional)
4. [ ] Setup design tools (Figma) with MyMantra branding
5. [ ] Create project repository: `github.com/[org]/mymantra`
6. [ ] Begin Phase 1.0 Week 1 (Specification)

### During Development
- Keep this index updated as documents evolve
- Reference document sections by name (e.g., "PRD Section 4.1")
- Update version numbers when making major revisions
- Cross-check changes across related documents

---

## Contact & Ownership

**Document Owner:** Product Team
**Technical Lead:** [TBD]
**Last Reviewed:** November 24, 2025
**Next Review:** Start of each phase

---

## Appendix: Quick Reference

### Key Numbers
- **Total Requirements:** 60+ (SR-1.1 to SR-9.3)
- **Development Timeline:** 7 months (3 phases)
- **Platforms:** 5 (iOS, Android, macOS, Web, Windows future)
- **Achievements:** 14+ badges
- **Target Users:** 10K downloads (6 months)

### Key Technologies
- **Framework:** Flutter 3.16+
- **Database:** Isar 3.1+
- **State:** Riverpod 2.5+
- **Cloud:** Google Drive API, iCloud (CloudKit)
- **Audio:** record, audioplayers packages

### Key Features by Phase
**1.0:** Offline mantra practice, reminders, streaks
**2.0:** Cloud sync, voice recording, multi-platform
**3.0:** Achievements, points, social sharing

---

**End of Documentation Index**

All documents are now aligned and ready for development kickoff! 🚀
