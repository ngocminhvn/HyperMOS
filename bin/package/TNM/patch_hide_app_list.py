#!/usr/bin/env python3
"""Strict Android 16 PackageManager client call-site patch (TNM Hide App List).

Fails rather than making a partial ROM patch if the method layout changes.
The helper class is intentionally independent from RYU/Kaorios/Keybox.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

OWNER = "Landroid/app/ApplicationPackageManager;"
FIELD = OWNER + "->mContext:Landroid/app/ContextImpl;"
HELPER = "Landroid/app/TnmHideAppList;"

# Android 16 RYU reference: the long-flag overloads (short overloads delegate to them).
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
        raise RuntimeError("Missing .locals/.registers in method")
    old = int(match.group(3))
    kind = match.group(2)
    if kind == "locals":
        local_base = old
        return method[:match.start()] + (
            f"{match.group(1)}.locals {old+2}"
        ) + method[match.end():], local_base
    if old < params:
        raise RuntimeError("Invalid .registers count")
    local_base = old - params
    # Before enlarging .registers, detach any v-register aliases of old p-registers.
    # This is necessary: growing .registers otherwise silently changes p0/p1 meanings.
    for i in range(params):
        number = local_base + i
        method = re.sub(rf"(?<![A-Za-z0-9_])v{number}\b", f"p{i}", method)
    match = REG.search(method)
    return method[:match.start()] + (
        f"{match.group(1)}.registers {old+2}"
    ) + method[match.end():], local_base


def patch_method(method: str, kind: str, callback: str, params: int) -> str:
    if HELPER in method:
        raise RuntimeError("TNM hook already present in a method (refusing duplicate)")
    modified, scratch = add_locals(method, params)
    a, b = f"v{scratch}", f"v{scratch+1}"
    if kind == "list":
        returns = list(RETURN.finditer(modified))
        if not returns:
            raise RuntimeError("List API has no return-object target")
        def inject(m: re.Match[str]) -> str:
            result = m.group(2)
            indent = m.group(1)
            return (
                f"{indent}iget-object {a}, p0, {FIELD}\n"
                f"{indent}move-object/from16 {b}, {result}\n"
                f"{indent}invoke-static/range {{{a} .. {b}}}, {HELPER}->{callback}"
                "(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;\n"
                f"{indent}move-result-object {result}\n"
                f"{indent}return-object {result}"
            )
        return RETURN.sub(inject, modified)
    if kind != "single":
        raise RuntimeError("Invalid patch kind")
    marker = ":tnm_hide_app_list_continue"
    if marker in modified:
        raise RuntimeError("Duplicate branch marker")
    # Insert before first real opcode, *after* .param and .annotation metadata.
    reg = REG.search(modified)
    assert reg is not None
    code = OPCODE.search(modified, reg.end())
    if code is None:
        raise RuntimeError("No method opcode anchor")
    injection = (
        f"    iget-object {a}, p0, {FIELD}\n"
        f"    move-object/from16 {b}, p1\n"
        f"    invoke-static/range {{{a} .. {b}}}, {HELPER}->shouldHide"
        "(Landroid/content/Context;Ljava/lang/String;)Z\n"
        f"    move-result {a}\n"
        f"    if-eqz {a}, {marker}\n"
        f"    new-instance {a}, Landroid/content/pm/PackageManager$NameNotFoundException;\n"
        f"    invoke-direct/range {{{a} .. {b}}}, "
        "Landroid/content/pm/PackageManager$NameNotFoundException;-><init>(Ljava/lang/String;)V\n"
        f"    throw {a}\n"
        f"    {marker}\n"
    )
    return modified[:code.start()] + injection + modified[code.start():]


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: patch_hide_app_list.py ApplicationPackageManager.smali")
    file = Path(sys.argv[1])
    original = file.read_text(encoding="utf-8")
    if OWNER not in original:
        raise RuntimeError("Not ApplicationPackageManager")
    count = {key: 0 for key in TARGETS}
    def replace(match: re.Match[str]) -> str:
        method = match.group()
        head = method.splitlines()[0]
        targets = [key for key in TARGETS if (" " + key) in head]
        if not targets:
            return method
        if len(targets) != 1:
            raise RuntimeError("Ambiguous overload: " + head)
        key = targets[0]
        count[key] += 1
        kind, cb, params = TARGETS[key]
        return patch_method(method, kind, cb, params)
    patched = METHOD.sub(replace, original)
    failures = {k: n for k, n in count.items() if n != 1}
    if failures:
        raise RuntimeError(f"Missing/duplicated Android 16 anchors: {failures}")
    if patched == original or patched.count(HELPER) < 10:
        raise RuntimeError("TNM hook insertion was ineffective")
    file.write_text(patched, encoding="utf-8")
    print("[TNM HIDE APP LIST] patched 6 APM methods")


if __name__ == "__main__":
    main()
