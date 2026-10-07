#!/usr/bin/env bash
set -euo pipefail
work_dir=$(pwd)
source "$work_dir/functions.sh"
src="$work_dir/bin/modfile/UpdateFile/HCL_Compat"
images="$work_dir/build/baserom/images"
# SukiSU/KernelSU use the su domain. Magisk builds may explicitly select magisk.
# No root-manager domain is created and SELinux is never relaxed by this port.
domain="${HCL_SELINUX_DOMAIN:-u:r:su:s0}"
case "$domain" in u:r:su:s0|u:r:magisk:s0) ;; *) error 'HCL: unsupported root domain'; exit 1 ;; esac
for file in hcl-compatctl hcl-diagnostics hcl-compat.rc default.conf LICENSE.HCL; do
    [[ -s "$src/$file" ]] || { error "HCL: missing $file"; exit 1; }
done
if [[ -d "$images/system_ext" ]]; then
    dst="$images/system_ext"; runtime=/system_ext
elif [[ -d "$images/product" ]]; then
    dst="$images/product"; runtime=/product
elif [[ -d "$images/system/system" ]]; then
    dst="$images/system/system"; runtime=/system
elif [[ -d "$images/system" ]]; then
    dst="$images/system"; runtime=/system
else
    warn 'HCL: no suitable partition; skipping optional integration'
    exit 0
fi
mods 'HCL compatibility: one-shot runtime, allowlisted identity, optional SuSFS'
mkdir -p "$dst/bin" "$dst/etc/init" "$dst/etc/hcl-compat"
sed -e "s|@HCL_CTL@|$runtime/bin/hcl-compatctl|g" \
    -e "s|@HCL_DEFAULTS@|$runtime/etc/hcl-compat/default.conf|g" \
    "$src/hcl-compatctl" > "$dst/bin/hcl-compatctl"
cp "$src/hcl-diagnostics" "$dst/bin/hcl-diagnostics"
cp "$src/default.conf" "$dst/etc/hcl-compat/default.conf"
cp "$src/LICENSE.HCL" "$dst/etc/hcl-compat/LICENSE.HCL"
sed -e "s|@HCL_CTL@|$runtime/bin/hcl-compatctl|g" \
    -e "s|@HCL_DOMAIN@|$domain|g" \
    "$src/hcl-compat.rc" > "$dst/etc/init/hcl-compat.rc"
chmod 0755 "$dst/bin/hcl-compatctl"
chmod 0644 "$dst/bin/hcl-diagnostics" "$dst/etc/hcl-compat/default.conf" "$dst/etc/init/hcl-compat.rc"
chmod 0644 "$dst/etc/hcl-compat/LICENSE.HCL"
# No other *.sh lives here: insupdate.sh would execute it on the build host.
if grep -Eq '@HCL_[A-Z_]+@' "$dst/bin/hcl-compatctl" "$dst/etc/init/hcl-compat.rc"; then
    error 'HCL: unresolved installation placeholder'; exit 1
fi
bash -n "$dst/bin/hcl-compatctl" "$dst/bin/hcl-diagnostics"
mods "HCL -> $runtime/bin/hcl-compatctl; root domain $domain"
mods 'HCL -> boot runtime needs installed root backend; missing backend fails open'
