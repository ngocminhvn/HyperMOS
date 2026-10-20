#!/usr/bin/env bash
# Xiaomi.eu-only build-time customization. China and Global builds are untouched.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"

source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$source_file" ]] || { error "EU: rom_source.txt is missing"; exit 1; }
rom_source="$(tr -d '\r\n' < "$source_file")"
[[ "$rom_source" == "xiaomi_eu" ]] || { error "EU: refusing to modify non-Xiaomi.eu source ($rom_source)"; exit 1; }

images="$work_dir/build/baserom/images"
[[ -d "$images/product/priv-app" ]] || { error "EU: product/priv-app missing from unpacked ROM"; exit 1; }

# Explicit user choice: keep the Kashi MiuiHome mod, but do not ship XiaomiEUExt.
# Remove only this exact directory, not other Xiaomi.eu system apps or overlays.
target="$images/product/priv-app/XiaomiEUExt"
if [[ -d "$target" && ! -L "$target" ]]; then
    rm -rf -- "$target"
    mods "EU: removed stock /product/priv-app/XiaomiEUExt"
elif [[ -e "$target" || -L "$target" ]]; then
    error "EU: unexpected non-directory XiaomiEUExt target: $target"
    exit 1
else
fi

[[ ! -e "$target" && ! -L "$target" ]] || {
    error "EU: XiaomiEUExt removal failed"
    exit 1
}
mods "EU: MiuiExtraPhoto and other Xiaomi.eu applications left untouched"
