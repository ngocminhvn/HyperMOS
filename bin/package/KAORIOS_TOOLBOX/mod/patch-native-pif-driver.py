#!/usr/bin/env python3
"""Add the MOD-owned native PIF bridge to a disassembled Kaorios driver."""

from __future__ import annotations

import argparse
from pathlib import Path


HOOK_REL = Path("android/security/kaorios/KaoriosHook.smali")
BRIDGE_REL = Path("android/security/ntmanager/PifNative.smali")
METHOD = ".method public static initContext(Landroid/content/Context;)V"
CALL = (
    "    invoke-static {p0}, "
    "Landroid/security/ntmanager/PifNative;->install(Landroid/content/Context;)V\n"
)


def patch(root: Path, template: Path) -> None:
    hook_path = root / HOOK_REL
    bridge_path = root / BRIDGE_REL
    if not hook_path.is_file():
        raise ValueError(f"Kaorios driver missing: {hook_path}")
    if bridge_path.exists():
        raise ValueError(f"native PIF bridge already present: {bridge_path}")

    hook = hook_path.read_text(encoding="utf-8")
    if hook.count(METHOD) != 1:
        raise ValueError("expected exactly one KaoriosHook.initContext")
    if CALL.strip() in hook:
        raise ValueError("native PIF call already present")
    start = hook.index(METHOD)
    end = hook.index(".end method", start)
    body = hook[start:end]
    anchor = "    :try_start_3\n"
    if body.count(anchor) != 1:
        raise ValueError("KaoriosHook.initContext layout changed")
    body = body.replace(anchor, anchor + CALL, 1)
    hook_path.write_text(hook[:start] + body + hook[end:], encoding="utf-8")

    bridge_path.parent.mkdir(parents=True, exist_ok=True)
    bridge_path.write_bytes(template.read_bytes())


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--template", type=Path, required=True)
    args = parser.parse_args()
    patch(args.root, args.template)


if __name__ == "__main__":
    main()
