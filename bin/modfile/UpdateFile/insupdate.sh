#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

mods "Starting Update File..."
TARGET_DIR="$work_dir/bin/modfile/UpdateFile"

# Only module entrypoints are executed here. Helpers such as
# Fonts/install-emoji.sh and TNM/tnm-hostsctl.sh must never be run
# standalone: their owning update.sh supplies the required arguments
# and stages them in the correct ROM location.
mapfile -t scripts < <(find "$TARGET_DIR" -mindepth 2 -type f -name "update.sh" | LC_ALL=C sort)

if (( ${#scripts[@]} == 0 )); then
    error "UpdateFile: no module update.sh entrypoints found"
    exit 1
fi

for script in "${scripts[@]}"; do
    if ! bash "$script"; then
        error "UpdateFile mod failed: $script"
        exit 1
    fi
done
