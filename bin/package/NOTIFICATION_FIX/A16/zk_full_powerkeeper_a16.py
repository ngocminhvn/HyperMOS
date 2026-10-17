#!/usr/bin/env python3
"""Retain ZK power services while restoring conditional EU-style UID cleanup."""
import argparse
import re
from pathlib import Path

from ryu_killprocess_a16 import port as port_conditional_uid_kill
from restore_uid_policy_abi_a16 import patch as restore_uid_policy_abi
from guard_gms_uid_kill_a16 import patch as guard_gms_uid_kill
from powerkeeper import (
    OLD_PERF_PREFIX,
    TNM_PERF_PREFIX,
    adapt as adapt_tnm_perf,
    patch_perfhook_write_verify,
    tnm_framework_smali,
)


TNM_BUILD = "Lcom/android/tnm/TNMBuild;"
OLD_BUILD = "Lmiui/zk/Build;"
TNM_SETTINGS = "Lcom/android/tnm/TNMSettingsHelper;"
OLD_SETTINGS = "Lcom/zk/SettingsHelper;"
OLD_SETTINGS_PATH = "com/zk/SettingsHelper.smali"
TNM_SETTINGS_PATH = "com/android/tnm/TNMSettingsHelper.smali"
PERF_HOOK = TNM_PERF_PREFIX + "PerfHook;"

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




def make_perfhook_init_passive(source: str) -> str:
    """Keep the observers, but avoid automatically writing thermal/performance.

    init() used to call applyInitialZeroOnce() (forces sconfig=0) and
    updateConfig() (can update GPU/CPU/governor). Explicit TNM settings
    changes remain observable by the registered ContentObservers.
    """
    method_re = re.compile(
        r"(?ms)^\.method[^\n]*[ \t]init\(\)V[ \t]*$.*?^\.end method[ \t]*$")
    matches = list(method_re.finditer(source))
    if len(matches) != 1:
        raise ValueError("Expected one original RYU PerfHook.init()")
    match = matches[0]
    body = match.group()
    for method in ("applyInitialZeroOnce", "updateConfig"):
        invocation = re.compile(
            rf"(?m)^[ \t]*invoke-(?:direct|virtual)(?:/range)?[ \t]+"
            rf"\{{[^}}]+\}},[ \t]*{re.escape(TNM_PERF_PREFIX)}PerfHook;"
            rf"->{method}\(\)V[ \t]*\n?")
        if len(list(invocation.finditer(body))) != 1:
            raise ValueError(f"Missing/ambiguous boot-only PerfHook.{method}() call")
        body = invocation.sub("", body, count=1)
    if "->startPerfWorker()V" not in body or "->registerContentObserver(" not in body:
        raise ValueError("RYU PerfHook passive observer contract changed")
    return source[:match.start()] + body + source[match.end():]


def graft_tnm_per_app_perf(zk_root: Path, ryu_root: Path):
    """Retain the existing TNM per-app percentage control, not RYU power policy."""
    source_dir = ryu_root / "smali/classes/com/projectryu/perf"
    sources = sorted(source_dir.glob("*.smali"))
    if len(sources) != 20 or not any(path.name == "PerfHook.smali" for path in sources):
        raise ValueError(f"Expected exactly 20 TNM per-app PerfHook classes, got {len(sources)}")
    if (zk_root / "smali/classes/com/android/tnm/TNMFramework.smali").exists():
        raise ValueError("ZK donor already contains TNMFramework")

    copied = 0
    for source in sources:
        relative = source.relative_to(ryu_root / "smali/classes")
        descriptor = "L" + relative.with_suffix("").as_posix() + ";"
        body, _, gates = adapt_tnm_perf(source.read_text(encoding="utf-8"))
        if gates:
            raise ValueError(f"Unexpected RYU build gates inside TNM PerfHook: {descriptor}")
        if descriptor == OLD_PERF_PREFIX + "PerfHook;":
            body = patch_perfhook_write_verify(body)
            body = make_perfhook_init_passive(body)
        target_descriptor = TNM_PERF_PREFIX + descriptor[len(OLD_PERF_PREFIX):]
        target = zk_root / "smali/classes" / (target_descriptor[1:-1] + ".smali")
        if target.exists():
            raise ValueError(f"TNM PerfHook class collides with ZK class: {target_descriptor}")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(body, encoding="utf-8")
        copied += 1

    framework = zk_root / "smali/classes/com/android/tnm/TNMFramework.smali"
    if framework.exists():
        raise ValueError("TNMFramework destination already exists")
    framework.parent.mkdir(parents=True, exist_ok=True)
    framework.write_text(tnm_framework_smali(), encoding="utf-8")

    application = zk_root / "smali/classes/com/miui/powerkeeper/PowerKeeperApplication.smali"
    source = application.read_text(encoding="utf-8")
    pattern = re.compile(r"(?ms)^\.method public onCreate\(\)V\s*$.*?^\.end method$")
    methods = list(pattern.finditer(source))
    if len(methods) != 1 or PERF_HOOK in source:
        raise ValueError("Unexpected ZK PowerKeeperApplication onCreate/PerfHook state")
    method = methods[0].group()
    anchor = "    return-void\n.end method"
    if method.count(anchor) != 1 or ".locals 0" in method:
        raise ValueError("Unexpected ZK PowerKeeperApplication onCreate layout")
    init_hook = (
        "    sget-object v0, Lcom/miui/powerkeeper/PowerKeeperApplication;->c:Landroid/content/Context;\n"
        f"    invoke-static {{v0}}, {PERF_HOOK}->getInstance(Landroid/content/Context;){PERF_HOOK}\n"
        "    move-result-object v0\n"
        f"    invoke-virtual {{v0}}, {PERF_HOOK}->init()V\n"
    )
    method = method.replace(anchor, init_hook + anchor)
    source = source[:methods[0].start()] + method + source[methods[0].end():]
    application.write_text(source, encoding="utf-8")

    output_dir = zk_root / "smali/classes/com/android/tnm/perf"
    if len(list(output_dir.glob("*.smali"))) != len(sources) or not framework.is_file():
        raise ValueError("TNM per-app PerfHook/Framework class set is incomplete")
    return {"tnm_per_app_perf_classes": copied, "tnm_framework_api_embedded": True,
            "application_init_hooked": True,
            "perfhook_boot_config_writes_suppressed": True}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--zk-raw", type=Path, required=True)
    parser.add_argument("--tnm-raw", type=Path, required=True)
    args = parser.parse_args()
    report = adapt_zk_smali(args.zk_raw)
    # EU-style battery-conscious UID cleanup: retained-app/visible-window
    # guards and per-UID POLICY 1/2 checks precede ProcessManager.kill().
    # The pinned RYU donor provides the equivalent scoped methods. All other
    # ZK controllers, GMS/Doze, thermal and TNM PerfHook code remain untouched.
    report.update(port_conditional_uid_kill(args.zk_raw, args.tnm_raw))
    # RYU/EU setUidState uses an interface getter absent from ZKOS.
    # Restore both the abstract declaration and the concrete UID POLICY reader
    # before DEX assembly. This also checks the existing second implementor.
    report.update(restore_uid_policy_abi(args.zk_raw))
    # The two local.config entries do not unconditionally suppress UID kill.
    # Skip only the GMS UID in the existing decision path (no daemon/polling).
    report.update(guard_gms_uid_kill(args.zk_raw))
    report.update(graft_tnm_per_app_perf(args.zk_raw, args.tnm_raw))
    report["powerkeeper_policy"] = "EU-style conditional UID kill + event-only GMS exemption, ZK background services, passive TNM PerfHook"
    report["non_dex_content"] = "Xiaomi stock original"
    print("[TNM ZK LOCAL DEX PORT] " + ", ".join(f"{k}={v}" for k, v in report.items()))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        print(f"[TNM ZK LOCAL DEX PORT] FAIL: {exc}", file=__import__("sys").stderr)
        raise SystemExit(1)
