#!/usr/bin/env python3
"""Inject HyperChanger into an unpacked, compatible Xiaomi SystemUI.

Only modifies the two verified extension points. Unsupported layouts fail
without writing a patched APK or an installation marker.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


HELPER = "Lcom/hypermos/hyperchanger/HyperChanger;"
HINT_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bstatic\b[^\n]*"
    r"getChargingHintText\(IZLandroid/content/Context;\)Ljava/lang/String;"
    r".*?^\.end method[ \t]*$"
)
CTOR_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bconstructor\s+<init>\([^\n]*\)V"
    r".*?^\.end method[ \t]*$"
)
RET_OBJECT = re.compile(r"(?m)^([ \t]*)return-object ([vp]\d+)[ \t]*$")
RET_VOID = re.compile(r"(?m)^([ \t]*)return-void[ \t]*$")


def replace_one(text: str, matcher: re.Pattern, transform, label: str) -> str:
    matches = list(matcher.finditer(text))
    if len(matches) != 1:
        raise ValueError(f"{label}: expected one method, found {len(matches)}")
    match = matches[0]
    return text[:match.start()] + transform(match.group()) + text[match.end():]


def patch_hint(text: str) -> str:
    def transform(method: str) -> str:
        if HELPER in method:
            raise ValueError("charging hint already patched")
        if "return-object" not in method:
            raise ValueError("charging hint has no object return")

        def inject(match: re.Match) -> str:
            indentation, value = match.groups()
            return (
                f"{indentation}invoke-static {{p2, {value}}}, {HELPER}"
                "->render(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;\n"
                f"{indentation}move-result-object {value}\n"
                + match.group()
            )
        result, count = RET_OBJECT.subn(inject, method)
        if not count:
            raise ValueError("charging hint returns could not be patched")
        return result

    return replace_one(text, HINT_METHOD, transform, "ChargeUtils.getChargingHintText")


def patch_view(text: str) -> str:
    if ".super Landroid/widget/TextView;" not in text:
        raise ValueError("KeyguardIndicationTextView is not a direct TextView")
    if HELPER in text:
        raise ValueError("keyguard view already patched")

    found = 0

    def transform(match: re.Match) -> str:
        nonlocal found
        method = match.group()
        # A constructor chain may call this(...). Bind exactly once after the
        # constructor that invokes the Android TextView superclass.
        if "Landroid/widget/TextView;-><init>(" not in method:
            return method
        found += 1
        if len(RET_VOID.findall(method)) != 1:
            raise ValueError("base TextView constructor must have one return")
        return RET_VOID.sub(
            lambda m: (
                f"{m.group(1)}invoke-static {{p0}}, {HELPER}->bind(Landroid/widget/TextView;)V\n"
                + m.group()
            ),
            method,
        )

    updated = CTOR_METHOD.sub(transform, text)
    if found != 1:
        raise ValueError(f"base TextView constructors: expected 1, found {found}")
    return updated


def find_exact(root: Path, filename: str, class_suffix: str) -> Path:
    results = []
    for path in root.rglob(filename):
        # Use the descriptor, not filename alone, as an integrity check.
        if f".class" in path.read_text(encoding="utf-8")[:500] and \
                class_suffix in path.read_text(encoding="utf-8")[:500]:
            results.append(path)
    if len(results) != 1:
        raise ValueError(f"{class_suffix}: expected one class, found {len(results)}")
    return results[0]


def smali_root(path: Path) -> Path:
    for parent in path.parents:
        if parent.name.startswith("smali"):
            return parent
    raise ValueError("APKEditor did not expose a smali root")


def main() -> int:
    cli = argparse.ArgumentParser()
    cli.add_argument("--unpacked", type=Path, required=True)
    cli.add_argument("--sources", type=Path, default=Path(__file__).parent)
    args = cli.parse_args()

    hint = find_exact(
        args.unpacked, "ChargeUtils.smali",
        "Lcom/miui/charge/ChargeUtils;",
    )
    view = find_exact(
        args.unpacked, "KeyguardIndicationTextView.smali",
        "Lcom/android/systemui/statusbar/phone/KeyguardIndicationTextView;",
    )
    root = smali_root(hint)
    target_dir = root / "com/hypermos/hyperchanger"
    if target_dir.exists():
        raise ValueError("HyperChanger class already installed")

    # Validate everything BEFORE mutating the unpacked tree.
    hint_patch = patch_hint(hint.read_text(encoding="utf-8"))
    view_patch = patch_view(view.read_text(encoding="utf-8"))
    helper = (args.sources / "HyperChanger.smali").read_text(encoding="utf-8")
    loop = (args.sources / "HyperChangerLoop.smali").read_text(encoding="utf-8")
    for symbol in (".method public static bind(Landroid/widget/TextView;)V", "->render(", "->refresh("):
        if symbol not in helper + loop:
            raise ValueError(f"Missing HyperChanger method contract: {symbol}")

    target_dir.mkdir(parents=True)
    (target_dir / "HyperChanger.smali").write_text(helper, encoding="utf-8")
    (target_dir / "HyperChanger$Loop.smali").write_text(loop, encoding="utf-8")
    hint.write_text(hint_patch, encoding="utf-8")
    view.write_text(view_patch, encoding="utf-8")
    print("[HyperChanger] Injected charging hint, keyguard view and runtime.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as error:
        sys.exit(f"[HyperChanger] INCOMPATIBLE: {error}")
