#!/usr/bin/env python3
"""Apply RYU HAOTIAN A16 DeviceIdleControllerStubImpl low-power-Doze flag.

RYU's DeviceIdleControllerStubImpl.<clinit> checks
com.projectryu.Build.IS_RYU_BUILD and writes false to
mIsLowPowerDozeDevice when that flag is true. We reproduce just that
field's final value in the base Xiaomi framework without importing any
RYU classes or changing Android DeviceIdleController.
"""
from pathlib import Path
import re
import sys

CLASS = "Lcom/android/server/DeviceIdleControllerStubImpl;"
FIELD = f"{CLASS}->mIsLowPowerDozeDevice:Z"
METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\s<clinit>\(\)V[ \t]*\n.*?^\.end method[ \t]*$"
)
WRITE = re.compile(
    rf"(?m)^([ \t]*)sput-boolean[ \t]+(v\d+),[ \t]*"
    rf"{re.escape(FIELD)}[ \t]*$"
)


def patch_class(content: str) -> str:
    matches = list(METHOD.finditer(content))
    if len(matches) != 1:
        raise ValueError(
            f"Expected one DeviceIdleControllerStubImpl.<clinit>, got {len(matches)}"
        )
    m = matches[0]
    body = m.group()
    if "Lmiui/os/Build;->" not in body:
        raise ValueError("Unexpected Xiaomi DeviceIdleController static initializer")
    writes = list(WRITE.finditer(body))
    if len(writes) != 1:
        raise ValueError(
            f"Expected one low-power-Doze field assignment in <clinit>, got {len(writes)}"
        )
    assignment = writes[0]
    register = assignment.group(2)
    # const/4 only accepts v0..v15, and reuses the existing field-value
    # register. Never change .locals/.registers or method control flow.
    if not 0 <= int(register[1:]) <= 15:
        raise ValueError(f"Unsupported field assignment register {register}")
    prefix = body[:assignment.start()]
    guard = re.compile(rf"(?:^|\n)[ \t]*const/4[ \t]+{register},[ \t]*0x0[ \t]*\n$")
    if guard.search(prefix):
        return content
    # Insert just after any branch labels and immediately before the unique
    # final field write so both fallthrough and jump-to-write paths use false.
    statement = f"{assignment.group(1)}const/4 {register}, 0x0\n"
    result = body[:assignment.start()] + statement + body[assignment.start():]
    updated = content[:m.start()] + result + content[m.end():]
    if updated.count(FIELD) != content.count(FIELD):
        raise ValueError("Field reference count unexpectedly changed")
    return updated


def main(root: Path) -> None:
    targets = list(root.glob("smali*/com/android/server/DeviceIdleControllerStubImpl.smali"))
    if len(targets) != 1:
        raise ValueError(
            f"Expected exactly one A16 DeviceIdleControllerStubImpl.smali; got {len(targets)}"
        )
    source = targets[0].read_text(encoding="utf-8")
    edited = patch_class(source)
    if patch_class(edited) != edited:
        raise ValueError("RYU Doze patch not idempotent")
    if edited == source:
        print("[RYU-A16-DOZE] Already configured: mIsLowPowerDozeDevice=false")
        return
    targets[0].write_text(edited, encoding="utf-8")
    print("[RYU-A16-DOZE] DeviceIdleControllerStubImpl.mIsLowPowerDozeDevice=false")
    print("[RYU-A16-DOZE] No DeviceIdle service, thermal, PowerKeeper, or projectryu changes")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: ryu_doze_a16.py <decompiled-miui-services-dir>")
        main(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[RYU-A16-DOZE] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
