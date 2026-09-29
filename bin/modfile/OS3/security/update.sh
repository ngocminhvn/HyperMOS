#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "HyperOS Security Center" \
    "Mods-Center/HyperOS-Security-Center" \
    "*SecurityCenter*.apk" \
    "MIUISecurityCenter" \
    "MIUISecurityCenterT" \
    "MIUISecurityCenterGlobal" \
    "MIUISecurityCenterPad" \
    "SecurityCenter"
