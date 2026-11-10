#!/usr/bin/env bash
# BEACHEADVN-style MultiLang: copy prebuilt China overlays unchanged.
# OS3 and OS4 use exactly the same installation path, only the APK source differs.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

module_dir="$work_dir/bin/modfile/UpdateFile/MultiLang"
info_dir="$work_dir/bin/ddevice"

for item in rom_os.txt rom_source.txt device_type.txt; do
  [[ -s "$info_dir/$item" ]] || { error "MultiLang: missing $item"; exit 1; }
done

rom_os="$(tr -d '\r\n' < "$info_dir/rom_os.txt")"
rom_source="$(tr -d '\r\n' < "$info_dir/rom_source.txt")"
device_type="$(tr -d '\r\n' < "$info_dir/device_type.txt")"

# Xiaomi.eu has its own translations; never add China overlays to EU ROMs.
if [[ "$rom_source" != "china" || "$device_type" != "China" ]]; then
  mods "MultiLang: not a China ROM; skip"
  exit 0
fi

case "$rom_os" in
  OS3|OS4) ;;
  *) mods "MultiLang: unsupported OS $rom_os; skip"; exit 0 ;;
esac

src="$module_dir/$rom_os/updatesource"
product="$work_dir/build/baserom/images/product"
target="$product/overlay"

[[ -d "$src" ]] || { error "MultiLang $rom_os: updatesource directory missing"; exit 1; }
[[ -d "$product" ]] || { error "MultiLang $rom_os: extracted product partition missing"; exit 1; }

# Both ROM generations follow the upstream BEACHEADVN copy-only approach.
# No XML merge, AAPT2, signing, ROM-version manifest, SHA-256 or JAR patch.
shopt -s nullglob
apks=("$src"/*.apk)
(( ${#apks[@]} > 0 )) || {
  error "MultiLang $rom_os: no prebuilt overlay APKs found"
  exit 1
}

mkdir -p "$target"
mods "Adding MultiLanguage to $rom_os China ROM..."
cp -f -- "${apks[@]}" "$target/"
mods "MultiLang $rom_os: copied ${#apks[@]} prebuilt overlay APKs unchanged into product/overlay"
