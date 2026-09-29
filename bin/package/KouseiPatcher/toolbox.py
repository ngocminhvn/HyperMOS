#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path


HOOK = "Landroid/security/kaorios/KaoriosHook;"

SIG_INSTR_STATIC = "newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;"
SIG_INSTR_INSTANCE = "newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;"
SIG_FEATURE = "hasSystemFeature(Ljava/lang/String;I)Z"
SIG_KEYPAIR = "generateKeyPair()Ljava/security/KeyPair;"
SIG_CHAIN = "engineGetCertificateChain(Ljava/lang/String;)[Ljava/security/cert/Certificate;"
SIG_DEV = "getStringForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;"
SIG_SYSTEMSERVER = "run()V"

TARGETS = {
    "instrumentation": "android/app/Instrumentation.smali",
    "package_manager": "android/app/ApplicationPackageManager.smali",
    "keypair": "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali",
    "keystore": "android/security/keystore2/AndroidKeyStoreSpi.smali",
    "settings": "android/provider/Settings$NameValueCache.smali",
    "system_server": "com/android/server/SystemServer.smali",
}


class PatchError(RuntimeError):
    pass


def read_text(path: Path) -> str:
    return path.read_bytes().decode("utf-8")


def write_text(path: Path, text: str) -> None:
    path.write_bytes(text.encode("utf-8"))


def find_one(root: Path, relative_path: str) -> Path:
    rel = Path(relative_path)
    matches = [p for p in root.rglob(rel.name) if str(p).replace("\\", "/").endswith(relative_path)]
    if len(matches) != 1:
        raise PatchError(f"expected exactly one {relative_path}; found {len(matches)}")
    return matches[0]


def method_span(text: str, signature: str) -> tuple[int, int]:
    rx = re.compile(
        r"(?m)^\.method[^\r\n]*" + re.escape(signature) + r"[^\r\n]*(?:\r?\n|$)"
    )
    matches = list(rx.finditer(text))
    if len(matches) != 1:
        raise PatchError(f"expected exactly one method {signature}; found {len(matches)}")

    end = re.search(
        r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)",
        text[matches[0].end():],
    )
    if end is None:
        raise PatchError(f"unterminated method {signature}")

    return matches[0].start(), matches[0].end() + end.end()


def method_body(text: str, signature: str) -> str:
    start, end = method_span(text, signature)
    return text[start:end]


def replace_method(text: str, signature: str, new_method: str) -> str:
    start, end = method_span(text, signature)
    return text[:start] + new_method + text[end:]


def unique_label(base: str, body: str) -> str:
    label = base
    n = 1
    while re.search(rf"(?m)^\s*{re.escape(label)}\s*$", body):
        label = f"{base}_{n}"
        n += 1
    return label


def directive_info(body: str) -> tuple[str, int, re.Match[str]]:
    m = re.search(r"(?m)^(?P<indent>[ \t]*)\.(?P<kind>locals|registers)[ \t]+(?P<num>\d+)[^\r\n]*(?:\r?\n|$)", body)
    if not m:
        raise PatchError("method has no .locals/.registers directive")
    return m.group("kind"), int(m.group("num")), m


def canonicalize_param_aliases(body: str, registers: int, param_count: int) -> str:
    first_param_v = registers - param_count
    if first_param_v < 0:
        raise PatchError(f".registers {registers} smaller than parameter width {param_count}")
    for p_idx in range(param_count - 1, -1, -1):
        body = re.sub(
            rf"(?<![A-Za-z0-9_])v{first_param_v + p_idx}(?![0-9])",
            f"p{p_idx}",
            body,
        )
    return body


def grow_one_local(body: str, param_count: int) -> tuple[str, str, int]:
    kind, count, m = directive_info(body)
    newline = "\r\n" if "\r\n" in body else "\n"

    if kind == "locals":
        scratch_num = count
        replacement = f"{m.group('indent')}.locals {count + 1}{newline}"
        body = body[:m.start()] + replacement + body[m.end():]
        return body, f"v{scratch_num}", scratch_num

    old_registers = count
    old_locals = old_registers - param_count
    if old_locals < 0:
        raise PatchError(f".registers {old_registers} smaller than parameter width {param_count}")

    body = canonicalize_param_aliases(body, old_registers, param_count)
    _, _, m2 = directive_info(body)
    replacement = f"{m2.group('indent')}.locals {old_locals + 1}{newline}"
    body = body[:m2.start()] + replacement + body[m2.end():]
    return body, f"v{old_locals}", old_locals


def param_physical_index(body: str, param_count: int, p_index: int) -> int:
    kind, count, _ = directive_info(body)
    if kind == "locals":
        return count + p_index
    return count - param_count + p_index


def code_insertion_offset(body: str) -> int:
    lines = body.splitlines(keepends=True)
    in_annotation = False
    last_header = 0

    for i, line in enumerate(lines):
        s = line.strip()
        if not s:
            continue
        if s.startswith(".method"):
            last_header = i + 1
            continue
        if s.startswith(".locals") or s.startswith(".registers") or s.startswith(".param"):
            last_header = i + 1
            continue
        if s.startswith(".annotation"):
            in_annotation = True
            last_header = i + 1
            continue
        if in_annotation:
            last_header = i + 1
            if s.startswith(".end annotation"):
                in_annotation = False
            continue
        break

    return sum(len(lines[i]) for i in range(last_header))


def invoke_one(reg: str, physical: int, target: str, opcode: str = "invoke-static") -> str:
    if physical > 15:
        return f"{opcode}/range {{{reg} .. {reg}}}, {target}"
    return f"{opcode} {{{reg}}}, {target}"


def patch_instrumentation(text: str) -> str:
    configs = [
        (SIG_INSTR_STATIC, "p1", 2),
        (SIG_INSTR_INSTANCE, "p3", 4),
    ]

    for signature, context_reg, param_count in configs:
        body = method_body(text, signature)
        hook_target = HOOK + "->initContext(Landroid/content/Context;)V"
        return_matches = list(re.finditer(r"(?m)^(?P<indent>[ \t]*)return-object\s+[vp]\d+[ \t]*(?:\r?\n|$)", body))
        if not return_matches:
            raise PatchError(f"{signature}: return-object not found")

        hook_count = body.count(hook_target)
        if hook_count == len(return_matches):
            continue
        if hook_count != 0:
            raise PatchError(f"{signature}: partial/duplicate initContext hooks ({hook_count})")

        physical = param_physical_index(body, param_count, int(context_reg[1:]))
        call = invoke_one(context_reg, physical, hook_target)

        patched = body
        for m in reversed(return_matches):
            newline = "\r\n" if "\r\n" in m.group(0) else "\n"
            inject = f"{m.group('indent')}{call}{newline}{newline}"
            patched = patched[:m.start()] + inject + patched[m.start():]

        text = replace_method(text, signature, patched)

    return text


def verify_instrumentation(text: str) -> None:
    for signature in (SIG_INSTR_STATIC, SIG_INSTR_INSTANCE):
        body = method_body(text, signature)
        returns = len(re.findall(r"(?m)^[ \t]*return-object\s+[vp]\d+", body))
        hooks = body.count(HOOK + "->initContext(Landroid/content/Context;)V")
        if returns < 1 or hooks != returns:
            raise PatchError(f"{signature}: expected {returns} initContext hooks, found {hooks}")


def patch_feature(text: str) -> str:
    body = method_body(text, SIG_FEATURE)
    target = HOOK + "->hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;"
    count = body.count(target)
    if count == 1:
        return text
    if count != 0:
        raise PatchError(f"{SIG_FEATURE}: duplicate hasSystemFeature hook")

    body, scratch, scratch_num = grow_one_local(body, 3)
    label = unique_label(":cond_kaorios_feature_stock", body)
    p1_phys = param_physical_index(body, 3, 1)
    p2_phys = param_physical_index(body, 3, 2)

    if p1_phys > 15 or p2_phys > 15:
        call = f"invoke-static/range {{p1 .. p2}}, {target}"
    else:
        call = f"invoke-static {{p1, p2}}, {target}"

    bool_target = "Ljava/lang/Boolean;->booleanValue()Z"
    if scratch_num > 15:
        bool_call = f"invoke-virtual/range {{{scratch} .. {scratch}}}, {bool_target}"
    else:
        bool_call = f"invoke-virtual {{{scratch}}}, {bool_target}"

    newline = "\r\n" if "\r\n" in body else "\n"
    inject = (
        f"    {call}{newline}"
        f"    move-result-object {scratch}{newline}"
        f"    if-eqz {scratch}, {label}{newline}"
        f"    {bool_call}{newline}"
        f"    move-result {scratch}{newline}"
        f"    return {scratch}{newline}"
        f"{newline}"
        f"    {label}{newline}"
    )
    off = code_insertion_offset(body)
    body = body[:off] + inject + body[off:]
    return replace_method(text, SIG_FEATURE, body)


def verify_feature(text: str) -> None:
    body = method_body(text, SIG_FEATURE)
    count = body.count(HOOK + "->hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;")
    if count != 1:
        raise PatchError(f"{SIG_FEATURE}: expected one hasSystemFeature hook, found {count}")


def patch_keypair(text: str) -> str:
    body = method_body(text, SIG_KEYPAIR)
    target = HOOK + "->initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;"
    count = body.count(target)
    if count == 1:
        return text
    if count != 0:
        raise PatchError(f"{SIG_KEYPAIR}: duplicate keypair hook")

    body, scratch, _ = grow_one_local(body, 1)
    label = unique_label(":cond_kaorios_gen_stock", body)
    p0_phys = param_physical_index(body, 1, 0)
    call = invoke_one("p0", p0_phys, target)

    newline = "\r\n" if "\r\n" in body else "\n"
    inject = (
        f"    {call}{newline}"
        f"    move-result-object {scratch}{newline}"
        f"    if-eqz {scratch}, {label}{newline}"
        f"    return-object {scratch}{newline}"
        f"{newline}"
        f"    {label}{newline}"
    )
    off = code_insertion_offset(body)
    body = body[:off] + inject + body[off:]
    return replace_method(text, SIG_KEYPAIR, body)


def verify_keypair(text: str) -> None:
    body = method_body(text, SIG_KEYPAIR)
    count = body.count(HOOK + "->initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;")
    if count != 1:
        raise PatchError(f"{SIG_KEYPAIR}: expected one keypair hook, found {count}")


def patch_chain(text: str) -> str:
    body = method_body(text, SIG_CHAIN)
    target = HOOK + "->CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;"
    return_matches = list(re.finditer(r"(?m)^(?P<indent>[ \t]*)return-object\s+(?P<reg>[vp]\d+)[ \t]*(?:\r?\n|$)", body))
    if not return_matches:
        raise PatchError(f"{SIG_CHAIN}: no return-object")

    count = body.count(target)
    if count == len(return_matches):
        return text
    if count != 0:
        raise PatchError(f"{SIG_CHAIN}: partial/duplicate certificate hooks ({count})")

    patched = body
    for ret in reversed(return_matches):
        prefix = patched[:ret.start()]
        aputs = list(re.finditer(r"aput-object\s+[vp]\d+,\s*(?P<arr>[vp]\d+),\s*[vp]\d+", prefix))
        if not aputs:
            raise PatchError(f"{SIG_CHAIN}: no aput-object before return {ret.group('reg')}")
        arr = aputs[-1].group("arr")
        if arr != ret.group("reg"):
            raise PatchError(
                f"{SIG_CHAIN}: last certificate array {arr} does not match returned {ret.group('reg')}"
            )
        num = int(arr[1:])
        call = invoke_one(arr, num, target)
        newline = "\r\n" if "\r\n" in ret.group(0) else "\n"
        inject = (
            f"{ret.group('indent')}{call}{newline}"
            f"{ret.group('indent')}move-result-object {arr}{newline}"
        )
        patched = patched[:ret.start()] + inject + patched[ret.start():]

    return replace_method(text, SIG_CHAIN, patched)


def verify_chain(text: str) -> None:
    body = method_body(text, SIG_CHAIN)
    returns = len(re.findall(r"(?m)^[ \t]*return-object\s+[vp]\d+", body))
    hooks = body.count(HOOK + "->CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;")
    if returns < 1 or hooks != returns:
        raise PatchError(f"{SIG_CHAIN}: expected {returns} certificate hooks, found {hooks}")


def patch_dev_status(text: str) -> str:
    body = method_body(text, SIG_DEV)
    target = HOOK + "->shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z"
    count = body.count(target)
    if count == 1:
        return text
    if count != 0:
        raise PatchError(f"{SIG_DEV}: duplicate dev/ADB hook")

    body, scratch, _ = grow_one_local(body, 4)
    label = unique_label(":cond_kaorios_dev_stock", body)
    newline = "\r\n" if "\r\n" in body else "\n"

    inject = (
        f"    if-eqz p2, {label}{newline}"
        f"    invoke-static/range {{p1 .. p3}}, {target}{newline}"
        f"    move-result {scratch}{newline}"
        f"    if-eqz {scratch}, {label}{newline}"
        f"    const-string {scratch}, \"0\"{newline}"
        f"    return-object {scratch}{newline}"
        f"{newline}"
        f"    {label}{newline}"
    )
    off = code_insertion_offset(body)
    body = body[:off] + inject + body[off:]
    return replace_method(text, SIG_DEV, body)


def verify_dev_status(text: str) -> None:
    body = method_body(text, SIG_DEV)
    count = body.count(HOOK + "->shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z")
    if count != 1:
        raise PatchError(f"{SIG_DEV}: expected one dev/ADB hook, found {count}")


def patch_system_server(text: str) -> str:
    body = method_body(text, SIG_SYSTEMSERVER)
    target = HOOK + "->initSystemServer()V"
    count = body.count(target)
    if count == 1:
        return text
    if count != 0:
        raise PatchError("SystemServer.run(): duplicate initSystemServer hook")

    anchor_rx = re.compile(
        r"(?m)^(?P<indent>[ \t]*)invoke-[^\r\n]*"
        r"Lcom/android/server/SystemServer;->startOtherServices"
        r"\(Lcom/android/server/utils/TimingsTraceAndSlog;\)V[ \t]*(?:\r?\n|$)"
    )
    matches = list(anchor_rx.finditer(body))
    if len(matches) != 1:
        raise PatchError(f"SystemServer.run(): expected one startOtherServices anchor, found {len(matches)}")

    m = matches[0]
    newline = "\r\n" if "\r\n" in m.group(0) else "\n"
    inject = f"{m.group('indent')}invoke-static {{}}, {target}{newline}{newline}"
    body = body[:m.start()] + inject + body[m.start():]
    return replace_method(text, SIG_SYSTEMSERVER, body)


def verify_system_server(text: str) -> None:
    body = method_body(text, SIG_SYSTEMSERVER)
    target = HOOK + "->initSystemServer()V"
    if body.count(target) != 1:
        raise PatchError("SystemServer.run(): initSystemServer hook count must be 1")

    hook_pos = body.find(target)
    anchor_pos = body.find(
        "Lcom/android/server/SystemServer;->startOtherServices(Lcom/android/server/utils/TimingsTraceAndSlog;)V"
    )
    if anchor_pos < 0 or hook_pos < 0 or hook_pos > anchor_pos:
        raise PatchError("SystemServer.run(): initSystemServer must precede startOtherServices")


def patch_framework(root: Path) -> None:
    files = {
        key: find_one(root, TARGETS[key])
        for key in ("instrumentation", "package_manager", "keypair", "keystore", "settings")
    }

    transforms = {
        "instrumentation": patch_instrumentation,
        "package_manager": patch_feature,
        "keypair": patch_keypair,
        "keystore": patch_chain,
        "settings": patch_dev_status,
    }

    for key, path in files.items():
        original = read_text(path)
        patched = transforms[key](original)
        write_text(path, patched)

    verify_framework(root)


def verify_framework(root: Path) -> None:
    checks = [
        ("instrumentation", verify_instrumentation),
        ("package_manager", verify_feature),
        ("keypair", verify_keypair),
        ("keystore", verify_chain),
        ("settings", verify_dev_status),
    ]
    for key, checker in checks:
        path = find_one(root, TARGETS[key])
        checker(read_text(path))
    print("Kaorios framework verifier: PASS")


def patch_services(root: Path) -> None:
    path = find_one(root, TARGETS["system_server"])
    write_text(path, patch_system_server(read_text(path)))
    verify_services(root)


def verify_services(root: Path) -> None:
    path = find_one(root, TARGETS["system_server"])
    verify_system_server(read_text(path))
    print("Kaorios services verifier: PASS")


def main() -> None:
    parser = argparse.ArgumentParser(description="HyperMOS Kaorios A13-A16 surgical smali patcher")
    parser.add_argument("root", type=Path, help="Root containing disassembled owner DEX directories")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--framework", action="store_true")
    group.add_argument("--services", action="store_true")
    group.add_argument("--verify-framework", action="store_true")
    group.add_argument("--verify-services", action="store_true")
    args = parser.parse_args()

    if not args.root.is_dir():
        raise PatchError(f"directory does not exist: {args.root}")

    if args.framework:
        patch_framework(args.root)
    elif args.services:
        patch_services(args.root)
    elif args.verify_framework:
        verify_framework(args.root)
    else:
        verify_services(args.root)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Kaorios patch failed: {exc}", file=sys.stderr)
        sys.exit(1)
