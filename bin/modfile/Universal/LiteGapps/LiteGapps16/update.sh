#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

# Xiaomi.eu ships this functionality natively. Check here so dispatchers stay generic.
if [[ -f "$work_dir/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    exit 0
fi

androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"
GMS_SOURCE="$work_dir/bin/modfile/Universal/LiteGapps/LiteGapps16"
GMS_COMMON="$work_dir/bin/modfile/Universal/LiteGapps/Gapps"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"

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

if [[ $regionTYPE != "China" ]]; then
  mods "Detected Xiaomi Global ROM! Skipped Added LiteGapps16."
  exit 0
fi

if [[ $androidVER != "16" ]]; then
  mods "Android ${androidVER}: skip LiteGapps16"
  exit 0
fi

# Same fail-closed APK/LFS/XML payload verification as LiteGapps17.
# Keep the Android 16-specific keyboard patch and Maps framework untouched.
if ! python3 "$work_dir/bin/modfile/Universal/LiteGapps/validate.py" 16; then
  error "LiteGapps16: payload integrity check failed"
  exit 1
fi

if [[ ! -d "$GMS_SOURCE/product" || ! -d "$GMS_SOURCE/system_ext" ]]; then
  error "LiteGapps16 payload is incomplete"
  exit 1
fi

required_payload=(
  "$GMS_COMMON/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
  "$GMS_SOURCE/product/priv-app/GmsCore/GmsCore.apk"
  "$GMS_SOURCE/product/priv-app/Phonesky/Phonesky.apk"
  "$GMS_COMMON/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"
  "$GMS_COMMON/product/priv-app/Velvet/Velvet.apk"
  "$GMS_SOURCE/system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk"
  "$GMS_COMMON/maps/com.google.android.maps.jar"
)
for required in "${required_payload[@]}"; do
  if [[ ! -s "$required" ]]; then
    error "LiteGapps16 required payload missing: $required"
    exit 1
  fi
done

[[ -f "$MAIN_FOLDER/system/system/build.prop" ]] || {
  error "LiteGapps16: system build.prop not found"
  exit 1
}

# Install identical shared GApps first, then Android 16-specific differences.
# Version-specific files always win; no APK is duplicated across layers.
for partition in product system_ext; do
  for layer in "$GMS_COMMON" "$GMS_SOURCE"; do
    if [[ -d "$layer/$partition" ]]; then
      cp -rf "$layer/$partition/." "$MAIN_FOLDER/$partition/" || {
        error "LiteGapps16: failed copying $layer/$partition"
        exit 1
      }
    fi
  done
done

# Gmail was explicitly excluded from both LiteGapps variants. Remove any
# existing PrebuiltGmail app from the source image as well.
if [[ -e "$MAIN_FOLDER/product/app/PrebuiltGmail" ]]; then
  rm -rf -- "$MAIN_FOLDER/product/app/PrebuiltGmail" || {
    error "LiteGapps16: failed to remove PrebuiltGmail"
    exit 1
  }
fi

if ! grep -q '^ro.miui.has_gmscore=1$' "$MAIN_FOLDER/system/system/build.prop"; then
  echo "ro.miui.has_gmscore=1" >> "$MAIN_FOLDER/system/system/build.prop"
fi

mkdir -p "$MAIN_FOLDER/product/framework"
cp -f "$GMS_COMMON/maps/com.google.android.maps.jar" "$MAIN_FOLDER/product/framework/" || {
  error "LiteGapps16: maps framework copy failed"
  exit 1
}

required_installed=(
  "$MAIN_FOLDER/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
  "$MAIN_FOLDER/product/priv-app/GmsCore/GmsCore.apk"
  "$MAIN_FOLDER/product/priv-app/Phonesky/Phonesky.apk"
  "$MAIN_FOLDER/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"
  "$MAIN_FOLDER/product/priv-app/Velvet/Velvet.apk"
  "$MAIN_FOLDER/system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk"
  "$MAIN_FOLDER/product/framework/com.google.android.maps.jar"
)
for required in "${required_installed[@]}"; do
  if [[ ! -s "$required" ]]; then
    error "LiteGapps16 installed payload missing: $required"
    exit 1
  fi
done

patch_enhanced_keyboard || {
  error "LiteGapps16: Enhanced Keyboard patch failed"
  exit 1
}
mods "Added LiteGapps16 Done"
