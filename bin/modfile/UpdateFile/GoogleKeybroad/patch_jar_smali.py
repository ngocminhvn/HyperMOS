#!/usr/bin/env python3
"""Scoped China IME integration inside CorePatch's existing JAR smali pass.

Run *before* CorePatch recompiles miui-services.jar / miui-framework.jar.
Do not globally replace com.xiaomi.type: SMS CAPTCHA and Xiaomi IME APIs are
not Gboard APIs. Avoid an extra DEX round-trip or independent JAR repack.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

GBOARD = "com.google.android.inputmethod.latin"
LEGACY = "com.baidu.input_mi"
EXTRA_LEGACY = {
    "miui-services": (
        "com/android/server/inputmethod/SecurityInputMethodSwitcher.smali",
        "com/android/server/stability/MiuiStabilityAppStateService.smali",
        "com/android/server/inputmethod/SogouInputMethodSwitcher.smali",
        "com/android/server/inputmethod/InputMethodManagerServiceImpl.smali",
    ),
    "miui-framework": (
        "android/inputmethodservice/InputMethodServiceInjector.smali",
        "android/view/inputmethod/InputMethodManagerStubImpl.smali",
        "com/android/internal/os/AnrEnhanceImpl.smali",
        "miui/util/HapticFeedbackUtil.smali",
    ),
}
LEGACY_LITERAL = re.compile(
    r'(\bconst-string(?:/jumbo)?[ \t]+[vp]\d+,[ \t]*")'
    + re.escape(LEGACY)
    + r'(")'
)
RESET_GATE = re.compile(
    r"(?ms)^\.method[^\n]*\bshouldSkipResetDefaultImeForXiaomiIme"
    r"\(Ljava/lang/String;\)Z[^\n]*\n.*?^\.end method[ \t]*$"
)
FIRST_INSTRUCTION = re.compile(r"(?m)^[ \t]+(?=[a-z])[a-z][a-z0-9/_-]*(?=[ \t\n])")
REGISTER_DECL = re.compile(r"(?m)^[ \t]*\.(?:registers|locals)[ \t]+\d+[ \t]*$")


def locate(root: Path, relative: str) -> list[Path]:
    return sorted(p for p in root.glob("smali*/" + relative) if p.is_file())


def neutralize_xiaomi_default_reset(source: str) -> tuple[str, bool]:
    matches = list(RESET_GATE.finditer(source))
    if len(matches) > 1:
        raise ValueError("multiple shouldSkipResetDefaultImeForXiaomiIme methods")
    if not matches:
        return source, False
    match = matches[0]
    block = match.group()
    if "com.xiaomi.type" not in block or "HyperMOS GoogleKeybroad:" in block:
        return source, False
    registers = REGISTER_DECL.search(block)
    if registers is None:
        raise ValueError("Xiaomi IME reset gate has no register declaration")
    first = FIRST_INSTRUCTION.search(block, registers.end())
    if first is None:
        raise ValueError("Xiaomi IME reset gate has no recognizable instruction")
    # Force "do not skip Android's default-IME reset" if MiType is removed.
    # Keep the original method, annotations, debug labels and other bytecode.
    prelude = (
        "    # HyperMOS GoogleKeybroad: preserve standard default IME fallback\n"
        "    const/4 v0, 0x0\n"
        "    return v0\n\n"
    )
    patched = block[:first.start()] + prelude + block[first.start():]
    return source[:match.start()] + patched + source[match.end():], True


def run() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--component", choices=sorted(EXTRA_LEGACY), required=True)
    parser.add_argument("--smali-root", type=Path, required=True)
    args = parser.parse_args()
    root = Path.cwd()
    source = (root / "bin/ddevice/rom_source.txt").read_text().strip()
    if source != "china":
        return
    android = (root / "bin/ddevice/androidver.txt").read_text().strip()
    if android not in ("15", "16", "17"):
        raise ValueError(f"unsupported China Android {android}")
    if not args.smali_root.is_dir():
        raise ValueError(f"smali tree missing: {args.smali_root}")

    updated_files = 0
    replaced_literals = 0
    patched_reset = False
    for relative in EXTRA_LEGACY[args.component]:
        paths = locate(args.smali_root, relative)
        if len(paths) > 1:
            raise ValueError(f"duplicate smali class for {relative}")
        for file in paths:
            original = file.read_text(encoding="utf-8")
            patched, count = LEGACY_LITERAL.subn(
                lambda m: m.group(1) + GBOARD + m.group(2), original)
            replaced_literals += count
            if (args.component == "miui-services"
                    and android == "17"
                    and relative.endswith("/InputMethodManagerServiceImpl.smali")):
                patched, reset_done = neutralize_xiaomi_default_reset(patched)
                patched_reset = patched_reset or reset_done
            if patched != original:
                file.write_text(patched, encoding="utf-8")
                updated_files += 1

    print(
        f"[GoogleKeybroad] {args.component}: {updated_files} smali file(s), "
        f"{replaced_literals} stale Baidu literal(s), "
        f"Xiaomi default IME reset gate patched={patched_reset}"
    )


if __name__ == "__main__":
    try:
        run()
    except (OSError, ValueError) as error:
        print(f"[GoogleKeybroad] ERROR: {error}", file=sys.stderr)
        sys.exit(1)
