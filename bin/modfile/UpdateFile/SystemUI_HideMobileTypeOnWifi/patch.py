#!/usr/bin/env python3
import os
import sys
import re

def replace_sget_boolean(content, field_regex, bool_value=True):
    val_str = "0x1" if bool_value else "0x0"
    pattern = rf"sget-boolean(?:\S*)\s+([vp]\d+),\s+{field_regex}"
    def replacer(m):
        reg = m.group(1)
        return f"const/4 {reg}, {val_str}"
    return re.subn(pattern, replacer, content)

def patch_operator_policy(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    content, count = replace_sget_boolean(content, r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z", True)
    if count > 0:
        print(f"[HideMobileType] Forced IS_INTERNATIONAL_BUILD ({count} occurrences) in {file_path}")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

def patch_cellular_icon_vm(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # Theo VSTeam: kiểm tra file có cả 'combine' và 'IS_INTERNATIONAL_BUILD'
    if "combine" in content and "IS_INTERNATIONAL_BUILD" in content:
        content, count = replace_sget_boolean(content, r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z", True)
        if count > 0:
            print(f"[HideMobileType] Patched CellularIconVM IS_INTERNATIONAL_BUILD ({count} occurrences) in {file_path}")
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)

def disable_wifi_mobile_type_config_string(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    target_str = '"config_status_bar_show_mobile_type_when_wifi_on"'
    if target_str in content:
        # VSTeam thay chuỗi này thành "vsteam" để làm mất hiệu lực cấu hình ép hiển thị.
        # Dùng const-string/jumbo để tránh lỗi Dalvik 16-bit string index overflow (Short value out of range 0x131aa > 0xffff).
        pattern = r'const-string(?:\/jumbo)?\s+([vp]\d+),\s+"config_status_bar_show_mobile_type_when_wifi_on"'
        if re.search(pattern, content):
            content = re.sub(pattern, r'const-string/jumbo \1, "vsteam"', content)
        else:
            content = content.replace(target_str, '"vsteam"')
        print(f"[HideMobileType] Disabled config_status_bar_show_mobile_type_when_wifi_on in {file_path}")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

def main():
    if len(sys.argv) < 2:
        print("Usage: patch.py <unpacked_dir>")
        sys.exit(1)

    unpacked_dir = sys.argv[1]
    for root, _, files in os.walk(unpacked_dir):
        for file in files:
            if not file.endswith(".smali"):
                continue

            full_path = os.path.join(root, file)

            # 1. Patch MiuiOperatorCustomizedPolicy.smali
            if file == "MiuiOperatorCustomizedPolicy.smali":
                patch_operator_policy(full_path)

            # 2. Patch MiuiCellularIconVM*.smali
            if "MiuiCellularIconVM" in file:
                patch_cellular_icon_vm(full_path)

            # 3. Disable config_status_bar_show_mobile_type_when_wifi_on string
            disable_wifi_mobile_type_config_string(full_path)

if __name__ == "__main__":
    main()
