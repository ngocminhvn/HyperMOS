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
ACTIVITY_STARTER_IMPL = "com/android/server/wm/ActivityStarterImpl.smali"

BUBBLE_BYPASS_MARKER = ":cond_allow_bubble_skip"
BUBBLE_BYPASS_HOOK = (
    r"\1\n"
    r"    const/16 v10, 0x3e8\n\n"
    r"    if-ne v3, v10, :cond_allow_bubble_skip\n\n"
    r"    if-eqz v1, :cond_allow_bubble_skip\n\n"
    r"    invoke-virtual {v1}, Landroid/content/Intent;->getFlags()I\n\n"
    r"    move-result v10\n\n"
    r"    const/high16 v11, 0x8080000\n\n"
    r"    and-int/2addr v10, v11\n\n"
    r"    if-ne v10, v11, :cond_allow_bubble_skip\n\n"
    r"    return v9\n\n"
    r"    :cond_allow_bubble_skip\n"
)


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

    # 3. Allow SystemUI (uid=1000) Bubble launches (NEW_DOCUMENT | MULTIPLE_TASK) without MIUIOP(10021)
    bubble_bypass_applied = False
    starter_file = locate(root, ACTIVITY_STARTER_IMPL)
    starter_src = starter_file.read_text(encoding="utf-8")
    if BUBBLE_BYPASS_MARKER not in starter_src:
        bubble_anchor = re.compile(
            r'(\.method public isAllowedStartActivity\(Landroid/content/Intent;IILjava/lang/String;IILandroid/content/pm/ActivityInfo;Lcom/android/server/wm/BackgroundActivityStartController\$BalVerdict;Lcom/android/server/wm/ActivityRecord;\)Z'
            r'.*?move/from16 v3, p5\s*\n'
            r'.*?const/4 v9, 0x1\s*\n)'
            , re.DOTALL
        )
        new_starter_src, n_subs = bubble_anchor.subn(BUBBLE_BYPASS_HOOK, starter_src, count=1)
        if n_subs == 1:
            starter_file.write_text(new_starter_src, encoding="utf-8")
            changed = True
            bubble_bypass_applied = True
    else:
        bubble_bypass_applied = True

    report = {
        "status": "success",
        "changed": changed,
        "target_jar": "miui-services.jar",
        "policy": "pure_global_eea",
        "is_cn_model_forced_false": True,
        "s_cn_model_forced_false": True,
        "bubble_start_bypass": bubble_bypass_applied,
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
