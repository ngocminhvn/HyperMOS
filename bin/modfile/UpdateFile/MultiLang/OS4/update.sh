#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

info_dir="$work_dir/bin/ddevice"
rom_os="$(tr -d '\r\n' < "$info_dir/rom_os.txt")"
android_ver="$(tr -d '\r\n' < "$info_dir/androidver.txt")"

if [[ "$rom_os" != "OS4" || "$android_ver" != "17" ]]; then
  error "MultiLang OS4 requires OS4 / Android 17"
  exit 1
fi

source_dir="$work_dir/bin/modfile/UpdateFile/MultiLang/OS4/Vietnamese/main"
images="$work_dir/build/baserom/images"
out="$images/product/overlay"
builder="$work_dir/bin/modfile/UpdateFile/MultiLang/OS4/build_vi_rro.py"

[[ -d "$source_dir" && -d "$images" ]] || {
  error "MultiLang OS4: Vietnamese XML or unpacked base ROM is missing"
  exit 1
}
[[ -f "$builder" ]] || { error "MultiLang OS4: builder missing"; exit 1; }

mods "MultiLang OS4: compiling Vietnamese XML to signed static RRO overlays"
python3 "$builder" "$source_dir" "$images" "$out" || {
  error "MultiLang OS4: RRO build failed; stop to avoid publishing incomplete ROM"
  exit 1
}
mods "MultiLang OS4: compiled Vietnamese RROs added to product/overlay"
