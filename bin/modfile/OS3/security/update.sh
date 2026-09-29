#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_privapp \
    "HyperOS Security Center" \
    "Mods-Center/HyperOS-Security-Center" \
    "*SecurityCenter*.apk" \
    "MIUISecurityCenter" \
    "MIUISecurityCenter.apk" \
    "privapp_whitelist_com.miui.securitycenter.xml" \
    "1" \
    "MIUISecurityCenter" \
    "MIUISecurityCenterT" \
    "MIUISecurityCenterGlobal" \
    "MIUISecurityCenterPad" \
    "SecurityCenter"
