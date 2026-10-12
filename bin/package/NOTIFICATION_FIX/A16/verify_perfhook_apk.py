#!/usr/bin/env python3
"""Fail closed unless all original RYU PerfHook classes are defined in output DEX."""
import argparse
import json
import re
import struct
import subprocess
import tempfile
import zipfile
from pathlib import Path


def defined_classes(blob: bytes) -> set[str]:
    if not blob.startswith(b"dex\n") or len(blob) < 0x70:
        raise ValueError("Invalid Android DEX")
    u32 = lambda pos: struct.unpack_from("<I", blob, pos)[0]
    str_count, str_off = u32(0x38), u32(0x3c)
    typ_count, typ_off = u32(0x40), u32(0x44)
    cls_count, cls_off = u32(0x60), u32(0x64)
    if (str_off + str_count * 4 > len(blob)
            or typ_off + typ_count * 4 > len(blob)
            or cls_off + cls_count * 32 > len(blob)):
        raise ValueError("Invalid DEX header tables")
    result = set()
    for i in range(cls_count):
        typ_idx = u32(cls_off + 32 * i)
        if typ_idx >= typ_count:
            raise ValueError("DEX class index outside type table")
        str_idx = u32(typ_off + 4 * typ_idx)
        if str_idx >= str_count:
            raise ValueError("DEX class descriptor outside string table")
        pos = u32(str_off + 4 * str_idx)
        # Dex string_data_item begins with UTF-16 length encoded as ULEB128.
        for _ in range(5):
            if pos >= len(blob):
                raise ValueError("DEX string offset out of bounds")
            flag = blob[pos]
            pos += 1
            if not flag & 0x80:
                break
        else:
            raise ValueError("Invalid DEX string length encoding")
        end = blob.find(b"\0", pos)
        if end < 0:
            raise ValueError("DEX descriptor not terminated")
        result.add(blob[pos:end].decode("utf-8"))
    return result



def verify_compiled_perfhook_smali(smali: str) -> None:
    """Reject the concrete ART receiver-type VerifyError from ROM #126."""
    match = re.search(
        r"(?ms)^\.method[^\n]*\bwriteRawAndVerify"
        r"\(Ljava/lang/String;Ljava/lang/String;\)Z[^\n]*$.*?^\.end method$",
        smali)
    if match is None:
        raise ValueError("Compiled writeRawAndVerify method missing")
    body = match.group()
    if not re.search(r"(?m)^\s+\.locals 8\s*$", body):
        raise ValueError("Compiled PerfHook needs local v7")
    instructions = [line.strip() for line in body.splitlines()
                    if re.match(r"^\s+[a-z][a-z0-9/-]*\s", line)]
    if not instructions or instructions[0] not in (
            "move-object/from16 v7, p0", "move-object v7, p0"):
        raise ValueError("Compiled PerfHook does not save this at entry")
    read = ("invoke-direct {v7, p1}, "
            "Lcom/android/tnm/perf/PerfHook;->readTrimmed"
            "(Ljava/lang/String;)Ljava/lang/String;")
    clamp = ("invoke-static {p1, p2, v1}, "
             "Lcom/android/tnm/perf/PerfHook;->tnmSafeMaxClamp"
             "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z")
    if read not in instructions or clamp not in instructions:
        raise ValueError("Compiled readTrimmed/clamp has wrong registers")
    pos = instructions.index(read)
    if instructions[pos + 1:pos + 3] != ["move-result-object v1", clamp]:
        raise ValueError("Compiled readback result type/order changed")
    if sum(bool(re.search(r"\bv7\b", line)) for line in instructions) != 2:
        raise ValueError("Compiled PerfHook saved receiver was overwritten")
    print("[RYU PERFHOOK] PASS: compiled DEX uses saved typed receiver v7")


def verify_compiled_receiver(dex_blob: bytes, baksmali: Path) -> None:
    if not baksmali or not baksmali.is_file():
        raise ValueError("Compiled DEX verification requires --baksmali")
    with tempfile.TemporaryDirectory(prefix="tnm-perfhook-dex-") as td:
        root = Path(td)
        dex = root / "classes.dex"
        out = root / "decoded"
        dex.write_bytes(dex_blob)
        cmd = ["java", "-jar", str(baksmali.resolve()), "d",
               "--use-locals", "-o", str(out), str(dex)]
        result = subprocess.run(cmd, capture_output=True, text=True,
                                timeout=120, check=False)
        if result.returncode:
            raise ValueError("Compiled DEX disassembly failed: " +
                             (result.stderr or result.stdout)[-1500:])
        smali = out / "com/android/tnm/perf/PerfHook.smali"
        if not smali.is_file():
            raise ValueError("Compiled PerfHook missing from disassembled DEX")
        verify_compiled_perfhook_smali(smali.read_text(encoding="utf-8"))


def verify(apk: Path, report: Path, baksmali: Path = None) -> None:
    manifest = json.loads(report.read_text(encoding="utf-8"))
    expected = set(manifest["classes"])
    safe_readback = manifest.get("safe_cpu_gpu_max_clamp_verification") is True
    if manifest.get("mode", "").startswith("full original RYUOS") and not safe_readback:
        raise ValueError("Full RYU port must verify safe max-frequency guard")
    if len(expected) != 20 or any(
            not name.startswith("Lcom/android/tnm/perf/") for name in expected):
        raise ValueError("Expected exactly 20 TNM-namespaced PerfHook classes")
    if len(expected) < 17:
        raise ValueError("Incomplete expected PerfHook class list")
    with zipfile.ZipFile(apk) as archive:
        files = [name for name in archive.namelist()
                 if re.fullmatch(r"classes(?:(?:[2-9]|[1-9]\d+))?\.dex", name)]
        if not files:
            raise ValueError("No compiled DEX found in APK")
        actual = set()
        compiled_methods = {}
        receiver_dex = None
        for name in files:
            data = archive.read(name)
            if (b"com/projectryu/perf/" in data
                    or b"com.projectryu.perf" in data):
                raise ValueError(
                    "Unrenamed original RYU PerfHook class/reference in compiled " + name)
            defined = defined_classes(data)
            actual.update(defined)
            if "Lcom/android/tnm/perf/PerfHook;" in defined:
                if receiver_dex is not None:
                    raise ValueError("Duplicate PerfHook class across DEX")
                receiver_dex = data
            if safe_readback:
                from verify_ryu_uid_policy_apk import entries
                methods = entries(data)
                duplicate = set(compiled_methods) & set(methods)
                if duplicate:
                    raise ValueError("Duplicate PerfHook DEX method definition")
                compiled_methods.update(methods)
    if safe_readback:
        owner = "Lcom/android/tnm/perf/PerfHook;"
        for method in (
            (owner, "tnmSafeMaxClamp",
             "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z"),
            (owner, "writeRawAndVerify", "(Ljava/lang/String;Ljava/lang/String;)Z"),
        ):
            if not compiled_methods.get(method):
                raise ValueError("Missing concrete safe MAX verification method: "
                                 + repr(method))
        if receiver_dex is None:
            raise ValueError("Compiled PerfHook class missing")
        verify_compiled_receiver(receiver_dex, baksmali)
        print("[RYU PERFHOOK] PASS: safe CPU/GPU MAX clamp guard compiled")
    missing = sorted(expected - actual)
    if missing:
        raise ValueError("APK silently omitted original RYU PerfHook classes: " + repr(missing))
    if "Lcom/miui/powerkeeper/PowerKeeperApplication;" not in actual:
        raise ValueError("Rebuilt APK missing PowerKeeperApplication")
    print("[RYU PERFHOOK] PASS: all", len(expected),
          "original RYU implementation classes renamed to TNM and defined in compiled APK DEX (" + ", ".join(files) + ")")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--baksmali", type=Path,
                        help="Required for full-donor DEX receiver verification")
    args = parser.parse_args()
    verify(args.apk, args.report, args.baksmali)


if __name__ == "__main__":
    main()
