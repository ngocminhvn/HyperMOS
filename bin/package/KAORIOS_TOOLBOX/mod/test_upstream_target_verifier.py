#!/usr/bin/env python3
"""Regression tests for the MOD-to-upstream single-target verifier bridge."""
import importlib.util
from pathlib import Path
import tempfile
import unittest


MOD_DIR = Path(__file__).resolve().parent
PATCHER_PATH = MOD_DIR.parent / "script" / "kaorios_patcher.py"
BRIDGE_PATH = MOD_DIR / "verify-upstream-target.py"


def load(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


bridge = load(BRIDGE_PATH, "kaorios_target_bridge")
patcher = bridge.load_patcher(PATCHER_PATH)


class UpstreamTargetVerifierTest(unittest.TestCase):
    def test_name_value_cache_uses_current_upstream_shape(self):
        stock = (
            ".class private Landroid/provider/Settings$NameValueCache;\n"
            ".super Ljava/lang/Object;\n"
            ".method public getStringForUser(Landroid/content/ContentResolver;"
            "Ljava/lang/String;I)Ljava/lang/String;\n"
            "    .registers 6\n"
            "    .line 42\n"
            "    move-object v0, p2\n"
            "    return-object v0\n"
            ".end method\n"
        )
        patched, changed = patcher.patch_name_value_cache(stock)
        self.assertTrue(changed)
        patcher.verify_target_content("Settings$NameValueCache.smali", patched)
        self.assertNotIn("if-eqz p2", patched)

        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "Settings$NameValueCache.smali"
            target.write_text(patched, encoding="utf-8")
            loaded = bridge.load_patcher(PATCHER_PATH)
            loaded.verify_target_content(target.name, target.read_text(encoding="utf-8"))

    def test_rejects_legacy_extra_branch_shape(self):
        stock = (
            ".class private Landroid/provider/Settings$NameValueCache;\n"
            ".super Ljava/lang/Object;\n"
            ".method public getStringForUser(Landroid/content/ContentResolver;"
            "Ljava/lang/String;I)Ljava/lang/String;\n"
            "    .registers 6\n"
            "    move-object v0, p2\n"
            "    return-object v0\n"
            ".end method\n"
        )
        patched, _ = patcher.patch_name_value_cache(stock)
        legacy = patched.replace(
            "    invoke-static/range {p1 .. p3}",
            "    if-eqz p2, :cond_kaorios_settings_stock\n"
            "    invoke-static/range {p1 .. p3}",
            1,
        )
        with self.assertRaises(ValueError):
            patcher.verify_target_content("Settings$NameValueCache.smali", legacy)


if __name__ == "__main__":
    unittest.main()
