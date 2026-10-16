#!/usr/bin/env python3
"""Offline ADB dump planning tests. No connected device required."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from adb_dump import target_location, selected_remote_files


class ADBDumpTests(unittest.TestCase):
    def test_installed_system_as_root_mapping(self):
        self.assertEqual(
            target_location("framework/system/system/framework/services.jar"),
            ("system", "framework/services.jar"))
        self.assertEqual(
            target_location("apps/product/app/Joyose/Joyose.apk"),
            ("product", "app/Joyose/Joyose.apk"))
        self.assertEqual(
            target_location("apps/system_ext/app/PowerKeeper/PowerKeeperZK.apk"),
            ("system_ext", "app/PowerKeeper/PowerKeeperZK.apk"))

    def test_base_only_5_files(self):
        inventory = [
            "/system/framework/framework.jar",
            "/system/framework/services.jar",
            "/system/framework/miui-framework.jar",
            "/system_ext/framework/miui-services.jar",
            "/system_ext/app/PowerKeeper/PowerKeeper.apk",
            "/vendor/lib64/libnotneeded.so",
        ]
        selected = selected_remote_files(inventory, "base", [])
        self.assertEqual(len(selected), 5)
        self.assertNotIn(inventory[-1], selected)
        self.assertEqual(
            selected["/system/framework/framework.jar"],
            ("system", "framework/framework.jar"))

    def test_full_exact_and_unique_apk_fallback(self):
        inventory = [
            "/system/framework/services.jar",
            "/system_ext/app/PowerKeeper/PowerKeeper.apk",
            "/product/app/Joyose/Joyose.apk",
        ]
        lines = [
            "framework/system/system/framework/services.jar",
            "apps/system_ext/app/PowerKeeper/PowerKeeperZK.apk",
            "apps/system_ext/app/PowerKeeper/PowerKeeperZK/assets/local.config",
            "apps/product/app/Joyose/Joyose.apk",
        ]
        selected = selected_remote_files(inventory, "full", lines)
        self.assertEqual(len(selected), 3)
        self.assertIn("/system_ext/app/PowerKeeper/PowerKeeper.apk", selected)

    def test_missing_files_not_mistaken_for_other_names(self):
        inventory = [
            "/product/app/App1/App1.apk",
            "/product/app/App1/App1.debug.apk",
            "/product/app/Different/Different.apk",
        ]
        targets = [
            "apps/product/app/App1/TargetMissing.apk",
            "apps/product/app/Other/Missing.apk",
        ]
        selected = selected_remote_files(inventory, "full", targets)
        self.assertEqual(selected, {})

    def test_not_mapped_when_no_partition(self):
        self.assertIsNone(target_location("pack-meta/INDEX.tsv"))


if __name__ == "__main__":
    unittest.main()
