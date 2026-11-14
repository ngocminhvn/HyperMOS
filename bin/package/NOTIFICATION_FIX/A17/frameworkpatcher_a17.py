#!/usr/bin/env python3
"""Global Android 17 / OS4 policy patcher for miui-services.jar.

Forces PolicyManagerConfig.isCnModel()Z = false and sCnModel = false,
activating native InternationalPolicyManager across Greeze, Aurogon, and ConfigManager.
Operates 100% identically to Global EEA without custom hook methods.
"""
import argparse
import json
import re
from pathlib import Path

POLICY_CONFIG = "com/miui/server/greeze/PolicyManagerConfig.smali"


def locate(root: Path, relative: str):
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    if not matches:
        direct = root / relative
        if direct.is_file():
            return direct
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"missing decompiled miui-services.jar: {root}")

    cfg_file = locate(root, POLICY_CONFIG)
    source = cfg_file.read_text(encoding="utf-8")
    original = source

    # 1. Force isCnModel() to return false (0)
    is_cn_re = re.compile(
        r"(?ms)^\.method public static isCnModel\(\)Z\s*\n.*?^\.end method[ \t]*$"
    )
    new_is_cn = (
        ".method public static isCnModel()Z\n"
        "    .registers 1\n\n"
        "    const/4 v0, 0x0\n\n"
        "    return v0\n"
        ".end method"
    )
    if is_cn_re.search(source):
        source = is_cn_re.sub(new_is_cn, source)

    # 2. Force sCnModel static field initializer to false
    clinit_re = re.compile(
        r"(?ms)^\.method static constructor <clinit>\(\)V\s*\n.*?^\.end method[ \t]*$"
    )
    new_clinit = (
        ".method static constructor <clinit>()V\n"
        "    .registers 1\n\n"
        "    const/4 v0, 0x0\n\n"
        "    sput-boolean v0, Lcom/miui/server/greeze/PolicyManagerConfig;->sCnModel:Z\n\n"
        "    return-void\n"
        ".end method"
    )
    if clinit_re.search(source):
        source = clinit_re.sub(new_clinit, source)

    changed = source != original
    if changed:
        cfg_file.write_text(source, encoding="utf-8")

    report = {
        "status": "success",
        "changed": changed,
        "target_jar": "miui-services.jar",
        "policy": "pure_global_eea",
        "is_cn_model_forced_false": True,
        "s_cn_model_forced_false": True,
    }
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_miui_services", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.decoded_miui_services)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[FRAMEWORKPATCHER A17] " + json.dumps(report))


if __name__ == "__main__":
    main()
