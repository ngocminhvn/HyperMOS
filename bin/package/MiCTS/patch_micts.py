#!/usr/bin/env python3
"""HyperMOS MiCTS: patch only the Android 16 native CSHelper path in services.jar.

Port of the *effect* of MiCTS VIMSHooker.GetStringHooker, NOT an Xposed runtime:
- When VoiceInteractionManagerService processes showSessionFromSession(), the
  resource-derived contextual search key becomes "omni.entry_point".
- When its existing getContextualSearchIntent() resolves the target package,
  the resource-derived package becomes "com.google.android.googlequicksearchbox".

The two const-string instructions execute only when those Android methods run.
No hooks, daemons, polling, helper processes, signature bypass or global permission
changes. Fail closed on any unrecognized bytecode shape.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

TARGET_CLASS = "VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali"
KEY = "omni.entry_point"
GOOGLE = "com.google.android.googlequicksearchbox"
MARKER_KEY = "# HyperMOS-MiCTS: native CSHelper key"
MARKER_PKG = "# HyperMOS-MiCTS: native CSHelper package"
GET_STRING = re.compile(
    r"\s*invoke-virtual\s+\{[^}]+\},\s*"
    r"Landroid/content/res/Resources;->getString\(I\)Ljava/lang/String;"
)
MOVE_RESULT = re.compile(r"\s*move-result-object\s+([vp]\d+)\s*$")
ARGS = re.compile(r"\{([^}]*)\}")
METHOD = re.compile(r"^\s*\.method\b.*?\s(?P<name>[A-Za-z0-9_<>]+)\(")
CLASS = "Lcom/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub;"


class PatchError(Exception):
    pass


def method_bounds(lines: list[str], method: str) -> tuple[int, int]:
    found = []
    for i, line in enumerate(lines):
        m = METHOD.match(line)
        if m and m.group("name") == method:
            found.append(i)
    if len(found) != 1:
        raise PatchError(f"{method}: expected one method, found {len(found)}")
    start = found[0]
    for j in range(start + 1, len(lines)):
        if lines[j].strip() == ".end method":
            return start, j
    raise PatchError(f"{method}: missing .end method")


def next_code(lines: list[str], i: int, end: int) -> int:
    for j in range(i + 1, end):
        s = lines[j].strip()
        if s and not s.startswith(("#", ".line", ".local", ".end local", ".restart local")):
            return j
    raise PatchError("Unexpected end of smali method after getString")


def split_regs(line: str) -> list[str]:
    match = ARGS.search(line)
    if not match:
        raise PatchError(f"Expected non-range invoke register list: {line}")
    regs = [r.strip() for r in match.group(1).split(",")]
    if not regs or not all(re.fullmatch(r"[vp]\d+", r) for r in regs):
        raise PatchError(f"Unsupported invoke registers: {line}")
    return regs


def resource_results(lines: list[str], start: int, end: int) -> list[tuple[int, str]]:
    results = []
    for i in range(start + 1, end):
        if GET_STRING.fullmatch(lines[i]):
            next_i = next_code(lines, i, end)
            m = MOVE_RESULT.fullmatch(lines[next_i])
            if not m:
                raise PatchError(f"Resources.getString at {i+1} has no move-result-object")
            results.append((next_i, m.group(1)))
    return results


def unique_invoke(lines: list[str], start: int, end: int, signature: str) -> int:
    matches = [i for i in range(start + 1, end) if signature in lines[i]]
    if len(matches) != 1:
        raise PatchError(f"{signature}: expected one invocation, found {len(matches)}")
    return matches[0]


def inject(lines: list[str], index: int, reg: str, marker: str, value: str) -> bool:
    expected = f'const-string {reg}, "{value}"'
    ahead = [line.strip() for line in lines[index + 1:index + 4]]
    if marker in ahead and expected in ahead:
        return False
    if marker in "\n".join(lines):
        raise PatchError(f"Damaged or misplaced existing patch marker: {marker}")
    lines[index + 1:index + 1] = [
        f"    {marker}",
        f"    {expected}",
    ]
    return True


def patch_key(lines: list[str]) -> bool:
    start, end = method_bounds(lines, "showSessionFromSession")
    block = "\n".join(lines[start:end])
    if "getContextualSearchIntent" not in block:
        raise PatchError("showSessionFromSession has no native CSHelper launch call")
    contains = unique_invoke(
        lines, start, end, "Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z"
    )
    args = split_regs(lines[contains])
    if len(args) != 2:
        raise PatchError("Unsupported Bundle.containsKey invocation")
    key_reg = args[1]
    candidates = [
        (i, reg) for i, reg in resource_results(lines, start, end)
        if i < contains and reg == key_reg
    ]
    if len(candidates) != 1:
        raise PatchError(
            f"CSHelper key register {key_reg}: expected one resource result, "
            f"found {len(candidates)}"
        )
    return inject(lines, candidates[0][0], key_reg, MARKER_KEY, KEY)


def patch_package(lines: list[str]) -> bool:
    start, end = method_bounds(lines, "getContextualSearchIntent")
    empty_i = unique_invoke(lines, start, end, "Ljava/lang/String;->isEmpty()Z")
    package_i = unique_invoke(
        lines, start, end,
        "Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;",
    )
    if empty_i >= package_i:
        raise PatchError("Unexpected Contextual Search package resolution flow")
    empty_regs = split_regs(lines[empty_i])
    package_regs = split_regs(lines[package_i])
    if len(empty_regs) != 1 or len(package_regs) != 2:
        raise PatchError("Unsupported contextual search package invoke signature")
    if empty_regs[0] != package_regs[1]:
        raise PatchError("isEmpty and setPackage do not use the same package register")
    pkg_reg = empty_regs[0]
    candidates = [
        (i, reg) for i, reg in resource_results(lines, start, end)
        if i < empty_i and reg == pkg_reg
    ]
    if len(candidates) != 1:
        raise PatchError(
            f"Contextual Search package register {pkg_reg}: expected one "
            f"resource result, found {len(candidates)}"
        )
    return inject(lines, candidates[0][0], pkg_reg, MARKER_PKG, GOOGLE)


def patch(root: Path) -> tuple[Path, bool, bool]:
    matches = sorted(root.glob("smali*/**/" + TARGET_CLASS))
    if len(matches) != 1:
        raise PatchError(
            f"Expected one {TARGET_CLASS}, found {len(matches)}"
        )
    path = matches[0]
    lines = path.read_text(encoding="utf-8").splitlines()
    classes = [line for line in lines if line.startswith(".class ")]
    if len(classes) != 1 or not classes[0].endswith(CLASS):
        raise PatchError(f"Wrong VoiceInteraction class: {path}")
    key_change = patch_key(lines)
    pkg_change = patch_package(lines)
    rendered = "\n".join(lines) + "\n"
    if rendered.count(MARKER_KEY) != 1 or rendered.count(MARKER_PKG) != 1:
        raise PatchError("Post-patch marker verification failed")
    if key_change or pkg_change:
        path.write_text(rendered, encoding="utf-8")
    return path, key_change, pkg_change


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("decoded", type=Path)
    p.add_argument("--report", type=Path, required=True)
    args = p.parse_args()
    try:
        path, key_change, pkg_change = patch(args.decoded)
    except (PatchError, OSError, UnicodeError) as ex:
        print(f"[MiCTS JAR][ERROR] {ex}", flush=True)
        return 1
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(
        "MiCTS native services.jar DEX patch\n"
        f"smali={path}\n"
        f"CSHelperKey={KEY}\n"
        f"CSHelperPackage={GOOGLE}\n"
        f"key_changed={key_change}\n"
        f"package_changed={pkg_change}\n"
        "patched_apks=none\n"
        "changed_services=none\n"
        "changed_permissions=none\n"
        "daemon=none\n"
        "launcher_long_press_hook=not_included\n",
        encoding="utf-8",
    )
    print(
        f"[MiCTS JAR] native VIMS CSHelper ready, "
        f"key_changed={key_change}, package_changed={pkg_change}",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
