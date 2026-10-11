#!/usr/bin/env python3
"""Regression tests for complete RYU PowerKeeper DEX staging (no Android runtime)."""
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("full_ryu", HERE / "ryu_full_powerkeeper_a16.py")
full = importlib.util.module_from_spec(spec)
spec.loader.exec_module(full)


def mock_apk(path, manifest=b"same"):
    with zipfile.ZipFile(path, "w") as z:
        z.writestr("AndroidManifest.xml", manifest)
        z.writestr("resources.arsc", b"stock-resources")
        z.writestr("classes.dex", b"dex\nmock")


def mock_smali(folder, descriptor, extra=""):
    path = folder / "smali" / (descriptor[1:-1] + ".smali")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(".class public " + descriptor +
                    "\n.super Ljava/lang/Object;\n" + extra, encoding="utf-8")
    return path


class FullRyuPort(unittest.TestCase):
    def test_build_time_compatibility_rewrites(self):
        value = full.RYU_GET + "\n" * 1 + (
            "    sget-boolean v16, Lcom/projectryu/Build;->IS_RYU_BUILD:Z\n")
        result, reads, gates = full.adapt(value)
        self.assertIn(full.ANDROID_GET, result)
        self.assertIn("const/16 v16, 0x1", result)
        self.assertEqual((reads, gates), (1, 1))
        with self.assertRaisesRegex(ValueError, "Unsupported RYU framework reference"):
            full.adapt("invoke-static {}, Lcom/projectryu/ProjectRYUFramework;->unknown()V")
        with self.assertRaisesRegex(ValueError, "parameter register"):
            full.adapt("    sget-boolean p0, Lcom/projectryu/Build;->IS_RYU_BUILD:Z")

    def test_full_class_set_transfer_and_manifest_guard(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            stock = root / "stock"
            donor = root / "donor"
            stock.mkdir()
            donor.mkdir()
            base_apk = root / "stock.apk"
            donor_apk = root / "donor.apk"
            mock_apk(base_apk)
            mock_apk(donor_apk)
            required = [
                "Lcom/miui/powerkeeper/PowerKeeperApplication;",
                "Lcom/miui/powerkeeper/controller/KillProcessController;",
                "Lcom/miui/powerkeeper/AppRuleChecker;",
                "Lcom/miui/powerkeeper/PowerKeeperInterface$l;",
            ]
            perf = ["Lcom/projectryu/perf/PerfHook;"] + [
                f"Lcom/projectryu/perf/PerfHook$Inner{i};" for i in range(19)]
            extras = [f"Lcom/miui/powerkeeper/mock/Dummy{i};"
                      for i in range(2800 - len(required) - len(perf))]
            donor_classes = required + perf + extras
            for cls in donor_classes:
                body = ""
                if cls == "Lcom/projectryu/perf/PerfHook;":
                    body = (".method public updateConfig()V\n"
                            + ("    invoke-static {v0, v1}, " + full.RYU_GET + "\n") * 3
                            + "    sget-boolean v0, Lcom/projectryu/Build;->IS_RYU_BUILD:Z\n"
                            + ".end method\n")
                mock_smali(donor, cls, body)
            # Stock contains older methods/classes, not the RYU-only PerfHook.
            for cls in required + extras:
                mock_smali(stock, cls)
            mock_smali(stock, "Lcom/miui/powerkeeper/StockOnly;")
            result = full.port(stock, donor, base_apk, donor_apk, root / "report.json")
            self.assertEqual(result["original_ryu_classes"], 2800)
            self.assertEqual(len(result["classes"]), 20)
            self.assertEqual(result["adapted_ryu_framework_setting_reads"], 3)
            self.assertEqual(result["adapted_ryu_build_gates"], 1)
            self.assertEqual(set(full.classes(stock)), set(full.classes(donor)))
            self.assertNotIn("Lcom/miui/powerkeeper/StockOnly;", full.classes(stock))
            perf_text = full.classes(stock)["Lcom/projectryu/perf/PerfHook;"].read_text()
            self.assertNotIn(full.RYU_GET, perf_text)
            self.assertIn(full.ANDROID_GET, perf_text)
            self.assertIn("const/4 v0, 0x1", perf_text)
            mock_apk(donor_apk, manifest=b"different")
            with self.assertRaisesRegex(ValueError, "manifests differ"):
                full.apk_contract(base_apk, donor_apk)


if __name__ == "__main__":
    unittest.main()
