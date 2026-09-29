#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "ColorOS Control Center V3" \
    "https://github.com/Mods-Center/ColorOS_Control_Center/releases/download/V3/ColorOS_plugin_mod_V3_%40kashis_cringey_stuffs.zip" \
    "0cd9436b9cc76a7c4138137190a44d830783a4cc67980d40e9e273f2c3327499" \
    "ColorOS_Control_Center_V3.zip" \
    "*MIUISystemUIPlugin*.apk" \
    "MIUISystemUIPlugin"
