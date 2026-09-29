#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "HyperOS Security Center V7" \
    "https://github.com/Mods-Center/HyperOS-Security-Center/releases/download/V7/HyperOS_SecurityV7%40kashis_cringey_stuffs.zip" \
    "b1722752144805f15e8e7d2d619403257594b05f123afb5ff61af004ba642d9c" \
    "HyperOS_Security_V7.zip" \
    "*SecurityCenter*.apk" \
    "MIUISecurityCenter" \
    "MIUISecurityCenterT" \
    "MIUISecurityCenterGlobal" \
    "MIUISecurityCenterPad" \
    "SecurityCenter"
