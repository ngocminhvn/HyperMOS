#!/usr/bin/env bash
# Stock Xiaomi PowerKeeper and vendor/ODM thermal/performance profiles are kept intact.
# RYU/TNM PerfHook, powerhint overlays and GPU permission changes are retired.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
mods "STOCK POWER/THERMAL: verified Xiaomi PowerKeeper; no donor DEX or RYU PerfHook"
