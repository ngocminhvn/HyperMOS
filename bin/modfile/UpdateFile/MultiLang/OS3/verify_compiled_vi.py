#!/usr/bin/env python3
"""Verify that original Vietnamese strings SURVIVED APK recompilation.

Read-only. Decode the actual checked-in compiled APKs; compare user-authored
source patches with the resources in the compiled APK, not just the build input.
"""
from __future__ import annotations
import argparse
import json
import subprocess
import tempfile
from pathlib import Path
import xml.etree.ElementTree as ET

NAMES = ("Nothings.Settings", "Nothings.MiuiSystemUI",
         "Nothings.MiuiSystemUIPlugin", "Nothings.SecurityCenter")


def values(path: Path) -> dict[str, str]:
    doc=ET.parse(path).getroot()
    return {e.get("name"): "".join(e.itertext())
            for e in doc if e.tag=="string" and e.get("name")}


def verify(root: Path, apktool: Path, dest: Path) -> dict:
    dest.mkdir(parents=True, exist_ok=True)
    records = []
    with tempfile.TemporaryDirectory(prefix="vi-compiled-verify-") as td:
        for name in NAMES:
            patches=[root/"owned-additions-batch"/(name+".xml")]
            # The retired 22 language/region strings must never be reintroduced.
            retired_path = root/"retired-language-region.keys"
            retired = set(retired_path.read_text(encoding="utf-8").splitlines()) if (
                name=="Nothings.Settings" and retired_path.is_file()) else set()
            expected={}
            for p in patches:
                if p.is_file():expected.update(values(p))
            apk=root/"updatesource"/(name+".apk")
            decoded=Path(td)/name
            p=subprocess.run(["java","-Xmx3g","-jar",str(apktool),"d","-f","-s",
                              str(apk),"-o",str(decoded)],
                             capture_output=True,text=True,errors="replace")
            if p.returncode:
                raise RuntimeError(f"Cannot decode {name}: {p.stderr[-500:]}")
            observed={}
            folders=[]
            for folder in sorted((decoded/"res").glob("values-vi*")):
                if not folder.is_dir():continue
                folders.append(folder.name)
                for file in folder.glob("*.xml"):
                    try: observed.update(values(file))
                    except ET.ParseError: continue
            default={}
            for file in (decoded/"res"/"values").glob("*.xml"):
                try: default.update(values(file))
                except ET.ParseError: continue
            resurrected = sorted(retired & set(observed))
            if resurrected:
                raise RuntimeError("Retired language/region strings reappeared in Settings: " +
                                   ", ".join(resurrected))
            absent = sorted(set(expected)-set(observed))
            different=sorted(k for k in expected if k in observed and expected[k]!=observed[k])
            record={
                "apk": apk.name,
                "source_entries": len(expected),
                "present_in_compiled_vi": len(set(expected)&set(observed)),
                "missing_from_vi":len(absent),
                "different_values":len(different),
                "locale_folders":folders,
                "sample_absent":absent[:30],
                "missing_but_in_default":sum(k in default for k in absent),
                "sample_different":different[:20],
                "sample_default_for_missing":{k:default[k][:100] for k in absent[:20] if k in default},
            }
            records.append(record)
            print("[ROUNDTRIP] "+json.dumps(record,ensure_ascii=False))
    result={"results":records,"all_present":all(not p["missing_from_vi"] and not p["different_values"] for p in records)}
    (dest/"compiled-vi-check.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    if not result["all_present"]:
        print("[ROUNDTRIP] WARNING: APK compilation lost or changed source Vietnamese strings")
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--multilang-dir",type=Path,required=True)
    p.add_argument("--apktool",type=Path,required=True)
    p.add_argument("--output",type=Path,default=Path("compiled-vi-check"))
    a=p.parse_args()
    result=verify(a.multilang_dir,a.apktool,a.output)
    raise SystemExit(0 if result["all_present"] else 1)


if __name__=="__main__":
    main()
