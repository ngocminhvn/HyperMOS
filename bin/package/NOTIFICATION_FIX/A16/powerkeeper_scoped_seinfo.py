#!/usr/bin/env python3
"""Assign a narrowly scoped SELinux seinfo for HyperMOS test PowerKeeper.

For a self-built custom ROM only. Does NOT create/forge Xiaomi signatures,
disable SELinux, alter seapp_contexts, or grant platform seinfo to other apps.
The existing Android 16 'user=system seinfo=platform' rule must be present.
"""
import argparse
import hashlib
import os
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

PKG = "com.miui.powerkeeper"
SEINFO = "platform"
TARGET = "system_ext/etc/selinux/system_ext_mac_permissions.xml"
OTHER = (
    "system/etc/selinux/plat_mac_permissions.xml",
    "product/etc/selinux/product_mac_permissions.xml",
    "vendor/etc/selinux/vendor_mac_permissions.xml",
    "odm/etc/selinux/odm_mac_permissions.xml",
)
SEAPP = (
    "system/etc/selinux/plat_seapp_contexts",
    "system_ext/etc/selinux/system_ext_seapp_contexts",
    "product/etc/selinux/product_seapp_contexts",
    "vendor/etc/selinux/vendor_seapp_contexts",
    "odm/etc/selinux/odm_seapp_contexts",
)


def signer_cert(pem: Path) -> tuple[str, str]:
    if not pem.is_file():
        raise ValueError("APK signer PEM certificate not found")
    der = subprocess.check_output(
        ["openssl", "x509", "-in", str(pem), "-outform", "DER"]
    )
    if not der or der[0] != 0x30:
        raise ValueError("Malformed X.509 certificate")
    return der.hex().upper(), hashlib.sha256(der).hexdigest()


def signer_entries(root: ET.Element, signature: str):
    matches = []
    for signer in root.findall("signer"):
        signatures = [signer.attrib.get("signature", "")]
        signatures += [c.attrib.get("signature", "") for c in signer.findall("cert")]
        if signature.lower() in [s.lower() for s in signatures if s]:
            if len(signatures) != 1:
                raise ValueError("Compound signer policy cannot be safely extended")
            matches.append(signer)
    return matches


def check_seapp(images: Path):
    candidates = [images / p for p in SEAPP if (images / p).is_file()]
    if not candidates:
        raise ValueError("No seapp_contexts supplied by ROM")
    for path in candidates:
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            parts = set(line.split())
            if {"user=system", "seinfo=platform", "domain=system_app"} <= parts:
                return str(path.relative_to(images))
    raise ValueError("ROM lacks user=system seinfo=platform domain=system_app; refusing to guess SELinux policy")


def apply(images: Path, cert: Path, verify_only: bool) -> None:
    signature, fingerprint = signer_cert(cert)
    check_seapp(images)
    target = images / TARGET
    files = [images / p for p in OTHER + (TARGET,) if (images / p).is_file()]
    roots = {}
    for p in files:
        try:
            tree = ET.parse(p)
        except ET.ParseError as e:
            raise ValueError(f"Malformed SELinux policy {p}: {e}") from e
        if tree.getroot().tag != "policy":
            raise ValueError(f"Invalid SELinux policy root: {p}")
        roots[p] = tree

    matches = [(p, signer) for p, tree in roots.items()
               for signer in signer_entries(tree.getroot(), signature)]
    if len(matches) > 1:
        raise ValueError("Duplicate signing certificate in MAC policy files")
    if matches:
        p, signer = matches[0]
        packages = [x for x in signer.findall("package")
                    if x.attrib.get("name") == PKG]
        if len(packages) > 1:
            raise ValueError("Duplicate PowerKeeper package in signer policy")
        if packages:
            labels = [x.attrib.get("value") for x in packages[0].findall("seinfo")]
            if labels != [SEINFO]:
                raise ValueError("Conflicting existing PowerKeeper seinfo")
            print(f"[POWERKEEPER SELINUX] PASS: scoped signer policy already present in {p}")
            return
    else:
        p = target
        if p not in roots:
            roots[p] = ET.ElementTree(ET.Element("policy"))
        signer = ET.SubElement(roots[p].getroot(), "signer", {"signature": signature})

    pkg = ET.SubElement(signer, "package", {"name": PKG})
    ET.SubElement(pkg, "seinfo", {"value": SEINFO})
    if verify_only:
        raise ValueError("Required scoped policy is missing from ROM at verification stage")

    p.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(roots[p], space="  ")
    with tempfile.NamedTemporaryFile(mode="wb", dir=p.parent,
                                     prefix=".pk-mac-", delete=False) as tmp:
        path = Path(tmp.name)
        roots[p].write(tmp, encoding="utf-8", xml_declaration=True)
    try:
        if ET.parse(path).getroot().tag != "policy":
            raise ValueError("Written policy validation failed")
        os.replace(path, p)
    finally:
        path.unlink(missing_ok=True)
    print("[POWERKEEPER SELINUX] Scoped signer/package mapping installed:", p)
    print("[POWERKEEPER SELINUX] Package:", PKG, "seinfo:", SEINFO)
    print("[POWERKEEPER SELINUX] Actual cert SHA256:", fingerprint)
    print("[POWERKEEPER SELINUX] SELinux enforcing unchanged")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--images", type=Path, required=True)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--verify-only", action="store_true")
    args = parser.parse_args()
    apply(args.images, args.cert, args.verify_only)
