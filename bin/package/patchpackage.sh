#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"

mods "Add Package..."
target_dir="$work_dir/bin/package"

run_package() {
    local label="$1"
    local script="$2"

    if bash "$script"; then
        patch "$label -> Done"
        return 0
    fi

    error "$label failed"
    return 1
}

run_package "COREPATCH" "$target_dir/COREPATCH/update.sh" || exit 1
run_package "DISABLE_AVB" "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
run_package "KouseiPatcher" "$target_dir/KouseiPatcher/update.sh" || exit 1
run_package "NOTIFICATION_FIX" "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" || exit 1
run_package "RefreshRate" "$target_dir/RefreshRate/1hz.sh" || exit 1

mods "Add Package Done"
