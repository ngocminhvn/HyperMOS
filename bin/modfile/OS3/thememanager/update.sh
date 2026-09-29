#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_native_module \
    "HyperOS Theme Manager" \
    "Mods-Center/HyperOS-Theme-Manager" \
    "com.android.thememanager" \
    "*ThemeManager*.apk" \
    "product/priv-app/MIUIThemeManager" \
    "MIUIThemeManager" \
    "MIUIThemeManagerT" \
    "MIUIThemeManagerGlobal" \
    "MIUIThemeManagerPad" \
    "ThemeManager"
