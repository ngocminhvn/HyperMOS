#!/usr/bin/env python3
"""Retain ZK power services while restoring conditional EU-style UID cleanup."""
import argparse
import re
from pathlib import Path

from ryu_killprocess_a16 import port as port_conditional_uid_kill
from restore_uid_policy_abi_a16 import patch as restore_uid_policy_abi
from guard_gms_uid_kill_a16 import patch as guard_gms_uid_kill
TNM_BUILD = "Lcom/android/tnm/TNMBuild;"
OLD_BUILD = "Lmiui/zk/Build;"
TNM_SETTINGS = "Lcom/android/tnm/TNMSettingsHelper;"
OLD_SETTINGS = "Lcom/zk/SettingsHelper;"
OLD_SETTINGS_PATH = "com/zk/SettingsHelper.smali"
TNM_SETTINGS_PATH = "com/android/tnm/TNMSettingsHelper.smali"

TNM_BUILD_SMALI = f""".class public final {TNM_BUILD}
.super Ljava/lang/Object;

.field public static final IS_TNM_BUILD:Z = true

.method private constructor <init>()V
    .locals 0
    invoke-direct {{p0}}, Ljava/lang/Object;-><init>()V
    return-void
.end method
"""


def adapt_zk_smali(root: Path):
    renamed = 0
    build_refs = settings_refs = settings_keys = thermal_nodes = brand_ids = 0
    for path in list(root.rglob("*.smali")):
        text = path.read_text(encoding="utf-8")
        build_refs += text.count(OLD_BUILD + "->IS_ZK_BUILD:Z")
        settings_refs += text.count(OLD_SETTINGS)
        settings_keys += text.count('"zk_max_fps"')
        thermal_nodes += text.count("/sys/class/thermal/thermal_message/zk_state")
        brand_ids += len(re.findall(
            r'(?m)^\s*(?:\.field[^\n]*=\s*|const-string(?:/jumbo)?\s+[^,]+,\s*)"ZK"\s*$',
            text))
        text = text.replace(OLD_BUILD + "->IS_ZK_BUILD:Z",
                            TNM_BUILD + "->IS_TNM_BUILD:Z")
        text = text.replace(OLD_SETTINGS, TNM_SETTINGS)
        text = text.replace('"zk_max_fps"', '"tnm_max_fps"')
        # Keep the donor's product property unchanged. Only its private thermal
        # message node is incompatible with the HAOTIAN kernel interface.
        text = text.replace("/sys/class/thermal/thermal_message/zk_state",
                            "/sys/class/thermal/thermal_message/temp_state")
        text = re.sub(
            r'(?m)(^\s*(?:\.field[^\n]*=\s*|const-string(?:/jumbo)?\s+[^,]+,\s*))"ZK"(\s*$)',
            r'\g<1>"TNM"\g<2>', text)
        if OLD_BUILD + "->" in text or OLD_SETTINGS in text:
            raise ValueError(f"Unadapted ZK API reference remains in {path}")
        for label, token in {
            "ZK FPS setting": '"zk_max_fps"',
            "ZK thermal node": "/sys/class/thermal/thermal_message/zk_state",
        }.items():
            if token in text:
                raise ValueError(f"Unadapted {label} remains in {path}")
        target = path
        if path.as_posix().endswith(OLD_SETTINGS_PATH):
            target = root / "smali/classes" / TNM_SETTINGS_PATH
            if target.exists():
                raise ValueError("TNMSettingsHelper destination already exists")
            target.parent.mkdir(parents=True, exist_ok=True)
            path.unlink()
            renamed += 1
        target.write_text(text, encoding="utf-8")

    if renamed != 1 or build_refs == 0 or settings_refs == 0:
        raise ValueError(
            f"Unexpected ZK API inventory: renamedSettings={renamed}, "
            f"buildRefs={build_refs}, settingsRefs={settings_refs}")
    if not (settings_keys and thermal_nodes and brand_ids):
        raise ValueError("Expected ZK settings, thermal-node and branding fields were not found")
    helper = root / "smali/classes" / TNM_SETTINGS_PATH
    if not helper.is_file() or TNM_SETTINGS not in helper.read_text(encoding="utf-8"):
        raise ValueError("TNMSettingsHelper was not emitted into an assembled DEX directory")

    build_path = root / "smali/classes/com/android/tnm/TNMBuild.smali"
    if build_path.exists():
        raise ValueError("TNMBuild destination already exists")
    build_path.parent.mkdir(parents=True, exist_ok=True)
    build_path.write_text(TNM_BUILD_SMALI, encoding="utf-8")
    return {
        "zk_build_gates_to_tnm": build_refs,
        "zk_settings_helper_to_tnm": settings_refs,
        "renamed_settings_helper_classes": renamed,
        "zk_max_fps_to_tnm_max_fps": settings_keys,
        "zk_thermal_node_to_stock_temp_state": thermal_nodes,
        "zk_brand_literals_to_tnm": brand_ids,
    }




def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--zk-raw", type=Path, required=True)
    parser.add_argument("--ryu-raw", type=Path, required=True)
    args = parser.parse_args()
    report = adapt_zk_smali(args.zk_raw)
    # EU-style battery-conscious UID cleanup: retained-app/visible-window
    # guards and per-UID POLICY 1/2 checks precede ProcessManager.kill().
    # The pinned RYU donor provides the equivalent scoped methods. All other
    # ZK controllers, GMS/Doze and thermal policy remain untouched.
    report.update(port_conditional_uid_kill(args.zk_raw, args.ryu_raw))
    # RYU/EU setUidState uses an interface getter absent from ZKOS.
    # Restore both the abstract declaration and the concrete UID POLICY reader
    # before DEX assembly. This also checks the existing second implementor.
    report.update(restore_uid_policy_abi(args.zk_raw))
    # The two local.config entries do not unconditionally suppress UID kill.
    # Skip only the GMS UID in the existing decision path (no daemon/polling).
    report.update(guard_gms_uid_kill(args.zk_raw))
    # The RYU donor is only used for two guarded UID decision methods.
    # No RYU performance or thermal code is imported.
    report["tnm_per_app_perf_classes"] = 0
    report["tnm_framework_api_embedded"] = False
    report["application_init_hooked"] = False
    report["perfhook_runtime_included"] = False
    report["powerkeeper_policy"] = "ZKOS power/thermal + RYU guarded UID cleanup + GMS exemption; no RYU PerfHook"
    report["non_dex_content"] = "Xiaomi stock original"
    print("[TNM ZK LOCAL DEX PORT] " + ", ".join(f"{k}={v}" for k, v in report.items()))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        print(f"[TNM ZK LOCAL DEX PORT] FAIL: {exc}", file=__import__("sys").stderr)
        raise SystemExit(1)
