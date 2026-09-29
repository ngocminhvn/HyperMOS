#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

modscenter_apply_module \
    "HyperOS App Vault V4.5" \
    "https://github.com/Mods-Center/HyperOS-App-Vault/releases/download/V4.5/HyperOS_AppVaultV4.5%40kashis_cringey_stuffs.zip" \
    "fee4f5398472b1febe1d10a12695a2ce7b7d7e3b1f4102be11117dd3150c97ab" \
    "HyperOS_AppVault_V4.5.zip" \
    "*PersonalAssistant*.apk" \
    "MIUIGlobalMinusScreenWidget" \
    "MIUIGlobalMinusScreen" \
    "MIUIPersonalAssistantT" \
    "MIUIPersonalAssistant" \
    "PersonalAssistant" \
    "MIUIPersonalAssistantPhoneMIUI15" \
    "MIUIPersonalAssistantPhoneOS2NoBeta" \
    "MIUIPersonalAssistantPhoneOS2" \
    "MIUIPersonalAssistantPhoneOS3" \
    "MIUIPersonalAssistantPhoneOS3NoBeta" \
    "MIUIPersonalAssistantOS3" \
    "MIUIPersonalAssistantPadOS3"
