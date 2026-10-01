#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"

payload="$work_dir/bin/package/ResetProp/system_ext"
system_ext="$work_dir/build/baserom/images/system_ext"
sepolicy="$system_ext/etc/selinux/system_ext_sepolicy.cil"
init_rc="$work_dir/build/baserom/images/system/system/etc/init/hw/init.rc"
toolbox="$system_ext/xbin/xeutoolbox"

mods "ResetProp: apply Fake Lock only"

[[ -s "$payload/xbin/xeutoolbox" ]] || {
    error "ResetProp: xeutoolbox payload missing"
    exit 1
}

[[ -f "$sepolicy" ]] || {
    error "ResetProp: system_ext_sepolicy.cil not found"
    exit 1
}

[[ -f "$init_rc" ]] || {
    error "ResetProp: init.rc not found"
    exit 1
}

mkdir -p "$system_ext/xbin" || exit 1
cp -f "$payload/xbin/xeutoolbox" "$toolbox" || {
    error "ResetProp: failed to install xeutoolbox"
    exit 1
}
chmod 0755 "$toolbox" 2>/dev/null || true

if ! grep -q '# HyperMOS ResetProp Fake Lock SELinux' "$sepolicy" 2>/dev/null; then
cat >> "$sepolicy" <<'EOF'

# HyperMOS ResetProp Fake Lock SELinux
(type xeutoolbox_exec)
(roletype object_r xeutoolbox_exec)
(typeattributeset file_type (xeutoolbox_exec))
(typeattributeset exec_type (xeutoolbox_exec))
(typeattributeset system_file_type (xeutoolbox_exec))
(allow init xeutoolbox_exec (file (read getattr map execute open execute_no_trans)))
EOF
fi

if ! grep -q '# HyperMOS ResetProp Fake Lock' "$init_rc" 2>/dev/null; then
cat >> "$init_rc" <<'EOF'

# HyperMOS ResetProp Fake Lock
on post-fs-data
    exec u:r:init:s0 root root -- /system_ext/xbin/xeutoolbox -n ro.boot.vbmeta.device_state locked
    exec u:r:init:s0 root root -- /system_ext/xbin/xeutoolbox -n ro.boot.verifiedbootstate green
    exec u:r:init:s0 root root -- /system_ext/xbin/xeutoolbox -n ro.secureboot.lockstate locked
EOF
fi

mods "ResetProp: Fake Lock -> Done"
