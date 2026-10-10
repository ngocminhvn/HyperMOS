#!/usr/bin/env python3
"""TEST BRANCH ONLY: import RYU HAOTIAN performance XMLs with exact SHA256 checks.

Copy an internally consistent powerhint/perf XML group. This does NOT touch
thermal safety profiles, per-app governors, kernel, boot, or notification policy.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile
import xml.etree.ElementTree as ET

EXPECTED = {
    "odm/etc/powerhint.xml": "5ad387d826856243c5c0bdfa05152b8176f572123ee4dbfaa55276db975289f1",
    "vendor/etc/powerhint.xml": "f4ff77239d7514200d7550166a1c0abd5375353f1843b7e806496915935ff745",
    "vendor/etc/perf/avcsysnodesconfigs.xml": "7fded53a23bd067374075f8c85b5c60dc03f6de1aba511200e5af39e3f8637ae",
    "vendor/etc/perf/commonsysnodesconfigs.xml": "4a59932560c78d8f051c509ebcb300c7fbe6968cfc3a95134224763707d6e3c9",
    "vendor/etc/perf/factorsconfig.xml": "74151f508f0b38fd7ffd0d651349d845327627e4221569934a65587151415ba5",
    "vendor/etc/perf/perfboostsconfig.xml": "6349a5c715c9fbef4abc08de6e8867a0ca265e49a2dfd9c36428c4ea09edf1fc",
    "vendor/etc/perf/qapeboostsconfig.xml": "a185649343167c4f25bd1aec286198dc498e4b4ba9d785b6fea00b93d5016284",
    "vendor/etc/perf/targetsysnodesconfigs.xml": "2fd83ec97045e3b58e1b7f4aca95ca5845314b650b25d69cdceb9c43628319a6",
    "vendor/etc/perf/targetavcsysnodesconfigs.xml": "61b568d120e3178f67606408cf406d5df19c7ebe7640f0383e0a439e85296e78",
    "vendor/etc/perf/thermalbreakboostconfig.xml": "7e5fbfc12305b5425b85710ebe70083e57a40843eaa4c5f3423182d66061765f",
}
# No thermal-boost.conf: binary & chipset-specific, unclear safety semantics.
# No thermal-*.conf, charging profiles, init scripts, FPS override.

def validate(artifact, rom):
    manifest_path = artifact / "manifest.json"
    if not manifest_path.is_file():
        raise RuntimeError("Missing RYU thermal artifact manifest.json")
    items = json.loads(manifest_path.read_text(encoding="utf-8"))
    entry_map = {x["partition"] + x["original_path"].lstrip("/"): x
                 for x in items}
    prepared = []
    for rel, expected_sha in EXPECTED.items():
        entry = entry_map.get(rel)
        if not entry:
            raise RuntimeError("Missing original RYU artifact entry: " + rel)
        source = (artifact / entry["artifact_path"]).resolve()
        if not source.is_relative_to(artifact.resolve()) or not source.is_file():
            raise RuntimeError("Unsafe/missing artifact path: " + rel)
        # Manifest produced by the RYU read-only collector, then pinned to
        # the actual original files supplied by the user.
        raw = source.read_bytes()
        actual_sha = hashlib.sha256(raw).hexdigest()
        if actual_sha != expected_sha or entry.get("sha256") != expected_sha:
            raise RuntimeError(f"RYU file changed or corrupted: {rel}")
        destination = rom / rel
        if not destination.is_file() or destination.is_symlink():
            raise RuntimeError("Missing non-symlink stock destination: " + rel)
        new_root = ET.fromstring(raw).tag
        old_root = ET.parse(destination).getroot().tag
        if new_root != old_root:
            raise RuntimeError(f"Root tag mismatch {rel}: stock={old_root}, RYU={new_root}")
        prepared.append((rel, raw, destination, expected_sha))
    return prepared

def run(artifact, rom):
    files = validate(artifact, rom)  # no writes until all 10 validated
    log = []
    for rel, raw, dst, digest in files:
        before = hashlib.sha256(dst.read_bytes()).hexdigest()
        if before == digest:
            print("[RYU PERF] SAME", rel)
            log.append({"file": rel, "stock_sha256": before, "ryu_sha256": digest, "changed": False})
            continue
        fd, tmp = tempfile.mkstemp(prefix=".ryu-", dir=str(dst.parent))
        try:
            with os.fdopen(fd, "wb") as f:
                f.write(raw)
            os.chmod(tmp, dst.stat().st_mode & 0o777)
            os.replace(tmp, dst)
        finally:
            if os.path.exists(tmp):
                os.unlink(tmp)
        print("[RYU PERF] PORT", rel, "stock", before, "RYU", digest)
        log.append({"file": rel, "stock_sha256": before, "ryu_sha256": digest, "changed": True})
    (rom.parent / "ryu-test-perf-manifest.json").write_text(
        json.dumps(log, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("[RYU PERF] Imported verified RYU perf/powerhint XML set; thermal protections preserved")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--artifact", required=True, type=Path)
    p.add_argument("--rom", required=True, type=Path)
    args = p.parse_args()
    run(args.artifact, args.rom)

if __name__ == "__main__":
    main()
