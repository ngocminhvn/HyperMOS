#!/usr/bin/env python3
"""HyperMOS Circle to Search (MiCTS / Omni) smali patcher for framework and services JARs.

Applies:
- framework.jar: Spoofs Google App (com.google.android.googlequicksearchbox) to Pixel 9 Pro (caiman).
- services.jar: Configures VoiceInteractionManagerServiceStub to route omni.entry_point to Google App (for MiCTS).
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


def locate_files(root: Path, relative_pattern: str) -> list[Path]:
    results = []
    # Check directly
    cand = root / relative_pattern
    if cand.is_file():
        results.append(cand)
    # Check across smali*/ and classes*/
    for prefix in ("smali", "classes"):
        for p in root.glob(f"{prefix}*/{relative_pattern}"):
            if p.is_file() and p not in results:
                results.append(p)
    if not results:
        for p in root.rglob(Path(relative_pattern).name):
            if str(p).endswith(relative_pattern) and p.is_file() and p not in results:
                results.append(p)
    return results


def patch_framework(root: Path) -> bool:
    targets = locate_files(root, "android/app/Instrumentation.smali")
    if not targets:
        print("[CTS][Framework] android/app/Instrumentation.smali not found, skipping")
        return False

    patched_any = False
    for file in targets:
        content = file.read_text(encoding="utf-8")
        if "HyperMOS Native Circle to Search" in content:
            print(f"[CTS][Framework] Already patched: {file}")
            continue

        pattern = r'(\.method public whitelist newApplication\(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;\)Landroid/app/Application;[ \t]*\n)(\s*\.(?:registers|locals)\s+\d+[ \t]*\n)'
        m = re.search(pattern, content)
        if not m:
            print(f"[CTS][Framework] Warning: newApplication signature not found in {file}")
            continue

        hook = (
            '    # HyperMOS Native Circle to Search: spoof Pixel 9 Pro for Google App\n'
            '    if-eqz p3, :cond_cts_skip\n\n'
            '    invoke-virtual {p3}, Landroid/content/Context;->getPackageName()Ljava/lang/String;\n\n'
            '    move-result-object v0\n\n'
            '    const-string v1, "com.google.android.googlequicksearchbox"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :cond_cts_skip\n\n'
            '    const-string v0, "Google"\n\n'
            '    sput-object v0, Landroid/os/Build;->MANUFACTURER:Ljava/lang/String;\n\n'
            '    const-string v0, "google"\n\n'
            '    sput-object v0, Landroid/os/Build;->BRAND:Ljava/lang/String;\n\n'
            '    const-string v0, "Pixel 9 Pro"\n\n'
            '    sput-object v0, Landroid/os/Build;->MODEL:Ljava/lang/String;\n\n'
            '    const-string v0, "caiman"\n\n'
            '    sput-object v0, Landroid/os/Build;->DEVICE:Ljava/lang/String;\n\n'
            '    sput-object v0, Landroid/os/Build;->PRODUCT:Ljava/lang/String;\n\n'
            '    :cond_cts_skip\n'
        )

        replacement = m.group(1) + '    .locals 2\n' + hook
        content = content[:m.start()] + replacement + content[m.end():]
        file.write_text(content, encoding="utf-8")
        print(f"[CTS][Framework] Patched {file}")
        patched_any = True

    return patched_any


def patch_services(root: Path) -> bool:
    patched_any = False

    # 1. VoiceInteractionManagerServiceStub
    stubs = locate_files(root, "com/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali")
    for file in stubs:
        content = file.read_text(encoding="utf-8")
        original = content

        # disableStartingContextualSearchViaVims() -> false (0)
        flags_pattern = r'invoke-static \{\}, Lcom/android/internal/hidden_from_bootclasspath/com/android/server/voiceinteraction/flags/Flags;->disableStartingContextualSearchViaVims\(\)Z\s+move-result\s+([vp]\d+)'
        content = re.sub(flags_pattern, r'const/4 \1, 0x0', content)

        # csKey 0x10402d3 -> "omni.entry_point"
        cskey_pattern = r'const v1, 0x10402d3\s+invoke-virtual \{[vp]\d+, v1\}, Landroid/content/res/Resources;->getString\(I\)Ljava/lang/String;\s+move-result-object [vp]\d+\s+move-object v1, [vp]\d+'
        content = re.sub(cskey_pattern, 'const-string v1, "omni.entry_point"', content)

        # csEnabledKey 0x10402d2 -> "omni.enabled"
        csenabled_pattern = r'const v2, 0x10402d2\s+invoke-virtual \{[vp]\d+, v2\}, Landroid/content/res/Resources;->getString\(I\)Ljava/lang/String;\s+move-result-object [vp]\d+\s+move-object v2, [vp]\d+'
        content = re.sub(csenabled_pattern, 'const-string v2, "omni.enabled"', content)

        # csPkgName in getContextualSearchIntent
        cspkg_pattern = r'const v1, 0x10402d5\s+invoke-virtual \{[vp]\d+, v1\}, Landroid/content/res/Resources;->getString\(I\)Ljava/lang/String;\s+move-result-object v0'
        content = re.sub(cspkg_pattern, 'const-string v0, "com.google.android.googlequicksearchbox"', content)

        # csPkgName in showSessionFromSession
        cspkg2_pattern = r'const v5, 0x10402d5\s+invoke-virtual \{[vp]\d+, v5\}, Landroid/content/res/Resources;->getString\(I\)Ljava/lang/String;\s+move-result-object v0'
        content = re.sub(cspkg2_pattern, 'const-string v0, "com.google.android.googlequicksearchbox"', content)

        if content != original:
            file.write_text(content, encoding="utf-8")
            print(f"[CTS][Services] Patched {file}")
            patched_any = True

    return patched_any


def patch_miui_services(root: Path) -> bool:
    """Gesture triggers for Circle to Search are intentionally omitted; MiCTS runs via VIMS."""
    return False


def main():
    parser = argparse.ArgumentParser(description="Patch smali files for Native Circle to Search")
    parser.add_argument("--component", choices=["framework", "services", "miui-services"], required=True)
    parser.add_argument("--smali-root", type=Path, required=True)
    args = parser.parse_args()

    if not args.smali_root.is_dir():
        print(f"[CTS] Smali root not a directory: {args.smali_root}")
        return

    if args.component == "framework":
        patch_framework(args.smali_root)
    elif args.component == "services":
        patch_services(args.smali_root)
    elif args.component == "miui-services":
        patch_miui_services(args.smali_root)


if __name__ == "__main__":
    main()
