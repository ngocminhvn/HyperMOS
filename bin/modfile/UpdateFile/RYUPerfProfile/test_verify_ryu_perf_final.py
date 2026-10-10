#!/usr/bin/env python3
"""Exercise final-stage RYU CPU/perf/thermal overwrite detection."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

import verify_ryu_perf_final as audit


def sha(data):
    return hashlib.sha256(data).hexdigest()


class Perf:
    EXPECTED = {}


class Thermal:
    REQUIRED = {"normal", "video", "per-normal", "hp-normal"}
    PROFILES = REQUIRED
    PROTECTED = {"charge", "chg-only", "nolimits", "tgame"}


class FinalAuditTests(unittest.TestCase):
    def setUp(self):
        d = tempfile.TemporaryDirectory(prefix="ryu-final-")
        self.addCleanup(d.cleanup)
        self.images = Path(d.name) / "images"
        self.images.mkdir()
        self.report = Path(d.name) / "report.json"
        self.perf_file = self.images / "vendor/etc/perf/perfboostsconfig.xml"
        self.perf_file.parent.mkdir(parents=True)
        xml = b'<configs><node name="cpu_freq" value="98765"/></configs>'
        self.perf_file.write_bytes(xml)
        Perf.EXPECTED = {"vendor/etc/perf/perfboostsconfig.xml": sha(xml)}
        (self.images.parent / "ryu-test-perf-manifest.json").write_text(
            json.dumps([{"file": "vendor/etc/perf/perfboostsconfig.xml",
                         "ryu_sha256": sha(xml)}])
        )
        installed = []
        for name in sorted(Thermal.REQUIRED):
            rel = "odm/etc/thermal-" + name + ".conf"
            target = self.images / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            raw = bytes([len(name)]) * 256
            target.write_bytes(raw)
            installed.append({"file": rel, "ryu_sha256": sha(raw)})
        safety = self.images / "odm/etc/thermal-nolimits.conf"
        safety.write_bytes(b"Xiaomi-safety-original")
        self.safety = safety
        self.thermal = self.images / installed[0]["file"]
        (self.images.parent / "ryu-test-thermal-profiles.json").write_text(
            json.dumps({"installed": installed,
                        "protected_stock_sha256":
                            {"odm/etc/thermal-nolimits.conf": sha(safety.read_bytes())}})
        )
        self.old_load = audit.load
        audit.load = lambda name: Perf if name == "port_ryu_perf" else Thermal
        self.addCleanup(lambda: setattr(audit, "load", self.old_load))

    def test_valid_ryu_config(self):
        audit.verify(self.images, self.report)
        record = json.loads(self.report.read_text())
        self.assertFalse(record["runtime_kernel_frequency_caps_verified"])

    def test_detects_cpu_overwrite(self):
        self.perf_file.write_text('<configs><node name="cpu_freq" value="123"/></configs>')
        with self.assertRaisesRegex(ValueError, "overwritten"):
            audit.verify(self.images, self.report)

    def test_detects_thermal_overwrite(self):
        self.thermal.write_bytes(b"bad")
        with self.assertRaisesRegex(ValueError, "thermal profile overwritten"):
            audit.verify(self.images, self.report)

    def test_detects_safety_override(self):
        self.safety.write_bytes(b"nolimits-override")
        with self.assertRaisesRegex(ValueError, "Protected Xiaomi thermal safety"):
            audit.verify(self.images, self.report)


if __name__ == "__main__":
    unittest.main()
