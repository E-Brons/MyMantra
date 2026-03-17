# MyMantra

A spiritual practice application for mantra repetition, streaks, and progress tracking.
Built with Flutter — targets iOS, Android, macOS, Windows, and Web from a single codebase.

---

## Quick Start

```bash
make install   # First-time: install tools and verify environment
make debug     # Run the app with hot reload (defaults to macOS)
```

To target a specific platform:

```bash
make debug TARGET=macos
make run   TARGET=ios
make run   TARGET=android
make run   TARGET=web
make run   TARGET=windows
```

Target configuration (devices, versions, build flags) is in [`target.json`](target.json).

---

## Prerequisites

- **macOS 26+** (primary development), or **Windows 10+** (web/windows targets)
- **Homebrew** — [brew.sh](https://brew.sh) (macOS only)
- **Xcode 16+** — install from the Mac App Store, or using `xcodes` then run:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```
- **Android Studio** — required for Android target; install the Android SDK and create an AVD via the AVD Manager
- **adb** (Android Debug Bridge) — bundled with Android Studio; ensure `platform-tools` is on your `PATH`

> **Windows developers:** You only need Flutter SDK, Git, and VS Code. Run `make install TARGET=windows` or `make install TARGET=web` to get started. Xcode, Homebrew, and Android Studio are not needed for web/windows targets.

`make install` checks and installs Flutter and all remaining dependencies automatically.

---

## Make Commands

| Command                            | What it does                            |
| ---------------------------------- | --------------------------------------- |
| `make install [TARGET=<t>]`        | Install tools and verify environment    |
| `make debug [TARGET=<t>]`          | Run with hot reload                     |
| `make run [TARGET=<t>]`            | Run release build                       |
| `make build [TARGET=<t>]`          | Build release artifacts                 |
| `make test`                        | `flutter analyze` + unit + widget tests |
| `make test-integration TARGET=<t>` | Integration tests (linux, macos, or windows) |
| `make clean`                       | Remove all build artifacts              |

---

## Project Structure

```
lib/
├── main.dart
└── src/
    ├── app/
    │   ├── app.dart                    # MaterialApp.router entry
    │   ├── router.dart                 # go_router navigation
    │   └── theme/                      # AppColors, AppTheme
    ├── core/
    │   ├── models/                     # Mantra, Session, Progress, Settings, Achievement
    │   ├── providers/                  # AppNotifier (Riverpod) — all state
    │   ├── services/                   # StorageService (SharedPreferences), HapticService
    │   └── utils/                      # date_utils (streak calc, ID gen, formatters)
    ├── features/
    │   ├── mantras/screens/            # HomeScreen, MantraDetailScreen, CreateMantraScreen
    │   ├── session/screens/            # SessionScreen (ring counter, haptics, celebration)
    │   ├── library/
    │   │   ├── data/                   # built_in_mantras, LibraryMantra model
    │   │   └── screens/                # LibraryScreen
    │   ├── progress/screens/           # ProgressScreen (stats + achievements)
    │   └── settings/screens/           # SettingsScreen
    └── shared/widgets/                 # AppScaffold (bottom nav shell)
```

---

## Documentation

| Document                                                                | Description                                                      |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [Application Foundations](docs/product/application_foundations.md)      | Vision, goals, and guiding principles                            |
| [Product Requirements (PRD)](docs/product/product_requirements.md)      | Full feature requirements, UX flows, KPIs                        |
| [Built-in Mantras Library](docs/product/builtin_mantras_library.md)     | Curated mantra content with Sanskrit/English/Hebrew metadata     |
| [Software Architecture](docs/software/software_architecture.md)         | Clean Architecture layers, module structure, tech stack          |
| [Software Requirements (SRS)](docs/software/software_requirements.md)   | Functional and non-functional requirements                       |
| [Folder Structure](docs/software/folder_structure.md)                   | Annotated source layout                                          |
| [Build System Architecture](docs/software/build-system-architecture.md) | Make targets, `target.json`, toolchain stages                    |
| [Git Workflow](docs/software/git_workflow.md)                           | Branching strategy, commit conventions, merge gate, release flow |

Full list with versions and status: [`docs/catalog.csv`](docs/catalog.csv).

### Contributor quick-reference

| I want to…                                            | Start here                                                                                                                                                    |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Open a PR or understand the branch/commit/merge rules | [Git Workflow](docs/software/git_workflow.md)                                                                                                                 |
| Implement a feature                                   | [PRD](docs/product/product_requirements.md) → [SRS](docs/software/software_requirements.md) → [Software Architecture](docs/software/software_architecture.md) |
| File a bug                                            | [SRS](docs/software/software_requirements.md) — identify the violated requirement                                                                             |
| Fix a bug                                             | [Git Workflow §8](docs/software/git_workflow.md) — follow the Red → Green testing idiom                                                                       |


