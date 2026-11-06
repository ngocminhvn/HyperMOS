#!/usr/bin/env bash
# OS4 China Android 17: install prebuilt Vietnamese APK overlays like OS3.
# No XML compilation, AAPT2, APK signing or ROM APK replacement at build time.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"

info_dir="$work_dir/bin/ddevice"
rom_os="$(tr -d '\r\n' < "$info_dir/rom_os.txt")"
android_ver="$(tr -d '\r\n' < "$info_dir/androidver.txt")"
base_rom_code="$(tr -d '\r\n' < "$info_dir/base_rom_code.txt")"

if [[ "$rom_os" != "OS4" || "$android_ver" != "17" ]]; then
  error "MultiLang OS4 requires OS4 / Android 17"
  exit 1
fi

module="$work_dir/bin/modfile/UpdateFile/MultiLang/OS4"
images="$work_dir/build/baserom/images"
rom_version="$(python3 "$module/rom_version.py" "$base_rom_code")" || {
  error "MultiLang OS4: invalid ROM version"
  exit 1
}
mods "MultiLang OS4: copying shared prebuilt Vietnamese overlays for ROM $rom_version"
python3 "$module/install_prebuilt.py" "$module" "$images" "$base_rom_code" || {
  error "MultiLang OS4: missing/invalid prebuilt overlays for $rom_version"
  exit 1
}
mods "MultiLang OS4: prebuilt APK overlays installed, no rebuild necessary"
