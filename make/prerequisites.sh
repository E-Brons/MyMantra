#!/usr/bin/env bash
# make/prerequisites.sh — check all required tools for myMantra Flutter dev
# Exit 0 if every required tool is present and arm64; non-zero otherwise.
# Writes make/prerequisites.yaml on success as a build-ready flag.
#
# Usage: bash make/prerequisites.sh [--targets ios,android,macos,web]
#   --targets  comma-separated list of active targets; only those platform
#              checks are treated as hard failures (default: all)

set -euo pipefail

FLAG="$(cd "$(dirname "$0")" && pwd)/prerequisites.yaml"

# ── target list ───────────────────────────────────────────────────────────────

REQUIRED_TARGETS="all"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --targets) REQUIRED_TARGETS="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

# Returns 0 (true) if the given platform is in the required targets list.
_targets_require() {
    [[ "$REQUIRED_TARGETS" == "all" ]] && return 0
    echo "$REQUIRED_TARGETS" | tr ',' '\n' | grep -qx "$1"
}

# ── arch resolution ───────────────────────────────────────────────────────────

_resolve_arch() {
  local bin="$1"
  local depth="${2:-0}"
  [[ $depth -gt 6 ]] && { echo "?"; return; }

  local lipo_out
  lipo_out="$(lipo -archs "$bin" 2>/dev/null)" || true
  if [[ -n "$lipo_out" ]]; then
    local archs=()
    read -ra archs <<< "$lipo_out"
    if [[ ${#archs[@]} -eq 1 ]]; then
      echo "${archs[0]}"
    else
      echo "$(IFS='+'; echo "${archs[*]}")"
    fi
    return
  fi

  local first_line
  first_line="$(head -1 "$bin" 2>/dev/null)" || { echo "?"; return; }
  if [[ "$first_line" == \#!* ]]; then
    local interp
    interp="$(printf '%s' "$first_line" | sed 's|^#! *||' | awk '{print $1}')"
    if [[ "$interp" == "/usr/bin/env" ]]; then
      local iname
      iname="$(printf '%s' "$first_line" | sed 's|^#! *||' | awk '{print $2}')"
      interp="$(command -v "$iname" 2>/dev/null)" || { echo "?"; return; }
    fi
    [[ -f "$interp" ]] && { _resolve_arch "$interp" $(( depth + 1 )); return; }
  fi

  echo "?"
}

arch_of() {
  local bin
  bin="$(command -v "$1" 2>/dev/null)" || { echo "-"; return; }
  _resolve_arch "$bin"
}

# ── version helpers ───────────────────────────────────────────────────────────

version_of() {
  command -v "$1" >/dev/null 2>&1 || { echo "-"; return; }
  case "$1" in
    flutter)    flutter --version 2>/dev/null | awk '/Flutter/{print $2; exit}' ;;
    dart)       dart --version 2>/dev/null | awk '{print $4; exit}' ;;
    xcodebuild) xcodebuild -version 2>/dev/null | awk '/Xcode/{print $2; exit}' ;;
    xcodes)     xcodes version 2>/dev/null | head -1 | tr -d '\n' ;;
    pod)        pod --version 2>/dev/null | tr -d '\n' ;;
    brew)       brew --version 2>/dev/null | awk 'NR==1{print $2}' ;;
    git)        git --version 2>/dev/null | awk '{print $3}' ;;
    java)       java -version 2>&1 | awk -F'"' '/version/{print $2; exit}' ;;
    adb)        adb version 2>/dev/null | awk 'NR==1{print $5}' ;;
    aria2c)     aria2c --version 2>/dev/null | awk 'NR==1{print $3}' ;;
    curl)       curl --version 2>/dev/null | awk 'NR==1{print $2}' ;;
    *)          echo "?" ;;
  esac
}

# ── tool list ─────────────────────────────────────────────────────────────────
# "name|required|description|install_cmd"
#   yes  — missing or wrong-arch exits 1
#   warn — noted in table, does not block

TOOLS=(
  "adb|warn|Android Debug Bridge|brew install android-platform-tools"
  "aria2c|yes|Download accelerator (xcodes)|brew install aria2"
  "brew|yes|Homebrew|see https://brew.sh"
  "curl|yes|HTTP client (fonts)|brew install curl"
  "dart|yes|Dart SDK|brew install dart"
  "flutter|yes|Flutter SDK|brew install flutter"
  "git|yes|Version control|brew install git"
  "java|warn|JDK (Android)|brew install openjdk"
  "pod|yes|CocoaPods (iOS/macOS)|brew install cocoapods"
  "xcodebuild|yes|Xcode (iOS/macOS builds)|xcode-select --install"
  "xcodes|yes|Xcode version manager|brew install xcodesorg/made/xcodes"
)

# ── table geometry ────────────────────────────────────────────────────────────
W_NAME=12
W_PATH=38
W_ARCH=14
W_VER=14
W_REQ=4
W_STATUS=9

# ── colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

colored_status() {
  local s="$1"
  local padded
  padded="$(printf '%-*s' $W_STATUS "$s")"
  case "$s" in
    OK)                       printf "${GREEN}%s${NC}"  "$padded" ;;
    MISSING|"ARCH FAIL")      printf "${RED}%s${NC}"    "$padded" ;;
    "ARCH WARN"|absent)       printf "${YELLOW}%s${NC}" "$padded" ;;
    *)                        printf '%s'                "$padded" ;;
  esac
}

sep()    { printf '%*s' "$1" '' | tr ' ' '─'; }
hdr_sep(){ printf '┌%s┬%s┬%s┬%s┬%s┬%s┐\n' \
             "$(sep $((W_NAME+2)))" "$(sep $((W_PATH+2)))" "$(sep $((W_ARCH+2)))" \
             "$(sep $((W_VER+2)))"  "$(sep $((W_REQ+2)))"  "$(sep $((W_STATUS+2)))"; }
mid_sep(){ printf '├%s┼%s┼%s┼%s┼%s┼%s┤\n' \
             "$(sep $((W_NAME+2)))" "$(sep $((W_PATH+2)))" "$(sep $((W_ARCH+2)))" \
             "$(sep $((W_VER+2)))"  "$(sep $((W_REQ+2)))"  "$(sep $((W_STATUS+2)))"; }
bot_sep(){ printf '└%s┴%s┴%s┴%s┴%s┴%s┘\n' \
             "$(sep $((W_NAME+2)))" "$(sep $((W_PATH+2)))" "$(sep $((W_ARCH+2)))" \
             "$(sep $((W_VER+2)))"  "$(sep $((W_REQ+2)))"  "$(sep $((W_STATUS+2)))"; }

row() {
  printf '│ %-*s │ %-*s │ %-*s │ %-*s │ %-*s │ %s │\n' \
    $W_NAME "$1"  $W_PATH "$2"  $W_ARCH "$3" \
    $W_VER  "$4"  $W_REQ  "$5"  "$6"
}

# ── main ──────────────────────────────────────────────────────────────────────

SYS_ARCH="$(uname -m)"

echo ""
echo "myMantra — prerequisites check  (system: ${SYS_ARCH})"
[[ "$REQUIRED_TARGETS" != "all" ]] && echo "  active targets: $REQUIRED_TARGETS"
echo ""

hdr_sep
row "Tool" "Path / Install" "Arch/Target" "Version" "Req" "$(printf '%-*s' $W_STATUS 'Status')"
mid_sep

overall=0
found_rows=()
missing_rows=()
tool_paths=()

for entry in "${TOOLS[@]}"; do
  IFS='|' read -r name req _desc install_cmd <<< "$entry"

  if command -v "$name" >/dev/null 2>&1; then
    bin_path_full="$(command -v "$name")"
    tool_paths+=("${name}:${bin_path_full}")
    bin_path="$bin_path_full"
    if [[ ${#bin_path} -gt $W_PATH ]]; then
      bin_path="…${bin_path: -$((W_PATH-1))}"
    fi
    arch="$(arch_of "$name")"
    ver="$(version_of "$name")"
    ver="${ver:0:$W_VER}"

    if [[ "$arch" == *arm64* ]]; then
      status="OK"
    else
      if [[ "$req" == "yes" ]]; then
        status="ARCH FAIL"
        overall=1
      else
        status="ARCH WARN"
      fi
    fi
    found_rows+=("$(row "$name" "$bin_path" "$arch" "$ver" "$req" "$(colored_status "$status")")")
  else
    if [[ "$req" == "yes" ]]; then
      status="MISSING"
      overall=1
    else
      status="absent"
    fi
    missing_rows+=("$(row "$name" "$install_cmd" "-" "-" "$req" "$(colored_status "$status")")")
  fi
done

# ── ios-sim row ───────────────────────────────────────────────────────────────
if command -v xcrun >/dev/null 2>&1; then
  _xcrun_path="$(command -v xcrun)"
  _sim_runtime="$(xcrun simctl list runtimes 2>/dev/null \
    | grep -E '^iOS [0-9]' | grep -iv 'unavailable' | tail -1 | grep -oE 'iOS [0-9.]+' || true)"
  _sim_count="$(xcrun simctl list devices 2>/dev/null \
    | awk '/^-- Unavailable/{s=1} /^--/{if(!/Unavailable/)s=0} !s' \
    | grep -cE "^\s+iPhone" || true)"
  _bin_path="$_xcrun_path simctl"
  [[ ${#_bin_path} -gt $W_PATH ]] && _bin_path="…${_bin_path: -$((W_PATH-1))}"
  if [[ -n "$_sim_runtime" && "$_sim_count" -gt 0 ]]; then
    found_rows+=("$(row "ios-sim" "$_bin_path" "${_sim_runtime:--}" "${_sim_count} avail" "yes" "$(colored_status "OK")")")
  elif _targets_require ios; then
    overall=1
    missing_rows+=("$(row "ios-sim" "xcodes runtimes list | grep iOS" "-" "-" "yes" "$(colored_status "MISSING")")")
  else
    missing_rows+=("$(row "ios-sim" "xcodes runtimes list | grep iOS" "-" "-" "warn" "$(colored_status "absent")")")
  fi
fi

# ── android-avd row ───────────────────────────────────────────────────────────
_android_sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-${HOME}/Library/Android/sdk}}"
_emulator_bin="${_android_sdk}/emulator/emulator"
if [[ -x "$_emulator_bin" ]]; then
  _first_avd="$("$_emulator_bin" -list-avds 2>/dev/null | head -1)"
  _emu_path="$_emulator_bin"
  [[ ${#_emu_path} -gt $W_PATH ]] && _emu_path="…${_emu_path: -$((W_PATH-1))}"
  _emu_arch="$(_resolve_arch "$_emulator_bin")"
  if [[ -n "$_first_avd" ]]; then
    found_rows+=("$(row "android-avd" "$_emu_path" "$_emu_arch" "${_first_avd:0:$W_VER}" "yes" "$(colored_status "OK")")")
  elif _targets_require android; then
    overall=1
    missing_rows+=("$(row "android-avd" "Android Studio > Tools > Device Manager" "-" "-" "yes" "$(colored_status "MISSING")")")
  else
    missing_rows+=("$(row "android-avd" "Android Studio > Tools > Device Manager" "-" "-" "warn" "$(colored_status "absent")")")
  fi
elif _targets_require android; then
  overall=1
  missing_rows+=("$(row "android-avd" "Install Android Studio" "-" "-" "yes" "$(colored_status "MISSING")")")
else
  missing_rows+=("$(row "android-avd" "Install Android Studio" "-" "-" "warn" "$(colored_status "absent")")")
fi

for r in "${found_rows[@]+"${found_rows[@]}"}";    do printf '%s\n' "$r"; done
for r in "${missing_rows[@]+"${missing_rows[@]}"}"; do printf '%s\n' "$r"; done

bot_sep

# ── flutter doctor summary ────────────────────────────────────────────────────
if command -v flutter >/dev/null 2>&1; then
  echo ""
  echo "flutter doctor:"
  echo "──────────────────────────────────────────────────────────"
  flutter doctor 2>&1 | grep -E '^\[|^  !' | sed 's/^/  /'
  echo "──────────────────────────────────────────────────────────"
fi

# ── result ────────────────────────────────────────────────────────────────────
echo ""
if [[ $overall -eq 0 ]]; then
  TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  flutter_root_yaml=""
  for tp in "${tool_paths[@]+"${tool_paths[@]}"}"; do
    if [[ "${tp%%:*}" == "flutter" ]]; then
      flutter_real="$(readlink -f "${tp#*:}" 2>/dev/null || echo "${tp#*:}")"
      candidate="$(dirname "$(dirname "$flutter_real")")"
      [[ -d "$candidate/packages/flutter_tools" ]] && flutter_root_yaml="$candidate"
      break
    fi
  done
  {
    printf '# Generated by make/prerequisites.sh — do not edit manually\n'
    printf 'checked_at: %s\n' "$TIMESTAMP"
    printf 'sys_arch: %s\n' "$SYS_ARCH"
    printf 'active_targets: %s\n' "$REQUIRED_TARGETS"
    printf 'result: ok\n'
    [[ -n "$flutter_root_yaml" ]] && printf 'flutter_root: %s\n' "$flutter_root_yaml"
    [[ -n "${_sim_runtime:-}" ]] && printf 'ios_runtime: %s\n' "$_sim_runtime"
    printf 'tools:\n'
    for tp in "${tool_paths[@]+"${tool_paths[@]}"}"; do
      printf '  %s: %s\n' "${tp%%:*}" "${tp#*:}"
    done
  } > "$FLAG"
  echo "All required tools OK — environment ready."
  echo "Flag written: ${FLAG}"
  exit 0
else
  rm -f "$FLAG"
  echo "One or more required tools failed. Fix the issues above, then re-run:"
  echo "  make install"
  exit 1
fi
