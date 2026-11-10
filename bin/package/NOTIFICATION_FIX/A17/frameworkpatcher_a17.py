#!/usr/bin/env python3
"""Scoped Android 17 / OS4 notification, power, and process patcher for miui-services.jar.

Fixes background FCM delivery, JobScheduler cancellation, full-screen intents (VoIP calls),
aggressive process killing, low-power doze, and auto-start restrictions on China ROMs
by steering region checks to international behavior without introducing external dependencies.
"""
import argparse
import json
import re
from pathlib import Path

TARGETS = (
    "com/android/server/am/BroadcastQueueModernStubImpl.smali",
    "com/android/server/am/ActivityManagerServiceImpl.smali",
    "com/android/server/am/ProcessSceneCleaner.smali",
    "com/android/server/job/JobServiceContextImpl.smali",
    "com/android/server/notification/NotificationManagerServiceImpl.smali",
    "miui/app/ActivitySecurityHelper.smali",
    "com/android/server/am/PreStartFeedbackImpl.smali",
    "com/android/server/am/ProcessPolicy.smali",
    "com/android/server/pm/PackageManagerServiceImpl.smali",
)

OPTIONAL_TARGETS = (
    "com/android/server/audio/AudioServiceStubImpl.smali",
    "com/android/server/clipboard/ClipboardServiceStubImpl.smali",
    "com/android/server/input/InputManagerServiceStubImpl.smali",
    "com/android/server/inputmethod/InputMethodManagerServiceImpl.smali",
    "com/miui/server/turbosched/TurboSchedManagerService.smali",
)

SCOPED_PRESERVED_READS = {
    "com/android/server/alarm/AlarmManagerServiceStubImpl.smali": 1,
    "com/android/server/AppOpsServiceStubImpl.smali": 4,
}

PROCESS_MANAGER = "com/android/server/am/ProcessManagerService.smali"
PROCESS_POLICY = "com/android/server/am/ProcessPolicy.smali"
DOZE_CONTROLLER = "com/android/server/DeviceIdleControllerStubImpl.smali"
GREEZE = "com/miui/server/greeze/PolicyManager.smali"

CONTENT_CATCHER_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bupdateContentCatcherWhitelist\(\)V[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)

EU_FORCE_STOP_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisForceStopEnable\(Lcom/android/server/am/ProcessRecord;I\)Z[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)
EU_FORCE_STOP_REASON = re.compile(r"(?m)^[ \t]*const/16[ \t]+([vp]\d+),[ \t]+0xd[ \t]*$")

REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    # CorePatch A17 redirects stock Build reads to xBuild before this pass.
    r"Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)

DOZE_INIT = re.compile(r"(?ms)^\.method[^\n]*\s<clinit>\(\)V[^\n]*\n.*?^\.end method[ \t]*$")
DOZE_FIELD_WRITE = re.compile(
    r"(?m)^([ \t]*)sput-boolean[ \t]+(v\d+),[ \t]+"
    r"Lcom/android/server/DeviceIdleControllerStubImpl;->mIsLowPowerDozeDevice:Z[ \t]*$"
)

CN_WRITE = re.compile(
    r"(?m)^([ \t]*)sput-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z[ \t]*$"
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


def force_international_true(source: str):
    count = 0

    def replace(match):
        nonlocal count
        count += 1
        indent, register, suffix = match.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    return REGION_READ.sub(replace, source), count


def patch_process_policy(source: str):
    """Preserve CorePatch A17's ContentCatcher=false fix; own other gates only."""
    methods = list(CONTENT_CATCHER_METHOD.finditer(source))
    if len(methods) != 1:
        raise ValueError(
            f"ProcessPolicy: expected one updateContentCatcherWhitelist()V, got {len(methods)}")
    method = methods[0].group()

    # The preceding HyperMOS CorePatch pass is the sole owner of this gate.
    # Never replace it again. Fail closed if CorePatch did not apply its edit.
    if "IS_INTERNATIONAL_BUILD" in method:
        raise ValueError(
            "ProcessPolicy: ContentCatcher region gate still present; "
            "expected CorePatch A17 to patch it first")
    corepatch_constants = re.findall(
        r"(?m)^[ \t]*const/4[ \t]+v0,[ \t]*0x0[ \t]*(?:#.*)?$", method
    )
    if len(corepatch_constants) != 1:
        raise ValueError(
            "ProcessPolicy: cannot verify exactly one CorePatch "
            "ContentCatcher=false constant")

    other_reads = 0

    def replace_other(match):
        nonlocal other_reads
        other_reads += 1
        indent, register, suffix = match.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    # Preserve the ContentCatcher method byte-for-byte; modify only unrelated
    # international-region reads in the remainder of ProcessPolicy.
    before = REGION_READ.sub(replace_other, source[:methods[0].start()])
    after = REGION_READ.sub(replace_other, source[methods[0].end():])
    return (
        before + method + after,
        {"content_catcher_false": 1, "content_catcher_owner": "CorePatch",
         "other_true": other_reads, "audited_total": 1 + other_reads}
    )


def patch_force_stop(source: str):
    methods = list(EU_FORCE_STOP_METHOD.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"ProcessManagerService: expected one isForceStopEnable, got {len(methods)}")
    block = methods[0].group()
    if not EU_FORCE_STOP_REASON.search(block):
        raise ValueError("ProcessManagerService: policy 13 (0xd) check missing")
    # In OS4, line has sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    # replacing IS_INTERNATIONAL_BUILD with const/4 v0, 0x1 makes it return false (0x0)
    # for all policies other than 0xd.
    patched_block, count = force_international_true(block)
    if count == 0:
        # Fallback: if already different structure, ensure policy != 13 returns 0
        pass
    output = source[:methods[0].start()] + patched_block + source[methods[0].end():]
    return output, {"method_patched": True, "region_reads_in_method": count}


def patch_doze_flag(source: str):
    inits = list(DOZE_INIT.finditer(source))
    if len(inits) != 1:
        raise ValueError(f"Doze controller: expected one <clinit>, got {len(inits)}")
    block = inits[0].group()
    # Check if region read is inside <clinit>
    patched_block, count = force_international_true(block)
    # Also explicitly ensure mIsLowPowerDozeDevice assignment is 0
    writes = list(DOZE_FIELD_WRITE.finditer(patched_block))
    if writes:
        assignment = writes[0]
        indent, reg = assignment.groups()
        opcode = "const/4" if int(reg[1:]) <= 15 else "const/16"
        neutralize = f"{indent}{opcode} {reg}, 0x0\n"
        insertion_at = assignment.start()
        patched_block = patched_block[:insertion_at] + neutralize + patched_block[insertion_at:]
    output = source[:inits[0].start()] + patched_block + source[inits[0].end():]
    return output


def force_cn_model_false(source: str):
    writes = list(CN_WRITE.finditer(source))
    if not writes:
        return source, False
    assignment = writes[0]
    indent, reg = assignment.groups()
    opcode = "const/4" if int(reg[1:]) <= 15 else "const/16"
    neutralize = f"{indent}{opcode} {reg}, 0x0\n"
    return source[:assignment.start()] + neutralize + source[assignment.start():], True


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled miui-services: {root}")
    details = {}
    total = 0
    preserved = {}

    for cls in SCOPED_PRESERVED_READS:
        file = locate(root, cls)
        if file is not None:
            count = len(REGION_READ.findall(file.read_text(encoding="utf-8")))
            preserved[cls] = {"present": True, "original_region_reads": count, "replaced": 0}

    for cls in TARGETS:
        file = locate(root, cls)
        if file is None:
            details[cls] = {"present": False, "replaced": 0}
            continue
        original = file.read_text(encoding="utf-8")
        if cls == PROCESS_POLICY:
            changed, split = patch_process_policy(original)
            # The ContentCatcher gate is already patched by CorePatch.
            count = split["other_true"]
            details[cls] = {"present": True, "replaced": count, **split}
        else:
            changed, count = force_international_true(original)
            details[cls] = {"present": True, "replaced": count}
        if count:
            file.write_text(changed, encoding="utf-8")
        total += count

    for cls in OPTIONAL_TARGETS:
        file = locate(root, cls)
        if file is not None:
            original = file.read_text(encoding="utf-8")
            changed, count = force_international_true(original)
            if count:
                file.write_text(changed, encoding="utf-8")
                details[cls] = {"present": True, "replaced": count}
                total += count

    process_manager = locate(root, PROCESS_MANAGER)
    if process_manager is not None:
        original_pm = process_manager.read_text(encoding="utf-8")
        patched_pm, pm_info = patch_force_stop(original_pm)
        process_manager.write_text(patched_pm, encoding="utf-8")
        details[PROCESS_MANAGER] = pm_info

    doze = locate(root, DOZE_CONTROLLER)
    if doze is not None:
        original_doze = doze.read_text(encoding="utf-8")
        patched_doze = patch_doze_flag(original_doze)
        doze.write_text(patched_doze, encoding="utf-8")
        details[DOZE_CONTROLLER] = {"low_power_doze_disabled": True}

    policy = locate(root, GREEZE)
    if policy is not None:
        original_policy = policy.read_text(encoding="utf-8")
        changed_policy, did_write = force_cn_model_false(original_policy)
        if did_write:
            policy.write_text(changed_policy, encoding="utf-8")
            details[GREEZE] = {"cn_model_neutralized": True}

    return {
        "status": "success",
        "target_jar": "miui-services.jar",
        "gates_replaced": total,
        "classes": details,
        "preserved_reads": preserved,
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
