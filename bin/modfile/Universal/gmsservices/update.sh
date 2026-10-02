work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"

GMS_BASE="$work_dir/bin/modfile/Universal/gmsservices"
GMS_A16="$work_dir/bin/modfile/Universal/gmsservices16"

if [[ $regionTYPE == "China" ]]; then
  if [[ $androidVER == "16" ]]; then
    GMS_SOURCE="$GMS_A16"
    mods "Android 16 detected: use gmsservices16"
  else
    GMS_SOURCE="$GMS_BASE"
    mods "Android ${androidVER} detected: use gmsservices"
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

  if [[ $androidVER == "16" ]]; then
    mkdir -p "$MAIN_FOLDER/product/framework"
    cp -f "$GMS_SOURCE/maps/com.google.android.maps.jar" "$MAIN_FOLDER/product/framework/"
  elif [[ $androidVER == "13" ]]; then
    cp -rf "$GMS_BASE/maps/A13/framework" "$MAIN_FOLDER/product/"
  elif [[ $androidVER == "14" ]]; then
    cp -rf "$GMS_BASE/maps/A14/framework" "$MAIN_FOLDER/product/"
  else
    cp -rf "$GMS_BASE/maps/A15/framework" "$MAIN_FOLDER/product/"
  fi

  mods "Added GMS Done"
else
  mods "Detected Xiaomi Global ROM!Skipped Added GMS."
fi
