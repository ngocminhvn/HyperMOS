#!/usr/bin/env python3
"""Fail closed unless all original RYU PerfHook classes are defined in output DEX."""
import argparse
import json
import re
import struct
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


def verify(apk: Path, report: Path) -> None:
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
        for name in files:
            data = archive.read(name)
            if (b"com/projectryu/perf/" in data
                    or b"com.projectryu.perf" in data):
                raise ValueError(
                    "Unrenamed original RYU PerfHook class/reference in compiled " + name)
            actual.update(defined_classes(data))
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
    args = parser.parse_args()
    verify(args.apk, args.report)


if __name__ == "__main__":
    main()
