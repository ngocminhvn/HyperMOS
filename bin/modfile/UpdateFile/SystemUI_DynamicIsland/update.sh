#!/usr/bin/env bash
# ==============================================================================
# SystemUI_DynamicIsland: Loại bỏ giới hạn Dynamic Island (Focus Notification)
# trên nền ROM China theo cơ chế của VSTeam.
#
# Hoạt động trên HyperOS (Android 14, 15, 16, 17+ / OS1, OS2, OS3, OS4):
# 1. MiuiSystemUI.apk:
#    - Bỏ whitelist ứng dụng (USE_WHITE_LISTS -> false)
#    - Mở quyền hiển thị Focus Notification (canShowFocus -> true)
#    - Mở cờ IS_INTERNATIONAL trong NotificationSettingsManager
# 2. MIUISystemUIPlugin.apk (nếu có, HyperOS pre-OS4):
#    - Mở quyền tùy chỉnh Focus Notification (canCustomFocus -> true)
#    - Mở cờ IS_INTERNATIONAL_BUILD trong FocusNotificationController
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

# Bỏ qua nếu là ROM xiaomi.eu (đã có tính năng này mặc định)
if [[ -f "$work_dir/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    exit 0
fi

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
module_dir="$work_dir/bin/modfile/UpdateFile/SystemUI_DynamicIsland"

# 1. Patch MiuiSystemUI.apk
target_systemui="$(find "$MAIN_FOLDER" -type f -name "MiuiSystemUI.apk" 2>/dev/null | head -n 1 || true)"
if [[ -n "$target_systemui" && -f "$target_systemui" ]]; then
    mods "SystemUI_DynamicIsland: Decoding MiuiSystemUI.apk..."
    tmp_dir="$(mktemp -d)"

    if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$target_systemui" -o "$tmp_dir/systemui_out" >/dev/null 2>&1; then
        rm -rf "$tmp_dir"
        error "SystemUI_DynamicIsland: Decode MiuiSystemUI failed"
        exit 1
    fi

    mods "SystemUI_DynamicIsland: Removing Focus Notification restrictions in MiuiSystemUI..."
    python3 "$module_dir/patch_systemui.py" "$tmp_dir/systemui_out"

    mods "SystemUI_DynamicIsland: Rebuilding MiuiSystemUI.apk..."
    if ! $APKEDITOR b -f -i "$tmp_dir/systemui_out" -o "$tmp_dir/MiuiSystemUI.apk" >/dev/null 2>&1; then
        rm -rf "$tmp_dir"
        error "SystemUI_DynamicIsland: Rebuild MiuiSystemUI failed"
        exit 1
    fi

    if [[ -s "$tmp_dir/MiuiSystemUI.apk" ]]; then
        target_dir="$(dirname "$target_systemui")"
        rm -rf "$target_dir/oat"
        install -m 0644 "$tmp_dir/MiuiSystemUI.apk" "$target_systemui"
        mods "SystemUI_DynamicIsland: MiuiSystemUI patched successfully"
    else
        rm -rf "$tmp_dir"
        error "SystemUI_DynamicIsland: Output MiuiSystemUI.apk missing or empty"
        exit 1
    fi
    rm -rf "$tmp_dir"
fi

# 2. Patch MIUISystemUIPlugin.apk (nếu có trong ROM)
target_plugin="$(find "$MAIN_FOLDER" -type f -name "MIUISystemUIPlugin.apk" 2>/dev/null | head -n 1 || true)"
if [[ -n "$target_plugin" && -f "$target_plugin" ]]; then
    mods "SystemUI_DynamicIsland: Decoding MIUISystemUIPlugin.apk..."
    tmp_dir="$(mktemp -d)"

    if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$target_plugin" -o "$tmp_dir/plugin_out" >/dev/null 2>&1; then
        mods "SystemUI_DynamicIsland: Decode MIUISystemUIPlugin failed; skipping"
    else
        mods "SystemUI_DynamicIsland: Removing Focus Notification restrictions in MIUISystemUIPlugin..."
        python3 "$module_dir/patch_plugin.py" "$tmp_dir/plugin_out"

        mods "SystemUI_DynamicIsland: Rebuilding MIUISystemUIPlugin.apk..."
        if $APKEDITOR b -f -i "$tmp_dir/plugin_out" -o "$tmp_dir/MIUISystemUIPlugin.apk" >/dev/null 2>&1 &&
           [[ -s "$tmp_dir/MIUISystemUIPlugin.apk" ]]; then
            target_dir="$(dirname "$target_plugin")"
            rm -rf "$target_dir/oat"
            install -m 0644 "$tmp_dir/MIUISystemUIPlugin.apk" "$target_plugin"
            mods "SystemUI_DynamicIsland: MIUISystemUIPlugin patched successfully"
        else
            mods "SystemUI_DynamicIsland: Rebuild MIUISystemUIPlugin failed; keeping original"
        fi
    fi
    rm -rf "$tmp_dir"
fi

mods "SystemUI_DynamicIsland: Done"
