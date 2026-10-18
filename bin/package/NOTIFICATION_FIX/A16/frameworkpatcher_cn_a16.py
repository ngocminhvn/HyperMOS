#!/usr/bin/env python3
"""Scoped Android 16 CN notification port from FrameworksForge/FrameworkPatcher.

Upstream: https://github.com/FrameworksForge/FrameworkPatcher/blob/master/scripts/patcher_a16.sh
Only imports the eight miui-services international-gate targets and Greeze
CN_MODEL=false; not signature, secure flag, Gboard or module generation.
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
