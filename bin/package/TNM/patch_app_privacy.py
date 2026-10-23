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
    # Reject competing visibility hooks by behavior, not by donor/vendor name.
    known_visibility_hooks = (
        "->shouldHideAppList(",
        "->filterApplicationInfoList(",
        "->filterPackageInfoList(",
    )
    if HELPER in method or any(hook in method for hook in known_visibility_hooks):
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


def has_single_hide_guard(method: str) -> bool:
    """Verify the actual guard instructions after DEX round-trip.

    Baksmali regenerates label names (for example :cond_0), so the
    source-only :tnm_app_privacy_continue name must not be required.
    """
    body = []
    for raw in method.splitlines():
        line = raw.partition("#")[0].strip()
        if line and (line.startswith(":") or not line.startswith(".")):
            body.append(line)

    signature = f"{HELPER}->shouldHide(Landroid/content/Context;Ljava/lang/String;)Z"
    calls = [i for i, insn in enumerate(body) if signature in insn]
    if len(calls) != 1:
        return False
    pos = calls[0]
    if pos < 2 or pos + 6 >= len(body):
        return False

    context = re.fullmatch(
        rf"iget-object\s+(v\d+),\s*p0,\s*{re.escape(FIELD)}", body[pos - 2]
    )
    name = re.fullmatch(r"move-object/from16\s+(v\d+),\s*p1", body[pos - 1])
    invocation = re.fullmatch(
        rf"invoke-static/range\s+\{{(v\d+)\s*\.\.\s*(v\d+)\}},\s*{re.escape(signature)}",
        body[pos],
    )
    if not context or not name or not invocation:
        return False
    context_reg, name_reg = context.group(1), name.group(1)
    if invocation.groups() != (context_reg, name_reg):
        return False

    exception = "Landroid/content/pm/PackageManager$NameNotFoundException;"
    result = re.fullmatch(r"move-result\s+(v\d+)", body[pos + 1])
    branch = re.fullmatch(r"if-eqz\s+(v\d+),\s*(:[\w$-]+)", body[pos + 2])
    allocation = re.fullmatch(
        rf"new-instance\s+(v\d+),\s*{re.escape(exception)}", body[pos + 3]
    )
    constructor = re.fullmatch(
        rf"invoke-direct/range\s+\{{(v\d+)\s*\.\.\s*(v\d+)\}},\s*"
        rf"{re.escape(exception)}-><init>\(Ljava/lang/String;\)V",
        body[pos + 4],
    )
    thrown = re.fullmatch(r"throw\s+(v\d+)", body[pos + 5])
    if not (result and branch and allocation and constructor and thrown):
        return False

    # Several labels may point to the same instruction after disassembly.
    labels = []
    for line in body[pos + 6:]:
        if not line.startswith(":"):
            break
        labels.append(line)
    return (
        result.group(1) == context_reg == branch.group(1)
        == allocation.group(1) == thrown.group(1)
        and constructor.groups() == (context_reg, name_reg)
        and branch.group(2) in labels
    )


def verify(apm_file: Path, helper_file: Path) -> None:
    apm = apm_file.read_text(encoding="utf-8")
    helper = helper_file.read_text(encoding="utf-8")
    if f".class public {OWNER}" not in apm:
        raise ValueError("ApplicationPackageManager class does not match")
    if ".class public final Landroid/app/TnmAppPrivacy;" not in helper:
        raise ValueError("TNM helper class does not match")

    for name, params in {
        "shouldHide": "(Landroid/content/Context;Ljava/lang/String;)Z",
        "filterPackageInfoList": "(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;",
        "filterApplicationInfoList": "(Landroid/content/Context;Ljava/util/List;)Ljava/util/List;",
    }.items():
        if f".method public static {name}{params}" not in helper:
            raise ValueError(f"TNM helper missing method: {name}")

    methods = METHOD.findall(apm)
    for signature, (kind, callback, _) in TARGETS.items():
        found = [m for m in methods if " " + signature in m.splitlines()[0]]
        if len(found) != 1:
            raise ValueError(f"Expected one APM method {signature}; found {len(found)}")
        method = found[0]
        expected = callback if kind == "list" else "shouldHide"
        if f"{HELPER}->{expected}(" not in method:
            raise ValueError(f"TNM hook missing in method {signature}")
        if kind == "single" and not has_single_hide_guard(method):
            raise ValueError(f"TNM hide guard incomplete: {signature}")
    print("[TNM APP PRIVACY] verified six APM call sites and helper in staged DEX")

if __name__ == "__main__":
    if len(sys.argv) == 4 and sys.argv[1] == "--verify":
        try:
            verify(Path(sys.argv[2]), Path(sys.argv[3]))
        except (OSError, ValueError) as exc:
            raise SystemExit(f"TNM App Privacy verification failed: {exc}")
    else:
        main()
