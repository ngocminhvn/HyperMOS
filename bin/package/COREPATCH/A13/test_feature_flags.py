#!/usr/bin/env python3
import importlib.util
import os
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("services_patch.py")
SPEC = importlib.util.spec_from_file_location("a13_services_patch", MODULE_PATH)
PATCHER = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(PATCHER)


class Android13FeatureFlagTest(unittest.TestCase):
    def test_runtime_secure_flag_does_not_get_overwritten(self):
        source = """.class public Ltest/Fixture;
.method public static verifySignatures(Lcom/android/server/pm/PackageSetting;Lcom/android/server/pm/SharedUserSetting;Lcom/android/server/pm/PackageSetting;Landroid/content/pm/SigningDetails;ZZZ)Z
    .registers 8
    const/4 v0, 0x1
    return v0
.end method
.method public isScreenCaptureAllowed(I)Z
    .registers 4
    const-string v0, "stock-secure-path"
    const/4 v0, 0x0
    return v0
.end method
"""
        old_signature = os.environ.get("COREPATCH_DISABLE_SIGNATURE_VERIFICATION")
        old_secure = os.environ.get("COREPATCH_DISABLE_SECURE_FLAG")
        try:
            os.environ["COREPATCH_DISABLE_SIGNATURE_VERIFICATION"] = "1"
            os.environ["COREPATCH_DISABLE_SECURE_FLAG"] = "0"
            with tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / "Fixture.smali"
                path.write_text(source, encoding="utf-8")
                PATCHER.modify_file(path)
                result = path.read_text(encoding="utf-8")
            self.assertIn('const-string v0, "stock-secure-path"', result)
            signature = result.split("verifySignatures", 1)[1].split(".end method", 1)[0]
            self.assertIn("const/4 v1, 0x0", signature)
        finally:
            if old_signature is None:
                os.environ.pop("COREPATCH_DISABLE_SIGNATURE_VERIFICATION", None)
            else:
                os.environ["COREPATCH_DISABLE_SIGNATURE_VERIFICATION"] = old_signature
            if old_secure is None:
                os.environ.pop("COREPATCH_DISABLE_SECURE_FLAG", None)
            else:
                os.environ["COREPATCH_DISABLE_SECURE_FLAG"] = old_secure


if __name__ == "__main__":
    unittest.main()
