#!/usr/bin/env python3
"""HyperLight AOD Patches for HyperMOS.

Applies patches directly to MiuiAod.apk:
1. LockScreenDepthAvoid:
   Removes the wallpaper depth of field limitation so Depth Effect can remain
   active regardless of how much the lockscreen clock overlaps the wallpaper subject.
   - Forces HierarchyImageAvoidController.isHierarchyEnable -> true
   - Forces WallpaperInfo.getSupportSubject -> true
   - Forces WallpaperController.needResetMagicType -> false
   - Raises DepthAvoidEvaluator$Threshold overlap ceiling from 0.2 (20%) to 1.0 (100%)
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


def patch_depth_avoid_aod(smali_dir: Path) -> bool:
    patched_any = False

    # 1. HierarchyImageAvoidController -> isHierarchyEnable() -> true
    for path in smali_dir.rglob("HierarchyImageAvoidController*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p = re.compile(r"(?ms)^\.method[^\n]*\bisHierarchyEnable\(\)Z.*?^\.end method[ \t]*$")
        if p.search(content):
            rep = (
                ".method public final isHierarchyEnable()Z\n"
                "    .registers 2\n\n"
                "    const/4 v0, 0x1\n\n"
                "    return v0\n"
                ".end method"
            )
            content = p.sub(rep, content)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # 2. WallpaperInfo -> getSupportSubject() -> true
    for path in smali_dir.rglob("WallpaperInfo*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p = re.compile(r"(?ms)^\.method[^\n]*\bgetSupportSubject\(\)Z.*?^\.end method[ \t]*$")
        if p.search(content):
            rep = (
                ".method public final getSupportSubject()Z\n"
                "    .registers 2\n\n"
                "    const/4 v0, 0x1\n\n"
                "    return v0\n"
                ".end method"
            )
            content = p.sub(rep, content)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # 3. WallpaperController -> needResetMagicType() -> false
    for path in smali_dir.rglob("WallpaperController*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        p = re.compile(r"(?ms)^\.method[^\n]*\bneedResetMagicType\(\)Z.*?^\.end method[ \t]*$")
        if p.search(content):
            rep = (
                ".method public final needResetMagicType()Z\n"
                "    .registers 2\n\n"
                "    const/4 v0, 0x0\n\n"
                "    return v0\n"
                ".end method"
            )
            content = p.sub(rep, content)
            path.write_text(content, encoding="utf-8")
            patched_any = True

    # 4. DepthAvoidEvaluator$Threshold -> replace 0.2 (20% overlap limit) with 1.0 (100%)
    for path in smali_dir.rglob("*Threshold*.smali"):
        try:
            content = path.read_text(encoding="utf-8")
        except OSError:
            continue
        # 0x3fc999999999999aL is IEEE 754 for double 0.2
        # 0x3ff0000000000000L is IEEE 754 for double 1.0
        if "0x3fc999999999999aL" in content:
            content = content.replace("0x3fc999999999999aL", "0x3ff0000000000000L")
            path.write_text(content, encoding="utf-8")
            patched_any = True

    return patched_any


def main() -> int:
    cli = argparse.ArgumentParser(description="Patch MiuiAod with HyperLight mods")
    cli.add_argument("--unpacked", type=Path, required=True, help="Path to unpacked AOD APK directory")
    args = cli.parse_args()

    smali_dir = args.unpacked / "smali"
    if not smali_dir.exists():
        print("[HyperLight/AOD] Error: smali directory not found", file=sys.stderr)
        return 1

    if patch_depth_avoid_aod(smali_dir):
        print("[HyperLight/AOD] [1/1] Successfully patched LockScreenDepthAvoid (100% threshold + hierarchy force enable).")
    else:
        print("[HyperLight/AOD] Notice: Depth avoid signatures not found or not applicable on this AOD build.")

    print("[HyperLight/AOD] AOD modification complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
