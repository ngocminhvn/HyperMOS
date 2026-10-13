#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
images="$work_dir/build/baserom/images"
source "$work_dir/functions.sh"

system_ext="$images/system_ext"
system="$images/system/system"
binary="$work_dir/bin/package/LOCK/system_ext/xbin/hypermos-resetprop"
rc="$work_dir/bin/package/LOCK/system/etc/init/tnm.rc"
policy="$system_ext/etc/selinux/system_ext_sepolicy.cil"
image_contexts="$system_ext/etc/selinux/system_ext_file_contexts"
config_contexts="$images/config/system_ext_file_contexts"
resetprop_path="/system_ext/xbin/hypermos-resetprop"
resetprop_context="u:object_r:tnm_resetprop_exec:s0"

[ -d "$system_ext" ] || { error "LOCK: system_ext tree missing"; exit 1; }
[ -d "$system" ] || { error "LOCK: system tree missing"; exit 1; }
[ -s "$binary" ] || { error "LOCK: standalone resetprop binary missing"; exit 1; }
[ -s "$rc" ] || { error "LOCK: init trigger missing"; exit 1; }
[ -s "$policy" ] || { error "LOCK: system_ext split SELinux policy missing"; exit 1; }
[ -s "$image_contexts" ] || { error "LOCK: system_ext file contexts missing"; exit 1; }
[ -s "$config_contexts" ] || { error "LOCK: repack file contexts missing"; exit 1; }

if [ -e "$system/etc/init/hypermos-lock.rc" ]; then
  error "LOCK: stale hypermos-lock.rc found; rebuild from a clean image tree"
  exit 1
fi
if [ -e "$system/etc/init/tnm.rc" ] && ! cmp -s "$rc" "$system/etc/init/tnm.rc"; then
  error "LOCK: existing tnm.rc differs; refusing to overwrite it"
  exit 1
fi

if ! grep -qF '(type tnm_resetprop_exec)' "$policy"; then
  cat >> "$policy" <<'EOF'

; HyperMOS TNM one-shot boot property synchronization.
(type tnm_resetprop_exec)
(roletype object_r tnm_resetprop_exec)
(typeattributeset file_type (tnm_resetprop_exec))
(typeattributeset exec_type (tnm_resetprop_exec))
(typeattributeset system_file_type (tnm_resetprop_exec))
(allow init tnm_resetprop_exec (file (read getattr map execute open execute_no_trans)))
EOF
fi

for contexts in "$image_contexts" "$config_contexts"; do
  existing="$(awk -v path="$resetprop_path" '$1 == path { print $2 }' "$contexts")"
  if [ -n "$existing" ] && [ "$existing" != "$resetprop_context" ]; then
    error "LOCK: conflicting SELinux context for $resetprop_path in $contexts: $existing"
    exit 1
  fi
  if [ -z "$existing" ]; then
    printf '%s %s\n' "$resetprop_path" "$resetprop_context" >> "$contexts"
  fi
done

# A modified split CIL must be compiled by init instead of using stale policy.
for part in vendor odm; do
  policy_dir="$images/$part/etc/selinux"
  if [ -d "$policy_dir" ]; then
    find "$policy_dir" -maxdepth 1 -type f -name 'precompiled_sepolicy*' -delete
  fi
done

install -D -m 0755 "$binary" "$system_ext/xbin/hypermos-resetprop"
install -D -m 0644 "$rc" "$system/etc/init/tnm.rc"

grep -qF '(allow init tnm_resetprop_exec (file (read getattr map execute open execute_no_trans)))' "$policy" || {
  error "LOCK: resetprop SELinux execution rule missing"
  exit 1
}
for contexts in "$image_contexts" "$config_contexts"; do
  grep -qF "$resetprop_path $resetprop_context" "$contexts" || {
    error "LOCK: resetprop file context missing from $contexts"
    exit 1
  }
done

mods "LOCK: bundled standalone resetprop with dedicated init execution policy"
info "LOCK: Kaorios hooks and AVB images left unchanged"
