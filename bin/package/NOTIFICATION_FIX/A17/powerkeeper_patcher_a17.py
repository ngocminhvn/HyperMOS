#!/usr/bin/env python3
"""Scoped Android 17 / OS4 PowerKeeper smali patcher.

Fixes aggressive battery saver, exclusive WeChat/QQ Doze whitelisting,
night sleep mode app kill, alarm restrictions, and China cloud control
by steering region checks to international behavior.
Does NOT import PerfHook or external Ryu classes.
"""
import argparse
import json
import re
from pathlib import Path

REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)

TARGET_CLASSES = (
    "com/miui/powerkeeper/controller/DeviceIdleController$1.smali",
    "com/miui/powerkeeper/controller/DeviceIdleController$2.smali",
    "com/miui/powerkeeper/statemachine/PadSleepModeController.smali",
    "com/miui/powerkeeper/customerpower/CustomerPowerCheck.smali",
    "com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali",
    "com/miui/powerkeeper/cloudcontrol/CloudUpdateReceiver.smali",
    "com/miui/powerkeeper/cloudcontrol/CloudUpdateHideMode.smali",
    "com/miui/powerkeeper/utils/Utils.smali",
    "com/miui/powerkeeper/unionpower/utils/UnionPowerConfig.smali",
    "com/miui/powerkeeper/PowerKeeperApplication.smali",
    "com/miui/powerkeeper/feedbackcontrol/ThermalLogUploader.smali",
    "com/miui/powerkeeper/statemachine/DisplayFrameSetting.smali",
    "com/miui/powerkeeper/thermalcollector/event/BaseEvent.smali",
    "com/miui/powerkeeper/tracker/TrackerManager$PrivacyPolicy.smali",
    "com/miui/powerkeeper/perfservice/onetrack/TrackAnalytics.smali",
)


def force_international_true(source: str):
    count = 0

    def replace(match):
        nonlocal count
        count += 1
        indent, register, suffix = match.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    return REGION_READ.sub(replace, source), count


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled PowerKeeper smali dir: {root}")

    details = {}
    total = 0

    # Patch explicitly targeted classes
    for rel in TARGET_CLASSES:
        matches = list(root.glob("smali*/" + rel))
        if not matches:
            direct = root / rel
            if direct.is_file():
                matches = [direct]
        if not matches:
            continue
        file = matches[0]
        text = file.read_text(encoding="utf-8", errors="replace")
        patched, count = force_international_true(text)
        if count:
            file.write_text(patched, encoding="utf-8")
            details[rel] = count
            total += count

    # Also scan mqsas and any remaining files in PowerKeeper
    for file in root.rglob("*.smali"):
        rel_str = str(file.relative_to(root))
        if rel_str in details:
            continue
        text = file.read_text(encoding="utf-8", errors="replace")
        if "IS_INTERNATIONAL_BUILD" in text:
            patched, count = force_international_true(text)
            if count:
                file.write_text(patched, encoding="utf-8")
                details[rel_str] = count
                total += count

    return {
        "status": "success",
        "target_apk": "PowerKeeper.apk",
        "gates_replaced": total,
        "patched_files": details,
        "perfhook_omitted": True,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("smali_dir", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.smali_dir)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[POWERKEEPER A17] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit("[POWERKEEPER A17] FAIL: " + str(exc))
