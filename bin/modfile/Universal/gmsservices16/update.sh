work_dir=$(pwd)
source "$work_dir/functions.sh"

androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"
GMS_SOURCE="$work_dir/bin/modfile/Universal/gmsservices16"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"

patch_enhanced_keyboard() {
  mods "Patching Enhanced Keyboard"

  MIUIFrequentPhraseDIR=$(find "$MAIN_FOLDER" -type d -name "MIUIFrequentPhrase" | head -n 1)
  MIUIFrequentPhrase=$(find "$MAIN_FOLDER" -type f -name "MIUIFrequentPhrase.apk" | head -n 1)

  if [[ -n "$MIUIFrequentPhrase" && -f "$MIUIFrequentPhrase" ]]; then
    rm -rf "$work_dir/apk_temp"
    mkdir -p "$work_dir/apk_temp/final"

    $APKEDITOR d -t raw -f -no-dex-debug       -i "$MIUIFrequentPhrase"       -o "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out" >/dev/null 2>&1

    Smali1=$(find "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out"       -type f -name "InputMethodBottomManager.smali" 2>/dev/null | head -n 1)

    if [[ -n "$Smali1" && -f "$Smali1" ]]; then
      sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$Smali1"

      MIUIFrequentPhraseName=$(basename "$MIUIFrequentPhrase")
      $APKEDITOR b -f         -i "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out"         -o "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" >/dev/null 2>&1

      if [[ -f "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" ]]; then
        rm -rf "$MIUIFrequentPhraseDIR/oat"
        rm -f "$MIUIFrequentPhraseDIR/$MIUIFrequentPhraseName"
        cp -f "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" "$MIUIFrequentPhraseDIR/"
      fi
    else
      mods "InputMethodBottomManager.smali not found, skipping patch"
    fi

    rm -rf "$work_dir/apk_temp"
  else
    mods "MIUIFrequentPhrase.apk not found, skipping patch"
  fi

  mods "Enhanced Keyboard Done"
}

if [[ $regionTYPE != "China" ]]; then
  mods "Detected Xiaomi Global ROM! Skipped Added GMS16."
  exit 0
fi

if [[ $androidVER != "16" ]]; then
  mods "Android ${androidVER}: skip gmsservices16"
  exit 0
fi

if [[ ! -d "$GMS_SOURCE/product" || ! -d "$GMS_SOURCE/system_ext" ]]; then
  echo "[ERROR] gmsservices16 payload is incomplete"
  exit 1
fi

GBOARD="$GMS_SOURCE/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
if [[ ! -f "$GBOARD" ]]; then
  echo "[ERROR] Android 16 keyboard not found: $GBOARD"
  exit 1
fi

VELVET_CTS="$GMS_SOURCE/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"
if [[ ! -f "$VELVET_CTS" ]]; then
  echo "[ERROR] GoogleVelvet_CTS.apk not found: $VELVET_CTS"
  exit 1
fi

cp -rf "$GMS_SOURCE/product/." "$MAIN_FOLDER/product/"
cp -rf "$GMS_SOURCE/system_ext/." "$MAIN_FOLDER/system_ext/"

if ! grep -q '^ro.miui.has_gmscore=1$' "$MAIN_FOLDER/system/system/build.prop"; then
  echo "ro.miui.has_gmscore=1" >> "$MAIN_FOLDER/system/system/build.prop"
fi

mkdir -p "$MAIN_FOLDER/product/framework"
cp -f "$GMS_SOURCE/maps/com.google.android.maps.jar" "$MAIN_FOLDER/product/framework/"

patch_enhanced_keyboard
mods "Added GMS16 Done"
