#!/usr/bin/env python3
import importlib.util
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("patch-settings-namevaluecache.py")
SPEC = importlib.util.spec_from_file_location("patch_settings_namevaluecache", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


METHOD_HEADER = ".method public getStringForUser(Landroid/content/ContentResolver;Ljava/lang/String;I)Ljava/lang/String;"
HOOK = MODULE.HOOK


def smali(block: str, extra_method: str = "") -> str:
    return f""".class public {MODULE.CLASS_DESC}
.super Ljava/lang/Object;

{METHOD_HEADER}
    .locals 4
{block}
    invoke-static {{p1}}, Landroid/provider/Settings;->stock()Ljava/lang/String;
    return-object v0
.end method

{extra_method}"""


def hook_block(label=":cond_0", scratch="v0"):
    return f"""    if-eqz p2, {label}
    invoke-static/range {{p1 .. p3}}, {HOOK}
    move-result {scratch}
    if-eqz {scratch}, {label}
    const-string {scratch}, \"0\"
    return-object {scratch}

{label}"""


class NameValueCacheVerifierTests(unittest.TestCase):
    def verify_roundtrip(self, text):
        MODULE.verify(text, roundtrip=True)

    def test_source_label_and_roundtrip_label_pass(self):
        source = smali(hook_block(MODULE.LABEL, MODULE.SCRATCH))
        MODULE.verify(source)
        self.verify_roundtrip(smali(hook_block(":cond_2", "v3")))

    def test_roundtrip_without_blank_line_passes(self):
        block = hook_block(":cond_17", "v2").replace(
            "return-object v2\\n\\n:cond_17",
            "return-object v2\\n:cond_17",
        )
        self.verify_roundtrip(smali(block))

    def test_different_branch_labels_fail(self):
        block = hook_block(":cond_2", "v3").replace("if-eqz v3, :cond_2", "if-eqz v3, :cond_3")
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali(block))

    def test_missing_hook_fails(self):
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali("    return-object p1"))

    def test_duplicate_hook_fails(self):
        block = hook_block(":cond_2", "v3") + "\n" + hook_block(":cond_4", "v2")
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali(block))

    def test_wrong_hidden_value_fails(self):
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali(hook_block(":cond_2", "v3").replace('"0"', '"1"')))

    def test_missing_stock_label_fails(self):
        block = hook_block(":cond_2", "v3")
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali(block).replace("\n:cond_2\n", "\n"))

    def test_hook_outside_target_method_fails(self):
        other = ".method public other()V\n" + hook_block(":cond_2", "v3") + "\n.end method"
        with self.assertRaises(MODULE.VerifyError):
            self.verify_roundtrip(smali("    return-object p1", other))


if __name__ == "__main__":
    unittest.main()