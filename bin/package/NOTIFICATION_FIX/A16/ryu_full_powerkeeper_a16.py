#!/usr/bin/env python3
"""Port *all* original RYUOS PowerKeeper bytecode into Xiaomi's APK at build time.

The pinned donor APK supplies every class/method (not a selective PerfHook
subset). Keep original Xiaomi AndroidManifest/resources and asset payloads.
Route the known RYU Settings wrappers to embedded TNMFramework; adapt build gates absent on
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
# TNMFramework is a real Java/Dalvik API embedded into the PowerKeeper DEX,
# not merely the name of an external shell script or a ProjectRYU JAR alias.
# Its static methods implement the same Settings.System contract that the
# TNM root-on-demand adapter writes. No additional service/daemon is spawned.
TNM_API = "Lcom/android/tnm/TNMFramework;"
RYU_OWNER = "Lcom/projectryu/ProjectRYUFramework;"
SETTINGS_OWNER = "Landroid/provider/Settings$System;"
TNM_METHODS = {
    "getSystemInt": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;I)I", "getInt", 3, "I"),
    "getSystemIntForUser": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;II)I", "getIntForUser", 4, "I"),
    "getSystemLong": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;J)J", "getLong", 4, "J"),
    "getSystemString": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;", "getString", 2, "L"),
    "putSystemInt": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;I)Z", "putInt", 3, "Z"),
    "putSystemLong": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;J)Z", "putLong", 4, "Z"),
    "putSystemString": (
        "(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z", "putString", 3, "Z"),
}
RYU_GET = RYU_OWNER + "->getSystemString" + TNM_METHODS["getSystemString"][0]
TNM_GET = TNM_API + "->getSystemString" + TNM_METHODS["getSystemString"][0]
OLD_PERF_PREFIX = "Lcom/projectryu/perf/"
TNM_PERF_PREFIX = "Lcom/android/tnm/perf/"
OLD_PERF_PATH = "com/projectryu/perf/"
TNM_PERF_PATH = "com/android/tnm/perf/"


def tnm_framework_smali():
    lines = [
        ".class public final " + TNM_API,
        ".super Ljava/lang/Object;",
        "",
        ".method private constructor <init>()V",
        "    .locals 0",
        "    invoke-direct {p0}, Ljava/lang/Object;-><init>()V",
        "    return-void",
        ".end method",
        "",
    ]
    for name, (proto, method, slots, result) in TNM_METHODS.items():
        operand = ", ".join("p" + str(i) for i in range(slots))
        lines.extend([
            ".method public static " + name + proto,
            "    .locals " + ("2" if result == "J" else "1"),
            "    invoke-static {" + operand + "}, " + SETTINGS_OWNER + "->" + method + proto,
            "    move-result" + ("-wide" if result == "J" else "-object" if result == "L" else "") + " v0",
            "    return" + ("-wide" if result == "J" else "-object" if result == "L" else "") + " v0",
            ".end method",
            "",
        ])
    return "\n".join(lines)


def install_tnm_framework(stock_root, donor):
    if TNM_API in donor:
        raise ValueError("Donor already defines TNMFramework; refusing overwrite")
    dirs = dex_dirs(stock_root)
    output_dir = dirs.get("smali") or next(iter(dirs.values()), None)
    if output_dir is None:
        raise ValueError("No decoded DEX directory for TNMFramework")
    target = output_dir / "com/android/tnm/TNMFramework.smali"
    if target.exists():
        raise ValueError("Duplicate embedded TNMFramework class")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(tnm_framework_smali(), encoding="utf-8")
    return str(target.relative_to(stock_root))


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



# The original RYU writeRawAndVerify uses strict string equality on sysfs.
# If kernel/thermal keeps a lower, positive MAX CPU/GPU cap, it is safer and
# shouldn't become a write-loop/false failure. Only after successful write;
# preserve errors, sconfig writes, and scaling_min_freq strict verification.
SAFE_MAX_HELPER = r"""
.method private static tnmSafeMaxClamp(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
    .locals 7

    const/4 v0, 0x0
    if-eqz p0, :tnm_false
    if-eqz p1, :tnm_false
    if-eqz p2, :tnm_false

    const-string v1, "/sys/devices/system/cpu/cpufreq/policy"
    invoke-virtual {p0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :tnm_gpu_path
    const-string v1, "/scaling_max_freq"
    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :tnm_compare

    :tnm_gpu_path
    const-string v1, "/sys/class/kgsl/"
    invoke-virtual {p0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :tnm_false
    const-string v1, "/devfreq/max_freq"
    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :tnm_false

    :tnm_compare
    :try_start_tnm
    invoke-static {p1}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J
    move-result-wide v1
    invoke-static {p2}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J
    move-result-wide v3
    const-wide/16 v5, 0x0
    cmp-long v0, v3, v5
    if-lez v0, :tnm_false
    cmp-long v0, v3, v1
    if-gez v0, :tnm_false
    :try_end_tnm
    .catch Ljava/lang/NumberFormatException; {:try_start_tnm .. :try_end_tnm} :tnm_parse_error

    const/4 v0, 0x1
    return v0

    :tnm_parse_error
    move-exception v1

    :tnm_false
    const/4 v0, 0x0
    return v0
.end method
"""


def patch_perfhook_write_verify(smali: str) -> str:
    """Safely allow lower CPU/GPU maximum caps, not failed writes."""
    if "tnmSafeMaxClamp(" in smali:
        raise ValueError("RYU PerfHook already has safe clamp patch")
    pattern = re.compile(
        r"(?ms)^\.method private writeRawAndVerify"
        r"\(Ljava/lang/String;Ljava/lang/String;\)Z\s*$.*?^\.end method$")
    matches = list(pattern.finditer(smali))
    if len(matches) != 1:
        raise ValueError("Expected exactly one RYU writeRawAndVerify method")
    found = matches[0]
    method = found.group()
    for required in (
        "    .locals 7",
        '    const-string v2, "Write did not stick: "',
        "->readTrimmed(Ljava/lang/String;)Ljava/lang/String;",
        "    return v3",
        "    return v4",
    ):
        if required not in method:
            raise ValueError("Unknown RYU write verifier layout: " + required)
    old = "    if-nez v1, :cond_2\n\n    new-instance v1, Ljava/lang/StringBuilder;"
    if method.count(old) != 1:
        raise ValueError("RYU strict readback comparison anchor changed")
    # The p0 receiver is a PerfHook instance, NOT a String. Re-read the
    # kernel value only on mismatch and keep it in the disposable v1 register.
    # All three helper arguments must be String references for ART verification.
    new = (
        "    if-nez v1, :cond_2\n\n"
        "    invoke-direct {p0, p1}, "
        "Lcom/android/tnm/perf/PerfHook;->readTrimmed"
        "(Ljava/lang/String;)Ljava/lang/String;\n"
        "    move-result-object v1\n"
        "    invoke-static {p1, p2, v1}, "
        "Lcom/android/tnm/perf/PerfHook;->tnmSafeMaxClamp"
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z\n"
        "    move-result v1\n"
        "    if-eqz v1, :tnm_exact_mismatch\n"
        "    return v4\n\n"
        "    :tnm_exact_mismatch\n"
        "    new-instance v1, Ljava/lang/StringBuilder;"
    )
    method = method.replace(old, new)
    if method.count("->tnmSafeMaxClamp(") != 1:
        raise ValueError("Expected exactly one safe clamp caller")
    return smali[:found.start()] + method + smali[found.end():] + "\n" + SAFE_MAX_HELPER


def adapt(body: str):
    """Minimal, build-time RYU framework compatibility, without new hooks."""
    reads = 0
    # Every original RYU call now targets a REAL concrete TNMFramework method
    # defined within PowerKeeper. The TNM controller and this API share the
    # original Settings keys, but no foreign framework JAR is loaded.
    for name, (proto, _, _, _) in TNM_METHODS.items():
        reference = RYU_OWNER + "->" + name + proto
        reads += body.count(reference)
        body = body.replace(reference, TNM_API + "->" + name + proto)
    gates = 0

    def gate(match):
        nonlocal gates
        reg = match[2]
        if not reg.startswith(("v", "p")):
            raise ValueError("Unexpected register for RYU build gate: " + reg)
        number = int(reg[1:])
        if number > 255:
            raise ValueError("RYU build gate register out of range")
        gates += 1
        # A p-register aliases a physical register after the local registers.
        # const/4 has only a 4-bit register operand; const/16 supports 8 bits.
        # The original donor method is subsequently assembled and validated.
        insn = "const/4" if reg.startswith("v") and number < 16 else "const/16"
        return match[1] + insn + " " + reg + ", 0x1"

    body = BUILD_GATE.sub(gate, body)
    # Remap original RYU PerfHook implementation to TNM's namespace.
    # Update ALL DEX references, including self/cross-class descriptors
    # and dotted class names sometimes used by Class.forName/reflection.
    # Do not touch projectryu_thermal_* Settings keys: those are the
    # live config protocol consumed by the transplanted PerfHook observer.
    body = body.replace(OLD_PERF_PREFIX, TNM_PERF_PREFIX)
    body = body.replace(OLD_PERF_PATH, TNM_PERF_PATH)
    body = body.replace("com.projectryu.perf.", "com.android.tnm.perf.")
    if "com.projectryu.perf" in body or OLD_PERF_PATH in body:
        raise ValueError("Unconverted original PerfHook namespace in DEX smali")
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
    safe_max_patch_count = 0
    for descriptor, source in donor.items():
        raw = source.read_text(encoding="utf-8")
        try:
            body, reads, gates = adapt(raw)
        except ValueError as exc:
            suspect = [line.strip()[:220] for line in raw.splitlines()
                       if ("Lcom/projectryu/ProjectRYUFramework;" in line
                           or "Lcom/projectryu/Build;" in line)]
            raise ValueError(f"{descriptor}: {exc}; references={suspect[:8]}") from exc
        if descriptor == "Lcom/projectryu/perf/PerfHook;":
            body = patch_perfhook_write_verify(body)
            safe_max_patch_count += 1
        adapted[descriptor] = body
        setting_reads += reads
        build_gates += gates
    if safe_max_patch_count != 1:
        raise ValueError("Missing RYU safe max-frequency verification patch")
    if setting_reads < 3:
        raise ValueError("Original RYU PerfHook getSystemString callers missing")
    for descriptor, body in adapted.items():
        for reference in FOREIGN_CLASS.findall(body):
            if reference not in donor:
                raise ValueError(descriptor + " depends on missing foreign class " + reference)

    renamed_perf = sorted(
        TNM_PERF_PREFIX + name[len(OLD_PERF_PREFIX):] for name in perf_classes)
    # Avoid accidental collisions before overwriting Xiaomi bytecode.
    if set(renamed_perf) & (set(donor) - set(perf_classes)):
        raise ValueError("TNM PerfHook namespace collides with donor class")

    # Preserve the stock APK's manifest, resources and all non-DEX payload.
    # Only the decoded executable classes are replaced by the COMPLETE donor.
    for name in stock_dirs:
        shutil.rmtree(stock_dirs[name])
        shutil.copytree(source_dirs[name], stock_dirs[name], symlinks=False)
    for descriptor, body in adapted.items():
        relative = donor[descriptor].relative_to(donor_root)
        target = stock_root / relative
        if descriptor.startswith(OLD_PERF_PREFIX):
            # Relocate the source file together with its class descriptor.
            # No obsolete com/projectryu/perf/*.smali survives the build.
            if OLD_PERF_PATH not in relative.as_posix():
                raise ValueError("Unexpected RYU PerfHook file location")
            new_relative = Path(relative.as_posix().replace(
                OLD_PERF_PATH, TNM_PERF_PATH, 1))
            new_target = stock_root / new_relative
            if new_target.exists():
                raise ValueError("Duplicate TNM PerfHook destination " + str(new_target))
            new_target.parent.mkdir(parents=True, exist_ok=True)
            target.unlink()
            target = new_target
        target.write_text(body, encoding="utf-8")
    embedded_api = install_tnm_framework(stock_root, donor)
    actual_classes = set(classes(stock_root))
    expected_classes = (set(donor) - set(perf_classes)) | set(renamed_perf) | {TNM_API}
    if actual_classes != expected_classes:
        raise ValueError("Full donor + renamed TNM PerfHook/framework class-set mismatch")
    if any(name.startswith(OLD_PERF_PREFIX) for name in actual_classes):
        raise ValueError("Legacy RYU PerfHook class definition survived")

    report = {
        "mode": "full original RYUOS PowerKeeper DEX port into Xiaomi APK",
        "original_xiaomi_classes": len(original),
        "original_ryu_classes": len(donor),
        "original_ryu_perf_classes": perf_classes,
        "classes": renamed_perf,  # compiled DEX verifier contract
        "tnm_perf_classes": renamed_perf,
        "renamed_ryu_perf_classes": len(renamed_perf),
        "legacy_ryu_perf_classes_remaining": 0,
        "ryu_only_classes": sorted(set(donor) - set(original)),
        "xiaomi_only_classes_removed": sorted(set(original) - set(donor)),
        "adapted_ryu_framework_setting_reads": setting_reads,
        "tnm_framework_api": TNM_API,
        "tnm_framework_method_signatures": [
            name + details[0] for name, details in TNM_METHODS.items()],
        "tnm_framework_embedded_path": embedded_api,
        "tnm_framework_call_sites": setting_reads,
        "projectryu_framework_jars_required": False,
        "adapted_ryu_build_gates": build_gates,
        "safe_cpu_gpu_max_clamp_verification": True,
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
    print("[RYU FULL APK] All donor DEX methods staged; TNMFramework API embedded; 20 PerfHook classes renamed to TNM; Xiaomi manifest/resources retained")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    for arg in ("stock-root", "donor-root", "stock-apk", "donor-apk", "report"):
        parser.add_argument("--" + arg, required=True, type=Path)
    args = parser.parse_args()
    port(args.stock_root, args.donor_root, args.stock_apk,
         args.donor_apk, args.report)
