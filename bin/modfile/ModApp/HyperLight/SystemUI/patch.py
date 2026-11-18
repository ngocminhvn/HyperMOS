#!/usr/bin/env python3
"""HyperLight SystemUI Patches for HyperMOS.

Applies clean, verified smali modifications directly to MiuiSystemUI.apk:
1. LockScreenNotificationKeep: Keep notifications on lock screen after unlocking.
2. LockScreenNotificationShowAll: Allow all notifications on lock screen.
3. LockScreenStackSink: Allow notification stack to sink down naturally without GXZW forced offset.
4. NotificationGroupDisable: Disable notification grouping so each notification displays independently without hiding.
5. NotificationGroupStack: Raise visible child limit in NotificationChildrenContainer when collapsed.
6. LockScreenDepthAvoid: Bypass lock screen depth avoid constraints in SystemUI (keep wallpaper depth with notifications).
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


EXPANDED_NOTIF_CLASS = "Lcom/android/systemui/statusbar/notification/ExpandedNotification;"
FILTER_CONTROLLER_CLASS = "Lcom/android/systemui/statusbar/notification/policy/NotificationFilterController;"

# Patch 1: mHasShownAfterUnlock reading in NotificationFilterController
HAS_SHOWN_RE = re.compile(
    r"(?m)^([ \t]*)iget-boolean\s+(\w+),\s*(\w+),\s*"
    + re.escape(EXPANDED_NOTIF_CLASS)
    + r"->mHasShownAfterUnlock:Z"
)

# Patch 2: canShowOnKeyguard() in ExpandedNotification
CAN_SHOW_KEYGUARD_RE = re.compile(
    r"(?ms)^\.method[^\n]*\bcanShowOnKeyguard\(\)Z.*?^\.end method[ \t]*$"
)

# Patch 3: GXZW_SENSOR check in KeyguardPanelViewController lambda
GXZW_CHECK_RE = re.compile(
    r"(?m)^([ \t]*)sget-boolean\s+(\w+),\s*Lcom/miui/utils/configs/MiuiConfigs;->GXZW_SENSOR:Z\s*\n\s*if-eqz\s+\2,\s*(:cond_\w+)"
)


def find_file(root: Path, filename: str, descriptor: str) -> Path | None:
    matches = []
    for path in root.rglob(filename):
        try:
            head = path.read_text(encoding="utf-8")[:1000]
            if descriptor in head:
                matches.append(path)
        except OSError:
            continue
    if len(matches) == 1:
        return matches[0]
    return None


def patch_filter_controller(file_path: Path) -> bool:
    """1. Keep notifications on lock screen after unlocking."""
    content = file_path.read_text(encoding="utf-8")
    if not HAS_SHOWN_RE.search(content):
        return False
    patched = HAS_SHOWN_RE.sub(r"\1const/4 \2, 0x0", content)
    file_path.write_text(patched, encoding="utf-8")
    return True


def patch_expanded_notification(file_path: Path) -> bool:
    """2. Show all notifications on lock screen."""
    content = file_path.read_text(encoding="utf-8")
    if not CAN_SHOW_KEYGUARD_RE.search(content):
        return False
    replacement = (
        ".method public final canShowOnKeyguard()Z\n"
        "    .registers 2\n\n"
        "    const/4 v0, 0x1\n\n"
        "    return v0\n"
        ".end method"
    )
    patched = CAN_SHOW_KEYGUARD_RE.sub(replacement, content, count=1)
    file_path.write_text(patched, encoding="utf-8")
    return True


def patch_stack_sink(unpacked: Path) -> bool:
    """3. Allow notification stack to sink down without GXZW forced offset."""
    patched_any = False
    for path in unpacked.rglob("*.smali"):
        if "KeyguardPanelViewController" not in path.name:
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "GXZW_SENSOR" not in content:
            continue
        if GXZW_CHECK_RE.search(content):
            patched = GXZW_CHECK_RE.sub(
                r"\1sget-boolean \2, Lcom/miui/utils/configs/MiuiConfigs;->GXZW_SENSOR:Z\n\1goto \3",
                content,
            )
            path.write_text(patched, encoding="utf-8")
            patched_any = True
    return patched_any


def patch_notification_ungroup(file_path: Path) -> bool:
    """4. NotificationGroupDisable: Disable notification grouping without hiding any notifications."""
    content = file_path.read_text(encoding="utf-8")
    modified = False

    is_group_method = (
        ".method public isGroup()Z\n"
        "    .registers 2\n\n"
        "    const/4 v0, 0x0\n\n"
        "    return v0\n"
        ".end method"
    )
    get_group_key_method = (
        ".method public getGroupKey()Ljava/lang/String;\n"
        "    .registers 2\n\n"
        "    invoke-virtual {p0}, Landroid/service/notification/StatusBarNotification;->getKey()Ljava/lang/String;\n\n"
        "    move-result-object v0\n\n"
        "    return-object v0\n"
        ".end method"
    )

    p_is_group = re.compile(r"(?ms)^\.method[^\n]*\bisGroup\(\)Z.*?^\.end method[ \t]*$")
    if p_is_group.search(content):
        content = p_is_group.sub(is_group_method, content, count=1)
        modified = True
    else:
        content += "\n\n" + is_group_method
        modified = True

    p_group_key = re.compile(r"(?ms)^\.method[^\n]*\bgetGroupKey\(\)Ljava/lang/String;.*?^\.end method[ \t]*$")
    if p_group_key.search(content):
        content = p_group_key.sub(get_group_key_method, content, count=1)
        modified = True
    else:
        content += "\n\n" + get_group_key_method
        modified = True

    if modified:
        file_path.write_text(content, encoding="utf-8")
    return modified


def patch_group_stack(unpacked: Path) -> bool:
    """6. NotificationGroupStack: Raise visible child limit in NotificationChildrenContainer when collapsed."""
    patched_any = False
    for path in unpacked.rglob("NotificationChildrenContainer.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_collapsed = re.compile(
            r"(?ms)(^\.method private getNumberOfChildrenWhenCollapsed\(\)I.*?)(const/4 p0, 0x3\s*\n\s*return p0\s*\n\.end method)"
        )
        if p_collapsed.search(content):
            content = p_collapsed.sub(r"\1const/16 p0, 0x8\n\n    return p0\n.end method", content, count=1)
            path.write_text(content, encoding="utf-8")
            patched_any = True
    return patched_any


def patch_depth_avoid_systemui(unpacked: Path) -> bool:
    """6. LockScreenDepthAvoid: Bypass depth avoiding in KeyguardDepthInteractor / KeyguardPanel."""
    patched_any = False
    for path in unpacked.rglob("*.smali"):
        if "Keyguard" not in path.name:
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "updateAvoidStatus(" not in content:
            continue
        p_avoid = re.compile(
            r"(?ms)(^\.method\s+[^\n]*\bupdateAvoidStatus\((Z?)\)V\n)"
            r"(?:\s*\.(?:locals|registers)[^\n]*\n)?"
            r".*?"
            r"(^\.end method)",
            re.MULTILINE,
        )
        def _repl(match: re.Match[str]) -> str:
            regs = 2 if match.group(2) else 1
            return f"{match.group(1)}    .registers {regs}\n\n    return-void\n{match.group(3)}"
        new_content, count = p_avoid.subn(_repl, content)
        if count > 0:
            path.write_text(new_content, encoding="utf-8")
            patched_any = True
    return patched_any


def main() -> int:
    cli = argparse.ArgumentParser(description="Patch MiuiSystemUI with HyperLight mods")
    cli.add_argument("--unpacked", type=Path, required=True, help="Path to unpacked SystemUI APK directory")
    args = cli.parse_args()

    smali_dir = args.unpacked / "smali"
    if not smali_dir.exists():
        print("[HyperLight/SystemUI] Error: smali directory not found", file=sys.stderr)
        return 1

    # 1. LockScreenNotificationKeep
    filter_ctrl = find_file(smali_dir, "NotificationFilterController.smali", FILTER_CONTROLLER_CLASS)
    if filter_ctrl and patch_filter_controller(filter_ctrl):
        print("[HyperLight/SystemUI] [1/6] Patched LockScreenNotificationKeep (keep notifications after unlock).")
    else:
        print("[HyperLight/SystemUI] Notice: NotificationFilterController bypass skipped or not applicable.")

    # 2. LockScreenNotificationShowAll
    expanded_notif = find_file(smali_dir, "ExpandedNotification.smali", EXPANDED_NOTIF_CLASS)
    if expanded_notif and patch_expanded_notification(expanded_notif):
        print("[HyperLight/SystemUI] [2/6] Patched LockScreenNotificationShowAll (canShowOnKeyguard -> true).")
    else:
        print("[HyperLight/SystemUI] Error: ExpandedNotification.smali could not be patched", file=sys.stderr)
        return 1

    # 3. LockScreenStackSink (Must be kept as requested)
    if patch_stack_sink(smali_dir):
        print("[HyperLight/SystemUI] [3/6] Patched LockScreenStackSink (GXZW_SENSOR constraint bypassed).")
    else:
        print("[HyperLight/SystemUI] Notice: GXZW_SENSOR stack sink constraint not applicable on this build.")

    # 4. NotificationGroupDisable (Thả từng thông báo riêng lẻ, không ẩn)
    if expanded_notif and patch_notification_ungroup(expanded_notif):
        print("[HyperLight/SystemUI] [4/6] Patched NotificationGroupDisable (standalone unhidden notifications).")
    else:
        print("[HyperLight/SystemUI] Notice: ExpandedNotification ungroup could not be applied.")

    # 5. NotificationGroupStack
    if patch_group_stack(smali_dir):
        print("[HyperLight/SystemUI] [5/6] Patched NotificationGroupStack (collapsed child limit -> 8).")

    # 6. LockScreenDepthAvoid (SystemUI)
    if patch_depth_avoid_systemui(smali_dir):
        print("[HyperLight/SystemUI] [6/6] Patched LockScreenDepthAvoid in SystemUI.")

    print("[HyperLight/SystemUI] SystemUI modification complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
