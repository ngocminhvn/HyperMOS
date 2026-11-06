#!/usr/bin/env python3
"""Shared OS4 overlay key: ROM version only, never Xiaomi device codename."""
from __future__ import annotations

import re
import sys
from pathlib import Path


def version_key(code: str) -> str:
    raw = code.strip()
    match = re.fullmatch(r"(OS4(?:\.[0-9]+){2,5})(?:\.[A-Za-z][A-Za-z0-9]*)?", raw)
    if not match:
        raise ValueError(f"Unsupported OS4 ROM version: {raw!r}")
    return match.group(1)


if __name__ == "__main__":
    try:
        source = (
            sys.argv[1] if len(sys.argv) > 1
            else Path("bin/ddevice/base_rom_code.txt").read_text(encoding="utf-8")
        )
        print(version_key(source))
    except (ValueError, OSError) as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
