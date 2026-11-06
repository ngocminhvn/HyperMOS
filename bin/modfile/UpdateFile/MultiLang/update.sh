#!/usr/bin/env bash
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
info_dir="$work_dir/bin/ddevice"
module_dir="$work_dir/bin/modfile/UpdateFile/MultiLang"
for item in rom_os.txt rom_source.txt device_type.txt; do
  [[ -s "$info_dir/$item" ]] || { error "MultiLang: missing $item"; exit 1; }
done
rom_os="$(tr -d '\r\n' < "$info_dir/rom_os.txt")"
rom_source="$(tr -d '\r\n' < "$info_dir/rom_source.txt")"
device_type="$(tr -d '\r\n' < "$info_dir/device_type.txt")"
if [[ "$rom_source" == "xiaomi_eu" ]]; then
  mods "MultiLang: Xiaomi.eu already provides translations; skip"
  exit 0
fi
if [[ "$rom_source" != "china" || "$device_type" != "China" ]]; then
  mods "MultiLang: not a China ROM; skip"
  exit 0
fi
case "$rom_os" in
  OS3|OS4)
    script="$module_dir/$rom_os/update.sh"
    [[ -f "$script" ]] || { error "MultiLang: missing $script"; exit 1; }
    mods "MultiLang: dispatch $rom_os"
    bash "$script" || { error "MultiLang: $rom_os module failed"; exit 1; }
    ;;
  *) mods "MultiLang: skip unsupported OS $rom_os" ;;
esac
