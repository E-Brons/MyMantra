# VS Code Setup Guide for MyMantra

This guide will help you set up Visual Studio Code to view mockups and run React Native on a simulated phone (iOS Simulator on Mac).

---

## 1. Required VS Code Extensions

VS Code will automatically suggest these extensions when you open the project (from `.vscode/extensions.json`):

### Essential Extensions:
1. **React Native Tools** (`msjsdiag.vscode-react-native`)
   - Debug React Native apps
   - Run on iOS Simulator/Android Emulator
   - IntelliSense for React Native APIs

2. **ESLint** (`dbaeumer.vscode-eslint`)
   - Linting for JavaScript/TypeScript

3. **Prettier** (`esbenp.prettier-vscode`)
   - Code formatting

4. **ES7+ React/Redux/React-Native snippets** (`dsznajder.es7-react-js-snippets`)
   - Code snippets for faster development

### Installation:
1. Open VS Code
2. Go to Extensions (⌘+Shift+X)
3. Click "Show Recommendations" in the Extensions sidebar
4. Click "Install Workspace Recommended Extensions"

Or install manually:
```bash
code --install-extension msjsdiag.vscode-react-native
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension dsznajder.es7-react-js-snippets
```

---

## 2. Prerequisites (Required Before Running)

### Install Xcode (for iOS Simulator on Mac)
```bash
# 1. Install Xcode from Mac App Store (15+ GB, takes time)
# 2. After installation, install command line tools:
xcode-select --install

# 3. Accept Xcode license
sudo xcodebuild -license accept

# 4. Install iOS Simulator (open Xcode once)
open -a Xcode
```

### Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Node.js
```bash
brew install node
# Verify
node --version  # Should be 18.x or higher
npm --version
```

### Install Watchman (for file watching)
```bash
brew install watchman
```

### Install CocoaPods (for iOS dependencies)
```bash
sudo gem install cocoapods
```

---

## 3. React Native Approach

### Expo (Recommended for Beginners) ⭐

**Pros:**
- Faster setup
- Built-in components
- Easy preview
- Over-the-air updates

**Setup:**
```bash
# Install Expo CLI globally
npm install -g expo-cli

# Initialize Expo project
npx create-expo-app@latest myMantra --template blank-typescript

# Move into project
cd myMantra

# Start Expo
npx expo start

# Press 'i' to open iOS Simulator
# Press 'a' to open Android Emulator
```

---

## 4. Viewing the Mockups

The mockups are currently in TypeScript/React Native format but **won't render directly** in VS Code. Here are your options:

### Option 1: Run in Simulator (Best Option)

1. **Initialize React Native project** (see section 3)
2. **Copy the mockup code** from `src/screens/mockups.tsx`
3. **Import in App.tsx**:
   ```typescript
   import { WelcomeScreen } from './src/screens/mockups';

   export default function App() {
     return <WelcomeScreen />;
   }
   ```
4. **Run the app**:
   ```bash
   # Expo
   npx expo start
   # then press 'i' for iOS

   # Or React Native CLI
   npx react-native run-ios
   ```

### Option 2: Use Expo Snack (Online Preview)

1. Go to https://snack.expo.dev/
2. Copy paste the mockup code
3. View live preview in browser or scan QR code on your phone

### Option 3: Storybook (Component Library)

```bash
# Install Storybook
npx sb init --type react_native

# Run Storybook
npm run storybook
```

---

## 5. Running iOS Simulator from VS Code

### Method 1: Using Debugger (Recommended)

1. Open VS Code
2. Go to Run and Debug (⌘+Shift+D)
3. Select "Run iOS (Simulator)" from dropdown
4. Press F5 (or click green play button)

This will:
- Start Metro bundler
- Launch iOS Simulator
- Install and run your app
- Enable debugging with breakpoints

### Method 2: Using Terminal in VS Code

1. Open integrated terminal (⌘+`)
2. Run:
   ```bash
   # Expo
   npx expo start
   # Press 'i' when Metro starts

   # React Native CLI
   npx react-native run-ios
   # Or specify simulator
   npx react-native run-ios --simulator="iPhone 15"
   ```

### Method 3: Using Tasks

1. Press ⌘+Shift+P
2. Type "Tasks: Run Task"
3. Select "Run iOS Simulator"

---

## 6. Available iOS Simulators

List available simulators:
```bash
xcrun simctl list devices
```

Run specific simulator:
```bash
# React Native CLI
npx react-native run-ios --simulator="iPhone 15 Pro"
npx react-native run-ios --simulator="iPhone 15 Pro Max"
npx react-native run-ios --simulator="iPad Pro"

# Or open simulator directly
open -a Simulator
```

---

## 7. Debugging in VS Code

### Set Breakpoints
1. Click left of line number to set breakpoint (red dot)
2. Run debugger (F5)
3. App will pause at breakpoint
4. Inspect variables in Debug sidebar

### Debug Console
- **Console output**: Shows console.log() statements
- **Watch variables**: Add variables to watch
- **Call stack**: See function call hierarchy

### React DevTools
```bash
# Install React DevTools
npm install -g react-devtools

# Run (in separate terminal)
react-devtools
```

---

## 8. Useful VS Code Shortcuts

### Navigation
- **⌘+P**: Quick file open
- **⌘+Shift+F**: Search in files
- **⌘+B**: Toggle sidebar
- **⌘+`**: Toggle terminal

### Editing
- **⌘+D**: Select next occurrence
- **⌥+↑/↓**: Move line up/down
- **⌘+/**: Toggle comment
- **⌥+Shift+F**: Format document

### Debugging
- **F5**: Start debugging
- **⌘+Shift+F5**: Restart debugging
- **Shift+F5**: Stop debugging
- **F9**: Toggle breakpoint
- **F10**: Step over
- **F11**: Step into

---

## 9. Project Structure in VS Code

```
myMantra/
├── .vscode/              # ✅ VS Code configuration
│   ├── extensions.json   # Recommended extensions
│   ├── launch.json       # Debugger configuration
│   ├── settings.json     # Editor settings
│   └── *.code-snippets   # Code snippets
├── src/
│   ├── theme/            # ✅ Theme system
│   └── screens/
│       └── mockups.tsx   # ✅ Screen mockups
└── docs/
    └── vscode-setup.md   # This file
```

## Quick Start (TL;DR)

```bash
# 1. Install Xcode from App Store (if not installed)

# 2. Install prerequisites
xcode-select --install
brew install node watchman
sudo gem install cocoapods

# 3. Install VS Code extensions
# (VS Code will prompt when you open the project)

# 4. Initialize Expo project
npx create-expo-app@latest myMantra --template blank-typescript
cd myMantra

# 5. Copy mockup code to App.tsx

# 6. Run
npx expo start
# Press 'i' for iOS Simulator

# 7. Open VS Code debugger (⌘+Shift+D) and press F5
```

---

## Resources

- **React Native Docs**: https://reactnative.dev/
- **Expo Docs**: https://docs.expo.dev/
- **VS Code React Native**: https://marketplace.visualstudio.com/items?itemName=msjsdiag.vscode-react-native
- **iOS Simulator**: https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device
