#!/usr/bin/env python3
"""Offline contract checks for the vendored extract.erofs output layout."""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import edit_super


class ErofsExtractorContractTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name) / "work"
        self.trees = self.work / "trees"
        self.config = self.work / "config"
        self.trees.mkdir(parents=True)
        self.config.mkdir(parents=True)
        (self.work / "reports").mkdir()
        for name, value in (("W", self.work), ("TREES", self.trees), ("CFG", self.config), ("REPORT", self.work / "reports")):
            p = patch.object(edit_super, name, value)
            p.start()
            self.addCleanup(p.stop)

    def simulate_tool(self, *args, omit_context=False, **kwargs):
        self.assertEqual(args[:4], ("extract.erofs", "-x", "-i", self.work / "product_a.img"))
        self.assertEqual(args[4], "-o")
        self.assertEqual(len(args), 6, "Do not pass -c; it selects an input file list")
        self.assertIn("stdout", kwargs, "Extractor progress should stay in a diagnostic report")
        stage = Path(args[5])
        (stage / "product_a" / "app").mkdir(parents=True)
        (stage / "product_a" / "app" / "unchanged.apk").write_bytes(b"test")
        (stage / "config").mkdir()
        (stage / "config" / "product_a_fs_config").write_text("product/app 0 0 0755\n")
        if not omit_context:
            (stage / "config" / "product_a_file_contexts").write_text("/product/app u:object_r:system_file:s0\n")

    def test_unpacks_tree_and_metadata_to_expected_locations(self):
        with patch.object(edit_super, "run", side_effect=self.simulate_tool):
            edit_super.extract_erofs_partition("product", self.work / "product_a.img")
        self.assertTrue((self.trees / "product" / "app" / "unchanged.apk").is_file())
        self.assertTrue((self.config / "product" / "product_a_fs_config").is_file())
        self.assertTrue((self.config / "product" / "product_a_file_contexts").is_file())
        self.assertFalse((self.work / "extract-staging" / "product").exists())

    def test_refuses_missing_selinux_metadata(self):
        def without_context(*args, **kwargs):
            self.simulate_tool(*args, omit_context=True, **kwargs)
        with patch.object(edit_super, "run", side_effect=without_context):
            with self.assertRaisesRegex(RuntimeError, "missing exact fs_config"):
                edit_super.extract_erofs_partition("product", self.work / "product_a.img")
        self.assertFalse((self.trees / "product").exists())
        self.assertFalse((self.config / "product").exists())


class HaotianVendorIdentityTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name) / "work"
        self.trees = self.work / "trees"
        self.ws = self.work / "super-work"
        self.report = self.work / "reports"
        for directory in (self.trees, self.ws / "images", self.report):
            directory.mkdir(parents=True)
        (self.ws / "images" / "vendor_a.img").write_bytes(b"original vendor image")
        (self.ws / "super_rw_manifest.json").write_text(
            '{"partitions": [{"name": "vendor_a", "image": "images/vendor_a.img", '
            '"filesystem": "erofs", "original_partition_size": 12345}]}'
        )
        for name,value in (
            ("W", self.work), ("WS", self.ws),
            ("TREES", self.trees), ("REPORT", self.report),
        ):
            patcher = patch.object(edit_super, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)

    def extract_original_vendor(self, device="haotian"):
        vendor = self.trees / "vendor"
        vendor.mkdir()
        if device is not None:
            (vendor / "build.prop").write_text(
                f"ro.product.vendor.device={device}\n"
            )

    def test_accepts_vendor_haotian_even_if_modded_system_has_other_properties(self):
        system = self.trees / "system"
        system.mkdir()
        (system / "build.prop").write_text("ro.product.device=ryuos\n")
        with patch.object(edit_super, "extract_erofs_partition",
                          side_effect=lambda base, image: self.extract_original_vendor()):
            edit_super.verify_haotian_base()
        self.assertIn("Verified device: haotian",
                      (self.report / "root-device.txt").read_text())

    def test_rejects_conflicting_vendor_identity(self):
        with patch.object(edit_super, "extract_erofs_partition",
                          side_effect=lambda base, image: self.extract_original_vendor("nuwa")):
            with self.assertRaisesRegex(RuntimeError, "conflicts"):
                edit_super.verify_haotian_base()

    def test_rejects_unidentified_vendor_despite_haotian_input_filename(self):
        with patch.object(edit_super, "extract_erofs_partition",
                          side_effect=lambda base, image: self.extract_original_vendor(None)):
            with self.assertRaisesRegex(RuntimeError, "no device declaration"):
                edit_super.verify_haotian_base()


if __name__ == "__main__":
    unittest.main()
