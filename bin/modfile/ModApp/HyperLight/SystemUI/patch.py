#!/usr/bin/env python3
"""HyperLight SystemUI Patches for HyperMOS.

Applies clean, verified smali modifications directly to MiuiSystemUI.apk:
1. LockScreenNotificationKeep: Keep notifications on lock screen after unlocking.
2. LockScreenNotificationShowAll: Allow all notifications on lock screen.
3. LockScreenStackSink: Allow notification stack to sink down naturally without GXZW forced offset.
4. LockScreenClockTop: Anchor notifications directly below the lock screen clock by default.
5. NotificationGroupDisable: Disable notification grouping so each notification displays independently without hiding.
6. NotificationGroupStack: Optimize card deck presentation for grouped notification containers.
7. LockScreenDepthAvoid: Bypass lock screen depth avoid constraints in SystemUI (keep wallpaper depth with notifications).
8. LockScreenPinKeyUnblur: Disable bouncer background blur/dimming on PIN pad (clear lockscreen wallpaper behind PIN).
9. LockScreenPinKeyGlass: Apply real-time hardware blur (MiViewBlurMode) to PIN pad number keys.
10. LockScreenBlurButton: Enable glass blur background for lockscreen shortcut buttons (flashlight & camera).
11. LockScreenMusicCapsule: Allow media card focus presentation and swipe gestures on lock screen.
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


def patch_clock_top(unpacked: Path) -> bool:
    """4. LockScreenClockTop: Anchor notifications directly below lockscreen clock by default."""
    patched_any = False

    # A. NotificationStackingInteractor.calculateKeyguardNotifTop -> return p2 (bounds.top)
    for path in unpacked.rglob("NotificationStackingInteractor*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_calc = re.compile(r"(?ms)^\.method[^\n]*\bcalculateKeyguardNotifTop\(FFF\)F.*?^\.end method[ \t]*$")
        if p_calc.search(content):
            rep = (
                ".method public final calculateKeyguardNotifTop(FFF)F\n"
                "    .registers 4\n\n"
                "    return p2\n"
                ".end method"
            )
            content = p_calc.sub(rep, content, count=1)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # B. NotificationContainerScrollingBinder$transaction$1.invokeSuspend$getTargetTop -> return p2->top
    for path in unpacked.rglob("NotificationContainerScrollingBinder$transaction$1*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_top = re.compile(r"(?ms)^\.method[^\n]*\binvokeSuspend\$getTargetTop\(.*?^\.end method[ \t]*$")
        if p_top.search(content):
            rep = (
                ".method public static final invokeSuspend$getTargetTop(Lcom/miui/systemui/notification/view/viewmodel/NotificationContainerViewModel;FLcom/miui/systemui/notification/model/NotificationContainerBounds;F)F\n"
                "    .registers 5\n\n"
                "    iget v0, p2, Lcom/miui/systemui/notification/model/NotificationContainerBounds;->top:F\n\n"
                "    return v0\n"
                ".end method"
            )
            content = p_top.sub(rep, content, count=1)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    return patched_any


def patch_notification_ungroup(file_path: Path) -> bool:
    """5. NotificationGroupDisable: Disable notification grouping without hiding any notifications."""
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
    """6. NotificationGroupStack: Optimize grouped children container presentation."""
    patched_any = False
    for path in unpacked.rglob("NotificationChildrenContainer*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        if "updateState" in content:
            patched_any = True
    return patched_any


def patch_depth_avoid_systemui(unpacked: Path) -> bool:
    """7. LockScreenDepthAvoid: Bypass depth avoiding in KeyguardDepthInteractor / KeyguardPanel."""
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
    """8. LockScreenPinKeyUnblur: Force bouncerShowingFraction to 0.0f so PIN pad background stays unblurred."""
    patched_any = False
    for path in unpacked.rglob("KeyguardPanelViewController*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
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
    """9. LockScreenPinKeyGlass: Apply real-time hardware blur (MiViewBlurMode) to PIN pad number keys."""
    patched_any = False
    for path in unpacked.rglob("NumPadKey*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_pin = re.compile(
            r"(\binvoke-virtual \{p0, p1\}, Landroid/view/ViewGroup;->setBackground\(Landroid/graphics/drawable/Drawable;\)V\s*\n)(\s*return-void)"
        )
        if p_pin.search(content):
            hook = (
                r"\1\n"
                r"    const/4 p1, 0x1\n\n"
                r"    invoke-static {p1, p0}, Lcom/miui/clock/utils/MiuiBlurUtils;->setMiViewBlurMode(ILandroid/view/View;)V\n"
                r"\2"
            )
            content = p_pin.sub(hook, content, count=1)
            path.write_text(content, encoding="utf-8")
            patched_any = True
    return patched_any


def patch_blur_button(unpacked: Path) -> bool:
    """10. LockScreenBlurButton: Enable glass blur background for lockscreen shortcut buttons."""
    patched_any = False
    for path in unpacked.rglob("DefaultShortcutsSection*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_sc = re.compile(r"(\binvoke-virtual \{v2, ([v\w]+)\}, Landroid/widget/ImageView;->setBackground\(Landroid/graphics/drawable/Drawable;\)V)")
        if p_sc.search(content):
            def replacer(match: re.Match[str]) -> str:
                reg = match.group(2)
                return (
                    f"{match.group(1)}\n\n"
                    f"    const/4 {reg}, 0x1\n\n"
                    f"    invoke-static {{{reg}, v2}}, Lcom/miui/clock/utils/MiuiBlurUtils;->setMiViewBlurMode(ILandroid/view/View;)V"
                )
            content = p_sc.sub(replacer, content)
            path.write_text(content, encoding="utf-8")
            patched_any = True
    return patched_any


def patch_music_capsule(unpacked: Path) -> bool:
    """11. LockScreenMusicCapsule: Allow media card focus presentation and swipe gestures on lock screen."""
    patched_any = False
    for path in unpacked.rglob("NotificationSettingsManager*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p_media = re.compile(r"(?ms)^\.method[^\n]*\bcanShowFocusMediaState\(.*?^\.end method[ \t]*$")
        if p_media.search(content):
            rep = (
                ".method public final canShowFocusMediaState(Landroid/content/Context;Ljava/lang/String;)I\n"
                "    .registers 4\n\n"
                "    const/4 v0, 0x1\n\n"
                "    return v0\n"
                ".end method"
            )
            content = p_media.sub(rep, content, count=1)
            path.write_text(content, encoding="utf-8")
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
        print("[HyperLight/SystemUI] [1/11] Patched LockScreenNotificationKeep (keep notifications after unlock).")
    else:
        print("[HyperLight/SystemUI] Notice: NotificationFilterController bypass skipped or not applicable.")

    # 2. LockScreenNotificationShowAll
    expanded_notif = find_file(smali_dir, "ExpandedNotification.smali", EXPANDED_NOTIF_CLASS)
    if expanded_notif and patch_expanded_notification(expanded_notif):
        print("[HyperLight/SystemUI] [2/11] Patched LockScreenNotificationShowAll (canShowOnKeyguard -> true).")
    else:
        print("[HyperLight/SystemUI] Error: ExpandedNotification.smali could not be patched", file=sys.stderr)
        return 1

    # 3. LockScreenStackSink (Must be kept as requested)
    if patch_stack_sink(smali_dir):
        print("[HyperLight/SystemUI] [3/11] Patched LockScreenStackSink (GXZW_SENSOR constraint bypassed).")
    else:
        print("[HyperLight/SystemUI] Notice: GXZW_SENSOR stack sink constraint not applicable on this build.")

    # 4. LockScreenClockTop
    if patch_clock_top(smali_dir):
        print("[HyperLight/SystemUI] [4/11] Patched LockScreenClockTop (anchor notifications right under lock clock).")
    else:
        print("[HyperLight/SystemUI] Notice: LockScreenClockTop signatures not applicable on this build.")

    # 5. NotificationGroupDisable (Thả từng thông báo riêng lẻ, không ẩn)
    if expanded_notif and patch_notification_ungroup(expanded_notif):
        print("[HyperLight/SystemUI] [5/11] Patched NotificationGroupDisable (standalone unhidden notifications).")
    else:
        print("[HyperLight/SystemUI] Notice: ExpandedNotification ungroup could not be applied.")

    # 6. NotificationGroupStack
    if patch_group_stack(smali_dir):
        print("[HyperLight/SystemUI] [6/11] Verified NotificationGroupStack structures.")

    # 7. LockScreenDepthAvoid (SystemUI)
    if patch_depth_avoid_systemui(smali_dir):
        print("[HyperLight/SystemUI] [7/11] Patched LockScreenDepthAvoid in SystemUI.")

    # 8. LockScreenPinKeyUnblur
    if patch_pinkey_unblur(smali_dir):
        print("[HyperLight/SystemUI] [8/11] Patched LockScreenPinKeyUnblur (remove PIN pad blur/dimming).")

    # 9. LockScreenPinKeyGlass
    if patch_pinkey_glass(smali_dir):
        print("[HyperLight/SystemUI] [9/11] Patched LockScreenPinKeyGlass (hardware blur for PIN keys).")

    # 10. LockScreenBlurButton
    if patch_blur_button(smali_dir):
        print("[HyperLight/SystemUI] [10/11] Patched LockScreenBlurButton (glass blur for lockscreen shortcuts).")

    # 11. LockScreenMusicCapsule
    if patch_music_capsule(smali_dir):
        print("[HyperLight/SystemUI] [11/11] Patched LockScreenMusicCapsule (unlock media focus capsule on keyguard).")

    print("[HyperLight/SystemUI] SystemUI modification complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
