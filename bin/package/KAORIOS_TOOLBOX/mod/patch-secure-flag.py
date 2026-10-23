#!/usr/bin/env python3
"""Apply or verify MOD-local permanent FLAG_SECURE bypasses."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Target:
    relative_class: str
    signature: str
    static_return: tuple[str, ...]


SERVICES_REQUIRED_TARGETS = (
    Target(
        "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali",
        "isScreenCaptureAllowed(I)Z",
        ("const/4 v0, 0x1", "return v0"),
    ),
    Target(
        "com/android/server/wm/WindowState.smali",
        "isSecureLocked()Z",
        ("const/4 v0, 0x0", "return v0"),
    ),
    Target(
        "com/android/server/wm/WindowState.smali",
        "setSecureLocked(Z)V",
        ("return-void",),
    ),
    Target(
        "com/android/server/wm/WindowStateAnimator.smali",
        "isSecureLocked()Z",
        ("const/4 v0, 0x0", "return v0"),
    ),
    Target(
        "com/android/server/wm/WindowStateAnimator.smali",
        "setSecureLocked(Z)V",
        ("return-void",),
    ),
)

# Android 13 used additional setters/getters. They are optional because newer
# releases removed or relocated them, but when present they must use the same
# build-time switch instead of keeping a second implementation in CorePatch.
SERVICES_OPTIONAL_TARGETS = (
    Target(
        "com/android/server/devicepolicy/DevicePolicyManagerService.smali",
        "getScreenCaptureDisabled(Landroid/content/ComponentName;IZ)Z",
        ("const/4 v0, 0x0", "return v0"),
    ),
    Target(
        "com/android/server/devicepolicy/DevicePolicyManagerService.smali",
        "setScreenCaptureDisabled(I)V",
        ("return-void",),
    ),
    Target(
        "com/android/server/wm/WindowState.smali",
        "setSecure(Z)V",
        ("return-void",),
    ),
    Target(
        "com/android/server/wm/WindowSurfaceController.smali",
        "setSecure(Z)V",
        ("return-void",),
    ),
)

MIUI_SERVICES_TARGETS = (
    Target(
        "com/android/server/wm/WindowManagerServiceImpl.smali",
        "notAllowCaptureDisplay(Lcom/android/server/wm/RootWindowContainer;I)Z",
        ("const/4 v0, 0x0", "return v0"),
    ),
)

# Backward-compatible alias used by existing tests and external callers.
TARGETS = SERVICES_REQUIRED_TARGETS


class PatchError(RuntimeError):
    pass


def find_unique(root: Path, relative: str) -> Path | None:
    matches = [path for path in root.rglob(Path(relative).name) if path.as_posix().endswith(relative)]
    if len(matches) > 1:
        raise PatchError(f"expected at most one {relative}, found {len(matches)}")
    return matches[0] if matches else None


def method_span(text: str, signature: str) -> tuple[int, int]:
    header = re.compile(rf"(?m)^\.method[^\n]*\s{re.escape(signature)}[ \t]*$")
    matches = list(header.finditer(text))
    if len(matches) != 1:
        raise PatchError(f"expected exactly one method {signature}, found {len(matches)}")
    end = text.find("\n.end method", matches[0].end())
    if end < 0:
        raise PatchError(f"unterminated method {signature}")
    return matches[0].start(), end + len("\n.end method")


def body_offset(block: str, signature: str) -> int:
    lines = block.splitlines(keepends=True)
    register_index = next(
        (index for index, line in enumerate(lines) if re.match(r"\s*\.(?:registers|locals)\s+", line)),
        None,
    )
    if register_index is None:
        raise PatchError(f"{signature}: missing .registers/.locals")

    annotation_depth = 0
    for index in range(register_index + 1, len(lines)):
        stripped = lines[index].strip()
        if stripped.startswith(".annotation") or stripped.startswith(".subannotation"):
            annotation_depth += 1
            continue
        if stripped.startswith(".end annotation") or stripped.startswith(".end subannotation"):
            annotation_depth -= 1
            continue
        if annotation_depth:
            continue
        if not stripped or stripped.startswith("#") or stripped.startswith("."):
            continue
        return sum(len(line) for line in lines[:index])
    raise PatchError(f"{signature}: no original instruction/label found")


def parameter_slots(signature: str, is_static: bool) -> int:
    descriptor = signature[signature.index("(") + 1 : signature.index(")")]
    slots = 0
    index = 0
    while index < len(descriptor):
        char = descriptor[index]
        if char in "JD":
            slots += 2
            index += 1
        elif char == "L":
            slots += 1
            index = descriptor.index(";", index) + 1
        elif char == "[":
            slots += 1
            index += 1
            while descriptor[index] == "[":
                index += 1
            index = descriptor.index(";", index) + 1 if descriptor[index] == "L" else index + 1
        else:
            slots += 1
            index += 1
    return slots if is_static else slots + 1


def static_method(block: str, target: Target) -> str:
    offset = body_offset(block, target.signature)
    prefix = block[:offset]
    if any("v0" in line for line in target.static_return):
        register = re.search(r"(?m)^([ \t]*)\.(locals|registers)[ \t]+(\d+)[ \t]*$", prefix)
        if register is None:
            raise PatchError(f"{target.signature}: missing .registers/.locals")
        count = int(register.group(3), 0)
        if register.group(2) == "locals":
            required = max(count, 1)
        else:
            header = block.splitlines()[0]
            required = max(count, parameter_slots(target.signature, " static " in f" {header} ") + 1)
        replacement = f"{register.group(1)}.{register.group(2)} {required}"
        prefix = prefix[: register.start()] + replacement + prefix[register.end() :]
    body = "".join(f"    {line}\n" for line in target.static_return)
    return prefix + body + ".end method"


def executable_instructions(block: str) -> tuple[str, ...]:
    """Return opcodes while ignoring baksmali's non-semantic metadata.

    A smali assemble/disassemble round trip may move ``.line``, ``.param`` and
    annotation directives between otherwise identical instructions. Final
    artifact verification must validate the bypass behavior, not require the
    regenerated text to match our pre-assembly text byte for byte.
    """
    instructions = []
    annotation_depth = 0
    for line in block.splitlines()[1:]:
        stripped = line.strip()
        if stripped.startswith((".annotation", ".subannotation")):
            annotation_depth += 1
            continue
        if stripped.startswith((".end annotation", ".end subannotation")):
            annotation_depth = max(0, annotation_depth - 1)
            continue
        if annotation_depth or not stripped:
            continue
        if stripped.startswith(("#", ".", ":")):
            continue
        instructions.append(stripped)
    return tuple(instructions)


def has_static_return(block: str, target: Target) -> bool:
    return executable_instructions(block) == target.static_return


def patch_target(path: Path, target: Target, check_only: bool) -> bool:
    text = path.read_text(encoding="utf-8")
    start, end = method_span(text, target.signature)
    block = text[start:end]
    if has_static_return(block, target):
        return False
    if check_only:
        raise PatchError(f"{path}: missing permanent bypass in {target.signature}")
    desired = static_method(block, target)
    path.write_text(text[:start] + desired + text[end:], encoding="utf-8")
    return True


def patch_if_supported(root: Path, target: Target, check_only: bool) -> bool:
    path = find_unique(root, target.relative_class)
    if path is None:
        return False
    try:
        changed = patch_target(path, target, check_only)
    except PatchError as exc:
        if "expected exactly one method" in str(exc) and "found 0" in str(exc):
            return False
        raise
    if changed:
        print(f"KAORIOS: statically patched {target.signature} in {path.name}")
    return True


def run_services(root: Path, check_only: bool) -> int:
    device_policy = find_unique(root, SERVICES_REQUIRED_TARGETS[0].relative_class)
    if device_policy is None:
        raise PatchError("DevicePolicyCacheImpl.smali not found")
    patch_target(device_policy, SERVICES_REQUIRED_TARGETS[0], check_only)

    window_patched = 0
    for target in SERVICES_REQUIRED_TARGETS[1:]:
        if patch_if_supported(root, target, check_only):
            window_patched += 1
    if window_patched == 0:
        raise PatchError("no supported WindowState/WindowStateAnimator secure method found")

    optional_patched = 0
    for target in SERVICES_OPTIONAL_TARGETS:
        if patch_if_supported(root, target, check_only):
            optional_patched += 1
    if optional_patched:
        print(f"KAORIOS: verified {optional_patched} optional Android 13 Secure Flag bypasses")
    print("KAORIOS: static Secure Flag bypasses verified" if check_only else "KAORIOS: static Secure Flag bypasses applied")
    return 0


def run_miui_services(root: Path, check_only: bool) -> int:
    target = MIUI_SERVICES_TARGETS[0]
    path = find_unique(root, target.relative_class)
    if path is None:
        raise PatchError("WindowManagerServiceImpl.smali not found in miui-services")
    patch_target(path, target, check_only)
    print(
        "KAORIOS: Xiaomi static Secure Flag bypass verified"
        if check_only
        else "KAORIOS: Xiaomi static Secure Flag bypass applied"
    )
    return 0


def run(root: Path, check_only: bool, archive: str = "services") -> int:
    if archive == "services":
        return run_services(root, check_only)
    if archive == "miui-services":
        return run_miui_services(root, check_only)
    raise PatchError(f"unsupported archive kind: {archive}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--check-only", action="store_true")
    parser.add_argument("--archive", choices=("services", "miui-services"), default="services")
    args = parser.parse_args()
    try:
        return run(args.root, args.check_only, args.archive)
    except (OSError, PatchError, ValueError) as exc:
        print(f"KAORIOS: Secure Flag patch failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
