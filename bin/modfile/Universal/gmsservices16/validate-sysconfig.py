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
    push = read(PUSH)
    # The two existing, valid Google backup transport declarations must be preserved.
    backup = [node.get("service") for node in google
              if node.tag == "backup-transport-whitelisted-service"]
    required_backup = [
        "com.google.android.gms/.backup.BackupTransportService",
        "com.google.android.gms/.backup.component.D2dTransportService",
    ]
    if sorted(backup) != sorted(required_backup):
        raise ValueError(f"google.xml: unexpected backup transports: {backup!r}")

    # Guard the current FCM connectivity exemptions; this change must NOT
    # reproduce the aggressive Google Play services Doze restrictions.
    for tag in ("allow-in-power-save", "allow-in-data-usage-save"):
        require(google, GOOGLE, tag, "package", "com.google.android.gms")
        for package in ("com.google.android.gms", "com.google.android.gsf",
                        "com.android.vending"):
            require(push, PUSH, tag, "package", package)
    for package in ("com.google.android.gms", "com.google.android.gsf",
                    "com.android.vending"):
        require(push, PUSH, "bg-restriction-exemption", "package", package)
    require(google, GOOGLE, "allow-implicit-broadcast", "action",
            "com.google.android.c2dm.intent.RECEIVE")
    for action in ("com.google.android.c2dm.intent.RECEIVE",
                   "com.google.android.gcm.intent.RETRY",
                   "com.google.android.intent.action.GCM_RECONNECT"):
        require(push, PUSH, "allow-implicit-broadcast", "action", action)
    print("[OK] Android 16 GMS sysconfig parses correctly")
    print("[OK] Both GMS backup transports preserved")
    print("[OK] Existing GMS/GSF/Play Store FCM exemptions unchanged")


if __name__ == "__main__":
    try:
        validate()
    except ValueError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
