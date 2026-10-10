#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
device_file="$work_dir/bin/ddevice/device_f.txt"
android_file="$work_dir/bin/ddevice/androidver.txt"

[[ -s "$device_file" && -s "$android_file" ]] || { error "RYU FULL PERF: device metadata missing"; exit 1; }
device="$(tr '[:upper:]' '[:lower:]' < "$device_file" | tr -d '\r\n')"
android="$(tr -d '\r\n' < "$android_file")"
if [[ "$device" != "haotian" || "$android" != "16" ]]; then
  mods "RYU FULL PERF: not HAOTIAN Android 16, skip"
  exit 0
fi

# Experimental import must never end up on HyperMOS main accidentally.
if [[ "${GITHUB_REF_NAME:-test-ryu-performance-haotian}" != "test-ryu-performance-haotian" ]]; then
  error "RYU FULL PERF is only permitted on test-ryu-performance-haotian"
  exit 1
fi

artifact="${RYU_REF_DIR:-}"
[[ -n "$artifact" && -s "$artifact/manifest.json" ]] || {
  error "RYU FULL PERF: missing validated repository thermal ZIP reference"
  exit 1
}
python3 "$work_dir/bin/modfile/UpdateFile/RYUPerfProfile/port_ryu_perf.py" \
  --artifact "$artifact" \
  --rom "$work_dir/build/baserom/images"

mods "RYU FULL PERF: original powerhint/perf configurations staged (safety profiles unchanged)"
