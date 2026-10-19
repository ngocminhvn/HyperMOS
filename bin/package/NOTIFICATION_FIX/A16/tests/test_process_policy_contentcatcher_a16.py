"""Regression checks: ProcessPolicy CN ContentCatcher and 3 RYU gates.

Run: python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/tests -v
"""
import importlib.util
from pathlib import Path
import unittest

PATCHER = Path(__file__).resolve().parents[1] / "frameworkpatcher_cn_a16.py"
spec = importlib.util.spec_from_file_location("frameworkpatcher_cn_a16", PATCHER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

SOURCE = """.class public Lcom/android/server/am/ProcessPolicy;
.method private updateContentCatcherWhitelist()V
    .locals 1
    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v0, :continue
    return-void
:continue
    return-void
.end method

.method public unrelatedMethod()V
    const/4 v7, 0x0
    return-void
.end method

.method public firstRyu()V
    sget-boolean v1, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    return-void
.end method
.method public secondRyu()V
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    return-void
.end method
.method public thirdRyu()V
    sget-boolean v3, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    return-void
.end method
"""

class TestProcessPolicyContentCatcher(unittest.TestCase):
    def test_one_cn_false_and_three_ryu_true(self):
        out, report = module.patch_process_policy(SOURCE)
        self.assertEqual(report["audited_total"], 4)
        self.assertEqual(report["contentcatcher_cn_false"], 1)
        self.assertEqual(report["ryu_true"], 3)
        self.assertIn("const/4 v0, 0x0\n    if-eqz v0, :continue", out)
        for register in (1, 2, 3):
            self.assertIn(f"const/4 v{register}, 0x1", out)
        self.assertNotIn("sget-boolean", out)
        self.assertIn(".method public unrelatedMethod()V\n    const/4 v7, 0x0", out)

    def test_missing_or_duplicate_contentcatcher_method_fails_closed(self):
        for src in (
            SOURCE.replace("updateContentCatcherWhitelist", "renamed"),
            SOURCE + "
" + SOURCE[SOURCE.index(".method private"):SOURCE.index(".method public")],
        ):
            with self.subTest(src=src[-100:]):
                with self.assertRaisesRegex(ValueError, "expected one updateContentCatcherWhitelist"):
                    module.patch_process_policy(src)

    def test_register_or_read_count_mismatch_fails_closed(self):
        invalid = (
            SOURCE.replace("sget-boolean v0", "sget-boolean v6", 1),
            SOURCE.replace("    sget-boolean v3, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z", ""),
            SOURCE.replace(
                "    if-eqz v0, :continue",
                "    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n"
                "    if-eqz v0, :continue",
            ),
        )
        for src in invalid:
            with self.subTest(src=src[-80:]):
                with self.assertRaises(ValueError):
                    module.patch_process_policy(src)

    def test_already_patched_gate_is_not_silently_accepted(self):
        out, _ = module.patch_process_policy(SOURCE)
        with self.assertRaisesRegex(ValueError, "one original ContentCatcher region read"):
            module.patch_process_policy(out)

if __name__ == "__main__":
    unittest.main()
