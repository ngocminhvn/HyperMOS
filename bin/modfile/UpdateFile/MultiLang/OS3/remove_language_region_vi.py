#!/usr/bin/env python3
"""Remove exactly the 22 user-rejected language/region strings from Settings RRO.

Read the original 22-translation manifest for exact-match safety. Never remove
other translations; preserve package, target, signer; verify roundtrip for all
remaining 85 authored Settings strings. Does not touch OS locale picker.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

from merge_owned_vi import process, cert, identity, check_compiled_strings, strings

def remove_from_xml(xmlfile: Path, unwanted: dict[str, str]) -> None:
    original = xmlfile.read_text(encoding="utf-8")
    parsed = ET.fromstring(original)
    have = {x.get("name"): "".join(x.itertext())
            for x in parsed if x.tag == "string" and x.get("name")}
    for name, text in unwanted.items():
        if name not in have:
            raise RuntimeError("Requested removal missing in Settings APK: " + name)
        if text != have[name]:
            raise RuntimeError("String changed since insertion; refusing removal: " + name)
        pattern = re.compile(r'(?m)^[ \t]*<string\s+name="' + re.escape(name) +
                             r'"(?:\s[^>]*)?>[^<]*</string>[ \t]*\r?\n?')
        original, matches = pattern.subn("", original)
        if matches != 1:
            raise RuntimeError(f"Expected exactly one translation element {name}, found {matches}")
    ET.fromstring(original)
    xmlfile.write_text(original, encoding="utf-8")


def remove_public(public: Path, unwanted: dict[str, str]) -> None:
    original = public.read_text(encoding="utf-8")
    for name in unwanted:
        pattern = re.compile(r'(?m)^[ \t]*<public\s+type="string"\s+name="' +
                             re.escape(name) + r'"\s+id="0x[0-9a-fA-F]+"\s*/>[ \t]*\r?\n?')
        original, count = pattern.subn("", original)
        if count != 1:
            raise RuntimeError(f"Expected one owned public symbol for {name}, found {count}")
    ET.fromstring(original)
    public.write_text(original, encoding="utf-8")


def inspect_final(apktool: Path, apk: Path, tmp: Path, log: Path,
                  unwanted: dict[str, str], retained: dict[str, str]) -> None:
    check_compiled_strings(apktool, apk, retained, tmp, log)
    final = tmp / "verified-final"
    observed = {}
    for directory in (final / "res").glob("values-vi*"):
        for file in directory.glob("*.xml"):
            for elem in ET.parse(file).getroot():
                if elem.tag == "string" and elem.get("name"):
                    observed[elem.get("name")] = "".join(elem.itertext())
    survived = sorted(set(unwanted) & set(observed))
    if survived:
        raise RuntimeError(f"Removed language/region strings still compiled into vi: {survived}")
    public = final / "res" / "values" / "public.xml"
    if public.exists():
        names = {elem.get("name") for elem in ET.parse(public).getroot()
                 if elem.tag == "public"}
        survived_public = sorted(names & set(unwanted))
        if survived_public:
            raise RuntimeError(f"Removed public symbols still present: {survived_public}")


def run(a: argparse.Namespace) -> None:
    a.output.mkdir(parents=True, exist_ok=True)
    log = a.output / "remove-22.log"
    unwanted = strings(a.remove_manifest)
    retained = strings(a.keep_manifest)
    if len(unwanted) != 22 or len(retained) != 85 or set(unwanted) & set(retained):
        raise RuntimeError("Expected 22 to remove and 85 to retain without overlap")
    signer = ["java", "-jar", str(a.apksigner_jar)]
    before_id = identity(a.aapt, a.original, log)
    before_cert = cert(signer, a.original, log)
    with tempfile.TemporaryDirectory(prefix="hypermos-remove-22-") as work:
        tmp = Path(work)
        decoded = tmp / "decoded"
        process(["java", "-Xmx3g", "-jar", str(a.apktool), "d", "-f", "-s",
                 str(a.original), "-o", str(decoded)], log)
        xml = decoded / "res" / "values-vi" / "strings.xml"
        if not xml.is_file():
            raise RuntimeError("Missing original values-vi/strings.xml")
        remove_from_xml(xml, unwanted)
        remove_public(decoded / "res" / "values" / "public.xml", unwanted)
        target = a.output / a.original.name
        unsigned, aligned = tmp / "new.apk", tmp / "aligned.apk"
        process(["java", "-Xmx3g", "-jar", str(a.apktool), "b", str(decoded),
                 "-o", str(unsigned)], log)
        process([a.zipalign, "-f", "4", str(unsigned), str(aligned)], log)
        process(signer + ["sign", "--key", str(a.key), "--cert", str(a.cert),
                          "--out", str(target), str(aligned)], log)
        if identity(a.aapt, target, log) != before_id:
            raise RuntimeError("Rebuilt overlay package/target changed")
        if cert(signer, target, log) != before_cert:
            raise RuntimeError("Rebuilt signing cert mismatch")
        inspect_final(a.apktool, target, tmp, log, unwanted, retained)
        report = {
            "apk": a.original.name, "removed": len(unwanted),
            "removed_keys": sorted(unwanted), "remaining_reviewed_settings": len(retained),
            "compiled_values_kept": True, "compiled_22_removed": True,
            "same_package_and_target": True, "same_certificate": True,
            "before_sha256": hashlib.sha256(a.original.read_bytes()).hexdigest(),
            "after_sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
            "on_device_overlay_verified": False,
        }
        (a.output / "remove-22-report.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print("[REMOVE-22] " + json.dumps({
            "removed": len(unwanted), "retained": len(retained),
            "same_cert": True, "same_overlay": True}, ensure_ascii=False))


def self_test() -> None:
    with tempfile.TemporaryDirectory() as work:
        base = Path(work)
        file = base / "strings.xml"
        file.write_text('<resources>\n    <string name="language_title">Ngôn ngữ</string>\n'
                        '    <string name="keep">Giữ nguyên</string>\n</resources>\n',
                        encoding="utf-8")
        remove_from_xml(file, {"language_title": "Ngôn ngữ"})
        assert "language_title" not in strings(file)
        assert strings(file)["keep"] == "Giữ nguyên"
        symbols = base / "public.xml"
        symbols.write_text('<resources>\n'
                           '    <public type="string" name="language_title" id="0x7f040100" />\n'
                           '    <public type="string" name="keep" id="0x7f040101" />\n'
                           '</resources>\n', encoding="utf-8")
        remove_public(symbols, {"language_title": "Ngôn ngữ"})
        assert "language_title" not in symbols.read_text(encoding="utf-8")
        assert "keep" in symbols.read_text(encoding="utf-8")
    print("[PASS] exact 22-key removal engine preserves unrelated strings/public symbols")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for arg in ("original", "remove-manifest", "keep-manifest",
                "apktool", "apksigner-jar", "key", "cert", "output"):
        p.add_argument("--" + arg, type=Path)
    for arg in ("aapt", "zipalign"):
        p.add_argument("--" + arg)
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()
    if a.self_test:
        self_test()
        return
    for required in ("original", "remove_manifest", "keep_manifest", "apktool",
                     "apksigner_jar", "aapt", "zipalign", "key", "cert", "output"):
        if not getattr(a, required):
            p.error(required + " is required")
    run(a)


if __name__ == "__main__":
    main()
