#!/usr/bin/env python3
"""Test-branch-only *scoped* SELinux signer mapping for PowerKeeper.

This does NOT sign the APK with Xiaomi's private key. It maps the test-signed
com.miui.powerkeeper to seinfo=platform, leaving SELinux enforcing and all
other packages unchanged. Runtime acceptance depends on device policy.
"""
import argparse
import hashlib
import re
import ssl
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

XIAOMI_CERT = "c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"
PKG = "com.miui.powerkeeper"


def cert_from_ryu(apk: Path) -> bytes:
    with zipfile.ZipFile(apk) as z:
        signed = z.read("META-INF/CERT.RSA")
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "signature.rsa"
        p.write_bytes(signed)
        out = subprocess.check_output(
            ["openssl", "pkcs7", "-inform", "DER", "-print_certs", "-in", str(p)],
            text=True,
        )
    match = re.search(r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", out, re.S)
    if not match:
        raise ValueError("RYU archive has no readable signer certificate")
    return ssl.PEM_cert_to_DER_cert(match.group())


def run(root: Path, signed: Path, signing_pem: Path, ryu: Path) -> None:
    if hashlib.sha256(cert_from_ryu(ryu)).hexdigest() != XIAOMI_CERT:
        raise ValueError("RYU certificate fingerprint mismatch")
    pem = signing_pem.read_text(encoding="ascii")
    der = ssl.PEM_cert_to_DER_cert(pem)
    cert_hex = der.hex().upper()
    signer_sha = hashlib.sha256(der).hexdigest()
    if signer_sha == XIAOMI_CERT:
        raise ValueError("Unexpected private Xiaomi signer availability")
    # Require same test cert as actual V2/V3 signing; caller verifies apksigner.
    if not signed.is_file():
        raise ValueError("Signed PowerKeeper file missing")
    candidate_paths = [
        root / "system_ext/etc/selinux/system_ext_mac_permissions.xml",
        root / "system/etc/selinux/plat_mac_permissions.xml",
        root / "system/etc/selinux/mac_permissions.xml",
    ]
    found = [p for p in candidate_paths if p.is_file()]
    if not found:
        raise ValueError("No known mac_permissions.xml file in unpacked ROM; do not guess a path")
    # Prefer the system_ext-specific policy. Never rewrite global signer records.
    policy = found[0]
    raw = policy.read_text(encoding="utf-8")
    parsed = ET.fromstring(raw)
    if parsed.tag != "policy":
        raise ValueError("Unexpected mac_permissions root element")
    for signer in parsed.findall("signer"):
        sig = signer.attrib.get("signature", "").lower()
        if sig == cert_hex.lower():
            for pkg in signer.findall("package"):
                if pkg.attrib.get("name") == PKG:
                    labels = [tag.attrib.get("value") for tag in pkg.findall("seinfo")]
                    if labels == ["platform"]:
                        print("[RYU SELINUX TEST] Already present: scoped platform seinfo")
                        return
                    raise ValueError("Existing PowerKeeper policy conflicts with requested label")
            if signer.find("seinfo") is not None:
                raise ValueError("Signer has an unscoped seinfo record; not safe to modify")
    insertion = (
        "  <!-- HyperMOS TEST ONLY: uid=1000 PowerKeeper with fixed testkey. -->\n"
        f'  <signer signature="{cert_hex}">\n'
        f'    <package name="{PKG}">\n'
        '      <seinfo value="platform" />\n'
        "    </package>\n"
        "  </signer>\n"
    )
    end = re.search(r"</policy>\s*$", raw)
    if not end:
        raise ValueError("Cannot safely append signer stanza to existing policy XML")
    updated = raw[:end.start()] + insertion + raw[end.start():]
    if ET.fromstring(updated).tag != "policy":
        raise ValueError("Policy XML validation failed")
    # Require a compatible existing seapp_contexts rule, do not fabricate one.
    contexts = list(root.glob("**/*seapp_contexts"))
    compatible = False
    for path in contexts:
        if not path.is_file():
            continue
        try:
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.strip().startswith("#"):
                    continue
                if all(token in line.split() for token in
                       ("user=system", "seinfo=platform", "domain=system_app")):
                    compatible = True
                    break
        except (UnicodeDecodeError, OSError):
            continue
    if not compatible:
        raise ValueError("Cannot find existing system_app seapp_context mapping; refusing unsafe edit")
    policy.write_text(updated, encoding="utf-8")
    print("[RYU SELINUX TEST] Installed signer/package-specific seinfo label in", policy)
    print("[RYU SELINUX TEST] RYU Xiaomi cert (reference only):", XIAOMI_CERT)
    print("[RYU SELINUX TEST] Actual test signer cert:", signer_sha)
    print("[RYU SELINUX TEST] Runtime check still required; this is not Xiaomi signing")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--images", type=Path, required=True)
    p.add_argument("--signed", type=Path, required=True)
    p.add_argument("--signing-pem", type=Path, required=True)
    p.add_argument("--ryu", type=Path, required=True)
    a = p.parse_args()
    run(a.images, a.signed, a.signing_pem, a.ryu)
