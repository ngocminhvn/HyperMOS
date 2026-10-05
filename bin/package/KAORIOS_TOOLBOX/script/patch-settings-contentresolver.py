#!/usr/bin/env python3
"""Fail-closed framework hook for direct Settings ContentResolver.call() reads.

HyperMOS keeps the stock SettingsProvider.apk byte-for-byte because Xiaomi's
platform private key is not available. Kaorios Toolbox, however, probes the
Settings runtime through ContentResolver.call(), while ordinary Settings.*
getters are already covered by the NameValueCache caller hook.

This patch adds a narrowly-scoped hook at the head of:

    Landroid/content/ContentResolver;->call(
        Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;
    )Landroid/os/Bundle;

The bridge only handles authority == "settings", ordinary application UIDs and
the current Binder identity. A null decision falls through to the stock method.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import smali_semantics as semantics

TARGET_REL = "android/content/ContentResolver.smali"
CLASS_DESC = "Landroid/content/ContentResolver;"
METHOD_ANCHOR = (
    "call(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
    "Landroid/os/Bundle;)Landroid/os/Bundle;"
)
HOOK = (
    "Landroid/security/kaorios/HyperMOSSettingsSpoof;->"
    "getOverrideForCall(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)"
    "Landroid/os/Bundle;"
)
LABEL = ":cond_hypermos_settings_call_stock"
PARAM_COUNT = 5  # p0=this, p1=authority, p2=method, p3=arg, p4=extras

CLASS_RE = re.compile(
    r"(?m)^\.class[^\r\n]*" + re.escape(CLASS_DESC) + r"[ \t]*(?:\r?\n|$)"
)
METHOD_RE = re.compile(
    r"(?m)^\.method[^\r\n]*" + re.escape(METHOD_ANCHOR) + r"[ \t]*(?:\r?\n|$)"
)
METHOD_END_RE = re.compile(r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)")
LOCALS_RE = re.compile(r"(?m)^[ \t]*\.locals[ \t]+(\d+)[ \t]*(?:\r?\n|$)")
REGISTERS_RE = re.compile(r"(?m)^[ \t]*\.registers[ \t]+(\d+)[ \t]*(?:\r?\n|$)")


class UnsupportedLayout(ValueError):
    pass


class VerifyError(ValueError):
    pass


def method_span(text: str) -> tuple[int, int]:
    if not CLASS_RE.search(text):
        raise UnsupportedLayout(f"expected .class {CLASS_DESC}")
    matches = list(METHOD_RE.finditer(text))
    if len(matches) != 1:
        raise UnsupportedLayout(
            f"expected exactly one {METHOD_ANCHOR}, found {len(matches)}"
        )
    end = METHOD_END_RE.search(text, matches[0].end())
    if end is None:
        raise UnsupportedLayout("unterminated ContentResolver.call method")
    return matches[0].start(), end.end()


def body_start(body: str) -> int:
    offset = 0
    annotation_depth = 0
    for raw in body.splitlines(keepends=True):
        stripped = raw.strip()
        if annotation_depth:
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


def local_slots(body: str) -> int:
    match = LOCALS_RE.search(body)
    if match is not None:
        slots = int(match.group(1))
    else:
        match = REGISTERS_RE.search(body)
        if match is None:
            raise UnsupportedLayout("missing .locals/.registers directive")
        slots = int(match.group(1)) - PARAM_COUNT
    if slots < 1:
        raise UnsupportedLayout("ContentResolver.call needs one free local register")
    return slots


def hook_block(newline: str) -> str:
    return (
        f"    invoke-static/range {{p1 .. p4}}, {HOOK}{newline}"
        f"    move-result-object v0{newline}"
        f"    if-eqz v0, {LABEL}{newline}"
        f"    return-object v0{newline}"
        f"{newline}"
        f"    {LABEL}{newline}"
    )


def verify(text: str, *, roundtrip: bool = False) -> None:
    start, end = method_span(text)
    body = text[start:end]
    local_slots(body)

    if body.count(HOOK) != 1:
        raise VerifyError("expected exactly one direct ContentResolver Settings hook")

    semantics.verify_prefix(body, hook_block("\n"), PARAM_COUNT)


def patch(text: str) -> tuple[str, bool]:
    start, end = method_span(text)
    body = text[start:end]
    if HOOK in body:
        verify(text)
        return text, False
    if LABEL in body:
        raise UnsupportedLayout(f"reserved label {LABEL} already exists")
    local_slots(body)

    newline = "\r\n" if "\r\n" in text else "\n"
    insert_at = start + body_start(body)
    result = text[:insert_at] + hook_block(newline) + text[insert_at:]
    verify(result)
    return result, True


def find_target(root: Path) -> Path | None:
    if root.is_file():
        return root
    matches = sorted(root.rglob(TARGET_REL))
    if len(matches) > 1:
        raise UnsupportedLayout(
            f"expected exactly one {TARGET_REL}, found {len(matches)}"
        )
    return matches[0] if matches else None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path)
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument(
        "--check-layout",
        action="store_true",
        help="validate the stock ContentResolver.call target/layout without requiring an existing hook",
    )
    parser.add_argument("--roundtrip", action="store_true")
    args = parser.parse_args()

    try:
        target = find_target(args.path)
        if target is None:
            raise UnsupportedLayout(f"missing {TARGET_REL}")
        text = target.read_bytes().decode("utf-8")
        if args.check_layout:
            start, end = method_span(text)
            body = text[start:end]
            local_slots(body)
            if HOOK in body:
                raise VerifyError("stock preflight target is already patched")
            if LABEL in body:
                raise UnsupportedLayout(f"reserved label {LABEL} already exists")
            print(f"PREFLIGHT_OK: Android 16 ContentResolver.call layout in {target}")
        elif args.verify_only:
            verify(text, roundtrip=args.roundtrip)
            print(f"VERIFIED: direct Settings ContentResolver.call hook in {target}")
        else:
            result, changed = patch(text)
            if changed:
                target.write_bytes(result.encode("utf-8"))
            print(f"VERIFIED: direct Settings ContentResolver.call hook in {target}")
    except (UnsupportedLayout, VerifyError, OSError, UnicodeError) as error:
        parser.exit(1, f"ERROR: {error}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
