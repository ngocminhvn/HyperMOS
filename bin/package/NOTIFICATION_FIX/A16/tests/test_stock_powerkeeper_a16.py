"""Regression tests for China stock PowerKeeper allowlist and equal-size gates."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
P = ROOT / "patch_stock_powerkeeper_a16.py"
spec = importlib.util.spec_from_file_location("stock_powerkeeper", P)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class StockGateTests(unittest.TestCase):
    def test_manifest_contains_only_gms_doze_not_display(self):
        gates = mod.load_manifest(ROOT / "powerkeeper_stock_patches.json")
        self.assertEqual(len(gates), 4)
        self.assertEqual({(x["class"], x["method"], x["prototype"]) for x in gates},
                         mod.APPROVED)
        self.assertTrue(all("DisplayFrameSetting" not in x["class"] for x in gates))

    def test_rejects_unapproved_display_gate(self):
        raw = json.loads((ROOT / "powerkeeper_stock_patches.json").read_text())
        raw["gates"][0]["class"] = mod.UNTOUCHED[0]
        with tempfile.TemporaryDirectory() as t:
            path = Path(t) / "manifest.json"
            path.write_text(json.dumps(raw))
            with self.assertRaisesRegex(ValueError, "Unapproved"):
                mod.load_manifest(path)

    def test_rejects_duplicates_and_missing_gates(self):
        raw = json.loads((ROOT / "powerkeeper_stock_patches.json").read_text())
        raw["gates"][1] = raw["gates"][0].copy()
        with tempfile.TemporaryDirectory() as t:
            path = Path(t) / "manifest.json"
            path.write_text(json.dumps(raw))
            with self.assertRaisesRegex(ValueError, "duplicate"):
                mod.load_manifest(path)
        raw["gates"].pop()
        with tempfile.TemporaryDirectory() as t:
            path = Path(t) / "manifest.json"
            path.write_text(json.dumps(raw))
            with self.assertRaisesRegex(ValueError, "Exactly four"):
                mod.load_manifest(path)

    def test_boolean_gate_preserves_length_and_register(self):
        import struct
        for reg in (0, 5, 15):
            data = bytearray(b"\xff" * 24)
            mod.rewrite_gate(data, 8, reg)
            self.assertEqual(len(data), 24)
            self.assertEqual(struct.unpack_from("<HH", data, 8),
                             (0x1012 | (reg << 8), 0))
            self.assertEqual(data[:8], b"\xff" * 8)
            self.assertEqual(data[12:], b"\xff" * 12)

    def test_gate_bounds_rejected(self):
        for offset, reg in ((-1, 1), (14, 1), (0, 16), (0, -1)):
            with self.assertRaises(ValueError):
                mod.rewrite_gate(bytearray(16), offset, reg)


if __name__ == "__main__":
    unittest.main()
