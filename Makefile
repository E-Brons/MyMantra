# ==========================================
#  Flutter Project Makefile — MyMantra
# ==========================================
#
# REQUIREMENTS:
#   Flutter SDK 3.16+  →  brew install flutter
#   Xcode 16.0+        →  Mac App Store (iOS/macOS)
#   Android Studio     →  developer.android.com/studio (Android)
#
# QUICK START:
#   make doctor        Check Flutter environment health
#   make get           Install dependencies
#   make run-ios       Run on iOS Simulator
#
# ==========================================

.PHONY: help doctor get clean build-runner \
        run-ios run-android run-macos run-web \
        build-ios build-android build-macos build-web \
        test test-coverage lint

help:
	@echo ""
	@echo "==================================================="
	@echo " Flutter Project Makefile (MyMantra)"
	@echo "==================================================="
	@echo ""
	@echo "Environment:"
	@echo "  make doctor          Run flutter doctor"
	@echo "  make get             Install/update dependencies"
	@echo "  make clean           Clean build artifacts"
	@echo "  make build-runner    Generate Isar/Riverpod code"
	@echo ""
	@echo "Run (debug):"
	@echo "  make run-ios         Run on iOS Simulator"
	@echo "  make run-android     Run on Android Emulator"
	@echo "  make run-macos       Run on macOS"
	@echo "  make run-web         Run in Chrome"
	@echo ""
	@echo "Build (release):"
	@echo "  make build-ios       Build iOS release"
	@echo "  make build-android   Build Android AAB release"
	@echo "  make build-macos     Build macOS release"
	@echo "  make build-web       Build web release"
	@echo ""
	@echo "Quality:"
	@echo "  make test            Run all tests"
	@echo "  make test-coverage   Run tests with coverage"
	@echo "  make lint            Run dart analyze"
	@echo "==================================================="
	@echo ""
	@flutter --version 2>/dev/null || echo "Flutter not found. Install: brew install flutter"
	@echo ""

# ── Environment ─────────────────────────────────────────

doctor:
	flutter doctor

get:
	flutter pub get

clean:
	flutter clean

build-runner: get
	dart run build_runner build --delete-conflicting-outputs

# ── Run (debug) ──────────────────────────────────────────

run-ios: get
	flutter run -d "iPhone 15 Pro"

run-android: get
	flutter run -d emulator-5554

run-macos: get
	flutter run -d macos

run-web: get
	flutter run -d chrome

# ── Build (release) ──────────────────────────────────────

build-ios: get
	flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols

build-android: get
	flutter build appbundle --release --obfuscate --split-debug-info=build/android/symbols

build-macos: get
	flutter build macos --release

build-web: get
	flutter build web --release

# ── Quality ──────────────────────────────────────────────

test: get
	flutter test

test-coverage: get
	flutter test --coverage

lint:
	flutter analyze
