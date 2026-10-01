#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"

# Keep the device-reported boot / AVB state untouched.
# Do not inject xeutoolbox, SELinux rules, or override ro.boot.* /
# ro.secureboot.* properties.
mods "Skip ResetProp: keep original boot integrity properties"
exit 0
