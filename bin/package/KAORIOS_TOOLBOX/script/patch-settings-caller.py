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
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "devstatus", Path(__file__).with_name("patch-settings-namevaluecache.py")
)
dev = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dev)

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
    directive = dev.LOCALS_RE.search(body) or dev.REGISTERS_RE.search(body)
    base = int(directive.group(1)) - (4 if dev.REGISTERS_RE.search(body) else 0)
    code = dev._significant_lines(body)
    # Allow assembler register aliases and move encoding changes on round-trip.
    patterns = [
        rf"move-object(?:/from16|/16)? v0, (?:p0|v{base})",
        re.escape(f"iget-object v0, v0, {FIELD}"),
        rf"move-object(?:/from16|/16)? v1, (?:p2|v{base + 2})",
        rf"move(?:/from16|/16)? v2, (?:p3|v{base + 3})",
        re.escape(f"invoke-static/range {{v0 .. v2}}, {HOOK}"),
        r"move-result-object v0",
        r"if-eqz v0, (?P<label>:[A-Za-z0-9_]+)",
        r'const-string(?:/jumbo)? v1, "value"',
        re.escape('invoke-virtual {v0, v1}, Landroid/os/BaseBundle;->getString(Ljava/lang/String;)Ljava/lang/String;'),
        r"move-result-object v0",
        r"return-object v0",
        r"(?P=label)",
    ]
    match = re.search("\n".join(patterns), "\n".join(code))
    if match is None:
        raise ValueError("caller hook does not preserve the override/null/stock branches")
    if code.count(match.group("label")) != 1:
        raise ValueError("ambiguous caller stock label")
    if not roundtrip:
        prefix = body[insertion(body):body.index("    move-object/from16 v0, p0")]
        if prefix.strip():
            raise ValueError("caller hook must precede the stock cache body")
    else:
        # Before our hook only the optional dev-status prefix may execute.
        head = "\n".join(code).split(match.group(0), 1)[0]
        if dev.HOOK in body:
            dev.verify(text, roundtrip=True)
            if head.count("invoke-") != 1 or dev.HOOK not in head:
                raise ValueError("unexpected code before caller hook")
        elif any(line and not line.startswith(('.method', ':')) for line in head.splitlines()):
            raise ValueError("caller hook is after stock instructions")
    tail = "\n".join(code)[match.end():]
    if not any(line.strip() and not line.strip().startswith((":", ".")) for line in tail.splitlines()):
        raise ValueError("stock cache body is missing")


def _bridge_method(text: str, descriptor: str) -> str:
    match = re.search(
        rf"(?ms)^\\.method [^\\n]*{re.escape(descriptor)}\\n(.*?)^\\.end method",
        text,
    )
    if match is None:
        raise ValueError(f"missing caller bridge method: {descriptor}")
    return match.group(1)


def _require_count(body: str, needle: str, minimum: int, label: str) -> None:
    count = body.count(needle)
    if count < minimum:
        raise ValueError(f"caller bridge missing {label}: {count} < {minimum}")


def verify_bridge(root: Path) -> None:
    """Verify security-relevant bridge behavior after smali round-trip.

    baksmali is allowed to rename labels, choose equivalent move/const encodings
    and switch between .locals/.registers. The old verifier compared the whole
    instruction stream byte-for-byte after normalization, which produced false
    failures on Android 16 even though all hooks survived. This verifier keeps
    fail-fast checks for the actual guards, policy call and cleanup paths.
    """
    matches = list(root.rglob("android/security/kaorios/HyperMOSSettingsSpoof.smali"))
    if len(matches) != 1:
        raise ValueError("expected exactly one caller Settings bridge")
    actual = matches[0].read_text(encoding="utf-8")

    for declaration in (
        ".class public final " + HELPER,
        ".field private static final sActive:Ljava/lang/ThreadLocal;",
    ):
        if declaration not in actual.splitlines():
            raise ValueError("caller bridge class/field declaration changed")

    call = _bridge_method(
        actual,
        "getOverrideForCall(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;",
    )
    for needle, label in (
        ('const-string', "settings authority guard"),
        ('Ljava/lang/String;->equals(Ljava/lang/Object;)Z', "settings authority comparison"),
        ('->getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;', "shared override bridge"),
        ('return-object', "call override return"),
    ):
        if needle not in call:
            raise ValueError(f"caller bridge lost {label}")

    clinit = _bridge_method(actual, "<clinit>()V")
    for needle, label in (
        ("Ljava/lang/ThreadLocal;", "ThreadLocal allocation"),
        ("->sActive:Ljava/lang/ThreadLocal;", "ThreadLocal field initialization"),
    ):
        if needle not in clinit:
            raise ValueError(f"caller bridge lost {label}")

    override = _bridge_method(
        actual,
        "getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;",
    )
    for needle, label in (
        ("Landroid/os/Process;->myUid()I", "process UID guard"),
        ("Landroid/os/Binder;->getCallingUid()I", "Binder UID guard"),
        ("0x186a0", "Android user-range divisor"),
        ("0x2710", "application UID lower bound"),
        ("0x4e1f", "application UID upper bound"),
        ("Ljava/lang/ThreadLocal;->get()Ljava/lang/Object;", "recursion guard read"),
        ("Ljava/lang/ThreadLocal;->set(Ljava/lang/Object;)V", "recursion guard set"),
        ("KaoriosHook;->filterSettingsCall(Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;", "policy call"),
    ):
        if needle not in override:
            raise ValueError(f"caller bridge lost {label}")

    _require_count(override, ".catchall", 2, "exception guards")
    _require_count(override, "Ljava/lang/ThreadLocal;->remove()V", 2, "ThreadLocal cleanup")
    _require_count(override, "return-object", 2, "override/stock returns")

    if override.count(
        "KaoriosHook;->filterSettingsCall(Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;"
    ) != 1:
        raise ValueError("caller bridge policy call count changed")

    print("VERIFIED: caller bridge guards, policy call and cleanup survived DEX round-trip")


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
