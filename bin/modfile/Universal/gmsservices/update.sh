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

    if [[ ! -d "$GMS_SOURCE/product" || ! -d "$GMS_SOURCE/system_ext" ]]; then
      echo "[ERROR] gmsservices16 payload is incomplete"
      exit 1
    fi
  else
    GMS_SOURCE="$GMS_BASE"

    # Keep the legacy Google Velvet CTS payload only for Android 13-15.
    mkdir -p "$GMS_SOURCE/product/priv-app/GoogleVelvet_CTS"
    aria2c -q \
      -d "$GMS_SOURCE/product/priv-app/GoogleVelvet_CTS/" \
      -o GoogleVelvet_CTS.apk \
      https://github.com/tiencv2006/NothingsVN-BuildExt/releases/download/oplus/GoogleVelvet_CTS.apk \
      && info "Get File Successfully"
  fi

  cp -rf "$GMS_SOURCE/product/." "$MAIN_FOLDER/product/"
  cp -rf "$GMS_SOURCE/system_ext/." "$MAIN_FOLDER/system_ext/"

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

  mods "Added GMS Done"
else
  mods "Detected Xiaomi Global ROM!Skipped Added GMS."
fi
