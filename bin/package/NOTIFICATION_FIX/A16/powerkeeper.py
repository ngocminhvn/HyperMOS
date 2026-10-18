#!/usr/bin/env python3
"""Decode-only DEX wrapper and scoped RYU conditional UID method adapter.

The shipped PowerKeeper executes the pinned adapted ZKOS implementation.
RYU is a method donor only for guarded UID cleanup, not performance hooks.
No full RYU PowerKeeper import or PerfHook translation is supported.
"""
import argparse
import re
import zipfile
from pathlib import Path

DEX = re.compile(r"classes(?:[2-9]\d*)?\.dex")
BUILD_GATE = re.compile(
    r"(?m)^([ \t]*)sget-boolean ([vp]\d+), "
    r"Lcom/projectryu/Build;->IS_RYU_BUILD:Z[ \t]*$")


def adapt(body: str):
    """Resolve a source RYU build guard on imported UID methods only."""
    count = 0

    def gate(match):
        nonlocal count
        register = match[2]
        index = int(register[1:])
        if index > 255:
            raise ValueError("RYU UID build gate register out of range")
        count += 1
        insn = "const/4" if register.startswith("v") and index < 16 else "const/16"
        return match[1] + insn + " " + register + ", 0x1"

    adapted = BUILD_GATE.sub(gate, body)
    if "Lcom/projectryu/" in adapted or "com.projectryu." in adapted:
        raise ValueError("Imported RYU UID decision has unsupported private dependency")
    return adapted, 0, count


def prepare_donor(stock_apk: Path, dex_file: Path, output: Path):
    """Create a temporary decode-only donor with stock manifest/resources and local DEX.

    It intentionally excludes META-INF signatures and must never be installed.
    """
    data = dex_file.read_bytes()
    if len(data) < 112 or not data.startswith(b"dex\n"):
        raise ValueError("Invalid local classes.dex")
    with zipfile.ZipFile(stock_apk) as stock:
        if stock.testzip():
            raise ValueError("Corrupt Xiaomi stock PowerKeeper")
        slots = {n for n in stock.namelist() if DEX.fullmatch(n)}
        if slots != {"classes.dex"}:
            raise ValueError(f"Expected one stock DEX slot; found {sorted(slots)}")
        output.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(output, "w") as donor:
            for info in stock.infolist():
                if info.filename.upper().startswith("META-INF/"):
                    continue
                payload = data if info.filename == "classes.dex" else stock.read(info.filename)
                donor.writestr(info, payload)
    print("[PowerKeeper] Local DEX staged with stock Xiaomi resources")



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("operation", choices=("prepare-donor",))
    parser.add_argument("--stock-apk", required=True, type=Path)
    parser.add_argument("--dex-file", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    prepare_donor(args.stock_apk, args.dex_file, args.output)
