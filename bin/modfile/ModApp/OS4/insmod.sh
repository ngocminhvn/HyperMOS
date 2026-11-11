#!/usr/bin/env bash
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
if [[ "$rom_os" != "OS4" ]]; then
    mods "Skip OS4 Kashi mods: ROM is $rom_os"
    exit 0
fi

mods "Starting OS4 Kashi / Mods-Center integration"
target_dir="$work_dir/bin/modfile/ModApp/OS4"
bash "$target_dir/kashimod.sh" || {
    error "OS4 Kashi mod integration failed"
    exit 1
}
# Additional OS4-specific installers can be added later as update.sh files.
mapfile -t scripts < <(find "$target_dir" -mindepth 2 -type f -name 'update.sh' | LC_ALL=C sort)
for script in "${scripts[@]}"; do
    bash "$script" || { error "OS4 mod failed: $script"; exit 1; }
done
# Replace stock Gallery only on OS4 China when a local SystemApp APK is present.
bash "$work_dir/bin/modfile/ModApp/SystemApp/update.sh" || {
    error "OS4 SystemApp Gallery integration failed"
    exit 1
}
mods "OS4 Kashi mods integrated"
