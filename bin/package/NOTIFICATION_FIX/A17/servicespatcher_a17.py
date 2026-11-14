#!/usr/bin/env python3
"""Android 17 services.jar patcher for HyperMOS.

Applies standard notification alert handling (anti-mute on update) and boot setup.
Removes custom MQTT service exemptions and stopped-package broadcast injection,
matching pure Global Android power management and idle battery behavior.
"""
import argparse
import json
import os
import re
from pathlib import Path

from smali_a17 import edit_method, replace_site
from boot_a17 import BOOT_CLASS, patch_boot


ATTENTION_HELPER = "com/android/server/notification/NotificationAttentionHelper.smali"
NOTIFICATION_MANAGER = "com/android/server/notification/NotificationManagerService.smali"


def locate(root: Path, relative: str) -> Path:
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    direct = root / relative
    if not matches and direct.is_file():
        matches = [direct]
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def patch_alerts(source, group, anti_mute, unthrottle):
    def mute_reasons(block):
        for method, feature in (
            ("suppressAlertingDueToGrouping()Z", "group alert"),
            ("isAlertRateLimited(Ljava/lang/String;)Z", "alert rate limit"),
        ):
            enabled = group if feature == "group alert" else unthrottle
            if enabled:
                site = (
                    r"(^[ \t]*invoke-virtual(?:/range)? [^\n]+->" + re.escape(method)
                    + r"\s+move-result (v\d+)\s*\n)([ \t]*)"
                )
                block = replace_site(
                    block,
                    site + r"(if-eqz \2, :\w+)$",
                    r"\1\3const/16 \2, 0x0\n\n\3\4",
                    feature,
                    site + r"const/(?:4|16) \2, 0x0\s+if-eqz \2, :\w+$",
                )
        return block

    def update_effects(block):
        for effect in ("Sound", "Vibrate"):
            # Jump over the existing cancellation block, preserving the key and
            # flags used earlier in this method for other alert decisions.
            cancellation = (
                r"(:\w+)(?=\s+if-nez v\d+, \2\s+(?:\.line \d+\s+)?"
                r"invoke-virtual \{v\d+\}, [^\n]+"
                rf"->clear{effect}Locked\(\)V)"
            )
            block = replace_site(
                block,
                r"^([ \t]*)if-eqz v\d+, " + cancellation,
                r"\1goto/16 \2",
                f"anti-mute {effect}",
                r"^[ \t]*goto(?:/16)? :goto_([0-9a-f]+)"
                r"(?=\s+if-nez v\d+, :cond_\1\s+(?:\.line \d+\s+)?"
                r"invoke-virtual \{v\d+\}, [^\n]+"
                rf"->clear{effect}Locked\(\)V)",
            )
        return block

    def play_sound(block):
        focus = r'(^[ \t]*const-string(?:/jumbo)? v\d+, "NotifAttentionHelper"\s*\n)[ \t]*'
        deny = (
            r"(^[ \t]*invoke-virtual[^\n]+->isDeniedPlaySound\([^\n]+\)Z"
            r"\s+move-result (v\d+)\s*\n)[ \t]*"
        )
        block = replace_site(
            block, focus + r"if-nez v\d+, (:\w+)$",
            r"\1    goto/16 \2", "play sound focus",
            focus + r"goto(?:/16)? :\w+$",
        )
        return replace_site(
            block, deny + r"if-eqz \2, (:\w+)$",
            r"\1    goto/16 \3", "play sound MIUI gate",
            deny + r"goto(?:/16)? :\w+$",
        )

    if group or unthrottle:
        source = edit_method(source, r"shouldMuteNotificationLocked\([^\n]+\)I", mute_reasons)
    if anti_mute:
        source = edit_method(source, r"buzzBeepBlinkLocked\([^\n]+\)I", update_effects)
    if unthrottle:
        source = edit_method(source, r"playSound\([^\n]+\)Z", play_sound)
    return source


def patch_call_full_screen_intent(source):
    # The null-intent branch already skips the permission check and sticky HUN
    # fallback. Take that same branch for call notifications with an intent.
    guard = (
        r"(^    iget-object v8, v1, Landroid/app/Notification;->fullScreenIntent:"
        r"Landroid/app/PendingIntent;\s+if-eqz v8, (:\w+))"
    )
    category_check = (
        "    iget-object v8, v1, Landroid/app/Notification;->category:Ljava/lang/String;\n\n"
        '    const-string v9, "call"\n\n'
        "    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n"
        "    move-result v8\n\n"
        r"    if-nez v8, \2"
    )

    def edit(block):
        return replace_site(
            block,
            guard + r"$(?=\s+(?:\.line \d+\s+)?"
            r"new-instance v8, Landroid/content/AttributionSource\$Builder;)",
            r"\1" + "\n\n" + category_check,
            "call full-screen intent",
            guard + r"\s+iget-object v8, v1, Landroid/app/Notification;->category:"
            r'Ljava/lang/String;\s+const-string(?:/jumbo)? v9, "call"\s+'
            r"invoke-virtual \{v9, v8\}, Ljava/lang/String;->equals\(Ljava/lang/Object;\)Z"
            r"\s+move-result v8\s+if-nez v8, \2$",
        )

    return edit_method(
        source,
        r"fixNotification\(Landroid/app/Notification;Ljava/lang/String;Ljava/lang/String;"
        r"IIILandroid/app/ActivityManagerInternal\$ServiceNotificationPolicy;ZZ\)V",
        edit,
    )


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"missing decompiled services.jar: {root}")

    flags = {}
    for option, default in (
        ("GROUP_ALERT_BYPASS", "0"),
        ("ANTI_MUTE_UPDATE", "1"),
        ("UNTHROTTLE_ALERT", "0"),
    ):
        value = os.getenv("A17_" + option, default)
        if value not in ("0", "1"):
            raise ValueError(f"A17_{option}: expected 0 or 1")
        flags[option] = value == "1"
    attention = locate(root, ATTENTION_HELPER)
    original = attention.read_text(encoding="utf-8")
    patched = patch_alerts(original, *flags.values())
    if patched != original:
        attention.write_text(patched, encoding="utf-8")
    manager = locate(root, NOTIFICATION_MANAGER)
    original_manager = manager.read_text(encoding="utf-8")
    patched_manager = patch_call_full_screen_intent(original_manager)
    call_gate_inserted = patched_manager != original_manager
    if call_gate_inserted:
        manager.write_text(patched_manager, encoding="utf-8")

    boot_inserted = patch_boot(locate(root, BOOT_CLASS))

    return {
        "status": "success",
        "changed": patched != original or boot_inserted or call_gate_inserted,
        "target_jar": "services.jar",
        "alert_options": flags,
        "call_fsi_gate_inserted": call_gate_inserted,
        "boot_actions_inserted": boot_inserted,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_services", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.decoded_services)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[SERVICESPATCHER A17] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit("[SERVICESPATCHER A17] FAIL: " + str(exc))
