#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
source "$work_dir/functions.sh"
magiskboot="$work_dir/bin/magiskboot"
prop="$work_dir/bin/package/KouseiPatcher/prop"
SEARCH_DIR="build/baserom/images"

[[ -x "$magiskboot" ]] || chmod +x "$magiskboot" 2>/dev/null || true
[[ -f "$magiskboot" ]] || {
  error "Kaorios fake-lock: magiskboot not found"
  exit 1
}

# 1. Patch vendor_boot.img (keep PenguinOS behavior, but fail cleanly and restore on error)
if [ -f "$work_dir/$SEARCH_DIR/vendor_boot.img" ]; then
  echo "[IMGPATCH] - PATCHING vendor_boot.img"
  rm -rf "$work_dir/temp_boot"
  mkdir -p "$work_dir/temp_boot"

  cp -f "$work_dir/$SEARCH_DIR/vendor_boot.img" "$work_dir/vendor_boot.img" || exit 1
  cp -f "$work_dir/$SEARCH_DIR/vendor_boot.img" "$work_dir/temp_boot/vendor_boot.img" || exit 1

  echo "[IMGPATCH] - Stage 1 Patching..."
  if ! "$magiskboot" unpack -h "$work_dir/vendor_boot.img" >/dev/null 2>&1; then
    error "Kaorios fake-lock: vendor_boot unpack failed"
    cp -f "$work_dir/temp_boot/vendor_boot.img" "$work_dir/$SEARCH_DIR/vendor_boot.img"
    exit 1
  fi

  if [[ ! -f "$work_dir/header" ]] || ! grep -q '^cmdline=' "$work_dir/header"; then
    error "Kaorios fake-lock: boot header/cmdline not found"
    cp -f "$work_dir/temp_boot/vendor_boot.img" "$work_dir/$SEARCH_DIR/vendor_boot.img"
    exit 1
  fi

  sed -i '/^cmdline=/ s/$/ androidboot.verifiedbootstate=green androidboot.flash.locked=1 androidboot.vbmeta.device_state=locked/' "$work_dir/header" || {
    cp -f "$work_dir/temp_boot/vendor_boot.img" "$work_dir/$SEARCH_DIR/vendor_boot.img"
    exit 1
  }

  echo "[IMGPATCH] - Stage 2 Patching..."
  if ! "$magiskboot" repack "$work_dir/vendor_boot.img" >/dev/null 2>&1 || [[ ! -s "$work_dir/new-boot.img" ]]; then
    error "Kaorios fake-lock: vendor_boot repack failed"
    cp -f "$work_dir/temp_boot/vendor_boot.img" "$work_dir/$SEARCH_DIR/vendor_boot.img"
    exit 1
  fi

  mv -f "$work_dir/new-boot.img" "$work_dir/$SEARCH_DIR/vendor_boot.img" || exit 1

  echo "[IMGPATCH] - Stage 3 Cleanup..."
  rm -rf "$work_dir/dtb" "$work_dir/header" "$work_dir/ramdisk.cpio"          "$work_dir/vendor_boot.img" "$work_dir/temp_boot"

  [[ -s "$work_dir/$SEARCH_DIR/vendor_boot.img" ]] || {
    error "Kaorios fake-lock: patched vendor_boot.img missing"
    exit 1
  }

  echo "[IMGPATCH] - Patched vendor_boot.img successfully!"
fi

# 2. XEUToolbox for API < 33
BUILD_PROP=$(find "$SEARCH_DIR" -type f -name "build.prop" | head -n 1)
if [ -n "$BUILD_PROP" ]; then
  first_api=$(grep "ro.product.first_api_level" "$BUILD_PROP" | awk 'NR==1' | cut -d '=' -f 2 | tr -d ' \r')
  if [ -n "$first_api" ] && [ "$first_api" -lt 33 ]; then
    mods "API lower than 33! Inject XEUToolbox by Xiaomi.eu"
    echo "/system_ext/xbin/xeu_toolbox  u:object_r:toolbox_exec:s0" >> build/baserom/images/config/system_ext_file_contexts
    echo "/system_ext/xbin/xeu_toolbox  u:object_r:toolbox_exec:s0" >> build/baserom/images/system_ext/etc/selinux/system_ext_file_contexts
    echo "(allow init toolbox_exec (file ((execute_no_trans))))" >> build/baserom/images/system_ext/etc/selinux/system_ext_sepolicy.cil
    cp -rf "$work_dir/bin/package/KouseiPatcher/bin/xeu_toolbox/"* "$work_dir/build/baserom/images/system_ext" || exit 1
    mods "Done!"
  fi
fi

# 3. Keep PenguinOS behavior: append build.prop here.
if [ -f "$prop/build.prop" ]; then
  cat "$prop/build.prop" >> "$work_dir/$SEARCH_DIR/system/system/build.prop" || exit 1
fi

# 4. Inject cust.prop into every cust_prop_white_keys_list.
echo "[IMGPATCH] - Scanning for cust_prop_white_keys_list..."
if [ -f "$prop/cust.prop" ]; then
  while IFS= read -r target_file; do
    cat "$prop/cust.prop" >> "$target_file" || exit 1
    echo "[IMGPATCH] - Injected cust.prop into: $target_file"
  done < <(find "$SEARCH_DIR" -type f -name "cust_prop_white_keys_list")
fi

patch "Done"
