#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)

if [[ "$rom_os" != "OS3" ]]; then
    mods "Skip OS3 Mods Center packages: ROM is $rom_os"
    exit 0
fi

mods "Starting Apply OS3 Mods Center packages..."

TARGET_DIR="$work_dir/bin/modfile/OS3"
KASHI_SCRIPT="$TARGET_DIR/kashimod.sh"

if [[ ! -f "$KASHI_SCRIPT" ]]; then
    error "OS3 Kashi mods: kashimod.sh not found"
    exit 1
fi

mods "OS3 -> kashimod"
if ! bash "$KASHI_SCRIPT"; then
    error "OS3 mod failed: $KASHI_SCRIPT"
    exit 1
fi

mapfile -t scripts < <(find "$TARGET_DIR" -mindepth 2 -type f -name "update.sh" | LC_ALL=C sort)

for script in "${scripts[@]}"; do
    mods "OS3 -> $(basename "$(dirname "$script")")"
    if ! bash "$script"; then
        error "OS3 mod failed: $script"
        exit 1
    fi
done

mods "OS3 Mods Center packages applied successfully"
