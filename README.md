# MyMantra

A spiritual practice application for mantra repetition, streaks, and progress tracking.
Built with Flutter — targets iOS, Android, macOS, and Web from a single codebase.

---

## Quick Start

```bash
make setup        # First-time: installs Flutter, scaffolds platform dirs, gets deps
make run-web      # Run in Chrome (no emulator needed)
```

---

## Installation

### Prerequisites

- **macOS 12+** (for iOS/macOS targets)
- **Homebrew** — [brew.sh](https://brew.sh)
- **Xcode 16+** — install from the Mac App Store, then run:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```

### Step-by-step

```bash
# 1. Install Flutter SDK
make install-flutter    # runs: brew install flutter

# 2. Scaffold platform directories (ios/, android/, macos/, web/)
#    Only needed once — safe to re-run, existing lib/ is preserved
make scaffold

# 3. Install dependencies
make get

# 4. Install CocoaPods dependencies (iOS/macOS only)
make pods

# 5. Add fonts (download from Google Fonts)
#    Place in assets/fonts/:
#      - Cinzel-Regular.ttf, Cinzel-SemiBold.ttf, Cinzel-Bold.ttf
#      - NotoSansDevanagari-Regular.ttf, NotoSansDevanagari-Medium.ttf
#    Download: https://fonts.google.com/specimen/Cinzel
#              https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari

# 6. Check everything is healthy
make doctor
```

Or run all of the above in one go:

```bash
make setup
```

---

## Running the App

### Recommended order for development

| Target | Command | Requirement |
|--------|---------|-------------|
| Web (Chrome) | `make run-web` | None — fastest to start |
| iOS Simulator | `make run-ios` | Xcode + Simulator (included with Xcode) |
| macOS | `make run-macos` | Xcode |
| Android Emulator | `make run-android` | Android Studio + AVD |

**Web is the recommended starting point** — no emulator, no provisioning profiles,
instant hot reload. Switch to iOS Simulator once you need to validate native behaviour
(haptics, notifications, safe-area).

### Hot reload

With the app running, press `r` in the terminal to hot-reload, `R` to hot-restart.
In VS Code, use the Flutter sidebar or `F5` to launch with full debug support.

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart               # MaterialApp.router entry
│   ├── router.dart            # go_router navigation
│   └── theme/                 # AppColors, AppTheme
├── core/
│   ├── models/                # Mantra, Session, Progress, Settings, Achievement
│   ├── providers/             # AppNotifier (Riverpod) — all state
│   ├── services/              # StorageService (SharedPreferences), HapticService
│   └── utils/                 # date_utils (streak calc, ID gen, formatters)
├── features/
│   ├── mantras/screens/       # HomeScreen, MantraDetailScreen, CreateMantraScreen
│   ├── session/screens/       # SessionScreen (ring counter, haptics, celebration)
│   ├── library/               # LibraryScreen + 7 built-in mantras
│   ├── progress/screens/      # ProgressScreen (stats + 14 achievements)
│   └── settings/screens/      # SettingsScreen
└── shared/widgets/            # AppScaffold (bottom nav shell)
```

---

## Make Commands

```bash
# Setup
make install-flutter   Install Flutter SDK via Homebrew
make scaffold          Generate platform dirs (run once)
make get               flutter pub get
make pods              pod install (iOS/macOS)
make setup             Full first-time setup (all of the above)
make doctor            flutter doctor

# Run (debug)
make run-web           Chrome
make run-ios           iOS Simulator
make run-macos         macOS native
make run-android       Android Emulator

# Build (release)
make build-web         Build web release → build/web/
make build-ios         Build iOS .ipa
make build-android     Build Android .aab
make build-macos       Build macOS .app

# Quality
make test              flutter test
make test-coverage     flutter test --coverage
make lint              flutter analyze
make clean             Remove build artifacts
```

---

## Design Reference

The Figma/React prototype is preserved in git history at commit `8c03645`.
To browse it: `git show 8c03645:src/pages/Session.tsx`

---

## Docs

See `docs/` for the full documentation suite:

- `flutter-build-environment.md` — platform-specific build setup
- `vscode-setup.md` — VS Code configuration
- `folder_structure.md` — Clean Architecture layout
- `product_requirements.md` — PRD (60+ pages)
- `mantra_architecture.md` — Technical architecture
