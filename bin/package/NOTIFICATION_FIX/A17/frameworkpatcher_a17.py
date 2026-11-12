#!/usr/bin/env python3
"""Port the XNotifyFix HyperOS China hooks to Android 17 miui-services.jar."""
import argparse
import json
import re
from pathlib import Path

from smali_a17 import FSI_PACKAGES, edit_method

PROCESS_MANAGER = "com/android/server/am/ProcessManagerService.smali"
GREEZE_SERVICE = "com/miui/server/greeze/GreezeManagerService.smali"
AUROGON_FILTER = "com/miui/server/greeze/AurogonFilterManager.smali"
DOMESTIC_POLICY = "com/miui/server/greeze/DomesticPolicyManager.smali"
ALARM_STUB = "com/android/server/alarm/AlarmManagerServiceStubImpl.smali"

REGION_GATES = (
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z"),
    ("com/android/server/am/ActivityManagerServiceImpl.smali",
     "checkRunningCompatibility(Landroid/content/ComponentName;III)Z"),
    ("com/android/server/alarm/AlarmManagerServiceStubImpl.smali",
     "init(Lcom/android/server/alarm/AlarmManagerService;)V"),
)
FSI_CLASS = "com/android/server/notification/NotificationManagerServiceImpl.smali"
FSI_METHOD = "checkFullScreenIntent(Landroid/app/Notification;Landroid/app/AppOpsManager;ILjava/lang/String;)V"

# Match #268's scoped keep-notification policy: AutoIdleKill (13) keeps its
# original force-stop behavior; the other cleanup policies use Global semantics.
AUTO_IDLE_POLICY = re.compile(r"(?m)^[ \t]*const/16[ \t]+([vp]\d+),[ \t]+0xd[ \t]*$")
FORCE_STOP_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisForceStopEnable\(Lcom/android/server/am/ProcessRecord;I\)Z[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)

REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    # CorePatch A17 redirects stock Build reads to xBuild before this pass.
    r"Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)

def locate(root: Path, relative: str):
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    if not matches:
        # Also check direct relative path
        direct = root / relative
        if direct.is_file():
            return direct
    if len(matches) > 1:
        raise ValueError(f"Duplicate smali class: {relative}")
    return matches[0] if matches else None


def patch_region_gate(source, signature, fsi_packages=()):

    def edit(block):
        if "# XNotifyFix international gate" in block or ":a17_compat_ready" in block:
            return block
        if signature.startswith("checkRunningCompatibility(") and re.search(
            r"(?m)^    move-object/from16 v1, p1\s+if-eqz v1, :\w+\s+const/4 v1, 0x1",
            block,
        ):
            return block
        if signature.startswith("init(") and re.search(
            r"(?m)^    const/4 (v\d+), 0x1\s+if-eqz \1, :\w+\s+"
            r"(?:\.line \d+\s+)?new-instance \1, Ljava/util/ArrayList;",
            block,
        ):
            return block
        matches = list(REGION_READ.finditer(block))
        if not matches:
            if signature.startswith("checkApplicationAutoStart(") and re.search(
                r'(?m)^    const/(?:4|16) (v\d+), 0x1\s+if-eqz \1, :[^\n]+'
                r'\s+(?:\.line \d+\s+)?const-string(?:/jumbo)? \1, "com.google.android.c2dm.intent.RECEIVE"',
                block,
            ):
                return block
            raise ValueError(f"{signature}: region gate missing")
        gate = matches[0]
        indent, register, _ = gate.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        replacement = f"{indent}{opcode} {register}, 0x1  # XNotifyFix international gate"
        if signature == FSI_METHOD:
            if not fsi_packages:
                return block
            # The A17 gate uses v0. v1 is a local overwritten by the stock path.
            if register != "v0" or "    .registers 12" not in block:
                raise ValueError("checkFullScreenIntent: unsupported register layout")
            if ":a17_fsi_allowed" in block or all(
                re.search(
                    rf'const-string(?:/jumbo)? v1, "{re.escape(package)}"\s+'
                    r'invoke-virtual \{v1, p4\}, Ljava/lang/String;->equals',
                    block,
                )
                for package in fsi_packages
            ):
                return block
            checks = []
            for package in fsi_packages:
                checks.extend((
                    f'    const-string v1, "{package}"',
                    "    invoke-virtual {v1, p4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z",
                    "    move-result v0",
                    "    if-nez v0, :a17_fsi_allowed",
                ))
            checks.extend((gate.group(), "    :a17_fsi_allowed"))
            replacement = "\n\n".join(checks)
        elif signature.startswith("checkRunningCompatibility("):
            # XNotifyFix returns false for a null ComponentName in Allow All.
            if register != "v1":
                raise ValueError("checkRunningCompatibility: unexpected region register")
            replacement = (
                "    move-object/from16 v1, p1\n\n"
                "    if-eqz v1, :a17_compat_null\n\n"
                "    const/4 v1, 0x1\n\n"
                "    goto :a17_compat_ready\n\n"
                "    :a17_compat_null\n"
                "    const/4 v1, 0x0\n\n"
                "    :a17_compat_ready"
            )
        return block[:gate.start()] + replacement + block[gate.end():]

    return edit_method(source, re.escape(signature), edit)


def patch_force_stop(source: str):
    """Preserve #268's AutoIdleKill (policy 13) exception.

    On the verified OS4/A17 China ROM, forcing the international region read
    inside isForceStopEnable() makes normal recents cleanup kill the process
    without force-stopping it. The stock policy-13 branch still returns true,
    allowing Xiaomi's AutoIdleKill to force-stop an idle app as in #268.
    No global KEEP_NOTIF=ALL preamble is injected.
    """
    methods = list(FORCE_STOP_METHOD.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"ProcessManagerService: expected one isForceStopEnable, got {len(methods)}")
    block = methods[0].group()
    if not AUTO_IDLE_POLICY.search(block):
        raise ValueError("ProcessManagerService: AutoIdleKill policy 13 (0xd) guard missing")
    if ":hypermos_keep_notif_all_stock" in block:
        raise ValueError("ProcessManagerService: unconditional KEEP_NOTIF=ALL hook still present")

    gates = list(REGION_READ.finditer(block))
    if not gates:
        # A second application to a compiled JAR loses Smali comments. If no
        # region read remains, the patcher cannot prove #268's exact behavior.
        # Refuse to silently accept an unknown method body as equivalent.
        raise ValueError("ProcessManagerService: region read missing; cannot verify #268 policy-13 behavior")

    def enable_international(match):
        indent, register, suffix = match.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    patched_block = REGION_READ.sub(enable_international, block)
    output = source[:methods[0].start()] + patched_block + source[methods[0].end():]
    return output, {
        "method_patched": True,
        "keep_notifications": "scoped_268",
        "auto_idle_policy_13": "stock_force_stop",
        "region_reads_replaced": len(gates),
        "runtime_module_required": False,
    }



def disable_gms_app_check(source):
    def edit(block):
        # In a two-register instance method, v0 and p0 are aliases. Baksmali
        # emits p0 on a second pass even if the original stub used v0.
        if re.fullmatch(
            r"\.method[^\n]*\n\s*\.(?:registers|locals) \d+\s+"
            r"const/4 ([vp]\d+), 0x0\s+return \1\s+\.end method",
            block,
        ):
            return block
        header = block.splitlines()[0]
        return f"{header}\n    .registers 2\n\n    const/4 p0, 0x0\n\n    return p0\n.end method"

    return edit_method(source, r"isGmsApp\(I\)Z", edit)


def replace_void_method(source: str, signature: str, registers: int = 1):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    header = methods[0].group().splitlines()[0]
    replacement = (
        f"{header}\n"
        f"    .registers {registers}\n\n"
        "    return-void\n"
        ".end method"
    )
    return source[:methods[0].start()] + replacement + source[methods[0].end():]


def inject_method_preamble(source: str, signature: str, preamble: str, label: str):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()
    existing = re.sub(r":fcm_a17_\w+", lambda _: r":\w+", re.escape(preamble.rstrip().rsplit("\n", 1)[0]))
    if label in block or re.search(existing, block):
        return source
    registers = re.search(r"(?m)^[ \t]*\.(?:registers|locals)[ \t]+\d+[ \t]*$", block)
    if not registers:
        raise ValueError(f"{signature}: missing registers declaration")
    at = registers.end()
    block = block[:at] + "\n\n" + preamble.rstrip() + block[at:]
    return source[:methods[0].start()] + block + source[methods[0].end():]


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled miui-services: {root}")
    details = {}
    modified = False
    for relative, signature in REGION_GATES:
        file = locate(root, relative)
        if file is None:
            raise ValueError(f"{relative}: missing")
        original = file.read_text(encoding="utf-8")
        changed = patch_region_gate(original, signature)
        if changed != original:
            file.write_text(changed, encoding="utf-8")
            modified = True
        details[signature] = "patched" if changed != original else "already patched"

    fsi = locate(root, FSI_CLASS)
    if fsi is None:
        raise ValueError(f"{FSI_CLASS}: missing")
    original = fsi.read_text(encoding="utf-8")
    changed = patch_region_gate(original, FSI_METHOD, FSI_PACKAGES)
    if changed != original:
        fsi.write_text(changed, encoding="utf-8")
        modified = True
    details[FSI_METHOD] = "patched" if changed != original else "already patched"
    details["full_screen_packages"] = FSI_PACKAGES

    process_manager = locate(root, PROCESS_MANAGER)
    if process_manager is None:
        raise ValueError(f"{PROCESS_MANAGER}: missing")
    original_pm = process_manager.read_text(encoding="utf-8")
    patched_pm, pm_info = patch_force_stop(original_pm)
    if patched_pm != original_pm:
        process_manager.write_text(patched_pm, encoding="utf-8")
        modified = True
    details[PROCESS_MANAGER] = pm_info

    # Port the verified fcm_notification_fix vectors to OS4/A17 without its
    # runtime module. Only C2DM broadcasts bypass screen-off Greeze policy.
    greeze_service = locate(root, GREEZE_SERVICE)
    if greeze_service is None:
        raise ValueError("GreezeManagerService missing")
    original_greeze = greeze_service.read_text(encoding="utf-8")
    service_text = inject_method_preamble(
        original_greeze,
        "isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z",
        '    const-string v0, "com.google.android.c2dm.intent.RECEIVE"\n\n'
        '    invoke-virtual {v0, p5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
        '    move-result v0\n\n'
        '    if-eqz v0, :fcm_a17_greeze_stock\n\n'
        '    const/4 v0, 0x1\n\n'
        '    return v0\n\n'
        '    :fcm_a17_greeze_stock',
        ":fcm_a17_greeze_stock")
    # On OS4, PowerKeeper's updateGmsNetStatus calls this same limiter.
    # Keep its Binder status round-trip and disable the limiter at its source.
    service_text = replace_void_method(
        service_text, "triggerGMSLimitAction()V")
    service_text = disable_gms_app_check(service_text)
    if service_text != original_greeze:
        greeze_service.write_text(service_text, encoding="utf-8")
        modified = True
    details[GREEZE_SERVICE] = {
        "c2dm_screen_off_thaw": True,
        "gms_limit_action_disabled": True,
        "gms_special_freeze_path_disabled": True,
    }

    # XNotifyFix-style Aurogon protection is scoped to GMS only.
    # Ordinary messenger apps may freeze when idle; they are awakened on
    # incoming C2DM by the GreezeManagerService.isAllowBroadcast hook and
    # FLAG_INCLUDE_STOPPED_PACKAGES in services.jar. Do not permanently exempt
    # apps such as Messenger here, to preserve stock idle battery behavior.
    aurogon = locate(root, AUROGON_FILTER)
    if aurogon is None:
        raise ValueError("AurogonFilterManager missing")
    original_aurogon = aurogon.read_text(encoding="utf-8")
    aurogon_text = inject_method_preamble(
        original_aurogon,
        "filter(ILjava/lang/String;I)Z",
        '    const-string v0, "com.google.android.gms"\n\n'
        '    invoke-virtual {v0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
        '    move-result v0\n\n'
        '    if-eqz v0, :fcm_a17_aurogon_stock\n\n'
        '    const/16 v0, 0x40\n\n'
        '    iput v0, p0, Lcom/miui/server/greeze/AurogonFilterManager;->mContinueReason:I\n\n'
        '    const/4 v0, 0x0\n\n'
        '    return v0\n\n'
        '    :fcm_a17_aurogon_stock',
        ":fcm_a17_aurogon_stock")
    if aurogon_text != original_aurogon:
        aurogon.write_text(aurogon_text, encoding="utf-8")
        modified = True
    details[AUROGON_FILTER] = {"gms_quick_freeze_shield": True}

    # Video scenario / Immobulus mode: prevent deferring & caching broadcasts to background apps
    domestic = locate(root, DOMESTIC_POLICY)
    if domestic is not None:
        original_domestic = domestic.read_text(encoding="utf-8")
        domestic_text = replace_boolean_method(original_domestic, "deferBroadcast(Ljava/lang/String;)Z", 0)
        domestic_text = replace_boolean_method(domestic_text, "needCacheBroadcast(Ljava/lang/String;II)Z", 0)
        if domestic_text != original_domestic:
            domestic.write_text(domestic_text, encoding="utf-8")
            modified = True
        details[DOMESTIC_POLICY] = {"defer_broadcast_disabled": True, "need_cache_broadcast_disabled": True}

    # Alarm throttling: exempt only GMS from SSRU 120s budget denial (canAfford=false)
    # Other apps remain strictly constrained by stock SSRU budget to protect idle battery and thermals.
    alarm_stub = locate(root, ALARM_STUB)
    if alarm_stub is not None:
        original_alarm = alarm_stub.read_text(encoding="utf-8")
        alarm_text = inject_method_preamble(
            original_alarm,
            "canAffordBillLocked(Lcom/android/server/alarm/Alarm;Lcom/android/server/ssru/ResourceBudgetManagerInternal$OperateAccount;)Z",
            '    const-string v0, "com.google.android.gms"

'
            '    iget-object v1, p1, Lcom/android/server/alarm/Alarm;->sourcePackage:Ljava/lang/String;

'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

'
            '    move-result v0

'
            '    if-eqz v0, :fcm_a17_alarm_stock

'
            '    const/4 v0, 0x1

'
            '    return v0

'
            '    :fcm_a17_alarm_stock',
            ":fcm_a17_alarm_stock"
        )
        if alarm_text != original_alarm:
            alarm_stub.write_text(alarm_text, encoding="utf-8")
            modified = True
        details[ALARM_STUB] = {"gms_alarm_budget_shield": True}

    return {
        "status": "success",
        "changed": modified,
        "target_jar": "miui-services.jar",
        "classes": details,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_miui_services", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.decoded_miui_services)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[FRAMEWORKPATCHER A17] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit("[FRAMEWORKPATCHER A17] FAIL: " + str(exc))
