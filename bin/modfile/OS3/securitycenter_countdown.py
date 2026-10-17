#!/usr/bin/env python3
"""Patch Xiaomi SecurityCenter confirmation countdowns in decoded smali.

The input is APKEditor raw output.  Only the named permission/install classes
are touched; manifest, resources, native libraries, and every unrelated class
remain stock from the downloaded ROM.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path


FRAGMENT = "com/miui/permcenter/privacymanager/InterceptPermissionFragment.smali"
INPUT_ACTIVITY = "com/miui/permcenter/install/AdbInputApplyActivity"
INSTALL_ACTIVITY = "com/miui/permcenter/install/AdbInstallActivity"

METHOD_RE = re.compile(r"(?ms)^\.method\b.*?^\.end method\s*$")
RETURN_INT_RE = re.compile(
    r"(?ms)^\.method\s+protected\s+[^\n]*\(\)I\s*\n"
    r"(?P<body>.*?)^\.end method\s*$"
)
CONST_INT_RE = re.compile(r"(?m)^\s*const(?:/4|/16)?\s+(?P<reg>[vp]\d+),\s*(?P<value>0x[a-fA-F0-9]+)\s*$")
RETURN_RE = re.compile(r"(?m)^\s*return\s+(?P<reg>[vp]\d+)\s*$")
WIDE_RE = re.compile(
    r"^(?P<prefix>\s*const-wide(?:/16|/32)?\s+(?P<reg>[vp]\d+),\s*)"
    r"(?P<value>-?0x[a-fA-F0-9]+)(?P<suffix>\s*)$"
)
DELAY_CALL = "Landroid/os/Handler;->sendEmptyMessageDelayed(IJ)Z"
DEX_RE = re.compile(r"classes(?:[2-9]|[1-9]\d+)?\.dex\Z")


@dataclass
class PatchReport:
    fragment_file: str
    fragment_old_seconds: int
    fragment_new_seconds: int
    adb_input_delay_sites: int
    adb_install_delay_sites: int
    changed_files: list[str]


def smali_files(decoded: Path) -> list[Path]:
    return sorted(path for path in decoded.rglob("*.smali") if path.is_file())


def unique_suffix(files: list[Path], suffix: str) -> Path:
    normalized = suffix.replace("\\", "/")
    matches = [path for path in files if path.as_posix().endswith(normalized)]
    if len(matches) != 1:
        raise ValueError(f"Expected one {suffix}, found {len(matches)}")
    return matches[0]


def class_family(files: list[Path], class_path: str) -> list[Path]:
    parent, stem = class_path.rsplit("/", 1)
    result = []
    for path in files:
        posix = path.as_posix()
        name = path.name
        if f"/{parent}/" not in posix:
            continue
        if name == stem + ".smali" or (name.startswith(stem + "$") and name.endswith(".smali")):
            result.append(path)
    if not result:
        raise ValueError(f"Class family not found: {class_path}")
    return sorted(result)


def meaningful_method_lines(body: str) -> list[str]:
    result = []
    for line in body.splitlines():
        stripped = line.strip()
        if (not stripped or stripped.startswith(".line") or
                stripped.startswith(".locals") or stripped.startswith(".registers")):
            continue
        result.append(stripped)
    return result


def patch_fragment(text: str) -> tuple[str, int]:
    candidates = []
    for match in RETURN_INT_RE.finditer(text):
        body = match.group("body")
        constants = list(CONST_INT_RE.finditer(body))
        returns = list(RETURN_RE.finditer(body))
        lines = meaningful_method_lines(body)
        if len(constants) != 1 or len(returns) != 1 or len(lines) != 2:
            continue
        if constants[0].group("reg") != returns[0].group("reg"):
            continue
        value = int(constants[0].group("value"), 16)
        if value in (0, 10):
            candidates.append((match, constants[0], value))
    if len(candidates) != 1:
        raise ValueError(
            "InterceptPermissionFragment countdown method is ambiguous or unsupported: "
            f"found {len(candidates)} candidates"
        )
    method, constant, old = candidates[0]
    if old == 0:
        return text, old
    body = method.group("body")
    start = method.start("body") + constant.start("value")
    end = method.start("body") + constant.end("value")
    return text[:start] + "0x0" + text[end:], old


def patch_delays(text: str) -> tuple[str, int, int]:
    lines = text.splitlines(keepends=True)
    sites = 0
    changed = 0
    for index, line in enumerate(lines):
        if DELAY_CALL not in line:
            continue
        invoke_registers = set(re.findall(r"[vp]\d+", line.split("}", 1)[0]))
        constant_index = None
        constant_match = None
        for previous in range(index - 1, max(-1, index - 25), -1):
            candidate = WIDE_RE.match(lines[previous].rstrip("\r\n"))
            if candidate and candidate.group("reg") in invoke_registers:
                constant_index = previous
                constant_match = candidate
                break
        if constant_index is None or constant_match is None:
            raise ValueError("Countdown delay call has no nearby const-wide argument")
        value = int(constant_match.group("value"), 16)
        if value not in (0, 1000, 1600):
            raise ValueError(f"Unsupported SecurityCenter countdown delay: {value} ms")
        sites += 1
        if value:
            ending = "\r\n" if lines[constant_index].endswith("\r\n") else "\n" if lines[constant_index].endswith("\n") else ""
            lines[constant_index] = (
                constant_match.group("prefix") + "0x0" + constant_match.group("suffix") + ending
            )
            changed += 1
    return "".join(lines), sites, changed


def process(decoded: Path, apply: bool) -> PatchReport:
    files = smali_files(decoded)
    fragment = unique_suffix(files, FRAGMENT)
    input_files = class_family(files, INPUT_ACTIVITY)
    install_files = class_family(files, INSTALL_ACTIVITY)
    changed_files: list[str] = []

    fragment_text = fragment.read_text(encoding="utf-8")
    fragment_patched, fragment_old = patch_fragment(fragment_text)
    if fragment_patched != fragment_text:
        changed_files.append(str(fragment.relative_to(decoded)))
        if apply:
            fragment.write_text(fragment_patched, encoding="utf-8", newline="")

    counts = {}
    for label, family in (("adb_input", input_files), ("adb_install", install_files)):
        total_sites = 0
        total_changed = 0
        for path in family:
            original = path.read_text(encoding="utf-8")
            patched, sites, changed = patch_delays(original)
            total_sites += sites
            total_changed += changed
            if patched != original:
                changed_files.append(str(path.relative_to(decoded)))
                if apply:
                    path.write_text(patched, encoding="utf-8", newline="")
        counts[label] = (total_sites, total_changed)

    if counts["adb_input"][0] < 2:
        raise ValueError("AdbInputApplyActivity countdown coverage is incomplete")
    if counts["adb_install"][0] < 2:
        raise ValueError("AdbInstallActivity countdown coverage is incomplete")
    if not apply:
        if fragment_old != 0:
            raise ValueError("InterceptPermissionFragment countdown is not zero")
        if counts["adb_input"][1] or counts["adb_install"][1]:
            raise ValueError("One or more ADB countdown delays are not zero")

    return PatchReport(
        fragment_file=str(fragment.relative_to(decoded)),
        fragment_old_seconds=fragment_old,
        fragment_new_seconds=0,
        adb_input_delay_sites=counts["adb_input"][0],
        adb_install_delay_sites=counts["adb_install"][0],
        changed_files=sorted(changed_files),
    )


def compare_apks(base: Path, apk: Path) -> dict:
    with zipfile.ZipFile(base) as original, zipfile.ZipFile(apk) as patched:
        original_names = original.namelist()
        patched_names = patched.namelist()
        if len(original_names) != len(set(original_names)):
            raise ValueError("Base APK contains duplicate ZIP entries")
        if len(patched_names) != len(set(patched_names)):
            raise ValueError("Patched APK contains duplicate ZIP entries")
        if original.testzip() or patched.testzip():
            raise ValueError("Base or patched APK contains a corrupt ZIP entry")
        if set(original_names) != set(patched_names):
            raise ValueError("Patched APK entry inventory differs from stock")
        dex_names = sorted(name for name in original_names if DEX_RE.fullmatch(name))
        if not dex_names:
            raise ValueError("Stock APK contains no DEX entries")
        changed_dex = []
        for name in original_names:
            before = original.read(name)
            after = patched.read(name)
            if DEX_RE.fullmatch(name):
                if before != after:
                    changed_dex.append(name)
            elif before != after:
                raise ValueError("Non-DEX APK content changed: " + name)
    if not changed_dex:
        raise ValueError("No compiled DEX changed in rebuilt APK")
    base_block = apk_signing_block(base)
    patched_block = apk_signing_block(apk)
    if base_block is not None and patched_block != base_block:
        raise ValueError("Xiaomi APK signing block was not preserved byte-for-byte")
    return {
        "base_sha256": hashlib.sha256(base.read_bytes()).hexdigest(),
        "patched_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
        "dex_entries": dex_names,
        "changed_dex_entries": changed_dex,
        "non_dex_entries_identical": True,
        "signing_block_preserved": base_block is not None and patched_block == base_block,
    }


def apk_signing_block(apk: Path) -> bytes | None:
    with zipfile.ZipFile(apk) as archive, apk.open("rb") as stream:
        central_directory = archive.start_dir
        if central_directory < 24:
            return None
        stream.seek(central_directory - 24)
        footer = stream.read(24)
        if len(footer) != 24 or footer[8:] != b"APK Sig Block 42":
            return None
        size = struct.unpack("<Q", footer[:8])[0]
        start = central_directory - size - 8
        if start < 0:
            raise ValueError("Malformed APK signing block size")
        stream.seek(start)
        block = stream.read(size + 8)
        if len(block) != size + 8 or struct.unpack("<Q", block[:8])[0] != size:
            raise ValueError("Malformed APK signing block header")
        return block


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("apply", "verify", "compare"))
    parser.add_argument("--decoded", type=Path)
    parser.add_argument("--base", type=Path)
    parser.add_argument("--apk", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    if args.command == "compare":
        if not args.base or not args.apk:
            parser.error("compare requires --base and --apk")
        payload = compare_apks(args.base, args.apk)
    else:
        if not args.decoded:
            parser.error(f"{args.command} requires --decoded")
        report = process(args.decoded, apply=args.command == "apply")
        payload = asdict(report)
    payload["mode"] = args.command
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload, indent=2))


if __name__ == "__main__":
    main()
