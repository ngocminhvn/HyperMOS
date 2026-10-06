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
magiskboot_primary="$work_dir/bin/magiskboot"
magiskboot_fallback="$work_dir/bin/Linux/x86_64/magiskboot"

if [ -f "$magiskboot_primary" ]; then
  magiskboot="$magiskboot_primary"
elif [ -f "$magiskboot_fallback" ]; then
  magiskboot="$magiskboot_fallback"
else
  error "KAORIOS FakeLock: magiskboot not found"
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

# 1. vendor_boot is intentionally NOT repatched here.
# HyperMOS already owns the boot/vendor_boot stage earlier in the pipeline.
# Re-running magiskboot here would mutate the same image a second time and
# increases boot-chain risk. Keep the PenguinOS FakeLock property/cust payload
# below, while leaving vendor_boot exactly as produced by HyperMOS Boot stage.
echo "[IMGPATCH] - FakeLock: skip duplicate vendor_boot patch (owned by HyperMOS Boot stage)"

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
