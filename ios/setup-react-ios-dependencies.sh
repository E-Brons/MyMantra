#!/bin/bash

# iOS Dependencies Setup Script for React Native 0.76
# Run this script on a machine with GitHub access

set -e

echo "========================================="
echo "React Native 0.76 - iOS Setup"
echo "========================================="
echo ""

# Check if we're in the ios directory
if [ ! -f "Podfile" ]; then
    echo "Error: Podfile not found. Please run this script from the ios/ directory."
    exit 1
fi

# Check for cmake (required for Hermes)
if ! command -v cmake &> /dev/null; then
    echo "Warning: cmake not found in PATH"
    echo "Looking for Xcode cmake..."

    XCODE_CMAKE="/Applications/Xcode.app/Contents/Developer/usr/local/bin/cmake"
    if [ -f "$XCODE_CMAKE" ]; then
        echo "Found Xcode cmake at: $XCODE_CMAKE"
        export PATH="/Applications/Xcode.app/Contents/Developer/usr/local/bin:$PATH"
    else
        echo "Error: cmake not found. Please install Xcode Command Line Tools."
        exit 1
    fi
fi

echo "Step 1: Cleaning previous installation..."
rm -rf Pods Podfile.lock

echo ""
echo "Step 2: Installing CocoaPods dependencies..."
echo "This will download dependencies from GitHub (requires internet access)"
pod install

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================="
    echo "Error: Pod installation failed"
    echo "========================================="
    exit 1
fi

# Verify critical files exist
echo ""
echo "Step 3: Verifying installation..."

if [ ! -d "Pods/Target Support Files/Pods-TempProject" ]; then
    echo "❌ ERROR: Pods/Target Support Files/Pods-TempProject is missing!"
    echo "This means pod install did not complete successfully."
    exit 1
fi

if [ ! -f "Podfile.lock" ]; then
    echo "❌ ERROR: Podfile.lock is missing!"
    exit 1
fi

echo "✅ Pods/Target Support Files/Pods-TempProject exists"
echo "✅ Podfile.lock exists"

echo ""
echo "=========================================================="
echo " ✅ Success! React Native 0.76 iOS dependencies installed "
echo "=========================================================="
echo ""

