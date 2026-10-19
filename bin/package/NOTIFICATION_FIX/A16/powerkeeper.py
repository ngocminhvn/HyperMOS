#!/usr/bin/env python3
"""Build an ephemeral PowerKeeper donor with the scoped Xiaomi.eu DEX.

Stock Xiaomi supplies its unchanged non-DEX files. The temporary wrapper
omits META-INF and must not be installed on a device. No retired ZKOS or
RYU conditional UID methods are imported by this module.
"""
import argparse
import re
import zipfile
from pathlib import Path

DEX = re.compile(r"classes(?:[2-9]\d*)?\.dex")


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
