#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src="$work_dir/bin/modfile/UpdateFile/TNM_Hosts/tnm-hosts.rc"
images="$work_dir/build/baserom/images"

if [[ ! -f "$src" ]]; then
  error "TNM Hosts: tnm-hosts.rc missing"
  exit 1
fi

if [[ -d "$images/system_ext" ]]; then
  dst="$images/system_ext/etc/init"
elif [[ -d "$images/product" ]]; then
  dst="$images/product/etc/init"
elif [[ -d "$images/system/system" ]]; then
  dst="$images/system/system/etc/init"
else
  error "TNM Hosts: no init-capable partition found"
  exit 1
fi

mods "TNM Hosts init"
mkdir -p "$dst"
cp -f "$src" "$dst/tnm-hosts.rc" || {
  error "TNM Hosts: copy failed"
  exit 1
}
chmod 0644 "$dst/tnm-hosts.rc" || {
  error "TNM Hosts: chmod failed"
  exit 1
}

[[ -s "$dst/tnm-hosts.rc" ]] || {
  error "TNM Hosts: installed rc missing or empty"
  exit 1
}

if ! grep -q '^on post-fs-data$' "$dst/tnm-hosts.rc" ||    ! grep -q '/data/system/tnm/hosts /system/etc/hosts bind' "$dst/tnm-hosts.rc"; then
  error "TNM Hosts: verification failed"
  exit 1
fi

mods "TNM Hosts init -> Done"
