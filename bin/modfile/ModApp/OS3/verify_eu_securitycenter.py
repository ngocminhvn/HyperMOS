#!/usr/bin/env python3
"""Verify the Xiaomi.eu SecurityCenter countdown without changing its signed APK."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

BASE = "com/miui/permcenter/privacymanager/InterceptBaseFragment.smali"
CHILD = "com/miui/permcenter/privacymanager/InterceptPermissionFragment.smali"
METHOD = re.compile(r"(?ms)^\\.method\\s+[^\\n]*?\\b(?P<name>[ij]0)\\(\\)I\\s*\\n(?P<body>.*?)^\\.end method\\s*$")


def find_one(root: Path, suffix: str) -> Path:
    matches = [path for path in root.rglob("*.smali")
               if path.is_file() and path.as_posix().endswith(suffix)]
    if len(matches) != 1:
        raise ValueError(f"Expected one {suffix}, found {len(matches)}")
    return matches[0]


def method_body(source: str, name: str) -> str:
    matches = [match.group("body") for match in METHOD.finditer(source)
               if match.group("name") == name]
    if len(matches) != 1:
        raise ValueError(f"Expected one {name}()I, found {len(matches)}")
    return matches[0]


def instructions(body: str) -> list[str]:
    return [line.strip() for line in body.splitlines()
            if line.strip() and not line.strip().startswith((".locals", ".registers", ".line"))]


def verify(root: Path) -> None:
    base = find_one(root, BASE).read_text(encoding="utf-8")
    child = find_one(root, CHILD).read_text(encoding="utf-8")
    countdown = instructions(method_body(base, "j0"))
    if countdown != ["const/4 v0, 0x0", "return v0"]:
        raise ValueError("EU countdown is not the verified zero-second implementation")
    if re.search(r"(?m)^\\.method\\s+[^\\n]*\\bj0\\(\\)I\\s*$", child):
        raise ValueError("EU permission fragment overrides the zero-second countdown")
    caller = instructions(method_body(base, "i0"))
    required = [
        "invoke-virtual {p0}, Lcom/miui/permcenter/privacymanager/InterceptBaseFragment;->j0()I",
        "move-result v1",
        "invoke-direct {v0, p0, v1}, Lcom/miui/permcenter/privacymanager/InterceptBaseFragment$b;-><init>(Lcom/miui/permcenter/privacymanager/InterceptBaseFragment;I)V",
    ]
    if not any(caller[index:index + len(required)] == required
               for index in range(len(caller) - len(required) + 1)):
        raise ValueError("EU countdown constructor no longer receives j0() result")
    print("EU SecurityCenter: signed stock APK already uses a zero-second countdown")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    verify(parser.parse_args().decoded)
