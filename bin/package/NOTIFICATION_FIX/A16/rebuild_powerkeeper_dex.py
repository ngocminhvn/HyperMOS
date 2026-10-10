#!/usr/bin/env python3
"""Assemble real smali classes and replace APKEditor raw-mode preserved DEX.

APKEditor v1.4.9 in raw mode logs "WARN: Ignore: .../smali/com" and may
return a valid APK whose original DEX does not contain the patched classes.
Always use the pinned in-repo smali assembler for executable patch changes.
"""
import argparse
import os
import re
import subprocess
import tempfile
import zipfile
from pathlib import Path


def dex_name(directory: str) -> str:
    if directory == "smali":
        return "classes.dex"
    match = re.fullmatch(r"smali_classes([2-9]\d*)", directory)
    if not match:
        raise ValueError("Unexpected smali directory: " + directory)
    return "classes" + match.group(1) + ".dex"


def rebuild(decoded: Path, apk: Path, smali_jar: Path, api: int) -> None:
    folders = sorted((p for p in decoded.iterdir()
                      if p.is_dir() and
                      (p.name == "smali" or re.fullmatch(r"smali_classes[2-9]\d*", p.name))),
                     key=lambda p: (p.name != "smali", p.name))
    if not folders:
        raise ValueError("No decoded smali directories to compile")
    if not apk.is_file() or not smali_jar.is_file():
        raise ValueError("Rebuilt PowerKeeper APK or smali assembler is missing")
    with tempfile.TemporaryDirectory(prefix="ryu-powerkeeper-dex-") as temp_dir:
        temp = Path(temp_dir)
        replacements = {}
        for folder in folders:
            target_name = dex_name(folder.name)
            output = temp / target_name
            cmd = ["java", "-jar", str(smali_jar.resolve()), "a", "--api", str(api),
                   str(folder.resolve()), "-o", str(output)]
            subprocess.run(cmd, check=True)
            if not output.is_file() or output.stat().st_size < 4096:
                raise RuntimeError("Smali assembler produced no DEX: " + target_name)
            replacements[target_name] = output.read_bytes()
            print(f"[RYU DEX] Compiled {folder.name} -> {target_name} "
                  f"({len(replacements[target_name])} bytes)", flush=True)
        temporary_apk = temp / "PowerKeeper.dex-verified.apk"
        with zipfile.ZipFile(apk, "r") as source:
            original_dex = set(n for n in source.namelist()
                               if re.fullmatch(r"classes(?:[2-9]\d*)?\.dex", n))
            if set(replacements) != original_dex:
                raise RuntimeError(
                    f"DEX directories do not match APK entries: "
                    f"assembled={sorted(replacements)}, original={sorted(original_dex)}")
            with zipfile.ZipFile(temporary_apk, "w", allowZip64=True) as output:
                output.comment = source.comment
                for member in source.infolist():
                    raw = replacements.get(member.filename)
                    if raw is None:
                        raw = source.read(member)
                    output.writestr(member, raw)
        with zipfile.ZipFile(temporary_apk) as verification:
            bad = verification.testzip()
            if bad:
                raise RuntimeError("Corrupted output ZIP member: " + bad)
        os.replace(temporary_apk, apk)
        print("[RYU DEX] Replaced all APK DEX with explicitly assembled patched classes",
              flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--decoded", type=Path, required=True)
    parser.add_argument("--apk", type=Path, required=True)
    parser.add_argument("--smali-jar", type=Path, required=True)
    parser.add_argument("--api", type=int, default=36)
    arguments = parser.parse_args()
    rebuild(arguments.decoded, arguments.apk, arguments.smali_jar, arguments.api)
