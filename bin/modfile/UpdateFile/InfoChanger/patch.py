#!/usr/bin/env python3
"""Inject TNM HyperChanger at the same SystemUI lifecycle point used by RYU.

The injected implementation is self-contained and reads TNM's Settings.System
contract. It does not depend on ProjectRYU framework classes or resource IDs.
Unsupported SystemUI layouts fail before the unpacked APK is mutated.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


HELPER = "Lcom/hypermos/hyperchanger/HyperChanger;"
INJECTOR = "Lcom/android/keyguard/injector/KeyguardIndicationInjector;"
CONTROLLER = "Lcom/android/systemui/statusbar/KeyguardIndicationController;"
CTOR_SIGNATURE = (
    "<init>(Landroid/content/Context;"
    "Lcom/android/systemui/statusbar/KeyguardIndicationController;"
    "Lcom/android/systemui/statusbar/phone/StatusBarKeyguardViewManager;"
    "Lcom/android/keyguard/KeyguardUpdateMonitor;)V"
)
CTOR_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bconstructor\s+"
    + re.escape(CTOR_SIGNATURE)
    + r".*?^\.end method[ \t]*$"
)
RET_VOID = re.compile(r"(?m)^([ \t]*)return-void[ \t]*$")


def patch_injector(text: str) -> str:
    if f".class public final {INJECTOR}" not in text:
        raise ValueError("unexpected KeyguardIndicationInjector descriptor")
    if f"{HELPER}->init(" in text:
        raise ValueError("HyperChanger is already injected")
    matches = list(CTOR_METHOD.finditer(text))
    if len(matches) != 1:
        raise ValueError(f"injector constructor: expected 1, found {len(matches)}")
    match = matches[0]
    method = match.group()
    required = (
        f"iput-object p1, p0, {INJECTOR}->mContext:Landroid/content/Context;",
        f"iput-object p2, p0, {INJECTOR}->mKeyguardIndicationController:{CONTROLLER}",
    )
    if not all(value in method for value in required):
        raise ValueError("injector constructor parameter mapping changed")
    returns = list(RET_VOID.finditer(method))
    if len(returns) != 1:
        raise ValueError(f"injector constructor returns: expected 1, found {len(returns)}")
    call = (
        "invoke-static {p1, p2}, " + HELPER
        + "->init(Landroid/content/Context;" + CONTROLLER + ")V"
    )
    updated = RET_VOID.sub(
        lambda item: f"{item.group(1)}{call}\n\n{item.group()}", method, count=1
    )
    return text[:match.start()] + updated + text[match.end():]


def find_exact(root: Path, filename: str, descriptor: str) -> Path:
    results = []
    for path in root.rglob(filename):
        head = path.read_text(encoding="utf-8")[:600]
        if descriptor in head:
            results.append(path)
    if len(results) != 1:
        raise ValueError(f"{descriptor}: expected one class, found {len(results)}")
    return results[0]


def dex_roots(unpacked: Path) -> list[Path]:
    roots = [path for path in (unpacked / "smali").iterdir()
             if path.is_dir() and re.fullmatch(r"classes\d*", path.name)]
    if not roots:
        raise ValueError("APKEditor exposed no DEX smali roots")

    def dex_number(path: Path) -> int:
        match = re.fullmatch(r"classes(\d*)", path.name)
        return int(match.group(1) or "1") if match else 0

    return sorted(roots, key=dex_number)


def main() -> int:
    cli = argparse.ArgumentParser()
    cli.add_argument("--unpacked", type=Path, required=True)
    cli.add_argument("--sources", type=Path, default=Path(__file__).parent)
    args = cli.parse_args()

    injector = find_exact(
        args.unpacked, "KeyguardIndicationInjector.smali", INJECTOR
    )
    controller = find_exact(
        args.unpacked, "KeyguardIndicationController.smali", CONTROLLER
    )
    controller_text = controller.read_text(encoding="utf-8")
    required_fields = (
        ".field public mLockScreenIndicationView:"
        "Lcom/android/systemui/statusbar/phone/KeyguardIndicationTextView;",
        ".field public mPowerPluggedIn:Z",
    )
    if not all(field in controller_text for field in required_fields):
        raise ValueError("KeyguardIndicationController runtime fields changed")

    injector_patch = patch_injector(injector.read_text(encoding="utf-8"))
    helper = (args.sources / "HyperChanger.smali").read_text(encoding="utf-8")
    loop = (args.sources / "HyperChangerLoop.smali").read_text(encoding="utf-8")
    contracts = (
        ".method public static init(Landroid/content/Context;"
        + CONTROLLER + ")V",
        ".method public run()V",
        "hyperchanger_update_interval",
    )
    if not all(symbol in helper + loop for symbol in contracts):
        raise ValueError("HyperChanger payload contract is incomplete")

    # Xiaomi's third DEX is already at the 65,536 string-reference ceiling on
    # HAOTIAN OS3.0.308. A dedicated next DEX avoids rewriting unrelated
    # const-string instructions as jumbo and keeps the payload isolated.
    roots = dex_roots(args.unpacked)
    last_match = re.fullmatch(r"classes(\d*)", roots[-1].name)
    next_number = int(last_match.group(1) or "1") + 1
    target_dir = (args.unpacked / "smali" / f"classes{next_number}"
                  / "com/hypermos/hyperchanger")
    if target_dir.exists():
        raise ValueError("HyperChanger classes already exist")

    # All validation is complete; only now mutate the unpacked tree.
    target_dir.mkdir(parents=True)
    (target_dir / "HyperChanger.smali").write_text(helper, encoding="utf-8")
    (target_dir / "HyperChanger$Loop.smali").write_text(loop, encoding="utf-8")
    injector.write_text(injector_patch, encoding="utf-8")
    print("[HyperChanger] Injected RYU lifecycle hook and TNM runtime.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as error:
        sys.exit(f"[HyperChanger] INCOMPATIBLE: {error}")

