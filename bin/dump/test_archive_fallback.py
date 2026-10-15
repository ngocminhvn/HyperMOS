#!/usr/bin/env python3
"""Small offline fixtures for nonstandard/custom ROM ZIP extraction."""
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import archive_fallback


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

    def test_traversal_rejected(self):
        self.make_zip({"../../escape/system/framework/framework.jar": b"NOT-SAFE"})
        with self.assertRaises(SystemExit):
            archive_fallback.extract(self.zip_path, self.work, "base")


if __name__ == "__main__":
    unittest.main()
