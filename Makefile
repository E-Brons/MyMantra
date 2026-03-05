# ==========================================
#  Flutter Project Makefile — MyMantra
# ==========================================
#
# FIRST TIME SETUP:
#   make setup           Full install + scaffold + deps (run once)
#
# DAILY USE:
#   make run-web         Run in Chrome (no emulator needed)
#   make run-ios         Run on iOS Simulator (Xcode required)
#
# See README.md for full documentation.
# ==========================================

FLUTTER    := flutter --suppress-analytics
FONTS_DIR  := assets/fonts
# Google Fonts GitHub — canonical source for all font downloads
GF         := https://raw.githubusercontent.com/google/fonts/main/ofl

.PHONY: help \
        install-flutter scaffold pods setup \
        install-fonts \
        doctor deps clean clean-pods build-runner \
        run-ios run-android run-macos run-web \
        build-ios build-android build-macos build-web \
        test test-coverage lint

help:
	@echo ""
	@echo "==================================================="
	@echo " Flutter Project Makefile (MyMantra)"
	@echo "==================================================="
	@echo ""
	@echo "First-time setup:"
	@echo "  make setup             Full install (flutter + scaffold + fonts + deps + pods)"
	@echo "  make install-flutter   Install Flutter SDK via Homebrew"
	@echo "  make scaffold          Generate platform dirs (ios/android/macos/web)"
	@echo "  make install-fonts     Download all mantra script fonts incl. CJK (~35 MB)"
	@echo "  make pods              Install CocoaPods dependencies (iOS/macOS)"
	@echo "  make deps              Resolve and install Dart package dependencies"
	@echo "  make doctor            Check Flutter environment health"
	@echo ""
	@echo "Run (debug) — recommended order:"
	@echo "  make run-web           Run in Chrome  [no emulator needed]"
	@echo "  make run-ios           Run on iOS Simulator  [Xcode required]"
	@echo "  make run-macos         Run on macOS"
	@echo "  make run-android       Run on Android Emulator  [Android Studio required]"
	@echo ""
	@echo "Build (release):"
	@echo "  make build-web         Compile optimized web app for deployment (output: build/web/)"
	@echo "  make build-ios         Build iOS release (.ipa)"
	@echo "  make build-android     Build Android AAB for Play Store"
	@echo "  make build-macos       Build macOS release (.app)"
	@echo ""
	@echo "Quality:"
	@echo "  make test              Run all tests"
	@echo "  make test-coverage     Run tests with coverage"
	@echo "  make lint              Run dart analyze"
	@echo "  make clean             Remove Flutter build artifacts"
	@echo "  make clean-pods        Deintegrate and reinstall CocoaPods (iOS/macOS)"
	@echo "==================================================="
	@echo ""
	@flutter --version 2>/dev/null || echo "  Flutter not found — run: make install-flutter"
	@echo ""

# ── First-time setup ─────────────────────────────────────

## Install Flutter SDK via Homebrew (macOS).
## Skipped if flutter is already on PATH.
install-flutter:
	@if command -v flutter >/dev/null 2>&1; then \
		echo "Flutter already installed: $$(flutter --version | head -1)"; \
	else \
		echo "Installing Flutter via Homebrew..."; \
		brew install flutter; \
	fi

## Generate platform scaffolding (ios/, android/, macos/, web/).
## Preserves existing lib/ code. Safe to re-run.
scaffold:
	@if [ ! -d ios ] && [ ! -d android ]; then \
		echo "Scaffolding platform directories..."; \
		$(FLUTTER) create . --org com.mymantra --platforms ios,android,macos,web; \
	else \
		echo "Platform directories already exist — skipping scaffold."; \
		echo "To force regeneration: flutter create . --org com.mymantra --platforms ios,android,macos,web"; \
	fi

## Install CocoaPods dependencies (required for iOS and macOS builds).
pods:
	@if command -v pod >/dev/null 2>&1; then \
		if [ -f ios/Podfile ]; then cd ios && pod install; fi; \
		if [ -f macos/Podfile ]; then cd macos && pod install; fi; \
	else \
		echo "CocoaPods not found. Installing..."; \
		sudo gem install cocoapods; \
		if [ -f ios/Podfile ]; then cd ios && pod install; fi; \
		if [ -f macos/Podfile ]; then cd macos && pod install; fi; \
	fi

## Full first-time setup: install Flutter, scaffold platforms, fonts, deps, install pods.
setup: install-flutter scaffold install-fonts deps pods

# ── Environment ─────────────────────────────────────────

doctor:
	$(FLUTTER) doctor -v

deps:
	$(FLUTTER) pub get

clean: clean-pods
	$(FLUTTER) clean

## Remove and reinstall CocoaPods for iOS and macOS.
## Runs flutter pub get first to regenerate Generated.xcconfig before pod install.
clean-pods:
	@if [ -f ios/Podfile ]; then cd ios && pod deintegrate; fi
	@if [ -f macos/Podfile ]; then cd macos && pod deintegrate; fi
	$(FLUTTER) pub get
	@if [ -f ios/Podfile ]; then cd ios && pod install; fi
	@if [ -f macos/Podfile ]; then cd macos && pod install; fi

build-runner: deps
	dart run build_runner build --delete-conflicting-outputs

# ── Fonts ────────────────────────────────────────────────
# Downloads each font only if the file is not already present (idempotent).
# Fonts are committed to the repo once downloaded; re-running skips existing files.
# Sources: google/fonts GitHub (canonical) — static TTF files.

## Download all mantra script fonts including CJK (~35 MB total, 22 files).
## Automatically run before every build/run target.
install-fonts:
	@mkdir -p $(FONTS_DIR)
	@echo "Checking mantra fonts..."
	@_dl() { \
		url="$$1"; \
		file="$$2"; \
		target="$(FONTS_DIR)/$$file"; \
		if [ -f "$$target" ]; then \
			printf "  ok   %s\n" "$$file"; \
		else \
			printf "  get  %s ... " "$$file"; \
			curl -fL --retry 3 -s -o "$$target" "$$url" \
				&& printf "done\n" || { printf "FAILED\n"; rm -f "$$target"; exit 1; }; \
		fi; \
	}; \
	_dl "$(GF)/cinzel/Cinzel%5Bwght%5D.ttf"                               Cinzel-Variable.ttf; \
	_dl "$(GF)/notosans/NotoSans%5Bwdth,wght%5D.ttf"                      NotoSans-Variable.ttf; \
	_dl "$(GF)/notosansdevanagari/NotoSansDevanagari%5Bwdth,wght%5D.ttf"  NotoSansDevanagari-Variable.ttf; \
	_dl "$(GF)/notosanshebrew/NotoSansHebrew%5Bwdth,wght%5D.ttf"          NotoSansHebrew-Variable.ttf; \
	_dl "$(GF)/notosansarabic/NotoSansArabic%5Bwdth,wght%5D.ttf"          NotoSansArabic-Variable.ttf; \
	_dl "$(GF)/notoseriftibetan/NotoSerifTibetan%5Bwght%5D.ttf"           NotoSerifTibetan-Variable.ttf; \
	_dl "$(GF)/notosansthai/NotoSansThai%5Bwdth,wght%5D.ttf"              NotoSansThai-Variable.ttf; \
	_dl "$(GF)/notosanstamil/NotoSansTamil%5Bwdth,wght%5D.ttf"            NotoSansTamil-Variable.ttf; \
	_dl "$(GF)/notoserifgujarati/NotoSerifGujarati%5Bwght%5D.ttf"         NotoSansGujarati-Variable.ttf; \
	_dl "$(GF)/notosanssc/NotoSansSC%5Bwght%5D.ttf"                       NotoSansSC-Variable.ttf; \
	_dl "$(GF)/notosansjp/NotoSansJP%5Bwght%5D.ttf"                       NotoSansJP-Variable.ttf; \
	_dl "$(GF)/notosanskr/NotoSansKR%5Bwght%5D.ttf"                       NotoSansKR-Variable.ttf \
	_dl "$(GF)/inter/Inter%5Bopsz,wght%5D.ttf"                            Inter-Variable.ttf; \
	_dl "$(GF)/plusjakartasans/PlusJakartaSans%5Bwght%5D.ttf"             PlusJakartaSans-Variable.ttf; \
	_dl "$(GF)/outfit/Outfit%5Bwght%5D.ttf"                               Outfit-Variable.ttf; \
	_dl "$(GF)/rubik/Rubik%5Bwght%5D.ttf"                                 Rubik-Variable.ttf; \
	_dl "$(GF)/tirodevanagarisanskrit/TiroDevanagariSanskrit-Regular.ttf" TiroSanskrit-Regular.ttf; \
	_dl "$(GF)/tirodevanagarisanskrit/TiroDevanagariSanskrit-Italic.ttf"  TiroSanskrit-Italic.ttf; \
	_dl "$(GF)/kalam/Kalam-Regular.ttf"                                   Kalam-Mantra.ttf; \
	_dl "$(GF)/kalam/Kalam-Bold.ttf"                                      Kalam-Mantra-Bold.ttf; \
	_dl "$(GF)/teko/Teko%5Bwght%5D.ttf"                                   Teko-Display-Mantra.ttf; \
	_dl "$(GF)/notoserifgujarati/NotoSerifGujarati%5Bwght%5D.ttf"         NotoGujarati-Variable.ttf

# ── Run (debug) ──────────────────────────────────────────

run-web: deps install-fonts
	$(FLUTTER) run -d chrome

run-ios: deps install-fonts
	$(FLUTTER) run -d "iPhone 16 Pro"

run-android: deps install-fonts
	$(FLUTTER) run -d emulator-5554

run-macos: deps install-fonts
	$(FLUTTER) run -d macos

# ── Build (release) ──────────────────────────────────────

build-web: deps install-fonts
	$(FLUTTER) build web --release

build-ios: deps install-fonts
	$(FLUTTER) build ios --release --obfuscate --split-debug-info=build/ios/symbols

build-android: deps install-fonts
	$(FLUTTER) build appbundle --release --obfuscate --split-debug-info=build/android/symbols

build-macos: deps install-fonts
	$(FLUTTER) build macos --release

# ── Quality ──────────────────────────────────────────────

test: deps
	$(FLUTTER) test

test-coverage: deps
	$(FLUTTER) test --coverage

lint:
	$(FLUTTER) analyze
