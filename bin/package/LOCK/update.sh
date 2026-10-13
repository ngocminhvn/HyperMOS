#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
images="$work_dir/build/baserom/images"
source "$work_dir/functions.sh"

system_ext="$images/system_ext"
system="$images/system/system"
binary="$work_dir/bin/package/LOCK/system_ext/xbin/hypermos-resetprop"
rc="$work_dir/bin/package/LOCK/system/etc/init/tnm.rc"

[ -d "$system_ext" ] || { error "LOCK: system_ext tree missing"; exit 1; }
[ -d "$system" ] || { error "LOCK: system tree missing"; exit 1; }
[ -s "$binary" ] || { error "LOCK: standalone resetprop binary missing"; exit 1; }
[ -s "$rc" ] || { error "LOCK: init trigger missing"; exit 1; }

if [ -e "$system/etc/init/hypermos-lock.rc" ]; then
  error "LOCK: stale hypermos-lock.rc found; rebuild from a clean image tree"
  exit 1
fi
if [ -e "$system/etc/init/tnm.rc" ] && ! cmp -s "$rc" "$system/etc/init/tnm.rc"; then
  error "LOCK: existing tnm.rc differs; refusing to overwrite it"
  exit 1
fi
install -D -m 0755 "$binary" "$system_ext/xbin/hypermos-resetprop"
install -D -m 0644 "$rc" "$system/etc/init/tnm.rc"

mods "LOCK: bundled standalone resetprop and synchronous post-fs-data property sync"
info "LOCK: Kaorios hooks and AVB images left unchanged"
