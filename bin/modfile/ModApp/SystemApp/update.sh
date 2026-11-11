#!/usr/bin/env bash
# Replace stock Xiaomi Gallery with a locally staged APK on OS4 China only.
# This module does not download or modify/re-sign the APK.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/bin/modfile/ModApp/OS3/_common.sh"

rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
rom_source="$(cat "$work_dir/bin/ddevice/rom_source.txt" 2>/dev/null || true)"
if [[ "$rom_os" != "OS4" || "$rom_source" != "china" ]]; then
    mods "SystemApp Gallery: skip for rom_os=$rom_os rom_source=$rom_source"
    exit 0
fi

source_apk="$work_dir/bin/modfile/ModApp/SystemApp/MIUIGallery.apk"
if [[ ! -f "$source_apk" ]]; then
    mods "SystemApp Gallery: MIUIGallery.apk not committed; keep stock OS4 China Gallery"
    exit 0
fi

if head -n 1 "$source_apk" | grep -Fqx 'version https://git-lfs.github.com/spec/v1'; then
    error "SystemApp Gallery: Git LFS pointer found; checkout with LFS enabled / git lfs pull"
    exit 1
fi

if ! unzip -tqq "$source_apk" >/dev/null; then
    error "SystemApp Gallery: invalid APK/ZIP: $source_apk"
    exit 1
fi

mod_package="$(modscenter_apk_package "$source_apk" || true)"
if [[ "$mod_package" != "com.miui.gallery" ]]; then
    error "SystemApp Gallery: expected com.miui.gallery; got ${mod_package:-<unreadable>}"
    exit 1
fi

stock_apk="$(modscenter_find_stock_apk "com.miui.gallery" "MIUIGallery")" || {
    error "SystemApp Gallery: cannot uniquely locate stock com.miui.gallery APK"
    exit 1
}
stock_dir="$(dirname "$stock_apk")"
stock_filename="$(basename "$stock_apk")"
staging="$work_dir/build/os4_systemapp_gallery"
rm -rf "$staging"
mkdir -p "$staging"
trap 'rm -rf "$staging"' EXIT

# Keep the original stock partition and APK filename; never re-sign the APK.
cp -f "$source_apk" "$staging/$stock_filename"
modscenter_supplement_native_libs "SystemApp OS4 Gallery" "$staging/$stock_filename" "$staging" || exit 1
find "$staging" -type d -exec chmod 0755 {} +
find "$staging" -type f -exec chmod 0644 {} +

mods "SystemApp OS4 Gallery: replacing $stock_dir (package: $mod_package)"
rm -rf "$stock_dir"
mkdir -p "$stock_dir"
cp -a "$staging/." "$stock_dir/" || {
    error "SystemApp Gallery: failed to copy replacement app"
    exit 1
}

copied_package="$(modscenter_apk_package "$stock_dir/$stock_filename" || true)"
if [[ "$copied_package" != "com.miui.gallery" ]]; then
    error "SystemApp Gallery: package validation failed after copy"
    exit 1
fi
modscenter_verify_folder_shape "SystemApp OS4 Gallery" "$staging" "$stock_dir" || exit 1
mods "SystemApp OS4 Gallery: replacement complete"
