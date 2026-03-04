# VS Code Setup Guide for MyMantra

This guide will help you set up Visual Studio Code to develop and run the Flutter-based MyMantra application.

---

## 1. Required VS Code Extensions

VS Code will automatically suggest these extensions when you open the project (from `.vscode/extensions.json`):

### Essential Extensions

1. **Flutter** (`Dart-Code.flutter`)
   - Full Flutter development support: run, debug, hot reload
   - Device picker, widget inspector, DevTools integration

2. **Dart** (`Dart-Code.dart-code`)
   - Dart language support (auto-installed with the Flutter extension)
   - Code analysis, formatting, and completion

3. **Pubspec Assist** (`jeroen-meijer.pubspec-assist`)
   - Quick dependency management for `pubspec.yaml`

### Recommended Extensions

4. **Error Lens** (`usernamehw.errorlens`)
   - Inline error and warning display

5. **GitLens** (`eamodio.gitlens`)
   - Enhanced git history and blame

### Installation

1. Open VS Code
2. Go to Extensions (⌘+Shift+X)
3. Click "Show Recommendations" in the Extensions sidebar
4. Click "Install Workspace Recommended Extensions"

Or install manually:
```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension jeroen-meijer.pubspec-assist
```

---

## 2. Prerequisites

### Install Flutter SDK

```bash
# macOS (Homebrew recommended)
brew install flutter

# Verify installation and check for issues
flutter doctor
```

All green checkmarks from `flutter doctor` are required before building. Fix any issues reported before proceeding.

See `docs/flutter-build-environment.md` for full environment setup details.

---

## 3. Running the App

```bash
# Check available devices and simulators
flutter devices

# Run on iOS Simulator
flutter run -d "iPhone 15 Pro"

# Run on Android Emulator
flutter run -d emulator-5554

# Run on web (Chrome)
flutter run -d chrome

# Run on macOS
flutter run -d macos
```

---

## 4. VS Code Debugging (Flutter)

### Run & Debug

1. Open VS Code
2. Go to **Run and Debug** (⌘+Shift+D)
3. Select a launch configuration from the dropdown
4. Press **F5** to start

Features available in debug mode:
- Hot reload (press `r` in terminal or click the lightning bolt icon)
- Hot restart (press `R`)
- Flutter Widget Inspector
- Flutter DevTools (Performance, Memory, Network)

### Hot Reload vs Hot Restart

| Action | When to use | Shortcut |
|--------|-------------|----------|
| Hot Reload | UI changes, widget rebuilds | ⌘+\ or `r` in terminal |
| Hot Restart | State reset, new app logic | Shift+⌘+\ or `R` in terminal |
| Full Restart | Dependency changes | Stop + Start |

---

## 5. Useful VS Code Shortcuts

### Navigation
- **⌘+P**: Quick file open
- **⌘+Shift+F**: Search in files
- **⌘+B**: Toggle sidebar
- **⌘+`**: Toggle terminal

### Editing
- **⌘+D**: Select next occurrence
- **⌥+↑/↓**: Move line up/down
- **⌘+/**: Toggle comment
- **⌥+Shift+F**: Format document (Dart formatter)

### Debugging
- **F5**: Start debugging
- **Shift+F5**: Stop debugging
- **⌘+\\**: Hot reload
- **Shift+⌘+\\**: Hot restart
- **F9**: Toggle breakpoint
- **F10**: Step over
- **F11**: Step into

---

## 6. Project Structure in VS Code

```
myMantra/
├── .vscode/                # VS Code configuration
│   ├── extensions.json     # Recommended extensions
│   ├── launch.json         # Flutter debug configurations
│   └── settings.json       # Editor settings (Dart formatter, etc.)
├── lib/                    # Main Flutter/Dart source code
├── test/                   # Unit and widget tests
├── assets/                 # Images, fonts, audio files
├── docs/                   # Documentation (this file)
└── pubspec.yaml            # Flutter dependencies & metadata
```

---

## 7. Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run a specific test file
flutter test test/features/mantras/mantra_test.dart
```

---

## 8. Code Generation

Isar database models and Riverpod code generation must be run after modifying annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use the watch mode during active development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **Dart Docs**: https://dart.dev/guides
- **Flutter VS Code Extension**: https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
- **Riverpod Docs**: https://riverpod.dev/
- **Isar DB Docs**: https://isar.dev/
