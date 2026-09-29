#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "HyperOS Theme Manager V7" \
    "https://github.com/Mods-Center/HyperOS-Theme-Manager/releases/download/V7/HyperOS_ThemeManagerV7%40kashis_cringey_stuffs.zip" \
    "caba9debf6ce68d42a734125d9956707ad89ab4beda9aa6bca84d6f904d28398" \
    "HyperOS_ThemeManager_V7.zip" \
    "*ThemeManager*.apk" \
    "MIUIThemeManager" \
    "MIUIThemeManagerT" \
    "MIUIThemeManagerGlobal" \
    "MIUIThemeManagerPad" \
    "ThemeManager"
