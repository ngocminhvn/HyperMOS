work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"

GMS_BASE="$work_dir/bin/modfile/Universal/gmsservices"
GMS_A16="$work_dir/bin/modfile/Universal/gmsservices16"

# LiteGapps Google Keyboard addon for Android 16 / arm64.
# This is the exact package verified from the uploaded ZIP and SourceForge.
GBOARD_A16_URL="https://sourceforge.net/projects/litegapps/files/addon/arm64/36/gapps/GoogleKeyboard/GoogleKeyboard-LiteGapps-Addon-arm64-16.0.zip/download"
GBOARD_A16_SHA256="6fe9ae5d44c0faf162a951e648f8b320628ac444a77bdc6ef5be73bb413ca5f8"
GBOARD_A16_ZIP="$work_dir/GoogleKeyboard-LiteGapps-Addon-arm64-16.0.zip"
GBOARD_A16_ENTRY="system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
GBOARD_A16_TARGET="$MAIN_FOLDER/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"

install_gboard_a16() {
  rm -f "$GBOARD_A16_ZIP"
  mkdir -p "$(dirname "$GBOARD_A16_TARGET")"

  mods "Downloading Google Keyboard (LiteGapps A16)"

  if ! aria2c -q       --allow-overwrite=true       --auto-file-renaming=false       -d "$(dirname "$GBOARD_A16_ZIP")"       -o "$(basename "$GBOARD_A16_ZIP")"       "$GBOARD_A16_URL"; then
    echo "[ERROR] Failed to download Google Keyboard addon"
    rm -f "$GBOARD_A16_ZIP"
    exit 1
  fi

  if ! echo "$GBOARD_A16_SHA256  $GBOARD_A16_ZIP" | sha256sum -c - >/dev/null 2>&1; then
    echo "[ERROR] Google Keyboard addon SHA-256 mismatch"
    rm -f "$GBOARD_A16_ZIP"
    exit 1
  fi

  if ! unzip -p "$GBOARD_A16_ZIP" "$GBOARD_A16_ENTRY" > "$GBOARD_A16_TARGET"; then
    echo "[ERROR] Failed to extract LatinIMEGooglePrebuilt.apk"
    rm -f "$GBOARD_A16_ZIP" "$GBOARD_A16_TARGET"
    exit 1
  fi

  rm -f "$GBOARD_A16_ZIP"

  if [[ ! -s "$GBOARD_A16_TARGET" ]]; then
    echo "[ERROR] Gboard APK missing after extraction: $GBOARD_A16_TARGET"
    exit 1
  fi

  mods "Gboard (LatinIMEGooglePrebuilt) -> Done"
}

if [[ $regionTYPE == "China" ]]; then
  if [[ $androidVER == "16" ]]; then
    GMS_SOURCE="$GMS_A16"
    mods "Android 16 detected: use gmsservices16"

    if [[ ! -d "$GMS_SOURCE/product" || ! -d "$GMS_SOURCE/system_ext" ]]; then
      echo "[ERROR] gmsservices16 payload is incomplete"
      exit 1
    fi
  else
    GMS_SOURCE="$GMS_BASE"
    mods "Android ${androidVER} detected: use gmsservices"
  fi

  VELVET_CTS="$GMS_SOURCE/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"
  if [[ ! -f "$VELVET_CTS" ]]; then
    echo "[ERROR] GoogleVelvet_CTS.apk not found: $VELVET_CTS"
    exit 1
  fi
  mods "GoogleVelvet_CTS.apk -> local payload"

  cp -rf "$GMS_SOURCE/product/." "$MAIN_FOLDER/product/"
  cp -rf "$GMS_SOURCE/system_ext/." "$MAIN_FOLDER/system_ext/"

  if [[ $androidVER == "16" ]]; then
    install_gboard_a16
  fi

  if ! grep -q '^ro.miui.has_gmscore=1$' "$MAIN_FOLDER/system/system/build.prop"; then
    echo "ro.miui.has_gmscore=1" >> "$MAIN_FOLDER/system/system/build.prop"
  fi

  if [[ $androidVER == "16" ]]; then
    mkdir -p "$MAIN_FOLDER/product/framework"
    if [[ -f "$GMS_SOURCE/maps/com.google.android.maps.jar" ]]; then
      cp -f "$GMS_SOURCE/maps/com.google.android.maps.jar" "$MAIN_FOLDER/product/framework/"
      mods "Android 16 Google Maps shared library -> Done"
    else
      echo "[ERROR] Android 16 com.google.android.maps.jar not found"
      exit 1
    fi
  elif [[ $androidVER == "13" ]]; then
    cp -rf "$GMS_BASE/maps/A13/framework" "$MAIN_FOLDER/product/"
  elif [[ $androidVER == "14" ]]; then
    cp -rf "$GMS_BASE/maps/A14/framework" "$MAIN_FOLDER/product/"
  else
    cp -rf "$GMS_BASE/maps/A15/framework" "$MAIN_FOLDER/product/"
  fi

  # Hard stop: China ROMs must never be packed without at least one keyboard.
  if [[ $androidVER == "16" && ! -s "$GBOARD_A16_TARGET" ]]; then
    echo "[ERROR] No Gboard found after GMS integration"
    exit 1
  fi

  mods "Added GMS Done"
else
  mods "Detected Xiaomi Global ROM!Skipped Added GMS."
fi
