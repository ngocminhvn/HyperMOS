#!/usr/bin/env python3
"""Small offline fixtures for nonstandard/custom ROM ZIP extraction."""
import sys
import tempfile
import unittest
import zipfile
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import archive_fallback
from archive_inspect import classify, LP_GEOMETRY, EROFS


class ArchiveFallbackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.zip_path = self.root / "custom_rom.zip"
        self.work = self.root / "work"

    def make_zip(self, members):
        with zipfile.ZipFile(self.zip_path, "w") as archive:
            for path, data in members.items():
                archive.writestr(path, data)

    def test_find_partition_image_nested_and_compressed(self):
        self.assertEqual(
            archive_fallback.find_part_image(
                "ROM/firmware/images/system_a.img.zst", ("system",)
            ),
            ("system", "_a", "system_a.img.zst"),
        )
        self.assertIsNone(
            archive_fallback.find_part_image(
                "ROM/images/boot.img", ("system", "system_ext", "product")
            )
        )

    def test_individual_images_nested(self):
        self.make_zip({
            "RomDir/images/system.img": b"RAW-FAKE-SYSTEM",
            "RomDir/images/product.img": b"RAW-FAKE-PRODUCT",
            "RomDir/images/vendor.img": b"NOT-WANTED-IN-BASE",
        })
        self.assertEqual(
            archive_fallback.extract(self.zip_path, self.work, "base"),
            "individual partition images",
        )
        self.assertEqual(
            (self.work / "partitions/system.img").read_bytes(),
            b"RAW-FAKE-SYSTEM",
        )
        self.assertFalse((self.work / "partitions/vendor.img").exists())

    def test_direct_rom_tree(self):
        self.make_zip({
            "RomDir/system/system/framework/framework.jar": b"EXAMPLE-JAR",
            "RomDir/system_ext/priv-app/PowerKeeper/PowerKeeper.apk": b"EXAMPLE-APK",
            "RomDir/unrelated.bin": b"NO",
        })
        self.assertEqual(
            archive_fallback.extract(self.zip_path, self.work, "base"),
            "direct partition file tree",
        )
        self.assertEqual(
            (self.work / "images/system/system/framework/framework.jar").read_bytes(),
            b"EXAMPLE-JAR",
        )
        self.assertTrue(
            (self.work / "images/system_ext/priv-app/PowerKeeper/PowerKeeper.apk").is_file()
        )

    def test_firmware_only_reports_missing_system_without_traceback(self):
        self.make_zip({
            "META-INF/com/google/android/update-binary": b"#!/bin/sh\nexit 0\n",
            "META-INF/com/google/android/updater-script": b"package_extract_file('firmware-update/custom.img')",
            "firmware-update/custom.img": b"NOT-A-SUPER-IMAGE",
            "firmware-update/boot.img": b"KERNEL-IMAGE-ONLY",
        })
        with self.assertRaises(SystemExit) as raised:
            archive_fallback.extract(self.zip_path, self.work, "full")
        self.assertIn("UNSUPPORTED-ROM-LAYOUT", str(raised.exception))
        self.assertIn("no verified Android system", str(raised.exception))
        inventory = json.loads((self.work / "zip-layout.json").read_text())
        self.assertEqual(inventory["members"], 4)
        self.assertEqual(inventory["entries"][0]["kind"], "shell-or-script")
        self.assertTrue((self.work / "updater-script.txt").is_file())
        self.assertIn("custom.img", (self.work / "zip-layout.txt").read_text())

    def test_renamed_image_requires_real_android_super_geometry_magic(self):
        self.assertEqual(classify(b"\0" * 4096 + LP_GEOMETRY), "android-super-raw")
        self.assertEqual(classify(b"\0" * 1024 + EROFS), "erofs")
        self.assertEqual(classify(b"\0" * 1080 + b"\x53\xef"), "ext4")
        self.assertEqual(classify(b"\x3a\xff\x26\xed"), "android-sparse")
        self.assertEqual(classify(b"KERNEL-IMAGE-ONLY"), "unknown")

    def test_traversal_rejected(self):
        self.make_zip({"../../escape/system/framework/framework.jar": b"NOT-SAFE"})
        with self.assertRaises(SystemExit):
            archive_fallback.extract(self.zip_path, self.work, "base")


if __name__ == "__main__":
    unittest.main()
