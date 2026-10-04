work_dir=$(pwd)
source "$work_dir/functions.sh"

androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"
GMS_SOURCE="$work_dir/bin/modfile/Universal/gmsservices"
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
  mods "Detected Xiaomi Global ROM! Skipped Added GMS."
  exit 0
fi

if [[ $androidVER == "16" ]]; then
  mods "Android 16 detected: skip legacy gmsservices"
  exit 0
fi


cp -rf "$GMS_SOURCE/product/." "$MAIN_FOLDER/product/"
cp -rf "$GMS_SOURCE/system_ext/." "$MAIN_FOLDER/system_ext/"

if ! grep -q '^ro.miui.has_gmscore=1$' "$MAIN_FOLDER/system/system/build.prop"; then
  echo "ro.miui.has_gmscore=1" >> "$MAIN_FOLDER/system/system/build.prop"
fi

if [[ $androidVER == "13" ]]; then
  cp -rf "$GMS_SOURCE/maps/A13/framework" "$MAIN_FOLDER/product/"
elif [[ $androidVER == "14" ]]; then
  cp -rf "$GMS_SOURCE/maps/A14/framework" "$MAIN_FOLDER/product/"
else
  cp -rf "$GMS_SOURCE/maps/A15/framework" "$MAIN_FOLDER/product/"
fi

patch_enhanced_keyboard
mods "Added GMS Done"
