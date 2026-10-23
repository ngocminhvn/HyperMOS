"""Xiaomi.eu Android 16 single-method patch regression tests."""
import importlib.util
import tempfile
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "contentcatcher_eu_a16.py"
spec = importlib.util.spec_from_file_location("eu_contentcatcher", SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
SOURCE = """.class public Lcom/android/server/am/ProcessPolicy;
.method private updateContentCatcherWhitelist()V
    .locals 1
    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v0, :continue
    return-void
:continue
    return-void
.end method
.method private unrelated()V
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    return-void
.end method
"""


class TestEuContentCatcher(unittest.TestCase):
    def test_one_gate_and_idempotence(self):
        patched, state = mod.patch_source(SOURCE)
        self.assertEqual(state, "patched")
        self.assertIn("const/4 v0, 0x0\n    if-eqz v0, :continue", patched)
        self.assertIn("sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z", patched)
        self.assertEqual(mod.patch_source(patched), (patched, "already_false"))

    def test_corepatch_baksmali_roundtrip_is_idempotent(self):
        # A rebuilt/redecoded JAR has a blank line between smali instructions.
        # This is the exact shape that failed in build run 39903876723.
        corepatch_roundtrip = SOURCE.replace(
            "    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n"
            "    if-eqz v0, :continue",
            "    const/4 v0, 0x0\n\n    if-eqz v0, :continue",
        )
        self.assertEqual(
            mod.patch_source(corepatch_roundtrip),
            (corepatch_roundtrip, "already_false"),
        )

    def test_fail_closed(self):
        samples = [
            SOURCE.replace("updateContentCatcherWhitelist", "renamed"),
            SOURCE.replace("sget-boolean v0", "sget-boolean v3", 1),
            SOURCE.replace("    if-eqz v0, :continue", "    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n    if-eqz v0, :continue"),
            SOURCE.replace("sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z", "const/4 v0, 0x1", 1),
        ]
        for sample in samples:
            with self.subTest(sample=sample[:70]), self.assertRaises(ValueError):
                mod.patch_source(sample)

    def test_multidex(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Path(tmp) / "smali_classes2" / mod.RELATIVE
            f.parent.mkdir(parents=True)
            f.write_text(SOURCE, encoding="utf-8")
            self.assertEqual(mod.patch_directory(Path(tmp))["status"], "patched")
            self.assertIn("const/4 v0, 0x0", f.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
