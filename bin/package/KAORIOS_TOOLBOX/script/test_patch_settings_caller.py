#!/usr/bin/env python3
"""Regression checks for caller-side Settings spoof and bytecode verification."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("caller", Path(__file__).with_name("patch-settings-caller.py"))
caller = importlib.util.module_from_spec(spec)
spec.loader.exec_module(caller)


def fixture(registers=".locals 4"):
    return f""".class public final Landroid/provider/Settings$NameValueCache;
.super Ljava/lang/Object;
.field private final mCallGetCommand:Ljava/lang/String;
.method public {caller.dev.METHOD_ANCHOR}
    {registers}
    const-string v0, "stock"
    return-object v0
.end method
"""


class CallerTests(unittest.TestCase):
    def test_stock_fallback_and_explicit_null_have_separate_branches(self):
        patched, changed = caller.patch(fixture())
        self.assertTrue(changed)
        caller.verify(patched)
        self.assertLess(patched.index(caller.HOOK), patched.index('const-string v0, "stock"'))
        self.assertIn('if-eqz v0, ' + caller.LABEL, patched)
        self.assertIn('const-string v1, "value"', patched)
        self.assertEqual(caller.patch(patched), (patched, False))

    def test_existing_parameter_register_numbers_are_preserved(self):
        for directive in (".registers 25", ".locals 21"):
            patched, _ = caller.patch(fixture(directive))
            self.assertIn(directive, patched)
            caller.verify(patched, roundtrip=True)
            aliases = patched.replace("p0", "v21").replace("p2", "v23").replace("p3", "v24")
            caller.verify(aliases, roundtrip=True)

    def test_devstatus_prefix_remains_verifiable(self):
        original, _ = caller.dev.patch(fixture())
        patched, _ = caller.patch(original)
        caller.dev.verify(patched)
        caller.verify(patched)
        caller.dev.verify(patched, roundtrip=True)
        caller.verify(patched, roundtrip=True)
        self.assertEqual(caller.patch(patched), (patched, False))

    def test_missing_field_or_insufficient_locals_are_rejected(self):
        for text in (fixture(".locals 2"), fixture().replace("mCallGetCommand", "wrongField")):
            with self.assertRaises(ValueError):
                caller.patch(text)

    def test_wrong_arguments_or_missing_fallback_are_rejected(self):
        patched, _ = caller.patch(fixture())
        for text in (patched.replace("move/from16 v2, p3", "move/from16 v2, p1"),
                     patched.replace('const-string v0, "stock"\n    return-object v0', ""),
                     patched.replace('const-string v1, "value"', 'const-string v1, "wrong"')):
            with self.assertRaises(ValueError):
                caller.verify(text, roundtrip=True)

    def test_hook_after_stock_instructions_is_rejected(self):
        patched, _ = caller.patch(fixture())
        moved = patched.replace(caller.block(), "").replace('    return-object v0\n.end method', caller.block() + '    return-object v0\n.end method')
        with self.assertRaises(ValueError):
            caller.verify(moved, roundtrip=True)

    def test_bridge_guards_and_cleanup_are_verified(self):
        template = Path(__file__).resolve().parents[1] / "framework/HyperMOSSettingsSpoof.smali"
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "android/security/kaorios/HyperMOSSettingsSpoof.smali"
            target.parent.mkdir(parents=True)
            text = template.read_text(encoding="utf-8")
            target.write_text(text, encoding="utf-8")
            caller.verify_bridge(root)
            for mutation in (text.replace("if-ne p2, v2, :stock", "if-eq p2, v2, :stock"),
                             text.replace(".catchall {:policy_start .. :policy_end} :policy_error", ""),
                             text.replace("ThreadLocal;->remove()V", "ThreadLocal;->get()Ljava/lang/Object;")):
                target.write_text(mutation, encoding="utf-8")
                with self.assertRaises(ValueError):
                    caller.verify_bridge(root)


if __name__ == "__main__":
    unittest.main()
