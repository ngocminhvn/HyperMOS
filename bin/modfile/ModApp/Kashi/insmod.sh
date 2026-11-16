#!/usr/bin/env bash
# ==============================================================================
# Kashi Mods Master Entrypoint (Invoked during ROM build)
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
if [[ "$rom_os" != "OS3" && "$rom_os" != "OS4" ]]; then
    mods "Skip Kashi mods: ROM is $rom_os (only OS3 and OS4 supported)"
    exit 0
fi

target_dir="$work_dir/bin/modfile/ModApp/Kashi"
bash "$target_dir/kashimod.sh" || {
    error "Kashi mod integration failed for $rom_os"
    exit 1
}

mods "Kashi mods successfully integrated ($rom_os)"
