#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"

# Keep stock ROM identity/properties.
# This module previously patched Settings.apk and appended custom
# ro.nothings.* properties to system/build.prop.
mods "Skip custom ROM information: keep stock Settings and build.prop"
exit 0
