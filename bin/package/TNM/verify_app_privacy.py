#!/usr/bin/env python3
"""Audit six actual TNM visibility call sites in the disassembled staged DEX."""
from pathlib import Path
import sys

from patch_app_privacy import HELPER, METHOD, OWNER, TARGETS


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
        if kind == "single" and (
            "Landroid/content/pm/PackageManager$NameNotFoundException;" not in method
            or ":tnm_app_privacy_continue" not in method
        ):
            raise ValueError(f"TNM hide guard incomplete: {signature}")
    print("[TNM APP PRIVACY] verified six APM call sites and helper in staged DEX")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: verify_app_privacy.py APM.smali TnmAppPrivacy.smali")
    try:
        verify(Path(sys.argv[1]), Path(sys.argv[2]))
    except (OSError, ValueError) as exc:
        raise SystemExit(f"TNM App Privacy verification failed: {exc}")
