#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src="$work_dir/bin/modfile/UpdateFile/VNeID_Compat"
images="$work_dir/build/baserom/images"
domain="${VNEID_SELINUX_DOMAIN:-u:r:su:s0}"

case "$domain" in
  u:r:su:s0|u:r:magisk:s0) ;;
  *) error "VNeID Compat: unsupported root domain"; exit 1 ;;
esac

for file in vneid-compatctl vneid-compat.rc LICENSE.HCL; do
  [[ -s "$src/$file" ]] || { error "VNeID Compat: missing $file"; exit 1; }
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
  warn "VNeID Compat: no suitable partition; skipping"
  exit 0
fi

mods "VNeID Compat: installing read-only inspector"
mkdir -p "$dst/bin" "$dst/etc/init" "$dst/etc/vneid-compat"

cp -f "$src/vneid-compatctl" "$dst/bin/vneid-compatctl"
cp -f "$src/LICENSE.HCL" "$dst/etc/vneid-compat/LICENSE.HCL"
sed -e "s|@VNEID_CTL@|$runtime/bin/vneid-compatctl|g"     -e "s|@VNEID_DOMAIN@|$domain|g"     "$src/vneid-compat.rc" > "$dst/etc/init/vneid-compat.rc"

chmod 0755 "$dst/bin/vneid-compatctl"
chmod 0644 "$dst/etc/init/vneid-compat.rc" "$dst/etc/vneid-compat/LICENSE.HCL"

if grep -Eq '@VNEID_[A-Z_]+@' "$dst/etc/init/vneid-compat.rc"; then
  error "VNeID Compat: unresolved install placeholder"
  exit 1
fi

bash -n "$dst/bin/vneid-compatctl"

# Build-time defense: read-only inspection may mention resetprop/SuSFS binaries,
# but must not contain known mutation operations.
if grep -Eqi   'add_sus_path|add_open_redirect|set_uname|force-stop|mount[[:space:]]+--bind|resetprop[[:space:]].*(-n|--delete)|/data/adb/tricky_store/.*(>|sed|rm)|/data/data/com\.vnid/.*(rm|sed|>)'   "$dst/bin/vneid-compatctl"; then
  error "VNeID Compat: mutating behavior detected"
  exit 1
fi

mods "VNeID Compat -> $runtime/bin/vneid-compatctl"
mods "VNeID Compat -> package/identity/matrix/audit/backend diagnostics"
mods "VNeID Compat -> no property, SuSFS, HMA or attestation mutation"
