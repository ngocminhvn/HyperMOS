#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

mods "Starting Update File..."
TARGET_DIR="$work_dir/bin/modfile/UpdateFile"

# Read Xiaomi.eu skip policy once; China keeps the exact original module set.
EU_SKIP_ACTIVE=0
EU_POLICY="$work_dir/bin/modfile/EU/policy.sh"
if [[ -s "$work_dir/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    [[ -s "$EU_POLICY" ]] || { error "Xiaomi.eu skip policy missing: $EU_POLICY"; exit 1; }
    source "$EU_POLICY"
    EU_SKIP_ACTIVE=1
    mods "Xiaomi.eu: skip China-only GMS/translation/region/notification patches"
fi


# Only module entrypoints are executed here. Helpers such as
# Emoji/install-emoji.sh and TNM/tnm-hostsctl.sh must never be run
# standalone: their owning update.sh supplies the required arguments
# and stages them in the correct ROM location.
mapfile -t scripts < <(find "$TARGET_DIR" -mindepth 2 -type f -name "update.sh" | LC_ALL=C sort)

if (( ${#scripts[@]} == 0 )); then
    error "UpdateFile: no module update.sh entrypoints found"
    exit 1
fi

for script in "${scripts[@]}"; do
    if [[ "$EU_SKIP_ACTIVE" == "1" ]] &&
       eu_skip_mod "${script#"$work_dir/bin/modfile/"}"; then
        mods "Xiaomi.eu: SKIP ${script#"$work_dir/bin/modfile/"}"
        continue
    fi

    if ! bash "$script"; then
        error "UpdateFile mod failed: $script"
        exit 1
    fi
done
