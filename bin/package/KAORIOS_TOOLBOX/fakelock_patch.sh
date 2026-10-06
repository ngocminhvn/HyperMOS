#!/bin/bash
# SPDX-License-Identifier: GPL-3.0
# Derived from PenguinOS bin/package/KouseiPatcher/fakelock_patch.sh.
# HyperMOS integration changes: KouseiPatcher -> KAORIOS_TOOLBOX,
# xeutoolbox/xeu_toolbox -> toolbox/toolbox, and corrected payload copy path.

set -e

work_dir=$(pwd)
# This script is executed in a child bash, so parent shell functions are not
# inherited. Load HyperMOS logging helpers locally before using error/mods/patch.
source "$work_dir/functions.sh"

kaorios_dir="$work_dir/bin/package/KAORIOS_TOOLBOX"
magiskboot="$work_dir/bin/Linux/x86_64/magiskboot"

if [ ! -f "$magiskboot" ]; then
  error "KAORIOS FakeLock: PenguinOS magiskboot not found: $magiskboot"
  exit 1
fi

# GitHub Actions no longer chmods the whole repository. Ensure the selected
# binary is executable instead of relying on checkout file mode.
chmod +x "$magiskboot" 2>/dev/null || {
  error "KAORIOS FakeLock: cannot make magiskboot executable: $magiskboot"
  exit 1
}

prop="$kaorios_dir/prop"
toolbox_payload="$kaorios_dir/toolbox"
SEARCH_DIR="$work_dir/build/baserom/images"

# 1. Patch vendor_boot.img after PenguinOS HMATools, matching Penguin's flow.
if [ -f "$SEARCH_DIR/vendor_boot.img" ]; then
  echo "[IMGPATCH] - PATCHING vendor_boot.img (PenguinOS flow)"
  temp_boot="$work_dir/temp_boot"
  rm -rf "$temp_boot"
  mkdir -p "$temp_boot"

  echo "[IMGPATCH] - Stage 1 Patching..."
  cp -f "$SEARCH_DIR/vendor_boot.img" "$work_dir/vendor_boot.img"
  cp -f "$SEARCH_DIR/vendor_boot.img" "$temp_boot/vendor_boot.img"

  set +e
  "$magiskboot" unpack -h "$work_dir/vendor_boot.img"
  unpack_rc=$?
  set -e

  case "$unpack_rc" in
    0|3)
      [ "$unpack_rc" -eq 3 ] && echo "[IMGPATCH] - magiskboot identified vendor_boot (rc=3); continuing"
      ;;
    *)
      error "KAORIOS FakeLock: magiskboot unpack failed (rc=$unpack_rc)"
      rm -f "$work_dir/vendor_boot.img" "$work_dir/header" "$work_dir/dtb" "$work_dir/ramdisk.cpio"
      rm -rf "$temp_boot"
      exit 1
      ;;
  esac

  if [ ! -s "$work_dir/header" ]; then
    error "KAORIOS FakeLock: magiskboot unpack did not create a usable header"
    rm -f "$work_dir/vendor_boot.img" "$work_dir/dtb" "$work_dir/ramdisk.cpio"
    rm -rf "$temp_boot"
    exit 1
  fi

  if ! grep -Fq 'androidboot.verifiedbootstate=green' "$work_dir/header"; then
    sed -i '/^cmdline=/ s/$/ androidboot.verifiedbootstate=green androidboot.flash.locked=1 androidboot.vbmeta.device_state=locked/' "$work_dir/header"
  fi

  echo "[IMGPATCH] - Stage 2 Patching..."
  if ! "$magiskboot" repack "$work_dir/vendor_boot.img"; then
    error "KAORIOS FakeLock: magiskboot failed to repack vendor_boot.img"
    rm -f "$work_dir/vendor_boot.img" "$work_dir/new-boot.img" "$work_dir/header" "$work_dir/dtb" "$work_dir/ramdisk.cpio"
    rm -rf "$temp_boot"
    exit 1
  fi

  if [ ! -s "$work_dir/new-boot.img" ]; then
    error "KAORIOS FakeLock: repack did not create new-boot.img"
    rm -f "$work_dir/vendor_boot.img" "$work_dir/header" "$work_dir/dtb" "$work_dir/ramdisk.cpio"
    rm -rf "$temp_boot"
    exit 1
  fi

  mv -f "$work_dir/new-boot.img" "$work_dir/vendor_boot.img"

  echo "[IMGPATCH] - Stage 3 Cleanup..."
  rm -f "$work_dir/dtb" "$work_dir/header" "$work_dir/ramdisk.cpio"
  mv -f "$work_dir/vendor_boot.img" "$SEARCH_DIR/vendor_boot.img"
  rm -rf "$temp_boot"

  echo "[IMGPATCH] - Patched vendor_boot.img successfully with PenguinOS magiskboot"
fi

# 2. Toolbox fallback for devices launched below API 33.
BUILD_PROP=$(find "$SEARCH_DIR" -type f -name "build.prop" | head -n 1)
if [ -n "$BUILD_PROP" ]; then
  first_api=$(grep "ro.product.first_api_level" "$BUILD_PROP" | awk 'NR==1' | cut -d '=' -f 2 | tr -d ' \r')
  if [ -n "$first_api" ] && [ "$first_api" -lt 33 ]; then
    mods "API lower than 33! Inject Toolbox"

    system_ext="$SEARCH_DIR/system_ext"
    mkdir -p "$system_ext/xbin" "$system_ext/etc/init"

    if [ ! -f "$toolbox_payload/xbin/toolbox" ]; then
      error "KAORIOS FakeLock: missing toolbox payload"
      exit 1
    fi

    cp -a "$toolbox_payload/." "$system_ext/"

    # Ensure resetprop is a real alias to the multicall toolbox binary.
    rm -f "$system_ext/xbin/resetprop"
    ln -s toolbox "$system_ext/xbin/resetprop"

    if [ -f "$SEARCH_DIR/config/system_ext_file_contexts" ]; then
      grep -Fq '/system_ext/xbin/toolbox  u:object_r:toolbox_exec:s0' "$SEARCH_DIR/config/system_ext_file_contexts" ||
        echo "/system_ext/xbin/toolbox  u:object_r:toolbox_exec:s0" >> "$SEARCH_DIR/config/system_ext_file_contexts"
    fi
    if [ -f "$system_ext/etc/selinux/system_ext_file_contexts" ]; then
      grep -Fq '/system_ext/xbin/toolbox  u:object_r:toolbox_exec:s0' "$system_ext/etc/selinux/system_ext_file_contexts" ||
        echo "/system_ext/xbin/toolbox  u:object_r:toolbox_exec:s0" >> "$system_ext/etc/selinux/system_ext_file_contexts"
    fi
    if [ -f "$system_ext/etc/selinux/system_ext_sepolicy.cil" ]; then
      grep -Fq '(allow init toolbox_exec (file ((execute_no_trans))))' "$system_ext/etc/selinux/system_ext_sepolicy.cil" ||
        echo "(allow init toolbox_exec (file ((execute_no_trans))))" >> "$system_ext/etc/selinux/system_ext_sepolicy.cil"
    fi

    mods "Toolbox injected"
  fi
fi

# 3. Append PenguinOS property payload once.
if [ -f "$prop/build.prop" ]; then
  target_prop="$SEARCH_DIR/system/system/build.prop"
  if [ -f "$target_prop" ] && ! grep -Fq '#PlayIntegrityFix' "$target_prop"; then
    cat "$prop/build.prop" >> "$target_prop"
  fi
fi

# 4. Inject cust.prop keys without duplicating existing entries.
echo "[IMGPATCH] - Scanning for cust_prop_white_keys_list..."
if [ -f "$prop/cust.prop" ]; then
  find "$SEARCH_DIR" -type f -name "cust_prop_white_keys_list" | while read -r target_file; do
    while IFS= read -r key; do
      [ -z "$key" ] && continue
      grep -Fxq "$key" "$target_file" || echo "$key" >> "$target_file"
    done < "$prop/cust.prop"
    echo "[IMGPATCH] - Injected cust.prop into: $target_file"
  done
fi

patch "Done"
