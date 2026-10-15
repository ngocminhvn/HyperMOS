#!/usr/bin/env python3
"""Preflight the actual pinned HAOTIAN ZKOS and RYU DEX sources, without a ROM.

This stages exactly the same Python DEX adaptations and smali compiler used
by the production port. It cannot prove that the Android APK loads or boots.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import traceback

from powerkeeper import adapt as adapt_ryu
from ryu_killprocess_a16 import get_methods, SET_UID, RULE_CHECK

REPO = Path(__file__).resolve().parents[4]
CONTROLLER = "com/miui/powerkeeper/controller"


def run(*args):
    command = [str(a) for a in args]
    print("[PREFLIGHT CMD]", " ".join(command), flush=True)
    subprocess.run(command, check=True)


def files(root):
    return {
        p.relative_to(root).as_posix(): p
        for p in root.rglob("*.smali")
    }


def unique_class(root, name):
    hits = list(root.rglob(name + ".smali"))
    if len(hits) != 1:
        raise ValueError(f"Expected one {name} in {root}, found {len(hits)}")
    return hits[0]


def validate(zk_dex, ryu_dex, output):
    results = {"device": "HAOTIAN Android 16", "source": "pinned local RYU and ZKOS DEX",
               "rom_built": False, "real_apk_tested": False, "boot_tested": False}
    with tempfile.TemporaryDirectory(prefix="a16-real-dex-") as tmp:
        root = Path(tmp)
        z = root / "zk" / "smali" / "classes"
        r = root / "ryu" / "smali" / "classes"
        z.mkdir(parents=True)
        r.mkdir(parents=True)
        run("baksmali", "disassemble", "--api", "36", "--use-locals", "--jobs", "2", zk_dex, "-o", z)
        run("baksmali", "disassemble", "--api", "36", "--use-locals", "--jobs", "2", ryu_dex, "-o", r)

        names = ("KillProcessController", "GmsObserver", "ActiveStateController")
        originals = {}
        for name in names:
            path = unique_class(z, name)
            donor = unique_class(r, name)
            print(f"[DEX CLASS] {name}: ZKOS={path.relative_to(z)}, RYU={donor.relative_to(r)}")
            originals[name] = path.read_text(encoding="utf-8")
        ryu_methods = get_methods((r / CONTROLLER / "KillProcessController.smali").read_text())
        source_methods = get_methods(originals["KillProcessController"])
        results["source_zkos_controller_method_count"] = len(source_methods)
        results["source_ryu_controller_method_count"] = len(ryu_methods)

        run(sys.executable, REPO / "bin/package/NOTIFICATION_FIX/A16/zk_full_powerkeeper_a16.py",
            "--zk-raw", root / "zk", "--tnm-raw", root / "ryu")
        staged = files(z)
        actual_methods = get_methods((z / CONTROLLER / "KillProcessController.smali").read_text())
        expected_uid = adapt_ryu(ryu_methods[SET_UID])[0]
        expected_checker = adapt_ryu(ryu_methods[RULE_CHECK])[0]
        if actual_methods[SET_UID] != expected_uid or actual_methods[RULE_CHECK] != expected_checker:
            raise ValueError("Ported UID-kill methods do not match the original RYU source")
        if any(actual_methods.get(m) != body for m, body in source_methods.items() if m != SET_UID):
            raise ValueError("Unrelated ZKOS KillProcessController method changed")
        if "com.google.android.gms" in actual_methods[SET_UID]:
            raise ValueError("Unexpected custom GMS exception in RYU policy")
        for token in ("->isLockedApplication(", "->checkAppOnWindowsStatus(I)Z",
                      "Lmiui/process/ProcessManager;->kill(", "->shouldKillByCheckerPolicy(I)Z"):
            if token not in actual_methods[SET_UID]:
                raise ValueError(f"Missing RYU UID policy operation: {token}")
        for name in ("GmsObserver", "ActiveStateController"):
            old = get_methods(originals[name])
            new = get_methods(unique_class(z, name).read_text())
            if old.keys() != new.keys():
                raise ValueError(f"{name} method inventory changed")
        perf_dir = z / "com/android/tnm/perf"
        perf_classes = list(perf_dir.glob("*.smali"))
        if len(perf_classes) != 20:
            raise ValueError(f"Expected 20 TNM PerfHook classes, got {len(perf_classes)}")
        if not (z / "com/android/tnm/TNMFramework.smali").is_file():
            raise ValueError("Missing TNMFramework")
        application = (z / "com/miui/powerkeeper/PowerKeeperApplication.smali").read_text()
        if "Lcom/android/tnm/perf/PerfHook;->init()V" not in application:
            raise ValueError("PerfHook initialization call missing")
        results["ryu_uid_and_checker_methods_exact_after_adaptation"] = True
        results["unchanged_zkos_controller_methods"] = len(source_methods) - 1
        results["tnm_perfhook_class_count"] = len(perf_classes)
        results["staged_class_count"] = len(staged)
        results["custom_gms_exception"] = False

        jar = REPO / "bin/apktool/smaliv2.jar"
        if not jar.is_file():
            raise FileNotFoundError(f"Production smali compiler not found: {jar}")
        dex_out = root / "ported-classes.dex"
        run("java", "-jar", jar, "a", "--api", "36", z, "-o", dex_out)
        if dex_out.stat().st_size < 4096:
            raise ValueError("Recompiled DEX is missing or suspiciously small")
        compiled = root / "compiled"
        compiled.mkdir()
        run("baksmali", "disassemble", "--api", "36", "--use-locals", "--jobs", "2", dex_out, "-o", compiled)
        compiled_files = files(compiled)
        if set(compiled_files) != set(staged):
            raise ValueError(
                f"Class inventory differs after DEX rebuild: "
                f"missing={sorted(set(staged)-set(compiled_files))[:15]}, "
                f"unexpected={sorted(set(compiled_files)-set(staged))[:15]}"
            )
        compiled_kill = (compiled / CONTROLLER / "KillProcessController.smali").read_text()
        for token in ("shouldKillByCheckerPolicy(I)Z", "->isLockedApplication(",
                      "->checkAppOnWindowsStatus(I)Z", "Lmiui/process/ProcessManager;->kill("):
            if token not in compiled_kill:
                raise ValueError(f"Reassembled DEX lost RYU policy: {token}")
        if "com.google.android.gms" in compiled_kill:
            raise ValueError("Compiled controller contains unwanted GMS exemption")
        if not (compiled / "com/android/tnm/perf/PerfHook.smali").is_file():
            raise ValueError("Compiled DEX missing relocated PerfHook")
        if not (compiled / "com/android/tnm/TNMFramework.smali").is_file():
            raise ValueError("Compiled DEX missing TNMFramework")
        results["compiled_dex_bytes"] = dex_out.stat().st_size
        results["compiled_class_count"] = len(compiled_files)
        results["compiled_classes_match_staged_classes"] = True
        results["real_dex_rebuild_succeeded"] = True
    return results


def main():
    cli = argparse.ArgumentParser()
    cli.add_argument("--zk", type=Path, required=True)
    cli.add_argument("--ryu", type=Path, required=True)
    cli.add_argument("--report", type=Path, required=True)
    args = cli.parse_args()
    args.report.parent.mkdir(parents=True, exist_ok=True)
    try:
        record = validate(args.zk, args.ryu, args.report)
        record["outcome"] = "PASS"
        exit_code = 0
    except Exception as error:
        traceback.print_exc()
        record = {"outcome": "FAIL", "failure": str(error),
                  "real_dex_rebuild_succeeded": False,
                  "rom_built": False, "boot_tested": False}
        exit_code = 1
    args.report.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print("[PREFLIGHT RESULT]", json.dumps(record, indent=2))
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
