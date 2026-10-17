#!/usr/bin/env python3
"""Patch Xiaomi SecurityCenter confirmation countdowns in decoded smali.

The input is APKEditor raw output.  Only the named permission/install classes
are touched; manifest, resources, native libraries, and every unrelated class
remain stock from the downloaded ROM.
"""
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


FRAGMENT = "com/miui/permcenter/privacymanager/InterceptPermissionFragment.smali"
INPUT_ACTIVITY = "com/miui/permcenter/install/AdbInputApplyActivity"
INSTALL_ACTIVITY = "com/miui/permcenter/install/AdbInstallActivity"

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


def patch_delays(text: str) -> tuple[str, int]:
    lines = text.splitlines(keepends=True)
    sites = 0
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
    return "".join(lines), sites


def patch(decoded: Path) -> PatchReport:
    files = smali_files(decoded)
    fragment = unique_suffix(files, FRAGMENT)
    input_files = class_family(files, INPUT_ACTIVITY)
    install_files = class_family(files, INSTALL_ACTIVITY)
    changed_files: list[str] = []

    fragment_text = fragment.read_text(encoding="utf-8")
    fragment_patched, fragment_old = patch_fragment(fragment_text)
    if fragment_patched != fragment_text:
        changed_files.append(str(fragment.relative_to(decoded)))
        fragment.write_text(fragment_patched, encoding="utf-8", newline="")

    counts = {}
    for label, family in (("adb_input", input_files), ("adb_install", install_files)):
        total_sites = 0
        for path in family:
            original = path.read_text(encoding="utf-8")
            patched, sites = patch_delays(original)
            total_sites += sites
            if patched != original:
                changed_files.append(str(path.relative_to(decoded)))
                path.write_text(patched, encoding="utf-8", newline="")
        counts[label] = total_sites

    if counts["adb_input"] < 2:
        raise ValueError("AdbInputApplyActivity countdown coverage is incomplete")
    if counts["adb_install"] < 2:
        raise ValueError("AdbInstallActivity countdown coverage is incomplete")
    return PatchReport(
        fragment_file=str(fragment.relative_to(decoded)),
        fragment_old_seconds=fragment_old,
        fragment_new_seconds=0,
        adb_input_delay_sites=counts["adb_input"],
        adb_install_delay_sites=counts["adb_install"],
        changed_files=sorted(changed_files),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    args = parser.parse_args()
    print(json.dumps(asdict(patch(args.decoded)), indent=2))


if __name__ == "__main__":
    main()
