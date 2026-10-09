#!/usr/bin/env python3
"""Remove inherited Google Backup transport registrations at ROM build time.

Leave other backup providers, XML content and notification/GMS policy untouched.
No boot service, loop or package disabling is installed.
"""
import argparse
from pathlib import Path
import re
import sys
import tempfile
import xml.etree.ElementTree as ET

GOOGLE = {"com.google.android.gms", "com.google.android.backuptransport"}
PARTITIONS = ("system/system", "system", "system_ext", "product", "vendor",
              "odm", "india", "my_bigball", "cust")
ENTRY = re.compile(
    r"(?m)^[ \t]*<backup-transport-whitelisted-service\b[^>]*?/>[ \t]*(?:\r?\n)?"
)


def is_google(service):
    return bool(service) and service.split("/", 1)[0] in GOOGLE


def services(root):
    return [el.get("service") for el in root.iter()
            if el.tag == "backup-transport-whitelisted-service"]


def strip(path):
    old = path.read_text(encoding="utf-8")
    if ("backup-transport-whitelisted-service" not in old
            or not any(pkg in old for pkg in GOOGLE)):
        return 0
    try:
        root = ET.fromstring(old)
    except ET.ParseError as exc:
        raise ValueError(f"{path}: malformed input XML: {exc}") from exc
    expected = sum(map(is_google, services(root)))
    if not expected:
        return 0
    count = 0

    def replace(match):
        nonlocal count
        text = match.group(0)
        try:
            service = ET.fromstring(text.strip()).get("service")
        except ET.ParseError as exc:
            raise ValueError(f"{path}: malformed transport entry") from exc
        if is_google(service):
            count += 1
            return ""
        return text

    new = ENTRY.sub(replace, old)
    if count != expected:
        raise ValueError(f"{path}: expected {expected} removals, got {count}")
    try:
        updated_root = ET.fromstring(new)
    except ET.ParseError as exc:
        raise ValueError(f"{path}: removal produced invalid XML: {exc}") from exc
    if any(map(is_google, services(updated_root))):
        raise ValueError(f"{path}: Google Backup transport is still allowed")
    path.write_text(new, encoding="utf-8")
    print(f"[GMS16] Removed {count} Google Backup transport(s): {path}")
    return count


def scan(images):
    total = 0
    for partition in PARTITIONS:
        for cfg_type in ("permissions", "sysconfig"):
            folder = images / partition / "etc" / cfg_type
            if folder.is_dir():
                for path in sorted(folder.glob("*.xml")):
                    total += strip(path)
    print(f"[GMS16] Removed inherited Google Backup transports: {total}")
    return total


def self_test():
    with tempfile.TemporaryDirectory(prefix="hypermos-gms16-") as tmp:
        images = Path(tmp)
        folder = images / "product/etc/sysconfig"
        folder.mkdir(parents=True)
        file = folder / "google.xml"
        file.write_text('''<?xml version="1.0"?>
<config>
    <!-- FCM preserved -->
    <allow-in-power-save package="com.google.android.gms" />
    <backup-transport-whitelisted-service
        service="com.google.android.gms/.backup.BackupTransportService" />
    <backup-transport-whitelisted-service
        service="com.google.android.gms/.backup.component.D2dTransportService" />
    <backup-transport-whitelisted-service
        service="com.example.local/.LocalTransport" />
</config>
''', encoding="utf-8")
        if scan(images) != 2:
            raise ValueError("Expected two Google Backup transport removals")
        text = file.read_text(encoding="utf-8")
        if "com.example.local/.LocalTransport" not in text:
            raise ValueError("Unrelated backup transport changed")
        if '<allow-in-power-save package="com.google.android.gms" />' not in text:
            raise ValueError("FCM exemption changed")
        if "<!-- FCM preserved -->" not in text:
            raise ValueError("Comments changed")
        ET.fromstring(text)
        if scan(images):
            raise ValueError("Backup removal was not idempotent")
    print("[OK] Google Backup removal leaves FCM and other transports intact")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("images", type=Path, nargs="?")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            self_test()
        elif args.images and args.images.is_dir():
            scan(args.images)
        else:
            parser.error("Pass ROM images directory or --self-test")
    except (ValueError, OSError) as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
