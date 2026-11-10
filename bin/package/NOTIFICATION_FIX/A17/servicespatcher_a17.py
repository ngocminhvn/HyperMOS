#!/usr/bin/env python3
"""Android 17 services.jar FCM wake patch.

HyperOS can deliver C2DM through GMS while the target package remains stopped.
Match the verified fcm_notification_fix wake vector without adding a runtime
module: add FLAG_INCLUDE_STOPPED_PACKAGES only to C2DM receive broadcasts.
"""
import argparse
import json
import re
from pathlib import Path


BROADCAST_CONTROLLER = "com/android/server/am/BroadcastController.smali"
BROADCAST_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bbroadcastIntentLockedTraced\([^\n]*\)I[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)
INTENT_MOVE = re.compile(
    r"(?m)^([ \t]*)move-object/from16[ \t]+v0,[ \t]+p4[ \t]*$"
)
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
    if PATCH_LABEL in block:
        return source, False

    moves = list(INTENT_MOVE.finditer(block))
    if not moves:
        raise ValueError(
            "BroadcastController: p4 Intent move into v0 not found")
    indent = moves[0].group(1)
    hook = (
        "\n\n"
        f"{indent}invoke-virtual {{v0}}, Landroid/content/Intent;->getAction()Ljava/lang/String;\n\n"
        f"{indent}move-result-object v11\n\n"
        f'{indent}const-string v12, "com.google.android.c2dm.intent.RECEIVE"\n\n'
        f"{indent}invoke-virtual {{v12, v11}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n"
        f"{indent}move-result v11\n\n"
        f"{indent}if-eqz v11, {PATCH_LABEL}\n\n"
        f"{indent}const/16 v11, 0x20\n\n"
        f"{indent}invoke-virtual {{v0, v11}}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;\n\n"
        f"{indent}{PATCH_LABEL}"
    )
    at = moves[0].end()
    block = block[:at] + hook + block[at:]
    output = source[:methods[0].start()] + block + source[methods[0].end():]
    return output, True


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"missing decompiled services.jar: {root}")
    controller = locate(root, BROADCAST_CONTROLLER)
    changed, inserted = patch_broadcast_controller(
        controller.read_text(encoding="utf-8"))
    controller.write_text(changed, encoding="utf-8")
    return {
        "status": "success",
        "target_jar": "services.jar",
        "c2dm_include_stopped_packages": True,
        "hook_inserted": inserted,
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
