#!/usr/bin/env python3
"""Regression tests for complete RYU PowerKeeper DEX staging (no Android runtime)."""
import importlib.util
import tempfile
import unittest
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
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
        self.assertIn(full.TNM_GET, result)
        self.assertIn("const/16 v16, 0x1", result)
        self.assertEqual((reads, gates), (1, 1))
        with self.assertRaisesRegex(ValueError, "Unsupported RYU framework reference"):
            full.adapt("invoke-static {}, Lcom/projectryu/ProjectRYUFramework;->unknown()V")
        parameter, _, count = full.adapt(
            "    sget-boolean p0, Lcom/projectryu/Build;->IS_RYU_BUILD:Z")
        self.assertIn("const/16 p0, 0x1", parameter)
        self.assertEqual(count, 1)

    def test_tnm_framework_real_method_implementations(self):
        smali = full.tnm_framework_smali()
        self.assertIn(".class public final " + full.TNM_API, smali)
        self.assertEqual(smali.count(".method public static "), 7)
        self.assertEqual(smali.count("invoke-static {"), 7)
        self.assertIn(
            "Landroid/provider/Settings$System;->getIntForUser"
            "(Landroid/content/ContentResolver;Ljava/lang/String;II)I", smali)
        self.assertIn(
            "Landroid/provider/Settings$System;->putLong"
            "(Landroid/content/ContentResolver;Ljava/lang/String;J)Z", smali)
        self.assertIn("move-result-wide v0", smali)
        self.assertIn("return-wide v0", smali)
        self.assertNotIn("ProjectRYUFramework", smali)
        # Reject any unverified foreign framework call, never silently allow it.
        with self.assertRaises(ValueError):
            full.adapt("invoke-static {}, Lcom/projectryu/ProjectRYUFramework;->unknown()V")


    def test_safe_ceiling_helper_strictly_scoped_and_fail_closed(self):
        fixture = (
            ".method private writeRawAndVerify(Ljava/lang/String;Ljava/lang/String;)Z\n"
            "    .locals 7\n"
            '    const-string v2, "Write did not stick: "\n'
            "    invoke-direct {p0, p1}, Lcom/android/tnm/perf/PerfHook;->readTrimmed(Ljava/lang/String;)Ljava/lang/String;\n"
            "    if-nez v1, :cond_2\n\n"
            "    new-instance v1, Ljava/lang/StringBuilder;\n"
            "    return v3\n"
            "    :cond_2\n"
            "    return v4\n"
            ".end method\n"
        )
        patched = full.patch_perfhook_write_verify(fixture)
        self.assertEqual(patched.count("->tnmSafeMaxClamp("), 1)
        # The saved receiver remains typed even when donor repurposes p0.
        self.assertIn(".locals 8", patched)
        self.assertIn("move-object/from16 v7, p0", patched)
        self.assertNotIn("invoke-static {p1, p2, p0}", patched)
        expected_call = (
            "    invoke-direct {v7, p1}, Lcom/android/tnm/perf/PerfHook;"
            "->readTrimmed(Ljava/lang/String;)Ljava/lang/String;\n"
            "    move-result-object v1\n"
            "    invoke-static {p1, p2, v1}, Lcom/android/tnm/perf/PerfHook;"
            "->tnmSafeMaxClamp(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z\n"
            "    move-result v1\n"
        )
        self.assertIn(expected_call, patched)
        self.assertLess(patched.index("move-object/from16 v7, p0"),
                        patched.index("invoke-direct {v7, p1}"))
        # The donor has one VALID early readTrimmed(p0, p1); only the new
        # mismatch read must use v7 after p0 is repurposed.
        self.assertEqual(patched.count("invoke-direct {p0, p1}, Lcom/android/tnm/perf/PerfHook;"), 1)
        overwritten = fixture.replace(
            "    if-nez v1, :cond_2",
            "    move-object p0, p1\n    if-nez v1, :cond_2")
        self.assertIn("invoke-direct {v7, p1}",
                      full.patch_perfhook_write_verify(overwritten))
        with self.assertRaisesRegex(ValueError, "scratch v7"):
            full.patch_perfhook_write_verify(
                fixture.replace("    .locals 7", "    .locals 7\n    const/4 v7, 0x0"))
        self.assertIn('"/scaling_max_freq"', patched)
        self.assertIn('"/devfreq/max_freq"', patched)
        self.assertNotIn('"/scaling_min_freq"', patched)
        self.assertNotIn('"/thermal_message/sconfig"', patched)
        self.assertIn("Ljava/lang/NumberFormatException;", patched)
        self.assertIn('const-string v2, "Write did not stick: "', patched)
        self.assertIn("if-eqz v1, :tnm_exact_mismatch", patched)
        with self.assertRaisesRegex(ValueError, "already has safe clamp"):
            full.patch_perfhook_write_verify(patched)
        with self.assertRaisesRegex(ValueError, "anchor changed"):
            full.patch_perfhook_write_verify(fixture.replace(
                "if-nez v1, :cond_2", "if-eqz v1, :cond_2"))


    def test_compiled_dex_rejects_wrong_receiver(self):
        from verify_perfhook_apk import verify_compiled_perfhook_smali
        compiled = (
            ".class public Lcom/android/tnm/perf/PerfHook;\n"
            ".method private writeRawAndVerify(Ljava/lang/String;Ljava/lang/String;)Z\n"
            "    .locals 8\n"
            "    move-object/from16 v7, p0\n"
            "    move-object p0, p1\n"
            "    invoke-direct {v7, p1}, Lcom/android/tnm/perf/PerfHook;->readTrimmed"
            "(Ljava/lang/String;)Ljava/lang/String;\n"
            "    move-result-object v1\n"
            "    invoke-static {p1, p2, v1}, Lcom/android/tnm/perf/PerfHook;->tnmSafeMaxClamp"
            "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z\n"
            "    move-result v1\n"
            "    return v1\n"
            ".end method\n"
        )
        verify_compiled_perfhook_smali(compiled)
        for bad in (
            compiled.replace("invoke-direct {v7, p1}", "invoke-direct {p0, p1}"),
            compiled.replace("    move-object/from16 v7, p0\n", ""),
            compiled.replace("    .locals 8", "    .locals 7"),
            compiled.replace("    move-object p0, p1\n", "    const/4 v7, 0x0\n"),
            compiled.replace("    move-result-object v1\n", "    move-result-object v2\n"),
        ):
            with self.assertRaises(ValueError):
                verify_compiled_perfhook_smali(bad)

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
                if cls == "Lcom/projectryu/perf/PerfHook;":
                    body += (
                        ".method private writeRawAndVerify(Ljava/lang/String;Ljava/lang/String;)Z\n"
                        "    .locals 7\n"
                        '    const-string v2, "Write did not stick: "\n'
                        "    invoke-direct {p0, p1}, Lcom/projectryu/perf/PerfHook;->readTrimmed(Ljava/lang/String;)Ljava/lang/String;\n"
                        "    if-nez v1, :cond_2\n\n"
                        "    new-instance v1, Ljava/lang/StringBuilder;\n"
                        "    return v3\n"
                        "    :cond_2\n"
                        "    return v4\n"
                        ".end method\n"
                    )
                if cls == "Lcom/miui/powerkeeper/AppRuleChecker;":
                    # The original Xiaomi caller should resolve the renamed
                    # TNM PerfHook, including reflection by dotted class name.
                    body = (
                        ".method public test()V\n"
                        "    .locals 1\n"
                        "    const-class v0, Lcom/projectryu/perf/PerfHook;\n"
                        '    const-string v0, "com.projectryu.perf.PerfHook"\n'
                        '    const-string v0, "projectryu_thermal_profiles"\n'
                        "    return-void\n"
                        ".end method\n")
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
            self.assertTrue(result["safe_cpu_gpu_max_clamp_verification"])
            expected = (
                set(full.classes(donor)) - set(perf)
                | set(result["tnm_perf_classes"]) | {full.TNM_API})
            self.assertEqual(set(full.classes(stock)), expected)
            self.assertEqual(result["renamed_ryu_perf_classes"], 20)
            self.assertEqual(result["legacy_ryu_perf_classes_remaining"], 0)
            self.assertTrue(all(x.startswith(full.TNM_PERF_PREFIX)
                                for x in result["classes"]))
            self.assertEqual(result["tnm_framework_api"], full.TNM_API)
            self.assertEqual(result["tnm_framework_call_sites"], 3)
            self.assertEqual(len(result["tnm_framework_method_signatures"]), 7)
            bridge = full.classes(stock)[full.TNM_API].read_text()
            for name in full.TNM_METHODS:
                self.assertIn(".method public static " + name + "(", bridge)
            self.assertNotIn("ProjectRYUFramework", bridge)
            self.assertNotIn("Lcom/miui/powerkeeper/StockOnly;", full.classes(stock))
            perf_text = full.classes(stock)["Lcom/android/tnm/perf/PerfHook;"].read_text()
            self.assertFalse(
                (stock / "smali/com/projectryu/perf/PerfHook.smali").exists())
            self.assertTrue(
                (stock / "smali/com/android/tnm/perf/PerfHook.smali").exists())
            checker = full.classes(stock)[
                "Lcom/miui/powerkeeper/AppRuleChecker;"].read_text()
            self.assertIn("Lcom/android/tnm/perf/PerfHook;", checker)
            self.assertIn("com.android.tnm.perf.PerfHook", checker)
            self.assertNotIn("com.projectryu.perf", checker)
            self.assertIn("projectryu_thermal_profiles", checker)
            self.assertNotIn(full.RYU_GET, perf_text)
            self.assertIn(full.TNM_GET, perf_text)
            self.assertIn("const/4 v0, 0x1", perf_text)
            self.assertEqual(perf_text.count("->tnmSafeMaxClamp("), 1)
            self.assertIn("invoke-static {p1, p2, v1}", perf_text)
            self.assertIn("move-object/from16 v7, p0", perf_text)
            self.assertIn("invoke-direct {v7, p1}", perf_text)
            self.assertNotIn("invoke-static {p1, p2, p0}", perf_text)
            self.assertIn(".method private static tnmSafeMaxClamp", perf_text)
            self.assertIn("Lcom/android/tnm/perf/PerfHook;->tnmSafeMaxClamp", perf_text)
            mock_apk(donor_apk, manifest=b"different")
            with self.assertRaisesRegex(ValueError, "manifests differ"):
                full.apk_contract(base_apk, donor_apk)


if __name__ == "__main__":
    unittest.main()
