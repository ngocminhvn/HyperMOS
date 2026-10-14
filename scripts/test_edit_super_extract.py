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
        for name, value in (("W", self.work), ("TREES", self.trees), ("CFG", self.config)):
            p = patch.object(edit_super, name, value)
            p.start()
            self.addCleanup(p.stop)

    def simulate_tool(self, *args, omit_context=False):
        self.assertEqual(args[:4], ("extract.erofs", "-x", "-i", self.work / "product_a.img"))
        self.assertEqual(args[4], "-o")
        self.assertEqual(len(args), 6, "Do not pass -c; it selects an input file list")
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
        def without_context(*args):
            self.simulate_tool(*args, omit_context=True)
        with patch.object(edit_super, "run", side_effect=without_context):
            with self.assertRaisesRegex(RuntimeError, "missing exact fs_config"):
                edit_super.extract_erofs_partition("product", self.work / "product_a.img")
        self.assertFalse((self.trees / "product").exists())
        self.assertFalse((self.config / "product").exists())


if __name__ == "__main__":
    unittest.main()
