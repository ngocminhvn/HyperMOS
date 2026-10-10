#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
profile_dir="$work_dir/bin/modfile/UpdateFile/RYUScrollEco"
device_file="$work_dir/bin/ddevice/device_f.txt"
android_file="$work_dir/bin/ddevice/androidver.txt"

# Scoped to the exact HAOTIAN Android 16 build. No global thermal modifications.
[[ -s "$device_file" && -s "$android_file" ]] || {
    warn "RYU Scroll Eco: device metadata missing, skip"
    exit 0
}
device="$(tr '[:upper:]' '[:lower:]' < "$device_file" | tr -d '\r\n')"
android="$(tr -d '\r\n' < "$android_file")"
if [[ "$device" != "haotian" || "$android" != "16" ]]; then
    mods "RYU Scroll Eco: not HAOTIAN Android 16, skip"
    exit 0
fi

# Explicit build-time opt-out: RYU_SCROLL_ECO_DISABLE=1
if [[ "${RYU_SCROLL_ECO_DISABLE:-0}" == "1" ]]; then
    mods "RYU Scroll Eco: disabled by build flag"
    exit 0
fi

target="$work_dir/build/baserom/images/vendor/etc/perf/thermalbreakboostconfig.xml"
if [[ ! -f "$target" ]]; then
    warn "RYU Scroll Eco: vendor boost config not present, leaving stock untouched"
    exit 0
fi

mods "RYU Scroll Eco: verify and selectively tune HAOTIAN scroll boost"
python3 "$profile_dir/patch_scroll_boost.py" --self-test
python3 "$profile_dir/patch_scroll_boost.py" --file "$target"
mods "RYU Scroll Eco: done (no thermal limit, launcher hint, FCM or PowerKeeper changes)"
