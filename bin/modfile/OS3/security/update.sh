#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_native_module \
    "HyperOS Security Center" \
    "Mods-Center/HyperOS-Security-Center" \
    "com.miui.securitycenter" \
    "*SecurityCenter*.apk" \
    "product/priv-app/MIUISecurityCenter" \
    "MIUISecurityCenter" \
    "MIUISecurityCenterT" \
    "MIUISecurityCenterGlobal" \
    "MIUISecurityCenterPad" \
    "SecurityCenter"
