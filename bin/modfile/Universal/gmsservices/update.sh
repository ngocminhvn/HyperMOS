work_dir=$(pwd)
source $work_dir/functions.sh
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
MAIN_FOLDER="$work_dir/build/baserom/images"

# Official LiteGapps Lite arm64 Android 16 (SDK 36), pinned and checksum-verified.
LITEGAPPS_A16_URL="https://github.com/litegapps/litegapps/releases/download/lite-build-20260709-3/LiteGapps-arm64-16.0-20260709-official.zip"
LITEGAPPS_A16_SHA256="6cc8c534d9e949d8242d63e4ceeb73510e87d3d55dd114eb0c7e7dd6c7be1ec3"

install_litegapps_a16() {
  local tmp_dir="$work_dir/build/litegapps_a16"
  local zip_file="$tmp_dir/LiteGapps-arm64-16.0.zip"
  local payload_dir="$tmp_dir/payload"
  local files_archive product_dir system_ext_dir

  rm -rf "$tmp_dir"
  mkdir -p "$payload_dir"
  info "Downloading official LiteGapps Lite arm64 Android 16..."
  aria2c -q -x 8 -s 8 -d "$tmp_dir" -o "$(basename "$zip_file")" "$LITEGAPPS_A16_URL" || return 1
  echo "$LITEGAPPS_A16_SHA256  $zip_file" | sha256sum -c - >/dev/null 2>&1 || { error "LiteGapps checksum verification failed."; return 1; }
  unzip -q "$zip_file" -d "$tmp_dir/extracted" || return 1

  files_archive=$(find "$tmp_dir/extracted" -type f \( -name "files.tar.xz" -o -name "files.tar.br" -o -name "files.tar" \) | head -n1)
  [[ -n "$files_archive" ]] || { error "LiteGapps payload archive not found."; return 1; }
  case "$files_archive" in
    *.tar.xz) xz -dc "$files_archive" | tar -xf - -C "$payload_dir" || return 1 ;;
    *.tar.br) command -v brotli >/dev/null || { error "brotli is required."; return 1; }; brotli -d -c "$files_archive" | tar -xf - -C "$payload_dir" || return 1 ;;
    *.tar) tar -xf "$files_archive" -C "$payload_dir" || return 1 ;;
  esac

  product_dir=$(find "$payload_dir" -type d -name product | head -n1)
  system_ext_dir=$(find "$payload_dir" -type d -name system_ext | head -n1)
  [[ -n "$product_dir" ]] && cp -a "$product_dir"/. "$MAIN_FOLDER/product/"
  [[ -n "$system_ext_dir" ]] && cp -a "$system_ext_dir"/. "$MAIN_FOLDER/system_ext/"
  [[ -n "$product_dir" || -n "$system_ext_dir" ]] || { error "LiteGapps product/system_ext payload not found."; return 1; }
  rm -rf "$tmp_dir"
  info "Official LiteGapps Android 16 core overlay completed."
}


if [[ $regionTYPE == "China" ]]; then 
  aria2c -q -d "$work_dir/bin/modfile/Universal/gmsservices/product/priv-app/GoogleVelvet_CTS/" -o GoogleVelvet_CTS.apk https://github.com/tiencv2006/NothingsVN-BuildExt/releases/download/oplus/GoogleVelvet_CTS.apk && info "Get File Successfully"
  cp -rf $work_dir/bin/modfile/Universal/gmsservices/product/* $work_dir/build/baserom/images/product/
  cp -rf $work_dir/bin/modfile/Universal/gmsservices/system_ext/* $work_dir/build/baserom/images/system_ext/
  if [[ $androidVER == "16" ]]; then
    # Overlay official LiteGapps after HyperMOS extras: matching core packages
    # (GMS/GSF/Play Store/sync/common) are refreshed while extra apps remain.
    install_litegapps_a16 || { error "Failed to update LiteGapps Android 16 core."; exit 1; }
  fi
  grep -q '^ro.miui.has_gmscore=1
  if [[ $androidVER == "13" ]]; then 
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A13/framework $work_dir/build/baserom/images/product/
  elif [[ $androidVER == "14" ]]; then
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A14/framework $work_dir/build/baserom/images/product/
  else
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A15/framework $work_dir/build/baserom/images/product/
  fi
  mods "Added GMS Done"
else
  mods "Detected Xiaomi Global ROM!Skipped Added GMS."
fi
 "$MAIN_FOLDER/system/system/build.prop" || echo "ro.miui.has_gmscore=1" >> "$MAIN_FOLDER/system/system/build.prop"
  if [[ $androidVER == "13" ]]; then 
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A13/framework $work_dir/build/baserom/images/product/
  elif [[ $androidVER == "14" ]]; then
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A14/framework $work_dir/build/baserom/images/product/
  else
    cp -rf $work_dir/bin/modfile/Universal/gmsservices/maps/A15/framework $work_dir/build/baserom/images/product/
  fi
  mods "Added GMS Done"
else
  mods "Detected Xiaomi Global ROM!Skipped Added GMS."
fi
