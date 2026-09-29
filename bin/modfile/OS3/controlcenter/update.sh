#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "ColorOS Control Center" \
    "Mods-Center/ColorOS_Control_Center" \
    "*MIUISystemUIPlugin*.apk" \
    "MIUISystemUIPlugin"
