#!/usr/bin/env python3
"""Hook Settings.* reads without changing the signed SettingsProvider APK.

The bridge evaluates policy before the stock value cache, so rule changes and
explicit null overrides do not become stale cached values. Direct provider
call/query and cross-user/system-process reads are outside this backend.
"""
from __future__ import annotations

import argparse
import importlib.util
import re
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "devstatus", Path(__file__).with_name("patch-settings-namevaluecache.py")
)
dev = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dev)

sys.path.insert(0, str(Path(__file__).resolve().parent))
import smali_semantics as semantics

TARGET = dev.TARGET_REL
HELPER = "Landroid/security/kaorios/HyperMOSSettingsSpoof;"
HOOK = HELPER + "->getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;"
FIELD = dev.CLASS_DESC + "->mCallGetCommand:Ljava/lang/String;"
LABEL = ":cond_hypermos_settings_stock"


def insertion(body: str) -> int:
    if dev.HOOK in body:
        # Keep the independently verified dev-status prefix at the method head.
        match = dev._hook_pattern().search(body)
        if match is None or body[dev._body_start(body):match.start()].strip():
            raise ValueError("unsupported existing dev-status prefix")
        return match.end()
    return dev._body_start(body)


def block() -> str:
    # Copy high p-registers into existing low locals. Do not shift parameters or
    # change .registers: OEM code may use v aliases for parameter registers.
    return f"""    move-object/from16 v0, p0
    iget-object v0, v0, {FIELD}
    move-object/from16 v1, p2
    move/from16 v2, p3
    invoke-static/range {{v0 .. v2}}, {HOOK}
    move-result-object v0
    if-eqz v0, {LABEL}
    const-string v1, "value"
    invoke-virtual {{v0, v1}}, Landroid/os/BaseBundle;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    return-object v0
    {LABEL}
"""


def verify(text: str, roundtrip: bool = False) -> None:
    start, end = dev._method_span(text)
    body = text[start:end]
    if dev._local_slots(body) < 3:
        raise ValueError("three existing local registers are required")
    if body.count(HOOK) != 1:
        raise ValueError("expected exactly one caller settings hook")
    prefix = (dev._hook_block("\n") if dev.HOOK in body else "") + block()
    semantics.verify_prefix(body, prefix, 4)
    if dev.HOOK in body:
        dev.verify(text, roundtrip=roundtrip)


def verify_bridge(root: Path) -> None:
    """Compare all bridge instructions and normal/exception CFG edges.

    The owned template is the contract, including UID/Binder/user/app-range
    guards, ThreadLocal lifecycle, exact policy arguments and null fallback.
    Labels/debug metadata/encoding changes are not part of that contract.
    """
    matches = list(root.rglob("android/security/kaorios/HyperMOSSettingsSpoof.smali"))
    if len(matches) != 1:
        raise ValueError("expected exactly one caller Settings bridge")
    actual = matches[0].read_text(encoding="utf-8")
    expected = (Path(__file__).resolve().parents[1] /
                "framework/HyperMOSSettingsSpoof.smali").read_text(encoding="utf-8")
    for declaration in (
        ".class public final " + HELPER,
        ".super Ljava/lang/Object;",
        ".field private static final sActive:Ljava/lang/ThreadLocal;",
    ):
        if declaration not in actual.splitlines():
            raise ValueError("caller bridge class/field declaration changed")
    for descriptor, parameters in (
        ("<clinit>()V", 0),
        ("getOverrideForCall(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;", 4),
        ("getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;", 3),
    ):
        actual_body = semantics.method(actual, descriptor)
        expected_body = semantics.method(expected, descriptor)
        if actual_body.splitlines()[0] != expected_body.splitlines()[0]:
            raise ValueError("caller bridge method declaration changed")
        semantics.equivalent(actual_body, expected_body, parameters, descriptor)
    print("VERIFIED: caller bridge instructions, branches, catch ranges and cleanup survived DEX round-trip")


def patch(text: str) -> tuple[str, bool]:
    start, end = dev._method_span(text)
    body = text[start:end]
    if re.search(r"(?m)^\.field[^\n]*\bmCallGetCommand:Ljava/lang/String;", text) is None:
        raise ValueError("missing String mCallGetCommand field")
    if HOOK in body:
        verify(text)
        return text, False
    if LABEL in body:
        raise ValueError("reserved caller label already exists")
    if dev._local_slots(body) < 3:
        raise ValueError("three existing locals required; refusing to shift OEM registers")
    if dev.HOOK in body:
        dev.verify(text)
    offset = start + insertion(body)
    newline = "\r\n" if "\r\n" in text else "\n"
    result = text[:offset] + block().replace("\n", newline) + text[offset:]
    verify(result)
    return result, True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path)
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--roundtrip", action="store_true")
    parser.add_argument("--verify-bridge", action="store_true")
    args = parser.parse_args()
    try:
        if args.verify_bridge:
            verify_bridge(args.path)
            print("VERIFIED: caller bridge guards and exception cleanup")
            return 0
        target = dev.find_target(args.path)
        if target is None:
            raise ValueError(f"missing {TARGET}")
        text = target.read_bytes().decode("utf-8")
        if args.verify_only:
            verify(text, args.roundtrip)
        else:
            result, changed = patch(text)
            if changed:
                target.write_bytes(result.encode("utf-8"))
        print(f"VERIFIED: caller Settings spoof in {target}")
    except (ValueError, OSError) as error:
        parser.exit(1, f"ERROR: {error}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
