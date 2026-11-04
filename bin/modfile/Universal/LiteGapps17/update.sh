#!/usr/bin/env bash
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/modfile/Universal/LiteGapps17"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")"
[[ "$android_ver" == "17" ]] || exit 0
rom_source="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")"
[[ "$rom_source" == "china" ]] || {
  info "LiteGapps17: skip non-China ROM ($rom_source)"
  exit 0
}
[[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/device_type.txt")" == "China" ]] || {
  error "LiteGapps17: source/region metadata mismatch"
  exit 1
}
info "LiteGapps17: loading pinned arm64 API 37 Core (2026-10-01) and matching addons"
python3 "$base/stage.py" --root "$work_dir" || {
  error "LiteGapps17: verified extraction failed; aborting build"
  exit 1
}
mods "LiteGapps17 Core + A17 addons staged"
