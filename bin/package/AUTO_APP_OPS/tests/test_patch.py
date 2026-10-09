#!/usr/bin/env python3
"""Offline contract checks; full ROM runtime verification still required."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("auto_ops_patch", ROOT / "patch.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class NewInstallHookTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name) / "smali_classes5/com/android/server/pm"
        self.folder.mkdir(parents=True)
        self.file = self.folder / "BroadcastHelper.smali"
        self.file.write_text(""".class public Lcom/android/server/pm/BroadcastHelper;
.super Ljava/lang/Object;
.field private final mContext:Landroid/content/Context;
.method private sendPackageAddedForNewUsers(Ljava/lang/String;I[I[IZILandroid/util/SparseArray;)V
    .registers 12
    .param p1, "packageName"
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation
    .end param

    :start
    const/4 v0, 0x0
    return-void
.end method
""", encoding="utf-8")
        self.helper = ROOT / "HyperMOSAutoOps.smali"

    def test_inject_once_without_changing_registers(self):
        _, did_patch = mod.patch_tree(Path(self.temp.name), self.helper)
        self.assertTrue(did_patch)
        code = self.file.read_text()
        self.assertEqual(code.count(mod.CALL), 1)
        self.assertLess(code.index(".end param"), code.index(mod.CALL))
        self.assertLess(code.index(mod.CALL), code.index("const/4 v0"))
        self.assertIn(".registers 12", code)
        self.assertTrue((self.folder / "HyperMOSAutoOps.smali").exists())
        _, did_patch_twice = mod.patch_tree(Path(self.temp.name), self.helper)
        self.assertFalse(did_patch_twice)

    def test_only_exact_xiaomi_ops(self):
        code = self.helper.read_text()
        for value in (10020, 10021, 10017):
            self.assertIn(f"0x{value:04x}", code)
        self.assertEqual(code.count("const/16 v3, 0x272"), 3)

    def test_missing_signature_aborts(self):
        self.file.write_text(".class public Lcom/android/server/pm/BroadcastHelper;\n")
        with self.assertRaisesRegex(RuntimeError, "Expected one A16"):
            mod.patch_tree(Path(self.temp.name), self.helper)
        self.assertFalse((self.folder / "HyperMOSAutoOps.smali").exists())

    def test_missing_context_aborts(self):
        content = self.file.read_text().replace(
            ".field private final mContext:Landroid/content/Context;", "")
        self.file.write_text(content)
        with self.assertRaisesRegex(RuntimeError, "Missing BroadcastHelper context field"):
            mod.patch_tree(Path(self.temp.name), self.helper)


if __name__ == "__main__":
    unittest.main()
