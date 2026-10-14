#!/usr/bin/env python3
"""Offline contract checks for the vendored extract.erofs output layout."""
import os
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


class HaotianRomInputTests(unittest.TestCase):
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
        for name, value in (
            ("W", self.work), ("WS", self.ws),
            ("TREES", self.trees), ("REPORT", self.report),
        ):
            patcher = patch.object(edit_super, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)

    def verify_url(self, filename):
        with patch.dict(os.environ, {
            "INPUT_URL": f"https://downloads.sourceforge.net/project/ryu/{filename}?use_mirror=onboardcloud"
        }):
            edit_super.verify_haotian_input()

    def test_accepts_haotian_archive_without_reading_build_prop(self):
        product = self.trees / "product"
        product.mkdir()
        (product / "build.prop").write_text("ro.product.device=ryuos\n")
        with patch.object(edit_super, "extract_erofs_partition",
                          side_effect=AssertionError("No vendor/property extraction allowed")):
            self.verify_url("RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip")
        report = (self.report / "root-device.txt").read_text()
        self.assertIn("HAOTIAN", report)
        self.assertEqual((product / "build.prop").read_text(), "ro.product.device=ryuos\n")

    def test_rejects_different_device_labeled_archive(self):
        with self.assertRaisesRegex(RuntimeError, "HAOTIAN-labeled"):
            self.verify_url("RYUOS_NUWA_OS3.0.309.0.zip")

    def test_rejects_unlabeled_archive(self):
        with self.assertRaisesRegex(RuntimeError, "HAOTIAN-labeled"):
            self.verify_url("custom-rom.zip")

    def test_rejects_missing_original_vendor(self):
        (self.ws / "images" / "vendor_a.img").unlink()
        with self.assertRaisesRegex(RuntimeError, "vendor image missing"):
            self.verify_url("RYUOS_HAOTIAN_OS3.zip")

    def test_rejects_unexpected_vendor_layout(self):
        (self.ws / "super_rw_manifest.json").write_text('{"partitions": []}')
        with self.assertRaisesRegex(RuntimeError, "vendor EROFS"):
            self.verify_url("RYUOS_HAOTIAN_OS3.zip")


class ErofsMetadataRepackTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.trees = root / "trees"
        self.report = root / "reports"
        self.trees.mkdir()
        self.report.mkdir()
        self.image = self.trees / "product"
        (self.image / "app").mkdir(parents=True)
        (self.image / "app" / "Original.apk").write_bytes(b"stock")
        self.fs = root / "fs_config"
        self.ctx = root / "file_contexts"
        for attr, value in (("TREES", self.trees), ("REPORT", self.report)):
            p = patch.object(edit_super, attr, value)
            p.start()
            self.addCleanup(p.stop)

    def test_rebases_extractor_relative_paths_and_preserves_ownership(self):
        self.fs.write_text(
            "/ 0 0 0755\n"
            "/app 0 0 0755\n"
            "/app/Original.apk 0 0 0644 capabilities=0x0\n"
        )
        self.ctx.write_text(
            "/ u:object_r:rootfs:s0\n"
            "/app u:object_r:system_file:s0\n"
            r"/app/Original\.apk u:object_r:system_file:s0" + "\n"
        )
        (self.image / "app" / "New.apk").write_bytes(b"mod")
        edit_super.reconcile_erofs_metadata("product", self.fs, self.ctx)
        config = self.fs.read_text()
        labels = self.ctx.read_text()
        # mkfs.erofs looks up its root inode with an empty path; the
        # canned config must have "/" rather than "product" for that entry.
        self.assertIn("/ 0 0 0755", config.splitlines())
        self.assertNotIn("product 0 0 0755", config.splitlines())
        self.assertIn("product/app 0 0 0755", config)
        self.assertIn("product/app/Original.apk 0 0 0644 capabilities=0x0", config)
        self.assertIn("product/app/New.apk 0 0 0644", config)
        self.assertIn("/product/app u:object_r:system_file:s0", labels)
        self.assertIn(r"/product/app/New\.apk u:object_r:system_file:s0", labels)
        self.assertNotIn("product/product/app", config)

    def test_accepts_already_prefixed_config(self):
        self.fs.write_text("product 0 0 0755\nproduct/app 0 0 0755\n"
                           "product/app/Original.apk 0 0 0644\n")
        self.ctx.write_text("/product u:object_r:rootfs:s0\n"
                            "/product/app u:object_r:system_file:s0\n"
                            r"/product/app/Original\.apk u:object_r:system_file:s0" + "\n")
        edit_super.reconcile_erofs_metadata("product", self.fs, self.ctx)
        self.assertEqual(len(self.fs.read_text().splitlines()), 3)
        self.assertIn("/ 0 0 0755", self.fs.read_text().splitlines())
        self.assertNotIn("product 0 0 0755", self.fs.read_text().splitlines())
        self.assertNotIn("product/product", self.fs.read_text())

    def test_refuses_fs_config_without_source_root(self):
        self.fs.write_text("/app 0 0 0755\n/app/Original.apk 0 0 0644\n")
        self.ctx.write_text("/ u:object_r:rootfs:s0\n"
                            "/app u:object_r:system_file:s0\n")
        with self.assertRaisesRegex(RuntimeError, "missing root inode metadata"):
            edit_super.reconcile_erofs_metadata("product", self.fs, self.ctx)

    def test_refuses_unlabeled_mod_directory(self):
        (self.image / "surprise").mkdir()
        self.fs.write_text("/ 0 0 0755\n/app 0 0 0755\n"
                           "/app/Original.apk 0 0 0644\n")
        self.ctx.write_text("/ u:object_r:rootfs:s0\n"
                            "/app u:object_r:system_file:s0\n")
        with self.assertRaisesRegex(RuntimeError, "inherited SELinux label"):
            edit_super.reconcile_erofs_metadata("product", self.fs, self.ctx)


if __name__ == "__main__":
    unittest.main()
