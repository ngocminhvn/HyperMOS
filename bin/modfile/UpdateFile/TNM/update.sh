#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src_rc="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hosts.rc"
src_ctl="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hostsctl.sh"
images="$work_dir/build/baserom/images"

[[ -f "$src_rc" ]] || { error "TNM Hosts: tnm-hosts.rc missing"; exit 1; }
[[ -f "$src_ctl" ]] || { error "TNM Hosts: tnm-hostsctl.sh missing"; exit 1; }

if [[ -d "$images/system_ext" ]]; then
  init_dst="$images/system_ext/etc/init"
  bin_dst="$images/system_ext/bin"
  runtime_ctl="/system_ext/bin/tnm-hostsctl"
elif [[ -d "$images/product" ]]; then
  init_dst="$images/product/etc/init"
  bin_dst="$images/product/bin"
  runtime_ctl="/product/bin/tnm-hostsctl"
elif [[ -d "$images/system/system" ]]; then
  init_dst="$images/system/system/etc/init"
  bin_dst="$images/system/system/bin"
  runtime_ctl="/system/bin/tnm-hostsctl"
else
  error "TNM Hosts: no init-capable partition found"
  exit 1
fi

mods "TNM Hosts backend"
mkdir -p "$init_dst" "$bin_dst"

sed "s|@TNM_HOSTSCTL@|$runtime_ctl|g" "$src_rc" > "$init_dst/tnm-hosts.rc"
cp -f "$src_ctl" "$bin_dst/tnm-hostsctl"
chmod 0644 "$init_dst/tnm-hosts.rc"
chmod 0755 "$bin_dst/tnm-hostsctl"

[[ -s "$init_dst/tnm-hosts.rc" ]] || { error "TNM Hosts: installed rc missing"; exit 1; }
[[ -x "$bin_dst/tnm-hostsctl" ]] || { error "TNM Hosts: controller not executable"; exit 1; }

grep -qF "$runtime_ctl boot" "$init_dst/tnm-hosts.rc" || {
  error "TNM Hosts: init controller verification failed"
  exit 1
}
grep -q 'mount --bind "$SRC" "$TARGET"' "$bin_dst/tnm-hostsctl" || {
  error "TNM Hosts: bind controller verification failed"
  exit 1
}
grep -q 'RESULT=RESOLVER_UNVERIFIED' "$bin_dst/tnm-hostsctl" || {
  error "TNM Hosts: resolver self-test missing"
  exit 1
}

mods "TNM Hosts backend -> Done"
