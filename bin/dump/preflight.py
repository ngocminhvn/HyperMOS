#!/usr/bin/env python3
"""Fail early for ROM ZIPs previously verified encrypted in our dump logs.

This is an exact release-specific guard, not a claim that all EliteRoms are
encrypted. No download or arbitrary remote code execution is performed.
"""
import argparse
import os
from pathlib import PurePosixPath
from urllib.parse import urlsplit

from sourceforge_download import normalize

# Verified in HyperMOS Actions runs 38829480282, 38835073204, 38840382765.
# The ZIP's firmware-update/custom.img begins with OpenSSL 'Salted__'.
KNOWN_ENCRYPTED = {
    ("eliteroms", "HyperOS-STABLE-UPDATES/HyperOS-v3.0/"
     "EliteRomLite_v4.05_HAOTIAN_OS3.0.307.0_ChinaStable-A16.zip".lower()),
}


def known_encrypted_release(url: str) -> bool:
    parts = urlsplit(url.strip())
    host = (parts.hostname or "").lower()
    is_sourceforge = (
        host in ("sourceforge.net", "www.sourceforge.net", "downloads.sourceforge.net")
        or host.endswith(".dl.sourceforge.net")
    )
    if not is_sourceforge:
        return False
    try:
        source = normalize(url)
    except ValueError:
        return False
    if source is None:
        return False
    _, project, relative = source
    return (project.lower(), relative.lower()) in KNOWN_ENCRYPTED


def check_source(url: str) -> int:
    if not known_encrypted_release(url):
        print("[PREFLIGHT] Source is not on the known-encrypted release list.")
        return 0

    headline = ("[UNSUPPORTED-ENCRYPTED-RELEASE] This exact EliteRomLite "
                "HAOTIAN v4.05 ZIP has already been verified to contain "
                "firmware-update/custom.img encrypted with OpenSSL Salted__. "
                "It cannot provide system framework/APK files to a hosted "
                "GitHub Actions dump without decryption material.")
    print("::error::" + headline)
    print("[PREFLIGHT] Skipping the known-failing ~7.5 GiB ROM download.")
    print("[PREFLIGHT] For the exact installed EliteRom ROM on your own phone, "
          "use bin/dump/adb_dump.py with authorized ADB on a local computer.")
    print("[PREFLIGHT] Alternatively supply an unencrypted ROM ZIP that contains "
          "the requested system partitions; stock files are not EliteRom files.")

    summary = os.getenv("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as output:
            output.write(
                "### Dump preflight: known encrypted ROM source\n\n"
                "This exact EliteRomLite v4.05 HAOTIAN ZIP was confirmed to "
                "contain an encrypted `firmware-update/custom.img` in "
                "[run #38840382765]"
                "(https://github.com/ngocminhvn/HyperMOS/actions/runs/38840382765). "
                "A ZIP-only GitHub runner cannot recover EliteRom system files "
                "from it without decryption information, so the 7.5 GiB "
                "download was skipped.\n\n"
                "For files from that exact installed ROM, run the read-only "
                "`bin/dump/adb_dump.py` tool on a computer connected to "
                "your authorized Android device. An unencrypted ZIP is "
                "required for cloud-only extraction.\n"
            )
    return 2


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True, help="User-supplied ROM ZIP URL")
    args = parser.parse_args()
    raise SystemExit(check_source(args.url))


if __name__ == "__main__":
    main()
