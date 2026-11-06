#!/usr/bin/env python3
"""Build Vietnamese Android 17 RROs from Xiaomi.eu XML without rebuilding target APKs.

Only the target APK package/resource metadata is read during build. APK files are
never decompiled, rebuilt, signed, or replaced. XML translations are used as-is.
"""
from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path
from xml.sax.saxutils import escape

RESOURCE_TAGS = {
    "string": "string",
    "plurals": "plurals",
    "string-array": "array",
    "integer-array": "array",
    "array": "array",
    "bool": "bool",
    "integer": "integer",
    "dimen": "dimen",
    "color": "color",
    "fraction": "fraction",
}
MUST_HAVE = {"Settings.apk", "MiuiSystemUI.apk", "framework-res.apk"}


def run(*args: str, check: bool = True) -> str:
    p = subprocess.run([str(a) for a in args], text=True, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, check=False)
    if check and p.returncode:
        raise RuntimeError(f"Command failed ({p.returncode}): {' '.join(map(str, args[:5]))}\n"
                           f"{(p.stderr or p.stdout)[-2500:]}")
    return p.stdout if p.returncode == 0 else ""


def source_names(xmls: list[Path]) -> set[str]:
    names: set[str] = set()
    for xml in xmls:
        tree = ET.parse(xml)
        if tree.getroot().tag != "resources":
            raise ValueError(f"Not an Android resources document: {xml}")
        for element in tree.getroot():
            tag = element.tag
            type_name = RESOURCE_TAGS.get(tag)
            if tag == "item":
                type_name = element.get("type")
            key = element.get("name")
            if type_name and key and re.fullmatch(r"[A-Za-z_][A-Za-z_0-9.]*", key):
                names.add(f"{type_name}/{key}")
    return names


def target_resources(aapt2: str, apk: Path) -> set[str]:
    dump = run(aapt2, "dump", "resources", "--no-values", str(apk))
    # aapt2 lines: resource 0x7f010000 string/name
    return set(re.findall(r"^\s*resource\s+0x[0-9a-fA-F]+\s+"
                          r"([a-z][a-z0-9_]*/[A-Za-z_0-9.]+)", dump, re.M))


def overlayable_groups(aapt2: str, apk: Path) -> dict[str, set[str]]:
    dump = run(aapt2, "dump", "overlayable", str(apk))
    groups: dict[str, set[str]] = defaultdict(set)
    group = ""
    allowed = False
    for line in dump.splitlines():
        named = re.match(r'\s*name="([^"]+)"\s+actor="[^"]*"', line)
        policy = re.match(r'\s*policies="([^"]+)"', line)
        if named:
            group = named.group(1)
            groups.setdefault(group, set())
            allowed = False
        elif policy:
            allowed = any(p in policy.group(1).lower() for p in ("public", "product"))
        elif group and allowed:
            item = line.strip()
            if re.fullmatch(r"[a-z][a-z0-9_]*/[A-Za-z_0-9.]+", item):
                groups[group].add(item)
    return dict(groups)


def package_name(aapt2: str, apk: Path) -> str:
    result = run(aapt2, "dump", "packagename", str(apk)).strip()
    if re.fullmatch(r"[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)+", result):
        return result
    match = re.search(r"package:\s+name='([^']+)'",
                      run(aapt2, "dump", "badging", str(apk)))
    if match:
        return match.group(1)
    raise ValueError(f"Cannot determine target package: {apk}")


def xml_write(path: Path, root: ET.Element) -> None:
    ET.ElementTree(root).write(path, encoding="utf-8", xml_declaration=True)


def update_config(path: Path, packages: list[str]) -> None:
    if not path.is_file():
        # Without an OverlayConfig, manifest isStatic=true enables RROs.
        return
    root = ET.parse(path).getroot()
    if root.tag != "config":
        raise ValueError(f"Unsupported OverlayConfig root: {path}")
    existing = {o.get("package") for o in root.iter("overlay")}
    for package in packages:
        if package not in existing:
            ET.SubElement(root, "overlay", {
                "package": package, "enabled": "true", "mutable": "false",
            })
    xml_write(path, root)


def one_overlay(aapt2: str, apksigner: str, zipalign: str, cert: Path, key: Path,
                work: Path, output: Path, framework: Path,
                src_dir: Path, package: str, group: str, names: set[str],
                apk_name: str, index: int) -> str:
    folder = work / f"{apk_name.replace('.apk','')}_{index}"
    src_res = src_dir / "res"
    res = folder / "res"
    shutil.copytree(src_res, res)
    (res / "xml").mkdir(exist_ok=True)
    mapping = ET.Element("overlay")
    for name in sorted(names):
        ET.SubElement(mapping, "item", {"target": name, "value": f"@{name}"})
    xml_write(res / "xml" / "overlays.xml", mapping)

    safe_name = re.sub(r"[^a-z0-9]", "", apk_name.lower().removesuffix(".apk"))
    overlay_package = f"com.hypermos.vi.os4.{safe_name}.r{index}"
    overlay_tag = (f'android:targetPackage="{escape(package)}" '
                   f'android:resourcesMap="@xml/overlays" '
                   'android:isStatic="true" android:priority="10"')
    if group:
        overlay_tag += f' android:targetName="{escape(group)}"'
    manifest = folder / "AndroidManifest.xml"
    manifest.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        f'<manifest xmlns:android="http://schemas.android.com/apk/res/android" '
        f'package="{overlay_package}">\n'
        '<application android:hasCode="false"/>\n'
        f'<overlay {overlay_tag}/>\n</manifest>\n', encoding="utf-8")
    compiled = folder / "compiled"
    compiled.mkdir(parents=True)
    run(aapt2, "compile", "--dir", str(res), "-o", str(compiled))
    flat = sorted(compiled.glob("*.flat"))
    if not flat:
        raise RuntimeError(f"No aapt2 compiled resources for {apk_name}")
    raw = folder / "unsigned.apk"
    run(aapt2, "link", "-o", str(raw), "--manifest", str(manifest),
        "-I", str(framework), "--no-resource-deduping", "--no-resource-removal",
        "--min-sdk-version", "30", *map(str, flat))
    aligned = folder / "aligned.apk"
    run(zipalign, "-f", "-p", "4", str(raw), str(aligned))
    final = output / f"HyperMOS.OS4.VI.{safe_name}.r{index}.apk"
    run(apksigner, "sign", "--key", str(key), "--cert", str(cert),
        "--out", str(final), str(aligned))
    run(apksigner, "verify", "--verbose", str(final))
    if not final.is_file() or final.stat().st_size == 0:
        raise RuntimeError(f"No valid signed RRO output: {final}")
    return overlay_package


def main() -> int:
    if len(sys.argv) != 4:
        print("Usage: build_vi_rro.py <Vietnamese/main> <extracted-images> <product/overlay>",
              file=sys.stderr)
        return 2
    source, images, out = map(lambda x: Path(x).resolve(), sys.argv[1:])
    tools = {name: shutil.which(name) for name in ("aapt2", "apksigner", "zipalign")}
    for name, path in tools.items():
        if not path:
            raise RuntimeError(f"{name} required for OS4 Vietnamese RRO build")
    aapt2, signer, aligner = (tools[k] for k in ("aapt2", "apksigner", "zipalign"))
    repo = Path(__file__).resolve().parents[5]  # HyperMOS root
    cert = repo / "bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"
    key = repo / "bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
    if not cert.is_file() or not key.is_file():
        raise RuntimeError("AOSP testkey absent; refusing unsigned RRO output")
    all_apks = list(images.rglob("*.apk"))
    indexed: dict[str, list[Path]] = defaultdict(list)
    for apk in all_apks:
        indexed[apk.name].append(apk)
    frame = indexed.get("framework-res.apk", [])
    if not frame:
        raise RuntimeError("framework-res.apk missing in extracted ROM")
    framework = sorted(frame, key=lambda a: ("/system/framework/" not in str(a), str(a)))[0]
    output = out / "HyperMOS-OS4-VI"
    output.mkdir(parents=True, exist_ok=True)
    generated: list[str] = []
    report: dict[str, object] = {"built": [], "skipped": [], "source_apks": 0}
    with tempfile.TemporaryDirectory(prefix="hypermos-os4-vi-") as tmp:
        work = Path(tmp)
        for src_app in sorted(source.iterdir()):
            if not src_app.is_dir() or not src_app.name.endswith(".apk"):
                continue
            xmls = sorted((src_app / "res").glob("values-*/*.xml"))
            if not xmls:
                continue
            report["source_apks"] += 1
            targets = indexed.get(src_app.name, [])
            if not targets:
                report["skipped"].append({"apk": src_app.name, "reason": "not in China ROM"})
                continue
            # APK names sometimes occur in multiple partitions. Match a single target,
            # never guess when two different packages could be involved.
            packages = {package_name(aapt2, apk) for apk in targets}
            if len(packages) != 1:
                raise RuntimeError(f"Ambiguous target APK packages for {src_app.name}: {packages}")
            package = next(iter(packages))
            target = targets[0]
            sources = source_names(xmls)
            available = target_resources(aapt2, target)
            compatible = sources & available
            groups = overlayable_groups(aapt2, target)
            selected = (
                [(name, compatible & names) for name, names in sorted(groups.items())]
                if groups else [("", compatible)]
            )
            count = 0
            for index, (group, names) in enumerate(selected, 1):
                if not names:
                    continue
                new_package = one_overlay(
                    aapt2, signer, aligner, cert, key, work, output, framework,
                    src_app, package, group, names, src_app.name, index)
                generated.append(new_package)
                report["built"].append({"apk": src_app.name, "target": package,
                                        "overlay": new_package, "entries": len(names),
                                        "targetName": group or None})
                count += 1
            if count == 0:
                report["skipped"].append({
                    "apk": src_app.name, "reason": "no eligible OS4 overlay resources"})
        if not generated:
            raise RuntimeError("No Vietnamese RRO built: refusing to publish unchanged OS4 ROM")
        update_config(out / "config" / "config.xml", generated)
        report_file = images.parent / "os4-vietnamese-report.json"
        report_file.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n",
                               encoding="utf-8")
        print(f"[MultiLang OS4] Built {len(generated)} signed overlays from "
              f"{report['source_apks']} XML source packages, "
              f"skipped {len(report['skipped'])}. Report: {report_file}")
        for entry in report["skipped"]:
            print(f"[MultiLang OS4] skipped {entry['apk']}: {entry['reason']}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, RuntimeError, ET.ParseError) as exc:
        print(f"[ERROR] MultiLang OS4: {exc}", file=sys.stderr)
        sys.exit(1)
