#!/usr/bin/env bash
# EU DEX PowerKeeper uses the base Xiaomi vendor/ODM thermal/performance profiles.
# RYU/TNM PerfHook, powerhint overlays and GPU permission changes are retired.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
mods "EU POWER/THERMAL: exact EU DEX, Xiaomi vendor thermal; no RYU PerfHook"
