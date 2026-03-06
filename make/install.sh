#!/usr/bin/env bash
# make/install.sh — install tools and verify environment
# Runs once per machine; safe to re-run (all steps are idempotent).
#
# Usage: bash make/install.sh [--target <name>]
#   --target  install only for the specified target (default: all build=true)

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── args ──────────────────────────────────────────────────────────────────────

SPECIFIED_TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target) SPECIFIED_TARGET="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

# ── helpers ───────────────────────────────────────────────────────────────────

_install_flutter() {
    if command -v flutter >/dev/null 2>&1; then
        echo "  flutter already installed: $(flutter --version 2>/dev/null | head -1)"
    else
        echo "  installing flutter via homebrew..."
        brew install flutter
    fi
}

_scaffold() {
    if [[ ! -d "$REPO_ROOT/ios" && ! -d "$REPO_ROOT/android" ]]; then
        echo "  scaffolding platform directories..."
        (cd "$REPO_ROOT" && $FLUTTER create . --org com.mymantra --platforms ios,android,macos,web)
    else
        echo "  platform directories already exist — skipping scaffold"
    fi
}

_ensure_cocoapods() {
    if ! command -v pod >/dev/null 2>&1; then
        echo "  installing cocoapods..."
        sudo gem install cocoapods
    fi
}

_install_pods() {
    local platform="$1"   # ios or macos
    _ensure_cocoapods
    $FLUTTER pub get
    local podfile="$REPO_ROOT/$platform/Podfile"
    if [[ -f "$podfile" ]]; then
        echo "  pod install ($platform)..."
        (cd "$REPO_ROOT/$platform" && pod install)
    else
        echo "  $platform/Podfile not found — run scaffold first"
    fi
}

_install_ios_runtime() {
    local installed
    installed="$(xcrun simctl list runtimes 2>/dev/null \
        | grep -E '^iOS [0-9]' | grep -iv 'unavailable' | tail -1 \
        | grep -oE 'iOS [0-9.]+' || true)"
    if [[ -n "$installed" ]]; then
        echo "  ios runtime already installed: $installed"
        return
    fi
    echo "  detecting latest available ios runtime via xcodes..."
    local runtime
    runtime="$(xcodes runtimes list 2>/dev/null \
        | grep -E '^iOS [0-9]' | tail -1 | grep -oE 'iOS [0-9.]+' || true)"
    if [[ -z "$runtime" ]]; then
        echo "  could not detect available runtime — check: xcodes runtimes list" >&2
        exit 1
    fi
    echo "  installing ios simulator runtime: $runtime (via xcodes + aria2)..."
    xcodes runtimes install "$runtime"
}

_install_fonts() {
    mkdir -p "$FONTS_DIR"
    echo "  checking fonts..."

    _dl() {
        local url="$1"
        local file="$2"
        local target="$FONTS_DIR/$file"
        if [[ -f "$target" ]]; then
            printf "    ok   %s\n" "$file"
        else
            printf "    get  %s ... " "$file"
            curl -fL --retry 3 -s -o "$target" "$url" \
                && printf "done\n" || { printf "FAILED\n"; rm -f "$target"; exit 1; }
        fi
    }

    _dl "$GF/cinzel/Cinzel%5Bwght%5D.ttf"                               Cinzel-Variable.ttf
    _dl "$GF/notosans/NotoSans%5Bwdth,wght%5D.ttf"                      NotoSans-Variable.ttf
    _dl "$GF/notosansdevanagari/NotoSansDevanagari%5Bwdth,wght%5D.ttf"  NotoSansDevanagari-Variable.ttf
    _dl "$GF/notosanshebrew/NotoSansHebrew%5Bwdth,wght%5D.ttf"          NotoSansHebrew-Variable.ttf
    _dl "$GF/notosansarabic/NotoSansArabic%5Bwdth,wght%5D.ttf"          NotoSansArabic-Variable.ttf
    _dl "$GF/notoseriftibetan/NotoSerifTibetan%5Bwght%5D.ttf"           NotoSerifTibetan-Variable.ttf
    _dl "$GF/notosansthai/NotoSansThai%5Bwdth,wght%5D.ttf"              NotoSansThai-Variable.ttf
    _dl "$GF/notosanstamil/NotoSansTamil%5Bwdth,wght%5D.ttf"            NotoSansTamil-Variable.ttf
    _dl "$GF/notoserifgujarati/NotoSerifGujarati%5Bwght%5D.ttf"         NotoSansGujarati-Variable.ttf
    _dl "$GF/notosanssc/NotoSansSC%5Bwght%5D.ttf"                       NotoSansSC-Variable.ttf
    _dl "$GF/notosansjp/NotoSansJP%5Bwght%5D.ttf"                       NotoSansJP-Variable.ttf
    _dl "$GF/notosanskr/NotoSansKR%5Bwght%5D.ttf"                       NotoSansKR-Variable.ttf
    _dl "$GF/inter/Inter%5Bopsz,wght%5D.ttf"                            Inter-Variable.ttf
    _dl "$GF/plusjakartasans/PlusJakartaSans%5Bwght%5D.ttf"             PlusJakartaSans-Variable.ttf
    _dl "$GF/outfit/Outfit%5Bwght%5D.ttf"                               Outfit-Variable.ttf
    _dl "$GF/rubik/Rubik%5Bwght%5D.ttf"                                 Rubik-Variable.ttf
    _dl "$GF/tirodevanagarisanskrit/TiroDevanagariSanskrit-Regular.ttf" TiroSanskrit-Regular.ttf
    _dl "$GF/tirodevanagarisanskrit/TiroDevanagariSanskrit-Italic.ttf"  TiroSanskrit-Italic.ttf
    _dl "$GF/kalam/Kalam-Regular.ttf"                                   Kalam-Mantra.ttf
    _dl "$GF/kalam/Kalam-Bold.ttf"                                      Kalam-Mantra-Bold.ttf
    _dl "$GF/teko/Teko%5Bwght%5D.ttf"                                   Teko-Display-Mantra.ttf
    _dl "$GF/notoserifgujarati/NotoSerifGujarati%5Bwght%5D.ttf"         NotoGujarati-Variable.ttf

    # Apple fonts (macOS only — mounted .dmg)
    if command -v hdiutil >/dev/null 2>&1; then
        _dl_dmg() {
            local url="$1" name="$2" stamp="$FONTS_DIR/.$name.installed"
            if [[ -f "$stamp" ]]; then
                printf "    ok   %s\n" "$name"; return
            fi
            printf "    get  %s ... " "$name"
            local tmp
            tmp="$(mktemp /tmp/apple-font-XXXXXX.dmg)"
            curl -fL --retry 3 -s -o "$tmp" "$url" \
                || { printf "FAILED\n"; rm -f "$tmp"; exit 1; }
            local vol
            vol="$(hdiutil attach -nobrowse -noautoopen "$tmp" 2>/dev/null \
                | awk -F'\t' '/\/Volumes\//{print $NF}' | xargs)"
            if [[ -z "$vol" ]]; then
                printf "MOUNT FAILED\n"; rm -f "$tmp"; exit 1
            fi
            find "$vol" \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
            hdiutil detach -quiet "$vol" 2>/dev/null || true
            rm -f "$tmp"
            touch "$stamp"
            printf "done\n"
        }
        echo "  checking Apple fonts..."
        _dl_dmg "$AC/SF-Pro.dmg"       sf-pro
        _dl_dmg "$AC/SF-Compact.dmg"   sf-compact
        _dl_dmg "$AC/SF-Mono.dmg"      sf-mono
        _dl_dmg "$AC/NY.dmg"           sf-new-york
        _dl_dmg "$AC/SF-Arabic.dmg"    sf-arabic
        _dl_dmg "$AC/SF-Armenian.dmg"  sf-armenian
        _dl_dmg "$AC/SF-Georgian.dmg"  sf-georgian
        _dl_dmg "$AC/SF-Hebrew.dmg"    sf-hebrew
    fi
}

# ── determine active targets ──────────────────────────────────────────────────

TARGETS_CSV=""
while IFS='|' read -r name _rest; do
    TARGETS_CSV="${TARGETS_CSV:+$TARGETS_CSV,}$name"
done < <(resolve_build_targets "$SPECIFIED_TARGET")

if [[ -z "$TARGETS_CSV" ]]; then
    echo "no targets to install for." >&2; exit 1
fi

echo "==> install: targets — $TARGETS_CSV"

# ── common ────────────────────────────────────────────────────────────────────

echo ""
echo "==> install: flutter"
_install_flutter

echo ""
echo "==> install: scaffold"
_scaffold

# ── per-target ────────────────────────────────────────────────────────────────

while IFS='|' read -r name _device _debug; do
    echo ""
    echo "==> install: $name"
    case "$name" in

        ios)
            _install_ios_runtime
            _install_pods ios
            ;;

        macos)
            _install_pods macos
            ;;

        android)
            ANDROID_SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
            if [[ -d "$ANDROID_SDK" ]]; then
                echo "  android sdk found: $ANDROID_SDK"
            else
                echo "  android sdk not found — install Android Studio:"
                echo "  https://developer.android.com/studio"
            fi
            ;;

        web)
            echo "  no additional installs required for web"
            ;;

        # ── future targets ────────────────────────────────────────────────────
        # python)
        #     command -v uv >/dev/null || pip install uv
        #     (cd "$REPO_ROOT/services" && uv sync)
        #     ;;

    esac
done < <(resolve_build_targets "$SPECIFIED_TARGET")

# ── fonts (shared across all targets) ────────────────────────────────────────

echo ""
echo "==> install: fonts"
_install_fonts

# ── verify ────────────────────────────────────────────────────────────────────

echo ""
echo "==> verify: prerequisites"
bash "$MAKE_DIR/prerequisites.sh" --targets "$TARGETS_CSV"
