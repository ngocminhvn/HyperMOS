#!/usr/bin/env bash
# ==============================================================================
# SystemUI_HideMobileTypeOnWifi: Ẩn biểu tượng loại mạng 4G/5G/LTE trên thanh
# trạng thái khi kết nối Wi-Fi hoặc khi tắt mạng di động theo cơ chế của VSTeam.
#
# Áp dụng cho HyperOS (Android 14, 15, 16, 17+ / OS1, OS2, OS3, OS4):
# 1. Ép cờ IS_INTERNATIONAL_BUILD trong MiuiOperatorCustomizedPolicy.smali
# 2. Vô hiệu hóa config "config_status_bar_show_mobile_type_when_wifi_on"
# 3. Patch tất cả MiuiCellularIconVM smali có chứa "combine" và "IS_INTERNATIONAL_BUILD"
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
module_dir="$work_dir/bin/modfile/UpdateFile/SystemUI_HideMobileTypeOnWifi"

target_systemui="$(find "$MAIN_FOLDER" -type f -name "MiuiSystemUI.apk" 2>/dev/null | head -n 1 || true)"
if [[ -z "$target_systemui" || ! -f "$target_systemui" ]]; then
    mods "SystemUI_HideMobileTypeOnWifi: MiuiSystemUI.apk not found; skipping"
    exit 0
fi

mods "SystemUI_HideMobileTypeOnWifi: Decoding MiuiSystemUI.apk..."
tmp_dir="$(mktemp -d)"

if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$target_systemui" -o "$tmp_dir/systemui_out" >/dev/null 2>&1; then
    rm -rf "$tmp_dir"
    error "SystemUI_HideMobileTypeOnWifi: Decode MiuiSystemUI failed"
    exit 1
fi

mods "SystemUI_HideMobileTypeOnWifi: Patching hide mobile type on Wi-Fi..."
python3 "$module_dir/patch.py" "$tmp_dir/systemui_out"

mods "SystemUI_HideMobileTypeOnWifi: Rebuilding MiuiSystemUI.apk..."
if ! $APKEDITOR b -f -i "$tmp_dir/systemui_out" -o "$tmp_dir/MiuiSystemUI.apk" >/dev/null 2>&1; then
    rm -rf "$tmp_dir"
    error "SystemUI_HideMobileTypeOnWifi: Rebuild MiuiSystemUI failed"
    exit 1
fi

if [[ -s "$tmp_dir/MiuiSystemUI.apk" ]]; then
    target_dir="$(dirname "$target_systemui")"
    rm -rf "$target_dir/oat"
    install -m 0644 "$tmp_dir/MiuiSystemUI.apk" "$target_systemui"
    mods "SystemUI_HideMobileTypeOnWifi: MiuiSystemUI patched successfully"
else
    rm -rf "$tmp_dir"
    error "SystemUI_HideMobileTypeOnWifi: Output MiuiSystemUI.apk missing or empty"
    exit 1
fi

rm -rf "$tmp_dir"
mods "SystemUI_HideMobileTypeOnWifi: Done"
