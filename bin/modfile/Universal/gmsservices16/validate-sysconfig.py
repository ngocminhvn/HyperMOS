#!/usr/bin/env python3
"""Fail fast on invalid HyperMOS Android 16 GMS sysconfig.

Pure validation. Does not modify GMS, Doze, notifications, or any ROM files.
"""
from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

CONFIG_DIR = Path(__file__).resolve().parent / "product/etc/sysconfig"
GOOGLE = CONFIG_DIR / "google.xml"
PUSH = CONFIG_DIR / "hypermos-google-push-keepalive.xml"
PREINSTALL = CONFIG_DIR / "preinstalled-packages-product-pixel-2017-and-newer.xml"
MAPS_APK = Path(__file__).resolve().parent / "product/app/Maps/Maps.apk"


def read(path: Path) -> ET.Element:
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError) as exc:
        raise ValueError(f"Invalid XML at {path}: {exc}") from exc
    if root.tag != "config":
        raise ValueError(f"{path}: expected <config> root, got <{root.tag}>")
    return root


def require(root: ET.Element, path: Path, tag: str, attr: str, value: str) -> None:
    if not any(node.tag == tag and node.get(attr) == value for node in root):
        raise ValueError(f"{path.name}: missing expected <{tag} {attr}={value!r}>")


def validate() -> None:
    google = read(GOOGLE)
    # RYU parity: Google's own stock sysconfig is the only GMS exemption source
    # shipped by this module. The old HyperMOS push XML added rules absent from
    # the original RYU HAOTIAN sysconfig.
    if PUSH.exists():
        raise ValueError(f"{PUSH.name}: extra GMS push exemptions not present in RYU")
    # The two existing, valid Google backup transport declarations must be preserved.
    backup = [node.get("service") for node in google
              if node.tag == "backup-transport-whitelisted-service"]
    required_backup = [
        "com.google.android.gms/.backup.BackupTransportService",
        "com.google.android.gms/.backup.component.D2dTransportService",
    ]
    if sorted(backup) != sorted(required_backup):
        raise ValueError(f"google.xml: unexpected backup transports: {backup!r}")

    # Maps APK is not bundled. No package installation declaration either.
    if MAPS_APK.exists():
        raise ValueError("Maps APK should not be preinstalled in GMS16")
    preinstall = read(PREINSTALL)
    if any(el.get("package") == "com.google.android.apps.maps"
           for el in preinstall.iter()):
        raise ValueError("Google Maps auto-install rule remains")

    # Actual RYUOS HAOTIAN product/etc/sysconfig/google.xml grants GMS
    # precisely these power/data-saver exemptions; it DOES NOT grant the
    # extra bg-restriction-exemption HyperMOS previously injected.
    for tag in ("allow-in-power-save", "allow-in-data-usage-save"):
        require(google, GOOGLE, tag, "package", "com.google.android.gms")
    for tag in ("allow-in-power-save", "allow-in-data-usage-save", "bg-restriction-exemption"):
        for package in ("com.google.android.gsf", "com.android.vending"):
            if any(node.tag == tag and node.get("package") == package for node in google):
                raise ValueError(f"google.xml: extra {tag} for {package}")
    if any(node.tag == "bg-restriction-exemption" and
           node.get("package") == "com.google.android.gms" for node in google):
        raise ValueError("google.xml: extra GMS background restriction exemption")
    require(google, GOOGLE, "allow-implicit-broadcast", "action",
            "com.google.android.c2dm.intent.RECEIVE")
    for action in ("com.google.android.gcm.intent.RETRY",
                   "com.google.android.intent.action.GCM_RECONNECT"):
        if any(node.tag == "allow-implicit-broadcast" and
               node.get("action") == action for node in google):
            raise ValueError(f"google.xml: extra non-RYU implicit broadcast {action}")
    print("[OK] Android 16 GMS sysconfig parses correctly")
    print("[OK] Both GMS backup transports preserved")
    print("[OK] Google Maps APK and auto-install rule absent")
    print("[OK] Exact RYU GMS power/data-saver exemption set; extra HyperMOS push XML absent")


if __name__ == "__main__":
    try:
        validate()
    except ValueError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
