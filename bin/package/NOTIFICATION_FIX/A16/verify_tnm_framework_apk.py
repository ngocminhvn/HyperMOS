#!/usr/bin/env python3
"""Verify the *compiled* PowerKeeper contains the TNMFramework API definitions.

Fail closed if legacy ProjectRYUFramework calls remain, the bridge was not
assembled, or the DEX contains references without concrete implementations.
"""
import argparse
import json
import re
import zipfile
from pathlib import Path

from powerkeeper import TNM_API, TNM_METHODS, RYU_OWNER
from verify_ryu_uid_policy_apk import entries

DEX = re.compile(r"classes(?:[2-9]\d*)?\.dex")


def verify(apk: Path, report: Path):
    manifest = json.loads(report.read_text(encoding="utf-8"))
    if manifest.get("tnm_framework_api") != TNM_API:
        raise ValueError("Full RYU port report does not declare the embedded TNMFramework")
    expected = {(TNM_API, name, proto[0]) for name, proto in TNM_METHODS.items()}
    if set(manifest.get("tnm_framework_method_signatures", [])) != {
            name + proto[0] for name, proto in TNM_METHODS.items()}:
        raise ValueError("TNMFramework contract signatures differ from build report")
    found = {}
    all_dex = []
    with zipfile.ZipFile(apk) as archive:
        for name in archive.namelist():
            if not DEX.fullmatch(name):
                continue
            data = archive.read(name)
            if RYU_OWNER.encode("utf-8") in data:
                raise ValueError("Legacy ProjectRYUFramework remains in output DEX " + name)
            all_dex.append(name)
            for key, code in entries(data).items():
                if key in found:
                    raise ValueError("Duplicate DEX method definition " + repr(key))
                found[key] = code
    if not all_dex:
        raise ValueError("PowerKeeper has no compiled DEX")
    missing = expected - set(found)
    if missing:
        raise ValueError("Compiled TNMFramework methods missing " + repr(sorted(missing)))
    for key in expected:
        if not found[key]:
            raise ValueError("Abstract/stub TNMFramework method " + repr(key))
    if manifest.get("tnm_framework_call_sites", 0) < 7:
        raise ValueError("Unexpected missing RYU -> TNM call sites in report")
    print("[TNMFramework DEX] PASS: 7 concrete bridge methods, "
          + str(manifest["tnm_framework_call_sites"])
          + " original RYU call sites; no ProjectRYUFramework reference")
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    verify(args.apk, args.report)
