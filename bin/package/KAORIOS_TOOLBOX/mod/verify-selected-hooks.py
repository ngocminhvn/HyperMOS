#!/usr/bin/env python3
"""Verify selected Kaorios callers in a final disassembled archive."""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path


TARGETS = {
    "activity_thread": "android/app/ActivityThread.smali",
    "instrumentation": "android/app/Instrumentation.smali",
    "system_feature": "android/app/ApplicationPackageManager.smali",
    "keypair": "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali",
    "keystore": "android/security/keystore2/AndroidKeyStoreSpi.smali",
    "devstatus": "android/provider/Settings$NameValueCache.smali",
    "build": "android/os/Build.smali",
    "build_version": "android/os/Build$VERSION.smali",
}

ADVANCED_POLICY_CLASSES = (
    "android/security/kaorios/settings/IAdvancedPolicyService.smali",
    "android/security/kaorios/settings/IAdvancedPolicyService$Stub.smali",
    "android/security/kaorios/settings/IAdvancedPolicyService$Stub$Proxy.smali",
    "android/security/kaorios/settings/AdvancedPolicyClient.smali",
    "android/security/kaorios/settings/AdvancedPolicyService.smali",
    "android/security/kaorios/settings/AdvancedPolicySnapshot.smali",
    "android/security/kaorios/settings/ServiceManagerBridge.smali",
    "android/security/kaorios/settings/SettingDecisionParcel.smali",
)


def load(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load verifier: {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def unique(root: Path, relative: str) -> Path:
    matches = list(root.rglob(relative))
    if len(matches) != 1:
        raise ValueError(f"expected exactly one {relative}; found {len(matches)}")
    return matches[0]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--script-dir", type=Path, required=True)
    parser.add_argument("--target", action="append", choices=sorted(TARGETS), default=[])
    parser.add_argument("--require-driver", action="store_true")
    parser.add_argument("--require-advanced-policy", action="store_true")
    args = parser.parse_args()

    owners: dict[str, list[Path]] = {}
    for dex_root in sorted(args.root.glob("classes*.dex.out")):
        for path in dex_root.rglob("*.smali"):
            owners.setdefault(path.relative_to(dex_root).as_posix(), []).append(path)
    duplicates = {name: paths for name, paths in owners.items() if len(paths) > 1}
    if duplicates:
        sample = ", ".join(sorted(duplicates)[:10])
        raise ValueError(f"duplicate class descriptors across DEX files: {sample}")

    patcher = load(args.script_dir / "kaorios_patcher.py", "kaorios_final_patcher")
    for target in args.target:
        path = unique(args.root, TARGETS[target])
        patcher.verify_target_content(path.name, path.read_text(encoding="utf-8"))

    if args.require_driver:
        unique(args.root, "android/security/kaorios/KaoriosHook.smali")
    if args.require_advanced_policy:
        for relative in ADVANCED_POLICY_CLASSES:
            unique(args.root, relative)
    print(f"KAORIOS: verified {len(args.target)} selected final caller(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
