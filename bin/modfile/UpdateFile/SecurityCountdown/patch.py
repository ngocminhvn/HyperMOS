#!/usr/bin/env python3
"""Apply the ZKOS-style permission countdown edit to stock SecurityCenter.

Only InterceptPermissionFragment's 10-second constant is changed to zero.
ADB input/install handler delays and all unrelated classes stay stock.
"""
from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


FRAGMENT = "com/miui/permcenter/privacymanager/InterceptPermissionFragment.smali"

RETURN_INT_RE = re.compile(
    r"(?ms)^\.method\s+protected\s+[^\n]*\(\)I\s*\n"
    r"(?P<body>.*?)^\.end method\s*$"
)
CONST_INT_RE = re.compile(r"(?m)^\s*const(?:/4|/16)?\s+(?P<reg>[vp]\d+),\s*(?P<value>0x[a-fA-F0-9]+)\s*$")
RETURN_RE = re.compile(r"(?m)^\s*return\s+(?P<reg>[vp]\d+)\s*$")
@dataclass
class PatchReport:
    fragment_file: str
    fragment_old_seconds: int
    fragment_new_seconds: int
    changed_files: list[str]


def smali_files(decoded: Path) -> list[Path]:
    return sorted(path for path in decoded.rglob("*.smali") if path.is_file())


def unique_suffix(files: list[Path], suffix: str) -> Path:
    normalized = suffix.replace("\\", "/")
    matches = [path for path in files if path.as_posix().endswith(normalized)]
    if len(matches) != 1:
        raise ValueError(f"Expected one {suffix}, found {len(matches)}")
    return matches[0]


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


def patch(decoded: Path) -> PatchReport:
    files = smali_files(decoded)
    fragment = unique_suffix(files, FRAGMENT)
    changed_files: list[str] = []

    fragment_text = fragment.read_text(encoding="utf-8")
    fragment_patched, fragment_old = patch_fragment(fragment_text)
    if fragment_patched != fragment_text:
        changed_files.append(str(fragment.relative_to(decoded)))
        fragment.write_text(fragment_patched, encoding="utf-8", newline="")

    return PatchReport(
        fragment_file=str(fragment.relative_to(decoded)),
        fragment_old_seconds=fragment_old,
        fragment_new_seconds=0,
        changed_files=sorted(changed_files),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    args = parser.parse_args()
    print(json.dumps(asdict(patch(args.decoded)), indent=2))


if __name__ == "__main__":
    main()
