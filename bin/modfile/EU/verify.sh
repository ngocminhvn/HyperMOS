#!/usr/bin/env bash
# Final EU-only guard after shared mod and package stages.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"

rom_source="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")"
[[ "$rom_source" == "xiaomi_eu" ]] || { error "EU verification invoked for unexpected source: $rom_source"; exit 1; }
images="$work_dir/build/baserom/images"
ext="$images/product/priv-app/XiaomiEUExt"
[[ ! -e "$ext" && ! -L "$ext" ]] || {
    error "EU: a later mod reintroduced XiaomiEUExt; stop before packaging"
    exit 1
}
# User wants the same Kashi launcher as China and no CN notification patch.
[[ -s "$images/product/priv-app/MiuiHome/MiuiHome.apk" ]] || {
    error "EU: Kashi MiuiHome not present after OS3 mods"
    exit 1
}
mods "EU: XiaomiEUExt absent, Kashi MiuiHome present; verification passed"
