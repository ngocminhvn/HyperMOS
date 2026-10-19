#!/usr/bin/env python3
"""Scoped Android 16 CN notification port from FrameworksForge/FrameworkPatcher.

Upstream: https://github.com/FrameworksForge/FrameworkPatcher/blob/master/scripts/patcher_a16.sh
Ports the eight miui-services international-gate targets, Greeze CN_MODEL=false,
and EU-style ProcessManagerService.isForceStopEnable() ONLY. Never copy the
whole EU class (constructor and dependencies differ from HAOTIAN China).
No signature, secure flag, Gboard or module-generation changes.
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
    "com/android/server/alarm/AlarmManagerServiceStubImpl.smali",
    "com/android/server/notification/NotificationManagerServiceImpl.smali",
    "com/android/server/AppOpsServiceStubImpl.smali",
    "miui/app/ActivitySecurityHelper.smali",
)
GREEZE = "com/miui/server/greeze/PolicyManager.smali"
PROCESS_MANAGER = "com/android/server/am/ProcessManagerService.smali"
# Confirmed by DEX-level EU vs CN OS3 A16 comparison: 28 instructions,
# 48 code units, one international-build read; method bytecode otherwise equal.
EU_FORCE_STOP_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisForceStopEnable\(Lcom/android/server/am/ProcessRecord;I\)Z[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)
EU_FORCE_STOP_REASON = re.compile(r"(?m)^[ \t]*const/16[ \t]+([vp]\d+),[ \t]+0xd[ \t]*$")
REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)
CN_WRITE = re.compile(
    r"(?m)^([ \t]*)sput-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z[ \t]*$"
)


def locate(root: Path, relative: str):
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    if len(matches) > 1:
        raise ValueError(f"Duplicate smali class: {relative}")
    return matches[0] if matches else None


def force_international_true(source: str):
    count = 0

    def replace(match):
        nonlocal count
        count += 1
        indent, register, suffix = match.groups()
        # Match upstream: register indices 0..15 use const/4.
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    return REGION_READ.sub(replace, source), count


def force_cn_model_false(source: str):
    matches = list(CN_WRITE.finditer(source))
    if len(matches) != 1:
        raise ValueError(f"Expected one Greeze CN_MODEL assignment, got {len(matches)}")
    match = matches[0]
    indent, register = match.groups()
    instruction = f"const/4 {register}, 0x0"
    previous = source[:match.start()]
    if previous.splitlines() and previous.splitlines()[-1].strip() == instruction:
        return source, False
    return previous + indent + instruction + "\n" + source[match.start():], True


def patch_eu_force_stop(source: str):
    """Fork only the EU decision *inside* the existing CN method.

    EU and CN have identical isForceStopEnable() instructions: the build field
    reads true on EU and false on China. Preserve the policy==13 fast path,
    auto-start/system/protected checks, other class methods, and ABIs verbatim.
    The existing cleaner can still remove tasks/processes without force-stop.
    """
    blocks = list(EU_FORCE_STOP_METHOD.finditer(source))
    if len(blocks) != 1:
        raise ValueError(f"Expected one EU-compatible isForceStopEnable method, got {len(blocks)}")
    old = blocks[0].group()
    gates = list(REGION_READ.finditer(old))
    if len(gates) != 1:
        raise ValueError(f"Expected exactly one EU international gate in isForceStopEnable, got {len(gates)}")
    gate = gates[0]
    reg = gate.group(2)
    if reg != "v0":
        raise ValueError(f"EU/CN isForceStopEnable DEX gate changed register: {reg}")
    guards = list(EU_FORCE_STOP_REASON.finditer(old))
    if len(guards) != 1 or guards[0].start() > gate.start():
        raise ValueError("EU/CN force-stop policy 13 guard missing or reordered")
    if len(re.findall(r"(?m)^[ \t]*return[ \t]", old[:gate.start()])) != 1:
        raise ValueError("Force-stop explicit policy early return changed")
    indent = gate.group(1)
    # This method-only const matches the international=true branch on Xiaomi.eu.
    changed_method = old[:gate.start()] + indent + "const/4 v0, 0x1" + gate.group(3) + old[gate.end():]
    patched = source[:blocks[0].start()] + changed_method + source[blocks[0].end():]
    if patched.replace(changed_method, old, 1) != source:
        raise ValueError("Unexpected edit outside isForceStopEnable")
    if REGION_READ.search(changed_method):
        raise ValueError("EU force-stop gate was not fully replaced")
    return patched, {
        "reference": "Xiaomi.eu A16 miui-servicesEU.jar method-level DEX comparison",
        "class": "ProcessManagerService",
        "method": "isForceStopEnable(Lcom/android/server/am/ProcessRecord;I)Z",
        "international_branch": True,
        "eu_method_instructions": 28,
        "eu_method_code_units": 48,
        "gate_reads_replaced": 1,
        "explicit_policy_13_retained": True,
        "onekeyclean_policy_1": "eu_international_branch",
        "swipeupclean_policy_7": "eu_international_branch",
        "other_process_manager_methods_untouched": True,
        "cleaner_process_removal_unchanged": True,
    }


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled miui-services: {root}")
    details = {}
    total = 0
    for cls in TARGETS:
        file = locate(root, cls)
        if file is None:
            details[cls] = {"present": False, "replaced": 0}
            continue
        original = file.read_text(encoding="utf-8")
        changed, count = force_international_true(original)
        if count:
            file.write_text(changed, encoding="utf-8")
        details[cls] = {"present": True, "replaced": count}
        total += count
    if total == 0:
        raise ValueError("No FrameworkPatcher notification gates found; refuse silent no-op")

    process_manager = locate(root, PROCESS_MANAGER)
    if process_manager is None:
        raise ValueError("ProcessManagerService missing; cannot apply EU force-stop decision")
    original_pm = process_manager.read_text(encoding="utf-8")
    patched_pm, eu_force_stop = patch_eu_force_stop(original_pm)
    process_manager.write_text(patched_pm, encoding="utf-8")

    policy = locate(root, GREEZE)
    if policy is None:
        raise ValueError("Greeze PolicyManager missing")
    original = policy.read_text(encoding="utf-8")
    changed, did_write = force_cn_model_false(original)
    if did_write:
        policy.write_text(changed, encoding="utf-8")
    return {
        "source": "FrameworksForge/FrameworkPatcher scripts/patcher_a16.sh",
        "target_jar": "miui-services.jar",
        "gates_replaced": total,
        "target_classes": details,
        "greeze_cn_model_false": True,
        "scoped_eu_force_stop": eu_force_stop,
        "greeze_changed": did_write,
        "corepatch_signature_or_secure_flag_changed": False,
        "powerkeeper_changed": False,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_miui_services", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.decoded_miui_services)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[FRAMEWORKPATCHER A16] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as exc:
        raise SystemExit("[FRAMEWORKPATCHER A16] FAIL: " + str(exc))
