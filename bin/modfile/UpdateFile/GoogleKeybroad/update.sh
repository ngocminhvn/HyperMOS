#!/usr/bin/env bash
# Shared China Enhanced Keyboard patch; APK payload stays in LiteGapps / stock ROM.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
rom_source="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/rom_source.txt")"
androidVER="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
regionTYPE="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/device_type.txt")"

# Xiaomi.eu/native Global IME provisioning is intentionally untouched.
if [[ "$rom_source" != "china" || "$regionTYPE" != "China" ]]; then
  exit 0
fi
case "$androidVER" in
  15|16|17) ;;
  *) error "GoogleKeybroad: unsupported China Android $androidVER"; exit 1 ;;
esac

# Fail closed rather than ship a clean-flash ROM with MiType removed and no
# Gboard system IME. LiteGapps must have staged the APK before UpdateFile.
gboard="$MAIN_FOLDER/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
[[ -s "$gboard" ]] || {
  error "GoogleKeybroad: missing system Gboard APK ($gboard); refusing unsafe ROM"
  exit 1
}

patch_enhanced_keyboard() {
  mods "Patching Enhanced Keyboard"

  local phrase_dir phrase_apk smali name
  phrase_dir=$(find "$MAIN_FOLDER" -type d -name "MIUIFrequentPhrase" -print -quit)
  phrase_apk=$(find "$MAIN_FOLDER" -type f -name "MIUIFrequentPhrase.apk" -print -quit)

  if [[ -z "$phrase_dir" || -z "$phrase_apk" || ! -f "$phrase_apk" ]]; then
    error "GMS: MIUIFrequentPhrase.apk target not found"
    return 1
  fi

  rm -rf "$work_dir/apk_temp/gms-keyboard"
  mkdir -p "$work_dir/apk_temp/gms-keyboard/final"

  if ! $APKEDITOR d -t raw -f -no-dex-debug \
      -i "$phrase_apk" \
      -o "$work_dir/apk_temp/gms-keyboard/out" >/dev/null 2>&1; then
    error "GMS: MIUIFrequentPhrase decode failed"
    return 1
  fi

  smali=$(find "$work_dir/apk_temp/gms-keyboard/out" \
      -type f -name "InputMethodBottomManager.smali" -print -quit)

  if [[ -z "$smali" || ! -f "$smali" ]]; then
    error "GMS: InputMethodBottomManager.smali not found"
    return 1
  fi

  if grep -q 'com.baidu.input_mi' "$smali"; then
    sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$smali"
  elif ! grep -q 'com.google.android.inputmethod.latin' "$smali"; then
    error "GMS: Enhanced Keyboard IME target changed"
    return 1
  fi

  if grep -q 'com.baidu.input_mi' "$smali" || \
     ! grep -q 'com.google.android.inputmethod.latin' "$smali"; then
    error "GMS: Enhanced Keyboard patch verification failed"
    return 1
  fi

  name=$(basename "$phrase_apk")
  if ! $APKEDITOR b -f \
      -i "$work_dir/apk_temp/gms-keyboard/out" \
      -o "$work_dir/apk_temp/gms-keyboard/final/$name" >/dev/null 2>&1; then
    error "GMS: MIUIFrequentPhrase rebuild failed"
    return 1
  fi

  if [[ ! -s "$work_dir/apk_temp/gms-keyboard/final/$name" ]]; then
    error "GMS: rebuilt MIUIFrequentPhrase.apk missing or empty"
    return 1
  fi

  unzip -tq "$work_dir/apk_temp/gms-keyboard/final/$name" >/dev/null || {
    error "GMS: rebuilt MIUIFrequentPhrase.apk is invalid"
    return 1
  }

  rm -rf "$phrase_dir/oat"
  cp -f "$work_dir/apk_temp/gms-keyboard/final/$name" "$phrase_dir/$name"

  if [[ ! -s "$phrase_dir/$name" ]]; then
    error "GMS: failed to install rebuilt MIUIFrequentPhrase.apk"
    return 1
  fi

  rm -rf "$work_dir/apk_temp/gms-keyboard"
  mods "Enhanced Keyboard Done"
}

patch_enhanced_keyboard || {
  error "GoogleKeybroad: China Android $androidVER Enhanced Keyboard patch failed"
  exit 1
}
mods "GoogleKeybroad: China Android $androidVER Enhanced Keyboard -> Done"
