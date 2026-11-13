#!/usr/bin/env python3
"""Android 17 services.jar FCM wake patch.

HyperOS can deliver C2DM through GMS while the target package remains stopped.
Match the verified fcm_notification_fix wake vector without adding a runtime
module: add FLAG_INCLUDE_STOPPED_PACKAGES only to C2DM receive broadcasts.
"""
import argparse
import json
import os
import re
from pathlib import Path

from smali_a17 import edit_method, replace_site
from boot_a17 import BOOT_CLASS, patch_boot


BROADCAST_CONTROLLER = "com/android/server/am/BroadcastController.smali"
BROADCAST_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bbroadcastIntentLockedTraced\([^\n]*\)I[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)
INTENT_MOVE = re.compile(
    r"(?m)^([ \t]*)move-object/from16[ \t]+v0,[ \t]+p4[ \t]*$"
)
ACTIVE_SERVICES = "com/android/server/am/ActiveServices.smali"
ATTENTION_HELPER = "com/android/server/notification/NotificationAttentionHelper.smali"
NOTIFICATION_MANAGER = "com/android/server/notification/NotificationManagerService.smali"
PATCH_LABEL = ":fcm_a17_c2dm_continue"


def locate(root: Path, relative: str) -> Path:
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    direct = root / relative
    if not matches and direct.is_file():
        matches = [direct]
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def patch_broadcast_controller(source: str):
    methods = list(BROADCAST_METHOD.finditer(source))
    if len(methods) != 1:
        raise ValueError(
            "BroadcastController: expected one broadcastIntentLockedTraced method, "
            f"got {len(methods)}")
    block = methods[0].group()
    if PATCH_LABEL in block or "->hypermosApplyC2dmWake(" in block or (
        "com.google.android.c2dm.intent.RECEIVE" in block
        and re.search(r"const/16 v11, 0x20\s+invoke-virtual \{v0, v11\}, Landroid/content/Intent;->addFlags", block)
    ):
        return source, False

    if not re.match(
        r"^\.method[^\n]*broadcastIntentLockedTraced\("
        r"Lcom/android/server/am/ProcessRecord;Ljava/lang/String;Ljava/lang/String;"
        r"Landroid/content/Intent;", block,
    ):
        raise ValueError("BroadcastController: expected Intent at p4")
    move = INTENT_MOVE.search(block)
    if not move:
        raise ValueError("BroadcastController: expected Intent setup")
    hook = (
        "\n\n    invoke-static/range {p4 .. p4}, Lcom/android/server/am/BroadcastController;"
        "->hypermosApplyC2dmWake(Landroid/content/Intent;)V"
    )
    at = move.end()
    block = block[:at] + hook + block[at:]
    output = source[:methods[0].start()] + block + source[methods[0].end():]
    return output + WAKE_HELPER, True


WAKE_HELPER = """
.method private static hypermosApplyC2dmWake(Landroid/content/Intent;)V
    .locals 2

    if-eqz p0, :done

    invoke-virtual {p0}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v0

    const-string v1, "com.google.android.c2dm.intent.RECEIVE"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :done

    const/16 v0, 0x20

    invoke-virtual {p0, v0}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    :done
    return-void
.end method
"""


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


MQTT_EXEMPT_HELPER = """
.method private static hypermosIsMqttServiceExempt(Lcom/android/server/am/ServiceRecord;)Z
    .locals 3
    .param p0, "service"    # Lcom/android/server/am/ServiceRecord;

    const/4 v0, 0x0

    if-nez p0, :cond_check_null

    return v0

    :cond_check_null
    iget-object v1, p0, Lcom/android/server/am/ServiceRecord;->packageName:Ljava/lang/String;

    if-nez v1, :cond_check_pkg

    return v0

    :cond_check_pkg
    const-string v2, "com.facebook.orca"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_check_comp

    return v0

    :cond_check_comp
    iget-object v1, p0, Lcom/android/server/am/ServiceRecord;->shortInstanceName:Ljava/lang/String;

    if-nez v1, :cond_check_name

    return v0

    :cond_check_name
    const-string v2, "MqttService"

    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_check_done

    return v0

    :cond_check_done
    const/4 v0, 0x1

    return v0
.end method
"""


def patch_active_services(source: str):
    method_sig = r"stopInBackgroundLocked\(I\)V"
    pattern = (
        r"^[ \t]*invoke-virtual/range \{v8 \.\. v16\}, "
        r"Lcom/android/server/am/ActivityManagerService;->getAppStartModeLOSP\([^\)]+\)I\s*\n"
        r"[ \t]*move-result v6\s*\n"
        r"[ \t]*if-eqz v6, :(\w+)\s*$"
    )

    def edit(block):
        if "hypermosIsMqttServiceExempt" in block or "# XNotifyFix mqtt service idle exemption" in block:
            return block
        m = re.search(pattern, block, re.MULTILINE)
        if not m:
            raise ValueError("stopInBackgroundLocked: getAppStartModeLOSP pattern not found")
        skip_label = ":" + m.group(1)
        hook = (
            f"    invoke-static {{v5}}, Lcom/android/server/am/ActiveServices;->hypermosIsMqttServiceExempt(Lcom/android/server/am/ServiceRecord;)Z\n\n"
            f"    move-result v6\n\n"
            f"    if-eqz v6, {skip_label}  # XNotifyFix mqtt service idle exemption\n\n"
        )
        return block[:m.start()] + hook + block[m.start():]

    method_pattern = rf"(?ms)^\.method[^\n]*\s{method_sig}[ \t]*\n.*?^\.end method[ \t]*$"
    m_meth = re.search(method_pattern, source)
    if not m_meth:
        raise ValueError("ActiveServices: expected stopInBackgroundLocked(I)V method")
    patched_method = edit(m_meth.group(0))
    if patched_method != m_meth.group(0):
        return source[:m_meth.start()] + patched_method + source[m_meth.end():] + MQTT_EXEMPT_HELPER, True
    return source, False


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"missing decompiled services.jar: {root}")
    controller = locate(root, BROADCAST_CONTROLLER)
    changed, inserted = patch_broadcast_controller(
        controller.read_text(encoding="utf-8"))
    if inserted:
        controller.write_text(changed, encoding="utf-8")

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

    active_services = locate(root, ACTIVE_SERVICES)
    patched_as, as_inserted = patch_active_services(active_services.read_text(encoding="utf-8"))
    if as_inserted:
        active_services.write_text(patched_as, encoding="utf-8")

    return {
        "status": "success",
        "changed": inserted or patched != original or boot_inserted or call_gate_inserted or as_inserted,
        "target_jar": "services.jar",
        "c2dm_include_stopped_packages": True,
        "hook_inserted": inserted,
        "alert_options": flags,
        "call_fsi_gate_inserted": call_gate_inserted,
        "boot_actions_inserted": boot_inserted,
        "mqtt_service_exempt_inserted": as_inserted,
        "class": BROADCAST_CONTROLLER,
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
