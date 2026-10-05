#!/usr/bin/env python3
"""Fail-closed Kaorios "hide Developer options / ADB" patch for Settings$NameValueCache.

Injects the Kaorios framework driver hook

    Landroid/security/kaorios/KaoriosHook;->shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

at the head of

    Landroid/provider/Settings$NameValueCache;->getStringForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;

so that the per-app AdvancedPolicy rules managed by Kaorios Toolbox can blank
developer/ADB related settings reads for a selected app. When the driver returns
a non-null Boolean TRUE the method returns "0" (developer options off) instead of
the stored value; when it returns null the stock body runs unchanged.

This module is deliberately HyperMOS-local: the maintained upstream
``kaorios_patcher.py`` documents this target as an optional, per-ROM manual patch
(guide section 11), so keeping the logic in a separate fail-closed module avoids
diverging from the upstream patcher and its verifier set. The injected block is
identical in shape to the upstream Template_V2060/a1x reference smali for
Android 13, 16 and 17.

Exit codes
    0   patched, or already patched and structurally verified
    1   hard failure (ambiguous target, failed verification, bad usage, --strict skip)
    3   skipped: target file absent, or layout not safely supported
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

TARGET_REL = "android/provider/Settings$NameValueCache.smali"
CLASS_DESC = "Landroid/provider/Settings$NameValueCache;"
METHOD_ANCHOR = (
    "getStringForUser"
    "(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;"
)
HOOK = (
    "Landroid/security/kaorios/KaoriosHook;->"
    "shouldHideDevStatusFromNameValueCache"
    "(Landroid/content/ContentResolver;Ljava/lang/String;I)Z"
)
LABEL = ":cond_kaorios_dev_stock"
HIDDEN_VALUE = "0"
SCRATCH = "v0"
INDENT = "    "
PARAM_COUNT = 4  # p0=this, p1=ContentResolver, p2=String name, p3=int user

CLASS_RE = re.compile(r"(?m)^\.class[^\r\n]*" + re.escape(CLASS_DESC) + r"[ \t]*(?:\r?\n|$)")
METHOD_RE = re.compile(
    r"(?m)^\.method[^\r\n]*" + re.escape(METHOD_ANCHOR) + r"[ \t]*(?:\r?\n|$)"
)
METHOD_END_RE = re.compile(r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)")
LOCALS_RE = re.compile(r"(?m)^[ \t]*\.locals[ \t]+(\d+)[ \t]*(?:\r?\n|$)")
REGISTERS_RE = re.compile(r"(?m)^[ \t]*\.registers[ \t]+(\d+)[ \t]*(?:\r?\n|$)")


class UnsupportedLayout(ValueError):
    """The target method is present but its layout cannot be patched safely."""


class VerifyError(ValueError):
    """The patched method does not satisfy the required hook structure."""


def _method_span(text: str) -> tuple[int, int]:
    """Return (start, end) of the target getStringForUser method, inclusive of .end method."""
    if not CLASS_RE.search(text):
        raise UnsupportedLayout(f"expected .class {CLASS_DESC} in Settings$NameValueCache.smali")
    matches = list(METHOD_RE.finditer(text))
    if len(matches) == 0:
        raise UnsupportedLayout(f"target method not found: {METHOD_ANCHOR}")
    if len(matches) > 1:
        raise UnsupportedLayout(f"ambiguous target method: found {len(matches)} matches of {METHOD_ANCHOR}")
    end = METHOD_END_RE.search(text, matches[0].end())
    if end is None:
        raise UnsupportedLayout("unterminated target method (missing .end method)")
    return matches[0].start(), end.end()


def _body_start(body: str) -> int:
    """Offset of the first real instruction inside a method body.

    Directives, labels, comments, blank lines and complete annotation blocks are
    skipped so the hook lands exactly where the upstream reference templates put
    it: after the leading ``.line`` marker and before the stock first opcode.
    """
    offset = 0
    annotation_depth = 0
    for raw in body.splitlines(keepends=True):
        stripped = raw.strip()
        if annotation_depth > 0:
            offset += len(raw)
            if stripped.startswith(".end annotation"):
                annotation_depth -= 1
            elif stripped.startswith(".annotation"):
                annotation_depth += 1
            continue
        if not stripped or stripped[0] in ".:#":
            offset += len(raw)
            if stripped.startswith(".annotation"):
                annotation_depth += 1
            continue
        return offset
    return offset


def _local_slots(body: str) -> int:
    """Number of local registers available for scratch use.

    Raises UnsupportedLayout when the directive is missing or leaves no free
    local register for the Boolean scratch value.
    """
    match = LOCALS_RE.search(body)
    if match is not None:
        slots = int(match.group(1))
    else:
        match = REGISTERS_RE.search(body)
        if match is None:
            raise UnsupportedLayout("neither .locals nor .registers directive found in target method")
        slots = int(match.group(1)) - PARAM_COUNT
    if slots < 1:
        raise UnsupportedLayout(
            f"target method exposes {slots} local register(s); a free local is required for the scratch value"
        )
    return slots


def _hook_block(newline: str) -> str:
    return (
        f"{INDENT}if-eqz p2, {LABEL}{newline}"
        f"{INDENT}invoke-static/range {{p1 .. p3}}, {HOOK}{newline}"
        f"{INDENT}move-result {SCRATCH}{newline}"
        f"{INDENT}if-eqz {SCRATCH}, {LABEL}{newline}"
        f"{INDENT}const-string {SCRATCH}, \"{HIDDEN_VALUE}\"{newline}"
        f"{INDENT}return-object {SCRATCH}{newline}"
        f"{newline}"
        f"{INDENT}{LABEL}{newline}"
    )


def _hook_pattern(roundtrip: bool = False) -> re.Pattern[str]:
    """Match the injected block, optionally tolerating baksmali label renaming."""
    label = r"(?P<stock>:[A-Za-z0-9_]+)" if roundtrip else re.escape(LABEL)
    second_label = r"(?P=stock)" if roundtrip else re.escape(LABEL)
    return re.compile(
        r"(?m)^[ \t]*if-eqz[ \t]+p2,[ \t]*" + label + r"[ \t]*\r?\n"
        r"^[ \t]*invoke-static/range[ \t]*\{p1[ \t]*\.\.[ \t]*p3\},[ \t]*" + re.escape(HOOK) + r"[ \t]*\r?\n"
        r"^[ \t]*move-result[ \t]+(?P<scratch>v\d+)[ \t]*\r?\n"
        r"^[ \t]*if-eqz[ \t]+(?P=scratch),[ \t]*" + second_label + r"[ \t]*\r?\n"
        r"^[ \t]*const-string[ \t]+(?P=scratch),[ \t]*\"0\"[ \t]*\r?\n"
        r"^[ \t]*return-object[ \t]+(?P=scratch)[ \t]*\r?\n"
        r"(?:^[ \\t]*\\r?\\n)*"
        r"^[ \t]*" + second_label + r"[ \t]*\r?\n"
    )


def _has_stock_instruction(body: str, label: str) -> bool:
    """Require a real opcode after the stock label, not just another label/end marker."""
    definition = re.search(r"(?m)^[ \t]*" + re.escape(label) + r"[ \t]*\r?\n", body)
    if definition is None:
        return False
    for line in body[definition.end():].splitlines():
        stripped = line.split("#", 1)[0].strip()
        if stripped and not stripped.startswith((".", ":")):
            return True
    return False


def verify(text: str, *, roundtrip: bool = False) -> None:
    """Assert the method carries exactly one correctly placed Kaorios dev-status hook."""
    start, end = _method_span(text)
    body = text[start:end]
    _local_slots(body)

    hook_count = body.count(HOOK)
    if hook_count != 1:
        raise VerifyError(f"expected exactly one dev-status hook call, found {hook_count}")

    match = _hook_pattern(roundtrip=roundtrip).search(body)
    if match is None:
        raise VerifyError("dev-status hook block does not match the required fail-closed structure")
    label = match.group("stock") if roundtrip else LABEL
    label_definitions = re.findall(r"(?m)^[ \t]*" + re.escape(label) + r"[ \t]*\r?$", body)
    if len(label_definitions) != 1:
        raise VerifyError(f"expected exactly one stock label definition for {label}, found {len(label_definitions)}")
    if not _has_stock_instruction(body, label):
        raise VerifyError("stock implementation is missing after the dev-status bypass label")
    head = _body_start(body)
    if match.start() < head or body[head:match.start()].strip():
        raise VerifyError("dev-status hook block is not at the head of the method body")
    if not roundtrip and match.group("scratch") != SCRATCH:
        raise VerifyError(f"dev-status hook must use {SCRATCH} as scratch register, found {match.group('scratch')}")


def patch(text: str) -> tuple[str, bool]:
    start, end = _method_span(text)
    body = text[start:end]
    if HOOK in body:
        verify(text)
        return text, False
    if LABEL in body:
        raise UnsupportedLayout(f"reserved label {LABEL} already present in target method")
    _local_slots(body)

    newline = "\r\n" if "\r\n" in text else "\n"
    insert_at = start + _body_start(body)
    patched = text[:insert_at] + _hook_block(newline) + text[insert_at:]
    verify(patched)
    return patched, True


def find_target(root: Path) -> Path | None:
    if root.is_file():
        return root
    matches = sorted(root.rglob(TARGET_REL))
    if len(matches) > 1:
        raise UnsupportedLayout(f"expected exactly one {TARGET_REL}, found {len(matches)}")
    return matches[0] if matches else None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Patch/verify the Kaorios dev-status hook in Settings$NameValueCache."
    )
    parser.add_argument("path", type=Path, help="decompiled framework smali tree, or the target .smali file")
    parser.add_argument("--verify-only", action="store_true", help="verify without modifying")
    parser.add_argument(
        "--verify-roundtrip",
        action="store_true",
        help="verify semantic hook structure after smali/baksmali label renaming",
    )
    parser.add_argument("--strict", action="store_true", help="treat SKIP conditions as hard failures")
    args = parser.parse_args()

    try:
        target = find_target(args.path)
    except UnsupportedLayout as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    if target is None:
        print(f"SKIP: {TARGET_REL} not present under {args.path}")
        return 1 if args.strict else 3

    try:
        text = target.read_bytes().decode("utf-8")
    except (OSError, UnicodeError) as error:
        print(f"ERROR: cannot read {target}: {error}", file=sys.stderr)
        return 1

    if args.verify_only:
        try:
            verify(text, roundtrip=args.verify_roundtrip)
        except (UnsupportedLayout, VerifyError) as error:
            print(f"ERROR: {error}", file=sys.stderr)
            return 1
        print(f"VERIFIED: {target}")
        return 0

    try:
        patched, changed = patch(text)
    except UnsupportedLayout as error:
        print(f"SKIP: {error}")
        return 1 if args.strict else 3
    except VerifyError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    if changed:
        try:
            target.write_bytes(patched.encode("utf-8"))
        except OSError as error:
            print(f"ERROR: cannot write {target}: {error}", file=sys.stderr)
            return 1
        print(f"PATCHED: {target}")
    else:
        print(f"ALREADY_PATCHED: {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
