#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_replace_existing_apk \
    "ColorOS Control Center" \
    "Mods-Center/ColorOS_Control_Center" \
    "*MIUISystemUIPlugin*.apk" \
    "MIUISystemUIPlugin" \
    "MIUISystemUIPlugin.apk"
