#!/usr/bin/env python3
"""Patch exactly six Android 16 ApplicationPackageManager API entry points.

The transformation is signature-gated and idempotence-rejecting. It never
patches a partial/unknown layout.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

OWNER = "Landroid/app/ApplicationPackageManager;"
FIELD = OWNER + "->mContext:Landroid/app/ContextImpl;"
HELPER = "Landroid/app/TnmAppPrivacy;"
TARGETS = {
    "getInstalledApplicationsAsUser(Landroid/content/pm/PackageManager$ApplicationInfoFlags;I)Ljava/util/List;":
        ("list", "filterApplicationInfoList", 3),
    "getInstalledPackagesAsUser(Landroid/content/pm/PackageManager$PackageInfoFlags;I)Ljava/util/List;":
        ("list", "filterPackageInfoList", 3),
    "getApplicationInfoAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$ApplicationInfoFlags;I)Landroid/content/pm/ApplicationInfo;":
        ("single", "", 4),
    "getPackageInfoAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;I)Landroid/content/pm/PackageInfo;":
        ("single", "", 4),
    "getPackageUidAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;I)I":
        ("single", "", 4),
    "getPackageGids(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;)[I":
        ("single", "", 3),
}
METHOD = re.compile(r"(?ms)^\.method\b[^\n]*\n.*?^\.end method[ \t]*$")
RETURN = re.compile(r"(?m)^([ \t]*)return-object[ \t]+([vp]\d+)[ \t]*$")
REG = re.compile(r"(?m)^([ \t]*)\.(locals|registers)[ \t]+(\d+)[ \t]*$")
OPCODE = re.compile(
    r"(?m)^[ \t]*(?:invoke-|move|iget-|const|if-|new-|return|throw|"
    r"check-cast|sget-|aput-|aget-|goto|monitor-|instance-of|array-length)"
)


def add_locals(method: str, params: int) -> tuple[str, int]:
    match = REG.search(method)
    if not match:
        raise RuntimeError("method lacks .locals/.registers")
    old = int(match.group(3))
    if match.group(2) == "locals":
        return (method[:match.start()] + f"{match.group(1)}.locals {old + 2}" +
                method[match.end():], old)
    if old < params:
        raise RuntimeError("invalid .registers count")
    local_base = old - params
    # Growing .registers moves p-register aliases. Rewrite aliases first.
    for index in range(params):
        method = re.sub(rf"(?<![A-Za-z0-9_])v{local_base + index}\b", f"p{index}", method)
    match = REG.search(method)
    assert match
    return (method[:match.start()] + f"{match.group(1)}.registers {old + 2}" +
            method[match.end():], local_base)


def patch_method(method: str, kind: str, callback: str, params: int) -> str:
    if HELPER in method or "ProjectRYUHook;->" in method:
        raise RuntimeError("existing package-visibility hook in target method")
    modified, scratch = add_locals(method, params)
    first, second = f"v{scratch}", f"v{scratch + 1}"
    if kind == "list":
        if not RETURN.search(modified):
            raise RuntimeError("list method has no return-object")

        def inject(match: re.Match[str]) -> str:
            indent, result = match.group(1), match.group(2)
            return (
                f"{indent}iget-object {first}, p0, {FIELD}\n"
                f"{indent}move-object/from16 {second}, {result}\n"
                f"{indent}invoke-static/range {{{first} .. {second}}}, {HELPER}->{callback}"
                "(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;\n"
                f"{indent}move-result-object {result}\n"
                f"{indent}return-object {result}"
            )

        return RETURN.sub(inject, modified)
    marker = ":tnm_app_privacy_continue"
    reg = REG.search(modified)
    code = OPCODE.search(modified, reg.end() if reg else 0)
    if code is None:
        raise RuntimeError("single-package method has no opcode anchor")
    injection = (
        f"    iget-object {first}, p0, {FIELD}\n"
        f"    move-object/from16 {second}, p1\n"
        f"    invoke-static/range {{{first} .. {second}}}, {HELPER}->shouldHide"
        "(Landroid/content/Context;Ljava/lang/String;)Z\n"
        f"    move-result {first}\n"
        f"    if-eqz {first}, {marker}\n"
        f"    new-instance {first}, Landroid/content/pm/PackageManager$NameNotFoundException;\n"
        f"    invoke-direct/range {{{first} .. {second}}}, "
        "Landroid/content/pm/PackageManager$NameNotFoundException;-><init>(Ljava/lang/String;)V\n"
        f"    throw {first}\n"
        f"    {marker}\n"
    )
    return modified[:code.start()] + injection + modified[code.start():]


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: patch_app_privacy.py ApplicationPackageManager.smali")
    path = Path(sys.argv[1])
    original = path.read_text(encoding="utf-8")
    if f".class public {OWNER}" not in original:
        raise RuntimeError("input is not ApplicationPackageManager")
    counts = {signature: 0 for signature in TARGETS}

    def replace(match: re.Match[str]) -> str:
        method = match.group()
        header = method.splitlines()[0]
        found = [signature for signature in TARGETS if " " + signature in header]
        if not found:
            return method
        if len(found) != 1:
            raise RuntimeError(f"ambiguous overload: {header}")
        signature = found[0]
        counts[signature] += 1
        return patch_method(method, *TARGETS[signature])

    patched = METHOD.sub(replace, original)
    invalid = {signature: count for signature, count in counts.items() if count != 1}
    if invalid:
        raise RuntimeError(f"unsupported Android 16 layout: {invalid}")
    if patched.count(HELPER) < 6:
        raise RuntimeError("hook insertion verification failed")
    path.write_text(patched, encoding="utf-8")
    print("[TNM APP PRIVACY] patched six verified ApplicationPackageManager methods")


if __name__ == "__main__":
    main()
