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
    r"Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)

GMS_OBSERVER = "com/miui/powerkeeper/utils/GmsObserver.smali"

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


def locate(root: Path, relative: str, required=True):
    matches = [path for path in root.glob("smali*/" + relative) if path.is_file()]
    direct = root / relative
    if not matches and direct.is_file():
        matches = [direct]
    if not matches and not required:
        return None
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def method_pattern(signature: str):
    return re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )


def force_boolean_parameter(source: str, signature: str, parameter: str, value: int):
    methods = list(method_pattern(signature).finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()
    registers = re.search(r"(?m)^([ \t]*)\.(?:registers|locals)[ \t]+\d+[ \t]*$", block)
    if not registers:
        raise ValueError(f"{signature}: missing registers declaration")
    instruction = f"{registers.group(1)}const/4 {parameter}, 0x{value:x}"
    following = block[registers.end():]
    already_forced = re.match(
        rf"\s*const/4[ \t]+{re.escape(parameter)},[ \t]+0x{value:x}\b", following)
    if not already_forced:
        at = registers.end()
        block = block[:at] + "\n\n" + instruction + block[at:]
    return source[:methods[0].start()] + block + source[methods[0].end():]


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

    # OS4 moved the old region-gated FCM behavior into a Google-reachability
    # observer. It inverts "reachable" to a Greezer "limit" bit. Keep the old
    # RYU outcome narrowly by forcing only that outgoing notification limit
    # bit false; do not alter sleep mode, alarms, or unrelated power policy.
    gms = locate(root, GMS_OBSERVER)
    gms.write_text(
        force_boolean_parameter(
            gms.read_text(encoding="utf-8"),
            "updateFrameworkGmsNetStatus(Z)Z", "p1", 0),
        encoding="utf-8")
    details[GMS_OBSERVER] = {"gms_network_limit_forced_false": True}
    total += 1

    if total == 0:
        raise ValueError("no Android 17 PowerKeeper gates were patched")

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
