#!/usr/bin/env python3
"""Add independent Vietnamese resources to ONE EXISTING HyperMOS RRO.

Safeguards: only stock-proven MISSING_VI keys, never replaces an existing value,
requires identical placeholders and original signing certificate, verifies the
RRO package and target do not change. Does not import upstream Xiaomi.eu text.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import escape

PLACEHOLDERS = re.compile(
    r"%(?!%)(?:[0-9]+\$)?[-+# 0,(]*[0-9]*(?:\.[0-9]+)?[A-Za-z]"
)
TARGET = re.compile(r'\btargetPackage\b[^\n]*?="([^"]+)"')


def process(args: list[str], log: Path) -> str:
    p = subprocess.run(args, capture_output=True, text=True, errors="replace")
    with log.open("a", encoding="utf-8") as out:
        out.write("COMMAND " + " ".join(args[:4]) + "\n")
        out.write(p.stdout[-4000:] + "\n" + p.stderr[-4000:] + "\n")
    if p.returncode:
        raise RuntimeError(f"Command failed: {args[:4]} (see {log})")
    return p.stdout


def cert(apksigner: list[str], apk: Path, log: Path) -> str:
    output = process(apksigner + ["verify", "--print-certs", str(apk)], log)
    match = re.search(r"Signer #1 certificate SHA-256 digest:\s*([0-9a-fA-F:]+)", output)
    if not match:
        raise RuntimeError("Could not determine APK signing certificate")
    return match.group(1).lower().replace(":", "")


def identity(aapt: str, apk: Path, log: Path) -> tuple[str, str]:
    badging = process([aapt, "dump", "badging", str(apk)], log)
    m = re.search(r"(?m)^package: name='([^']+)'", badging)
    if not m:
        raise RuntimeError("APK package ID not found")
    tree = process([aapt, "dump", "xmltree", str(apk), "AndroidManifest.xml"], log)
    t = TARGET.search(tree)
    if not t:
        raise RuntimeError("RRO targetPackage not found")
    return m.group(1), t.group(1)


def strings(filename: Path) -> dict[str, str]:
    doc = ET.parse(filename).getroot()
    if doc.tag != "resources":
        raise RuntimeError(f"Not resources XML: {filename}")
    result = {}
    for child in doc:
        if child.tag != "string":
            raise RuntimeError(f"Expected only <string>, got {child.tag}")
        name = child.get("name")
        if not name or name in result or len(child):
            raise RuntimeError(f"Invalid/duplicate/non-text string: {name}")
        result[name] = "".join(child.itertext())
    return result


def english_stock_rows(path: Path, apk_name: str) -> dict[str, str]:
    records = {}
    with path.open(encoding="utf-8-sig", newline="") as source:
        for row in csv.DictReader(source):
            if row["overlay_apk"] != apk_name or row["status"] != "MISSING_VI":
                continue
            records[row["resource_name"]] = row["english_source"]
    return records


def append_only(existing: Path, additions: dict[str, str], english: dict[str, str]) -> list[str]:
    original = existing.read_text(encoding="utf-8")
    parsed = ET.fromstring(original)
    keys = {node.get("name") for node in parsed if node.tag == "string"}
    new = []
    for name, translated in sorted(additions.items()):
        if name in keys:
            raise RuntimeError(f"Refusing to overwrite existing translation: {name}")
        if name not in english:
            raise RuntimeError(f"Not verified MISSING_VI in matching stock: {name}")
        if not translated.strip():
            raise RuntimeError(f"Empty translation: {name}")
        from_en = sorted(PLACEHOLDERS.findall(english[name]))
        from_vi = sorted(PLACEHOLDERS.findall(translated))
        if from_en != from_vi:
            raise RuntimeError(f"Format placeholders changed for {name}: {from_en} vs {from_vi}")
        new.append('    <string name="' + name + '">' + escape(translated) + '</string>')
    if not new:
        raise RuntimeError("No new translations to add")
    pattern = re.compile(r"</resources>\s*$")
    if not pattern.search(original):
        raise RuntimeError("Existing values-vi/strings.xml lacks closing tag")
    edited = pattern.sub("\n" + "\n".join(new) + "\n</resources>\n", original, count=1)
    ET.fromstring(edited)
    existing.write_text(edited, encoding="utf-8")
    return list(sorted(additions))


def run(a: argparse.Namespace) -> None:
    a.output.mkdir(parents=True, exist_ok=True)
    log = a.output / "patch.log"
    reviewed = english_stock_rows(a.english_review, a.original.name)
    additions = strings(a.patch)
    if not additions or len(additions) > 300:
        raise RuntimeError("Patch size must be 1..300 verified translations")
    signer = ["java", "-jar", str(a.apksigner_jar)]
    original_id = identity(a.aapt, a.original, log)
    original_cert = cert(signer, a.original, log)
    with tempfile.TemporaryDirectory(prefix="owned-hypermos-vi-") as work:
        root = Path(work)
        decoded = root / "decoded"
        unsigned, aligned = root / "unsigned.apk", root / "aligned.apk"
        target = a.output / a.original.name
        process(["java", "-Xmx3g", "-jar", str(a.apktool),
                 "d", "-f", "-s", str(a.original), "-o", str(decoded)], log)
        xml = decoded / "res" / "values-vi" / "strings.xml"
        if not xml.is_file():
            raise RuntimeError("Expected original Vietnamese overlay strings.xml")
        added = append_only(xml, additions, reviewed)
        process(["java", "-Xmx3g", "-jar", str(a.apktool),
                 "b", str(decoded), "-o", str(unsigned)], log)
        process([a.zipalign, "-f", "4", str(unsigned), str(aligned)], log)
        process(signer + ["sign", "--key", str(a.key), "--cert", str(a.cert),
                          "--out", str(target), str(aligned)], log)
        new_id = identity(a.aapt, target, log)
        new_cert = cert(signer, target, log)
        if new_id != original_id:
            target.unlink(missing_ok=True)
            raise RuntimeError(f"Overlay identity changed: {original_id} -> {new_id}")
        if new_cert != original_cert:
            target.unlink(missing_ok=True)
            raise RuntimeError("Signing certificate mismatch; refusing to use rebuilt APK")
        report = {
            "apk": a.original.name,
            "original_sha256": hashlib.sha256(a.original.read_bytes()).hexdigest(),
            "updated_sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
            "added_names": added,
            "added_count": len(added),
            "same_overlay_package_and_target": True,
            "same_signing_certificate": True,
            "old_values_overwritten": 0,
            "device_idmap_verified": False,
            "requires_device_test": True,
        }
        (a.output / "patch-report.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print("[VI-MERGE] " + json.dumps({
            "apk": a.original.name, "added": len(added),
            "same_certificate": True, "same_rro_identity": True
        }, ensure_ascii=False))


def self_test() -> None:
    with tempfile.TemporaryDirectory() as p:
        t = Path(p) / "strings.xml"
        t.write_text('<resources>\n<string name="old">Bản cũ</string>\n</resources>\n', encoding="utf-8")
        got = append_only(t, {"language_title": "Ngôn ngữ và khu vực"},
                          {"language_title": "Language & region"})
        assert got == ["language_title"]
        assert 'Bản cũ' in t.read_text(encoding="utf-8")
        try:
            append_only(t, {"language_title": "Tiếng Việt"}, {"language_title": "Language"})
        except RuntimeError as exc:
            assert "overwrite" in str(exc)
        else:
            raise AssertionError("Must reject overwriting")
        t2 = Path(p) / "strings2.xml"
        t2.write_text("<resources></resources>", encoding="utf-8")
        try:
            append_only(t2, {"x": "Đổi khu vực?"}, {"x": "Change to %s?"})
        except RuntimeError as exc:
            assert "placeholders" in str(exc)
        else:
            raise AssertionError("Must reject placeholder mismatch")
    print("[PASS] additive-only, no overwrite, stock-key and placeholder safeguards")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--original", type=Path)
    p.add_argument("--patch", type=Path)
    p.add_argument("--english-review", type=Path)
    p.add_argument("--output", type=Path, default=Path("tested-vi-apks"))
    p.add_argument("--apktool", type=Path)
    p.add_argument("--apksigner-jar", type=Path)
    p.add_argument("--aapt")
    p.add_argument("--zipalign")
    p.add_argument("--key", type=Path)
    p.add_argument("--cert", type=Path)
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()
    if a.self_test:
        self_test()
        return
    required = ("original", "patch", "english_review", "apktool",
                "apksigner_jar", "aapt", "zipalign", "key", "cert")
    for name in required:
        if not getattr(a, name):
            p.error("--" + name.replace("_", "-") + " is required")
    run(a)


if __name__ == "__main__":
    main()
