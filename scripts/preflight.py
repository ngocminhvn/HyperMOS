#!/usr/bin/env python3
"""Read-only configuration validation. Never downloads or edits an image."""
import hashlib
import json
import os
from pathlib import Path
from urllib.parse import urlsplit

cfg = json.loads(Path("config.json").read_text(encoding="utf-8"))
url = cfg.get("source_super_url", "").strip()
checksum = cfg.get("source_sha256", "").strip().lower()
bundle_url = cfg.get("apk_bundle_url", "").strip()
bundle_checksum = cfg.get("apk_bundle_sha256", "").strip().lower()

def validate_source(label, value, digest, optional=False):
    if not value and not digest and optional:
        return
    if not value or not digest:
        raise SystemExit(f"{label}: URL and SHA-256 must both be set")
    p = urlsplit(value)
    if p.scheme != "https" or not p.hostname or p.username or p.password:
        raise SystemExit(f"{label}: use an HTTPS download URL without credentials")
    if len(digest) != 64 or any(c not in "0123456789abcdef" for c in digest):
        raise SystemExit(f"{label}: SHA-256 must be exactly 64 hex digits")

validate_source("super.img", url, checksum, optional=True)
validate_source("APK bundle", bundle_url, bundle_checksum, optional=True)
if not cfg.get("preserve_unrelated_mods"):
    raise SystemExit("preserve_unrelated_mods must be true")
if cfg.get("requested_changes", {}).get("build_prop") != "audit_only":
    raise SystemExit("build_prop is audit_only until exact keys/dependencies have been reviewed")
if not cfg.get("os3_source_ref") or len(cfg["os3_source_ref"]) != 40:
    raise SystemExit("os3_source_ref must be a pinned 40-character commit SHA")
out = Path(os.environ.get("GITHUB_OUTPUT", "/dev/null"))
with out.open("a", encoding="utf-8") as f:
    f.write("has_source=" + ("true" if url else "false") + "\n")
if url:
    print("Preflight OK: read-only image inspection enabled.")
else:
    print("Preflight OK. Waiting for source_super_url + source_sha256 in config.json.")
    print("No image was downloaded or edited; no flashable artifact has been generated.")
