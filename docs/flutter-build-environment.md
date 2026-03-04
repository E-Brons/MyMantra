# Flutter Build Environment & Setup
## MyMantra - Spiritual Practice Application

**Framework:** Flutter 3.16+ / Dart 3.2+
**Last Updated:** March 2026

---

## Technology Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.16+ | Cross-platform framework |
| Dart | 3.2+ | Programming language |
| Xcode | 16.0+ | iOS / macOS builds |
| Android Studio | 2023.x+ | Android SDK and emulator |
| CocoaPods | 1.16+ | iOS native dependency management |

---

## Platform Targets

| Platform | Min Version | Phase |
|----------|-------------|-------|
| iOS | 14.0+ | 1.0 |
| Android | 8.0+ (API 26) | 1.0 |
| macOS | 11.0+ | 2.0 |
| Web | Chrome 90+, Safari 14+ | 2.0 |
| Windows | 10+ | 3.0 |

---

## Initial Setup

### 1. Install Flutter SDK

```bash
# macOS — Homebrew (recommended)
brew install flutter

# Verify installation
flutter doctor
```

All items in `flutter doctor` output must be green before building for any platform. Address each reported issue before proceeding.

### 2. iOS Setup (macOS only)

```bash
# Install Xcode from the Mac App Store (required: version 16.0+)

# Install Xcode Command Line Tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept

# Install CocoaPods (Flutter iOS dependency manager)
sudo gem install cocoapods
```

### 3. Android Setup

1. Download and install [Android Studio](https://developer.android.com/studio)
2. Open **SDK Manager**: `Android Studio → Settings → Android SDK`
3. Install:
   - Android SDK Platform (API 26+)
   - Android SDK Build-Tools
   - Android Emulator
4. Accept all licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### 4. Install Project Dependencies

```bash
# From the project root
flutter pub get

# Generate Isar models and Riverpod code
dart run build_runner build --delete-conflicting-outputs
```

---

## Building

### iOS

```bash
# Debug — runs on iOS Simulator
flutter run -d "iPhone 15 Pro"

# Release build (for App Store)
flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
# Then archive and upload via Xcode → Product → Archive
```

### Android

```bash
# Debug — runs on Android Emulator
flutter run -d emulator-5554

# Release AAB (recommended for Google Play)
flutter build appbundle --release --obfuscate --split-debug-info=build/android/symbols

# Release APK (for direct distribution / testing)
flutter build apk --release
```

### macOS

```bash
# Debug
flutter run -d macos

# Release
flutter build macos --release
```

### Web

```bash
# Debug (Chrome)
flutter run -d chrome

# Release (output: build/web/)
flutter build web --release
```

---

## Useful Flutter Commands

```bash
# Check environment health
flutter doctor

# List connected devices and simulators
flutter devices

# Install / update dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Run code generation (Isar models, Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run all tests
flutter test

# Run tests with coverage report
flutter test --coverage

# Static analysis
flutter analyze

# Update Flutter SDK
flutter upgrade
```

---

## Version History

| Version | Date | Tools | Notes |
|---------|------|-------|-------|
| 1.0 | March 2026 | Flutter 3.16+, Xcode 16, Dart 3.2+ | Initial Flutter environment |

---

## Additional Resources

- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
- [Flutter Doctor Troubleshooting](https://docs.flutter.dev/get-started/install/macos)
- [Xcode Release Notes](https://developer.apple.com/documentation/xcode-release-notes)
- [Android Studio Setup](https://developer.android.com/studio/install)
- [Isar Database Docs](https://isar.dev/)
- [Riverpod Docs](https://riverpod.dev/)
