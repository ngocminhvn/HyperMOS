#!/usr/bin/env python3
"""Patch already-shipped RRO resource entries in-place in APK copies for review.

This tool NEVER creates a second overlay package. The original APKs in git
are not modified; output APKs must be reviewed, tested for signing/idmap,
then explicitly integrated into ROM build.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


def execute(argv: list[str], log: Path) -> None:
    with log.open("a", encoding="utf-8") as stream:
        stream.write("$ " + " ".join(argv) + "\n")
        result = subprocess.run(argv, text=True, stdout=stream, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f"command failed ({result.returncode}): {argv[0]} - see {log}")


def output(argv: list[str]) -> str:
    result = subprocess.run(argv, capture_output=True, text=True, errors="replace")
    if result.returncode:
        raise RuntimeError(f"{argv[0]} returned {result.returncode}: {result.stderr[-500:]}")
    return result.stdout


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def signer(apksigner: list[str], apk: Path) -> str:
    try:
        out = output(apksigner + ["verify", "--print-certs", str(apk)])
        match = re.search(r"Signer #1 certificate SHA-256 digest:\s*([0-9a-f]+)", out)
        return match.group(1) if match else "unknown"
    except RuntimeError:
        return "unverified"


def placeholders(value: str) -> list[str]:
    # Order is significant for unnumbered format strings.
    return re.findall(r"%(?:\d+\$)?[-+# 0,(]*\d*(?:\.\d+)?[a-zA-Z]", value)


def patch_strings(decoded: Path, patch_file: Path) -> tuple[int, list[str]]:
    strings_file = decoded / "res" / "values-vi" / "strings.xml"
    if not strings_file.is_file():
        raise RuntimeError("Overlay has no values-vi/strings.xml")
    document = strings_file.read_text(encoding="utf-8")
    originals = {}
    for item in ET.fromstring(document):
        if item.tag == "string":
            name = item.get("name")
            if name in originals:
                raise RuntimeError(f"Duplicate resource name in original: {name}")
            originals[name] = item

    patchroot = ET.parse(patch_file).getroot()
    if patchroot.tag != "resources":
        raise RuntimeError("Patch XML root must be <resources>")
    changed = []
    seen = set()
    for node in patchroot:
        if node.tag != "string" or len(node):
            raise RuntimeError("Only text-only <string> entries are currently supported")
        name = node.get("name")
        if not name or not re.fullmatch(r"[\w.]+", name):
            raise RuntimeError(f"Invalid resource name: {name!r}")
        if name in seen:
            raise RuntimeError(f"Patch contains duplicate key: {name}")
        seen.add(name)
        if name not in originals:
            raise RuntimeError(
                f"{name} is not already present in {patch_file.stem}. "
                "Adding *new* RRO keys requires matching-stock resource validation."
            )
        old_value = "".join(originals[name].itertext())
        new_value = "".join(node.itertext())
        if sorted(placeholders(old_value)) != sorted(placeholders(new_value)):
            raise RuntimeError(f"Placeholder change rejected: {name}")
        if not new_value.strip():
            raise RuntimeError(f"Blank translation: {name}")
        if old_value == new_value:
            continue
        pattern = re.compile(
            r"<string\b(?=[^>]*\bname=['\"]" + re.escape(name)
            + r"['\"])[^>]*>.*?</string>",
            re.DOTALL,
        )
        replacement = ET.tostring(node, encoding="unicode")
        document, found = pattern.subn(lambda _: replacement, document)
        if found != 1:
            raise RuntimeError(f"Expected one XML element for {name}; got {found}")
        changed.append(name)

    ET.fromstring(document)
    strings_file.write_text(document, encoding="utf-8")
    return len(changed), changed


def check_identity(aapt: str, orig: Path, patched: Path, aapt2: bool) -> tuple[str, str]:
    def pkg(apk: Path) -> str:
        if aapt2:
            return output([aapt, "dump", "packagename", str(apk)]).strip()
        info = output([aapt, "dump", "badging", str(apk)])
        match = re.search(r"(?m)^package: name='([^']+)'", info)
        if not match:
            raise RuntimeError(f"Could not read Android package name: {apk.name}")
        return match.group(1)
    def target(apk: Path) -> str:
        if aapt2:
            out = output([aapt, "dump", "xmltree", str(apk), "--file", "AndroidManifest.xml"])
        else:
            out = output([aapt, "dump", "xmltree", str(apk), "AndroidManifest.xml"])
        match = re.search(r'\btargetPackage\b[^\n]*?="([^"]+)"', out)
        if not match:
            raise RuntimeError(f"Overlay targetPackage missing: {apk.name}")
        return match.group(1)
    old, new = (pkg(orig), target(orig)), (pkg(patched), target(patched))
    if old != new:
        raise RuntimeError(f"Overlay identity CHANGED: {old} != {new}")
    return old


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--patches", type=Path, required=True)
    ap.add_argument("--output", type=Path, required=True)
    ap.add_argument("--apktool", type=Path, required=True)
    resources = ap.add_mutually_exclusive_group(required=True)
    resources.add_argument("--aapt2")
    resources.add_argument("--aapt")
    signing = ap.add_mutually_exclusive_group(required=True)
    signing.add_argument("--apksigner")
    signing.add_argument("--apksigner-jar")
    ap.add_argument("--zipalign", required=True)
    ap.add_argument("--key", type=Path, required=True)
    ap.add_argument("--cert", type=Path, required=True)
    args = ap.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    apk_signer = ([args.apksigner] if args.apksigner else
                  ["java", "-jar", str(args.apksigner_jar)])
    resource_tool = args.aapt2 or args.aapt
    resource_is_aapt2 = args.aapt2 is not None
    report: list[dict] = []
    failures = []

    for patch in sorted(args.patches.glob("*.xml")):
        name = patch.stem
        src = args.source / f"{name}.apk"
        row = {"overlay": f"{name}.apk", "changes": 0, "names": []}
        log = args.output / f"{name}.log"
        try:
            if not src.is_file():
                raise RuntimeError(f"Original overlay APK not found: {src}")
            with tempfile.TemporaryDirectory(prefix="rro-") as temp:
                tempdir = Path(temp)
                decoded = tempdir / "decoded"
                unsigned = tempdir / "unsigned.apk"
                aligned = tempdir / "aligned.apk"
                target = args.output / f"{name}.apk"
                execute(["java", "-Xmx3g", "-jar", str(args.apktool),
                         "d", "-f", "-s", str(src), "-o", str(decoded)], log)
                row["changes"], row["names"] = patch_strings(decoded, patch)
                row["original_sha256"] = sha(src)
                row["original_signer"] = signer(apk_signer, src)
                if not row["changes"]:
                    row["status"] = "unchanged"
                    report.append(row)
                    continue
                execute(["java", "-Xmx3g", "-jar", str(args.apktool),
                         "b", str(decoded), "-o", str(unsigned)], log)
                execute([args.zipalign, "-f", "4", str(unsigned), str(aligned)], log)
                execute(apk_signer + ["sign", "--key", str(args.key), "--cert",
                         str(args.cert), "--out", str(target), str(aligned)], log)
                execute(apk_signer + ["verify", "--print-certs", str(target)], log)
                row["package"], row["target_package"] = check_identity(
                    resource_tool, src, target, resource_is_aapt2
                )
                row["patched_sha256"] = sha(target)
                row["patched_signer"] = signer(apk_signer, target)
                row["signer_preserved"] = row["original_signer"] == row["patched_signer"]
                if not row["signer_preserved"] or row["original_signer"] in ("unknown", "unverified"):
                    raise RuntimeError(f"Original signing certificate differs for {name}")
                row["status"] = "candidate_needs_device_validation"
                print(f"[RRO] {name}: {row['changes']} changed resources; "
                      f"signature-preserved={row['signer_preserved']}")
                report.append(row)
        except (OSError, ET.ParseError, RuntimeError) as exc:
            row["status"] = "error"
            row["error"] = str(exc)
            failures.append(row)
            report.append(row)
            print(f"[RRO] ERROR: {name}: {exc}", file=sys.stderr)
    (args.output / "patch-report.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    summary = [
        "# Vietnamese patches for original overlay packages (TEST ARTIFACTS)",
        "",
        "These APKs keep the ORIGINAL overlay package names and targetPackage.",
        "They have been REBUILT and RE-SIGNED; Android may reject them if the original",
        "signature is necessary for overlayable policy. Do NOT integrate into ROM",
        "unless signature compatibility and idmap are verified on-device.",
        "",
        "| APK | Changed resources | Original signer retained | Status |",
        "| --- | ---: | --- | --- |",
    ]
    for item in report:
        preserved = item.get("signer_preserved")
        summary.append(
            f"| {item['overlay']} | {item['changes']} | "
            f"{preserved if preserved is not None else 'N/A'} | {item['status']} |"
        )
    (args.output / "PATCH_REPORT.md").write_text("\n".join(summary)+"\n", encoding="utf-8")
    if failures:
        return 1
    if not report:
        print("[RRO] ERROR: no XML patches found", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
