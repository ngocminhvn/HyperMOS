#!/usr/bin/env bash
# ==============================================================================
# HyperLight Master Dispatcher for HyperMOS
# Executes component-specific patches under SystemUI/, AOD/, etc.
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

hl_dir="$work_dir/bin/modfile/ModApp/HyperLight"

# 1. SystemUI Patches (Lockscreen Notification Keep, Show All, Stack Sink, Grouping, etc.)
if [[ -f "$hl_dir/SystemUI/update.sh" ]]; then
    bash "$hl_dir/SystemUI/update.sh" || exit 1
fi

# 2. AOD Patches (LockScreenDepthAvoid, LockScreenBlurButton)
if [[ -f "$hl_dir/AOD/update.sh" ]]; then
    bash "$hl_dir/AOD/update.sh" || exit 1
fi
