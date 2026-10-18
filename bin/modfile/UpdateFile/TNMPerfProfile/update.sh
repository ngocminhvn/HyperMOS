#!/usr/bin/env bash
# ZKOS PowerKeeper uses the original Xiaomi vendor/ODM thermal/perf profiles.
# RYU/TNM PerfHook, powerhint overlays and GPU permission changes are retired.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
mods "ZKOS POWER/THERMAL: original Xiaomi profiles; no RYU PerfHook import"
