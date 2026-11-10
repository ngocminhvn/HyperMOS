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


if [[ $regionTYPE != "China" ]]; then
  mods "Detected Xiaomi Global ROM! Skipped Added LiteGapps16."
  exit 0
fi


if [[ $androidVER != "16" ]]; then
  mods "Android ${androidVER}: skip LiteGapps16"
  exit 0
fi

# Same fail-closed APK/LFS/XML payload verification as LiteGapps17.
# Keep Android 16 GApps/Maps unchanged; Enhanced Keyboard now runs from UpdateFile/GoogleKeybroad.
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

mods "Added LiteGapps16 Done"
