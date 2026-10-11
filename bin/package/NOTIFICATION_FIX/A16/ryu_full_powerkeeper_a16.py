#!/usr/bin/env python3
"""Port *all* original RYUOS PowerKeeper bytecode into Xiaomi's APK at build time.

The pinned donor APK supplies every class/method (not a selective PerfHook
subset). Keep original Xiaomi AndroidManifest/resources and asset payloads.
Only adapt the known RYU Settings wrappers/build gates absent on
the target ROM. No loader, daemon, runtime hook or extra framework jar.
"""
import argparse
import hashlib
import json
import re
import shutil
import zipfile
from pathlib import Path

DEX = re.compile(r"classes(?:[2-9]\d*)?\.dex")
SMALI_DIR = re.compile(r"smali(?:_classes[2-9]\d*)?")
CLASS = re.compile(r"(?m)^\.class\b[^\n]*\s(L[^;\s]+;)\s*$")
BUILD_GATE = re.compile(
    r"(?m)^([ \t]*)sget-boolean ([vp]\d+), "
    r"Lcom/projectryu/Build;->IS_RYU_BUILD:Z[ \t]*$")
RYU_GET = (
    "Lcom/projectryu/ProjectRYUFramework;->getSystemString"
    "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;")
ANDROID_GET = (
    "Landroid/provider/Settings$System;->getString"
    "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;")
RYU_COMPAT = {
    # Original ProjectRYUFramework is absent from Xiaomi base. Its original
    # SettingsHelper methods use matching platform Settings.System signatures.
    # Keep calls inside PowerKeeper; do not add any runtime framework/hook.
    "getSystemInt": "getInt",
    "getSystemIntForUser": "getIntForUser",
    "getSystemLong": "getLong",
    "getSystemString": "getString",
    "putSystemInt": "putInt",
    "putSystemLong": "putLong",
    "putSystemString": "putString",
}
FOREIGN_CLASS = re.compile(r"Lcom/projectryu/[^;\s]+;")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def apk_contract(stock_apk: Path, donor_apk: Path):
    with zipfile.ZipFile(stock_apk) as stock, zipfile.ZipFile(donor_apk) as donor:
        for label, archive in (("Xiaomi", stock), ("RYU", donor)):
            if len(archive.namelist()) != len(set(archive.namelist())):
                raise ValueError(label + " APK has duplicate ZIP entries")
            bad = archive.testzip()
            if bad:
                raise ValueError(label + " APK has corrupt ZIP member " + bad)
        if stock.read("AndroidManifest.xml") != donor.read("AndroidManifest.xml"):
            raise ValueError("RYU/Xiaomi manifests differ; full bytecode port is unsafe")
        stock_dex = {name for name in stock.namelist() if DEX.fullmatch(name)}
        donor_dex = {name for name in donor.namelist() if DEX.fullmatch(name)}
        if not stock_dex or stock_dex != donor_dex:
            raise ValueError("RYU and Xiaomi DEX slots differ: "
                             + repr((sorted(stock_dex), sorted(donor_dex))))
        resources_equal = (
            "resources.arsc" in stock.namelist()
            and "resources.arsc" in donor.namelist()
            and stock.read("resources.arsc") == donor.read("resources.arsc"))
        return {
            "manifest_sha256": sha(stock.read("AndroidManifest.xml")),
            "dex_entries": sorted(donor_dex),
            "resources_arsc_equal": resources_equal,
            "donor_only_non_dex": sorted(set(donor.namelist())
                - set(stock.namelist()) - {n for n in donor.namelist()
                    if n.startswith("META-INF/")}),
        }


def dex_dirs(root: Path):
    return {p.name: p for p in root.iterdir()
            if p.is_dir() and SMALI_DIR.fullmatch(p.name)}


def classes(root: Path):
    result = {}
    for directory in dex_dirs(root).values():
        for path in directory.rglob("*.smali"):
            match = CLASS.search(path.read_text(encoding="utf-8"))
            if match is None:
                raise ValueError("Missing class descriptor: " + str(path))
            descriptor = match[1]
            if descriptor in result:
                raise ValueError("Duplicate donor class: " + descriptor)
            result[descriptor] = path
    return result


def adapt(body: str):
    """Minimal, build-time RYU framework compatibility, without new hooks."""
    reads = 0
    # Transplant the entire donor, including its SettingsHelper class. Exact
    # method signatures are preserved while only the provider class/method
    # owner changes to Android's platform Settings.System implementation.
    for ryu_name, platform_name in RYU_COMPAT.items():
        reference = "Lcom/projectryu/ProjectRYUFramework;->" + ryu_name + "("
        reads += body.count(reference)
        body = body.replace(
            reference, "Landroid/provider/Settings$System;->" + platform_name + "(")
    gates = 0

    def gate(match):
        nonlocal gates
        reg = match[2]
        if not reg.startswith("v"):
            raise ValueError("Unexpected parameter register for RYU build gate: " + reg)
        number = int(reg[1:])
        if number > 255:
            raise ValueError("RYU build gate register out of range")
        gates += 1
        insn = "const/4" if number < 16 else "const/16"
        return match[1] + insn + " " + reg + ", 0x1"

    body = BUILD_GATE.sub(gate, body)
    if ("Lcom/projectryu/ProjectRYUFramework;" in body
            or "Lcom/projectryu/Build;" in body):
        raise ValueError("Unsupported RYU framework reference after compatibility adaptation")
    return body, reads, gates


def port(stock_root: Path, donor_root: Path, stock_apk: Path,
         donor_apk: Path, report_path: Path):
    if not stock_root.is_dir() or not donor_root.is_dir():
        raise ValueError("APKEditor decoded directories are missing")
    contract = apk_contract(stock_apk, donor_apk)
    stock_dirs = dex_dirs(stock_root)
    source_dirs = dex_dirs(donor_root)
    if set(stock_dirs) != set(source_dirs):
        raise ValueError("RYU/Xiaomi decoded DEX directories do not match: "
                         + repr((sorted(stock_dirs), sorted(source_dirs))))
    original = classes(stock_root)
    donor = classes(donor_root)
    if len(donor) < 2800:
        raise ValueError("Incomplete original RYU PowerKeeper class set: " + str(len(donor)))
    required = [
        "Lcom/miui/powerkeeper/PowerKeeperApplication;",
        "Lcom/miui/powerkeeper/controller/KillProcessController;",
        "Lcom/miui/powerkeeper/AppRuleChecker;",
        "Lcom/miui/powerkeeper/PowerKeeperInterface$l;",
        "Lcom/projectryu/perf/PerfHook;",
    ]
    for descriptor in required:
        if descriptor not in donor:
            raise ValueError("Original RYU PowerKeeper is missing " + descriptor)
    perf_classes = sorted(name for name in donor if
                          name.startswith("Lcom/projectryu/perf/"))
    if len(perf_classes) != 20:
        raise ValueError("Expected all 20 original RYU perf classes, got "
                         + str(len(perf_classes)))

    # Validate everything before replacing the decoded Xiaomi bytecode.
    adapted = {}
    setting_reads = build_gates = 0
    for descriptor, source in donor.items():
        raw = source.read_text(encoding="utf-8")
        try:
            body, reads, gates = adapt(raw)
        except ValueError as exc:
            suspect = [line.strip()[:220] for line in raw.splitlines()
                       if ("Lcom/projectryu/ProjectRYUFramework;" in line
                           or "Lcom/projectryu/Build;" in line)]
            raise ValueError(f"{descriptor}: {exc}; references={suspect[:8]}") from exc
        adapted[descriptor] = body
        setting_reads += reads
        build_gates += gates
    if setting_reads < 3:
        raise ValueError("Original RYU PerfHook getSystemString callers missing")
    for descriptor, body in adapted.items():
        for reference in FOREIGN_CLASS.findall(body):
            if reference not in donor:
                raise ValueError(descriptor + " depends on missing foreign class " + reference)

    # Preserve the stock APK's manifest, resources and all non-DEX payload.
    # Only the decoded executable classes are replaced by the COMPLETE donor.
    for name in stock_dirs:
        shutil.rmtree(stock_dirs[name])
        shutil.copytree(source_dirs[name], stock_dirs[name], symlinks=False)
    for descriptor, body in adapted.items():
        relative = donor[descriptor].relative_to(donor_root)
        target = stock_root / relative
        target.write_text(body, encoding="utf-8")
    if set(classes(stock_root)) != set(donor):
        raise ValueError("Full donor class transfer produced a class-set mismatch")

    report = {
        "mode": "full original RYUOS PowerKeeper DEX port into Xiaomi APK",
        "original_xiaomi_classes": len(original),
        "original_ryu_classes": len(donor),
        "original_ryu_perf_classes": perf_classes,
        "classes": perf_classes,  # verify_perfhook_apk.py input contract
        "ryu_only_classes": sorted(set(donor) - set(original)),
        "xiaomi_only_classes_removed": sorted(set(original) - set(donor)),
        "adapted_ryu_framework_setting_reads": setting_reads,
        "adapted_ryu_build_gates": build_gates,
        "no_runtime_hook_or_daemon": True,
        "apk_contract": contract,
        "non_dex_payload": "original Xiaomi APK; donor executable classes",
        "runtime_tested": False,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n",
                           encoding="utf-8")
    print(f"[RYU FULL APK] {len(donor)} donor classes ({len(perf_classes)} PerfHook), "
          f"{setting_reads} Settings compatibility calls, {build_gates} build gates")
    print("[RYU FULL APK] All donor DEX methods staged; Xiaomi manifest/resources retained")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    for arg in ("stock-root", "donor-root", "stock-apk", "donor-apk", "report"):
        parser.add_argument("--" + arg, required=True, type=Path)
    args = parser.parse_args()
    port(args.stock_root, args.donor_root, args.stock_apk,
         args.donor_apk, args.report)
