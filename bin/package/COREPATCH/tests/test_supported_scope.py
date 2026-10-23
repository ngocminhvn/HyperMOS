"""Guard the CorePatch/Kaorios ownership boundary and supported ROM versions."""

import unittest
from pathlib import Path


COREPATCH = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[4]


class SupportedScopeTest(unittest.TestCase):
    def test_only_android_15_to_17_patchers_are_present(self):
        self.assertEqual(
            sorted(path.name for path in COREPATCH.glob("jar_patcher_a*.sh")),
            ["jar_patcher_a15.sh", "jar_patcher_a16.sh", "jar_patcher_a17.sh"],
        )
        self.assertFalse((COREPATCH / "A13").exists())
        self.assertFalse((REPO / "bin/package/NOTIFICATION_FIX/A13").exists())
        self.assertFalse((REPO / "bin/package/NOTIFICATION_FIX/A14").exists())
        self.assertFalse((REPO / "bin/modfile/Universal/gmsservices/maps/A13").exists())
        self.assertFalse((REPO / "bin/modfile/Universal/gmsservices/maps/A14").exists())

    def test_dispatcher_rejects_unsupported_android_versions(self):
        dispatcher = (COREPATCH / "update.sh").read_text(encoding="utf-8")
        for version in ("15", "16", "17"):
            self.assertIn(f'AndroidVER == "{version}"', dispatcher)
        for version in ("12", "13", "14"):
            self.assertNotIn(f'AndroidVER == "{version}"', dispatcher)
        self.assertIn("unsupported Android version", dispatcher)
        self.assertIn("--kaorios", dispatcher)
        self.assertNotIn("--hypermos", dispatcher)

    def test_hypermos_and_kaorios_corepatch_run_in_order(self):
        driver = (REPO / "bin/package/patchpackage.sh").read_text(encoding="utf-8")
        hypermos = 'COREPATCH/update.sh"'
        kaorios = 'KAORIOS_TOOLBOX/mod/corepatch.sh"'
        toolbox = 'KAORIOS_TOOLBOX/patch.sh"'
        self.assertIn(hypermos, driver)
        self.assertIn(kaorios, driver)
        self.assertIn(toolbox, driver)
        self.assertLess(driver.index(hypermos), driver.index(kaorios))
        self.assertLess(driver.index(kaorios), driver.index(toolbox))
        self.assertIn("hypermos_corepatch_args+=(--kaorios)", driver)

        dispatcher = (COREPATCH / "update.sh").read_text(encoding="utf-8")
        self.assertIn('"")', dispatcher)
        self.assertIn("COREPATCH_DISABLE_SIGNATURE_VERIFICATION=1", dispatcher)
        self.assertIn("COREPATCH_DISABLE_SIGNATURE_VERIFICATION=0", dispatcher)
        self.assertEqual(dispatcher.count("COREPATCH_RUN_HYPERMOS_EXTRAS=1"), 2)

        kaorios_driver = (
            REPO / "bin/package/KAORIOS_TOOLBOX/mod/corepatch.sh"
        ).read_text(encoding="utf-8")
        self.assertIn("COREPATCH_DISABLE_SIGNATURE_VERIFICATION=1", kaorios_driver)
        self.assertIn("COREPATCH_RUN_HYPERMOS_EXTRAS=0", kaorios_driver)
        for version in ("a15", "a16", "a17"):
            self.assertIn(f"jar_patcher_{version}.sh", kaorios_driver)

    def test_build_and_kaorios_reject_unsupported_versions(self):
        guarded_entrypoints = (
            REPO / "build.sh",
            REPO / "packROM.sh",
            REPO / "bin/modfile/Universal/gmsservices/update.sh",
            REPO / "bin/package/KAORIOS_TOOLBOX/patch.sh",
            REPO / "bin/package/NOTIFICATION_FIX/notificationFIX.sh",
        )
        for path in guarded_entrypoints:
            content = path.read_text(encoding="utf-8")
            self.assertIn("15|16|17", content)
            self.assertIn("unsupported android version", content.lower())

    def test_android_15_notification_driver_uses_android_15_guard(self):
        driver = (REPO / "bin/package/NOTIFICATION_FIX/A15/SystemUI.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn('androidVER == "15"', driver)
        self.assertNotIn('androidVER == "16"', driver)

    def test_hypermos_extras_keep_eu_and_china_paths_separate(self):
        package_driver = (REPO / "bin/package/patchpackage.sh").read_text(encoding="utf-8")
        self.assertIn("HYPERMOS_PRESERVE_EU_FRAMEWORK=1", package_driver)
        self.assertIn("HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1", package_driver)

        for version in ("15", "16", "17"):
            patcher = (COREPATCH / f"jar_patcher_a{version}.sh").read_text(encoding="utf-8")
            self.assertIn("HYPERMOS_PRESERVE_EU_FRAMEWORK", patcher)
            self.assertIn("regionTYPE", patcher)
            self.assertIn("apply_miui_services_global_patch", patcher)
            self.assertIn("apply_miui_services_gboard", patcher)

    def test_corepatch_does_not_reimplement_kaorios_secure_flag(self):
        forbidden = (
            "COREPATCH_DISABLE_SECURE_FLAG",
            "FEATURE_DISABLE_SECURE_FLAG",
            "--disable-secure-flag",
            "notAllowCaptureDisplay",
            "isScreenCaptureAllowed",
            "isSecureLocked",
            "setSecureLocked",
        )
        for path in COREPATCH.rglob("*"):
            if path == Path(__file__) or path.suffix not in {".py", ".sh"}:
                continue
            content = path.read_text(encoding="utf-8")
            for token in forbidden:
                self.assertNotIn(token, content, f"{token} remains in {path.relative_to(REPO)}")


if __name__ == "__main__":
    unittest.main()
