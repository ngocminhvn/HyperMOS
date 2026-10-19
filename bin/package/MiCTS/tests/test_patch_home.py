#!/usr/bin/env python3
"""No APK mutation; Home keycodes aside from 3 keep stock path."""
import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from patch_home import patch, PatchError

SAMPLE = """.class public Lcom/android/server/policy/MiuiSingleKeyRule;
.super Ljava/lang/Object;
.field private mKeyCode:I
.method public onLongPress(J)V
    .locals 1
    return-void
.end method
.method public supportLongPress()Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
"""

class HomeTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        d=self.root/"smali"/"com/android/server/policy"
        d.mkdir(parents=True)
        self.file=d/"MiuiSingleKeyRule.smali"
        self.file.write_text(SAMPLE)

    def test_home_only_and_idempotent(self):
        _,changed=patch(self.root)
        self.assertTrue(changed)
        code=self.file.read_text()
        self.assertIn("const/4 v1, 0x3",code)
        self.assertIn("if-eqz v0, :hmcts_stock_long",code)
        self.assertEqual(code.count("# HYPERMOS_MICTS_HOME"),2)
        _,changed=patch(self.root)
        self.assertFalse(changed)
        self.assertEqual(self.file.read_text(),code)

    def test_missing_required_method_fails(self):
        self.file.write_text(SAMPLE.replace("supportLongPress()Z","supportOther()Z"))
        with self.assertRaises(PatchError):
            patch(self.root)

if __name__=="__main__":
    unittest.main()
