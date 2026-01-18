# iOS Build Environment & Setup

## Toolchains

This project has been successfully built and tested with the following configuration:

### ver 1.0.0 - January 2026
#### Required Tools & Versions

- **macOS**: 15.x or later (ARM 64 - Apple Silicon)
- **Xcode**: 16.0 or later
  - iOS SDK: 19.0
  - Command Line Tools installed
- **Node.js**: 18.x or later
- **npm**: 9.x or later
- **CocoaPods**: 1.16.x or later
- **React Native**: 0.76.9

#### iOS Deployment Targets

- **Minimum iOS Version**: 15.1
- **Target Devices**: iPhone 13 and newer
- **Simulators**: iOS 15.1

## Initial Setup

### 1. Install Prerequisites

```bash
# Install Node.js (if not already installed)
# Download from https://nodejs.org/ or use Homebrew:
brew install node

# Install CocoaPods
sudo gem install cocoapods

# Verify Xcode Command Line Tools
xcode-select --install
```

### 2. Install Project Dependencies

```bash
# From project root
npm install

# Install iOS dependencies
cd ios
pod install
cd ..
```

### 3. Build and Run

```bash
# Run on iOS Simulator
npm run ios

# Or specify a device
npm run ios -- --simulator="iPhone 15 Pro"
```

## Project Configuration

### Podfile

The `ios/Podfile` is configured for:
- iOS 15.0+ deployment target
- React Native 0.76.9
  - react-native-reanimated from version 3.16.7
- New Architecture disabled (for compatibility)
- Hermes JavaScript engine enabled

### Xcode Project Settings

- **Project**: TempProject.xcodeproj
- **Workspace**: TempProject.xcworkspace (use this, not .xcodeproj)
- **Scheme**: TempProject
- **Bundle Identifier**: Configured in project settings

## Version Compatibility

### React Native 0.76.9 + Xcode 16

This combination is **officially supported** and tested:
- ✅ No patches required
- ✅ Full Xcode 16 compatibility
- ✅ iOS SDK 19.0 support
- ✅ Apple Silicon (M1/M2/M3) native support

## Build Types

### Debug Build (Development)

```bash
npm run ios
```

- Includes Metro bundler
- Hot reloading enabled
- Developer menu accessible (Cmd+D in simulator)
- Connects to localhost:8081

### Release Build (Production)

```bash
# Build release version
cd ios
xcodebuild -workspace TempProject.xcworkspace \
  -scheme TempProject \
  -configuration Release \
  -sdk iphonesimulator \
  -derivedDataPath build
```

## Additional Resources

- [React Native Environment Setup](https://reactnative.dev/docs/environment-setup)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [Xcode Release Notes](https://developer.apple.com/documentation/xcode-release-notes)
