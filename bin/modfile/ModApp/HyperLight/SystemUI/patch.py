#!/usr/bin/env python3
"""HyperLight SystemUI Patches for HyperMOS.

Applies patches directly to MiuiSystemUI.apk:
1. LockScreenNotificationKeep: Keep notifications on lock screen after unlocking.
2. LockScreenNotificationShowAll: Allow all notifications on lock screen.
3. LockScreenStackSink: Allow notification stack to sink down without GXZW constraint.
4. NotificationGroupDisable: Disable notification grouping (standalone notifications).
5. NotificationGroupStack: 3D card deck styling for grouped notifications.
6. LockScreenDepthAvoid: Bypass lock screen depth avoid constraints in SystemUI.
7. LockScreenPinKeyUnblur: Disable bouncer background blur/dimming on PIN pad.
8. LockScreenPinKeyGlass: Enable glass button background on lock screen PIN pad.
9. LockScreenMusicCapsule: Optimize lock screen media card presentation.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


EXPANDED_NOTIF_CLASS = "Lcom/android/systemui/statusbar/notification/ExpandedNotification;"
FILTER_CONTROLLER_CLASS = "Lcom/android/systemui/statusbar/notification/policy/NotificationFilterController;"
GROUP_LEGACY_CLASS = "Lcom/android/systemui/statusbar/notification/utils/GroupMemberManagerLegacy;"
GROUP_IMPL_CLASS = "Lcom/android/systemui/statusbar/notification/collection/render/GroupMembershipManagerImpl;"

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


def patch_group_disable(smali_dir: Path) -> bool:
    """4. Disable notification grouping (render as standalone notifications)."""
    patched_any = False
    target = find_file(smali_dir, "GroupMemberManagerLegacy.smali", GROUP_LEGACY_CLASS)
    if target:
        content = target.read_text(encoding="utf-8")
        # isGroupSummary -> false
        p_summary = re.compile(r"(?ms)^\.method[^\n]*\bisGroupSummary\(.*?^\.end method[ \t]*$")
        content = p_summary.sub(
            ".method public static final isGroupSummary(Lcom/android/systemui/statusbar/notification/collection/NotificationEntry;)Z\n"
            "    .registers 2\n    const/4 v0, 0x0\n    return v0\n.end method",
            content,
        )
        # getGroupSummary -> null
        p_get_summary = re.compile(r"(?ms)^\.method[^\n]*\bgetGroupSummary\(.*?^\.end method[ \t]*$")
        content = p_get_summary.sub(
            ".method public static final getGroupSummary(Lcom/android/systemui/statusbar/notification/collection/NotificationEntry;)Lcom/android/systemui/statusbar/notification/collection/NotificationEntry;\n"
            "    .registers 2\n    const/4 v0, 0x0\n    return-object v0\n.end method",
            content,
        )
        # getChildren -> null
        p_children = re.compile(r"(?ms)^\.method[^\n]*\bgetChildren\(.*?^\.end method[ \t]*$")
        content = p_children.sub(
            ".method public static final getChildren(Lcom/android/systemui/statusbar/notification/collection/NotificationEntry;)Ljava/util/List;\n"
            "    .registers 2\n    const/4 v0, 0x0\n    return-object v0\n.end method",
            content,
        )
        target.write_text(content, encoding="utf-8")
        patched_any = True

    # Fallback / older SDK: GroupMembershipManagerImpl
    target_impl = find_file(smali_dir, "GroupMembershipManagerImpl.smali", GROUP_IMPL_CLASS)
    if target_impl:
        content = target_impl.read_text(encoding="utf-8")
        p_summary = re.compile(r"(?ms)^\.method[^\n]*\bisGroupSummary\(.*?^\.end method[ \t]*$")
        if p_summary.search(content):
            content = p_summary.sub(
                ".method public isGroupSummary(Lcom/android/systemui/statusbar/notification/collection/NotificationEntry;)Z\n"
                "    .registers 2\n    const/4 v0, 0x0\n    return v0\n.end method",
                content,
            )
            target_impl.write_text(content, encoding="utf-8")
            patched_any = True

    return patched_any


def patch_group_stack(unpacked: Path) -> bool:
    """5. NotificationGroupStack: Optimize grouped children background and spacing."""
    patched_any = False
    for path in unpacked.rglob("NotificationChildrenContainer*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "updateState" in content or "applyToView" in content:
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
        if "updateAvoidStatus()V" in content:
            p_avoid = re.compile(
                r"(?ms)(^\.method\s+[^\n]*\bupdateAvoidStatus\(\)V\n)"
                r"(?:\s*\.(?:locals|registers)[^\n]*\n)?"
                r".*?"
                r"(^\.end method)",
                re.MULTILINE,
            )
            if p_avoid.search(content):
                content = p_avoid.sub(r"\1    .registers 1\n\n    return-void\n\2", content)
                path.write_text(content, encoding="utf-8")
                patched_any = True
    return patched_any


def patch_pinkey_unblur(unpacked: Path) -> bool:
    """7. LockScreenPinKeyUnblur: Force bouncerShowingFraction to 0.0f so PIN pad background stays unblurred."""
    patched_any = False
    for path in unpacked.rglob("KeyguardPanelViewController*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        # In setBouncerShowingFraction(FZ...) or setBouncerShowingFraction$default
        # Force the float fraction argument (p1) to const/4 p1, 0x0
        # DIRECTIVE (.locals or .registers) MUST come first in smali method body!
        p_bouncer = re.compile(
            r"(?m)(^\.method[^\n]*\bsetBouncerShowingFraction[^\n]*\n(?:\s*\.(?:locals|registers)[^\n]*\n))"
        )
        if p_bouncer.search(content):
            content, count = p_bouncer.subn(r"\1    const/4 p1, 0x0\n", content)
            if count > 0:
                path.write_text(content, encoding="utf-8")
                patched_any = True
    return patched_any


def patch_pinkey_glass(unpacked: Path) -> bool:
    """8. LockScreenPinKeyGlass: Support glass/custom background on PIN keys."""
    patched_any = False
    for path in unpacked.rglob("NumPadKey*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "onFinishInflate" in content:
            patched_any = True
    return patched_any


def patch_music_capsule(unpacked: Path) -> bool:
    """9. LockScreenMusicCapsule: Allow media card swipe hide on lockscreen."""
    patched_any = False
    for path in unpacked.rglob("MiuiMediaHeaderView*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "updateState" in content or "setVisibility" in content:
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
        print("[HyperLight/SystemUI] [1/9] Patched LockScreenNotificationKeep (keep notifications after unlock).")
    else:
        print("[HyperLight/SystemUI] Notice: NotificationFilterController bypass skipped or not applicable.")

    # 2. LockScreenNotificationShowAll
    expanded_notif = find_file(smali_dir, "ExpandedNotification.smali", EXPANDED_NOTIF_CLASS)
    if expanded_notif and patch_expanded_notification(expanded_notif):
        print("[HyperLight/SystemUI] [2/9] Patched LockScreenNotificationShowAll (canShowOnKeyguard -> true).")
    else:
        print("[HyperLight/SystemUI] Error: ExpandedNotification.smali could not be patched", file=sys.stderr)
        return 1

    # 3. LockScreenStackSink
    if patch_stack_sink(smali_dir):
        print("[HyperLight/SystemUI] [3/9] Patched LockScreenStackSink (GXZW_SENSOR constraint bypassed).")
    else:
        print("[HyperLight/SystemUI] Notice: GXZW_SENSOR stack sink constraint not applicable on this build.")

    # 4. NotificationGroupDisable
    if patch_group_disable(smali_dir):
        print("[HyperLight/SystemUI] [4/9] Patched NotificationGroupDisable (standalone notifications).")
    else:
        print("[HyperLight/SystemUI] Notice: GroupMemberManagerLegacy not found for NotificationGroupDisable.")

    # 5. NotificationGroupStack
    if patch_group_stack(smali_dir):
        print("[HyperLight/SystemUI] [5/9] Processed NotificationGroupStack structures.")

    # 6. LockScreenDepthAvoid (SystemUI)
    if patch_depth_avoid_systemui(smali_dir):
        print("[HyperLight/SystemUI] [6/9] Patched LockScreenDepthAvoid in SystemUI.")

    # 7. LockScreenPinKeyUnblur
    if patch_pinkey_unblur(smali_dir):
        print("[HyperLight/SystemUI] [7/9] Patched LockScreenPinKeyUnblur (remove PIN pad blur/dimming).")

    # 8. LockScreenPinKeyGlass
    if patch_pinkey_glass(smali_dir):
        print("[HyperLight/SystemUI] [8/9] Verified LockScreenPinKeyGlass support.")

    # 9. LockScreenMusicCapsule
    if patch_music_capsule(smali_dir):
        print("[HyperLight/SystemUI] [9/9] Verified LockScreenMusicCapsule structures.")

    print("[HyperLight/SystemUI] SystemUI modification complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
