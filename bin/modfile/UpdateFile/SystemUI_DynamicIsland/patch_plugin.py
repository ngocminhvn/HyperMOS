#!/usr/bin/env python3
import os
import sys
import re

def replace_method_body(content, method_name, return_val_smali):
    pattern = rf"(\.method\s+[^\n]*\b{method_name}\([^\)]*\)Z\n)([\s\S]*?)(\.end method)"
    match = re.search(pattern, content)
    if not match:
        return content, False
    new_body = f"    .locals 1\n\n    {return_val_smali}\n"
    new_content = content[:match.start(2)] + new_body + content[match.start(3):]
    return new_content, True

def replace_sget_boolean(content, field_regex, bool_value=True):
    val_str = "0x1" if bool_value else "0x0"
    pattern = rf"sget-boolean(?:\S*)\s+([vp]\d+),\s+{field_regex}"
    def replacer(m):
        reg = m.group(1)
        return f"const/4 {reg}, {val_str}"
    return re.subn(pattern, replacer, content)

def patch_notification_settings_manager(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # repM 'canCustomFocus' 1
    content, changed = replace_method_body(content, "canCustomFocus", "const/4 v0, 0x1\n\n    return v0")
    if changed:
        print(f"[DynamicIsland Plugin] Patched canCustomFocus() in {file_path}")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

def patch_focus_notification_controller(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # ftrue FocusNotificationController.smali Lmiui/systemui/notification/NotificationUtil;->IS_INTERNATIONAL_BUILD:Z
    content, count = replace_sget_boolean(content, r"Lmiui/systemui/notification/NotificationUtil;->IS_INTERNATIONAL_BUILD:Z", True)
    if count > 0:
        print(f"[DynamicIsland Plugin] Forced NotificationUtil->IS_INTERNATIONAL_BUILD ({count} occurrences) in {file_path}")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)

def main():
    if len(sys.argv) < 2:
        print("Usage: patch_plugin.py <unpacked_dir>")
        sys.exit(1)

    unpacked_dir = sys.argv[1]
    for root, _, files in os.walk(unpacked_dir):
        for file in files:
            if file == "NotificationSettingsManager.smali":
                patch_notification_settings_manager(os.path.join(root, file))
            elif file == "FocusNotificationController.smali":
                patch_focus_notification_controller(os.path.join(root, file))

if __name__ == "__main__":
    main()
