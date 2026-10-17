#!/usr/bin/env python3
"""Test the real call-site strategy, including non-adjacent RYU instructions."""
import tempfile
import unittest
from pathlib import Path

from guard_gms_uid_kill_a16 import patch, patch_method, GMS, LOCKED, WRAPPER

UID = f""".method private setUidState(IZ)V
    .registers 9
    invoke-static {{v1, v7}}, Lcom/miui/powerkeeper/utils/PackageUtil;->getPackageNameByUid(Landroid/content/Context;I)Ljava/lang/String;
    move-result-object v8
    .line 421
    const-string v2, "unrelated intermediate instruction"
    invoke-static {{v8, v3}}, {LOCKED}
    move-result v3
    if-nez v3, :cond_skip
    invoke-direct {{p0, p1}}, Lcom/miui/powerkeeper/controller/KillProcessController;->shouldKillByCheckerPolicy(I)Z
    move-result v0
    invoke-static {{v4}}, Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z
    :cond_skip
    return-void
.end method"""


class GuardTest(unittest.TestCase):
    def test_nonadjacent_lookup_and_lock_does_not_require_spare_register(self):
        patched = patch_method(UID)
        self.assertEqual(patched.count("->getPackageNameByUid("), 1)
        self.assertEqual(patched.count(WRAPPER), 1)
        self.assertEqual(patched.replace(WRAPPER, LOCKED), UID)
        self.assertNotIn(GMS, patched)  # constant lives only in helper
        with self.assertRaises(ValueError):
            patch_method(patched)

    def test_full_class_includes_scoped_helper(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "KillProcessController.smali"
            original = (".class public Lcom/miui/powerkeeper/controller/KillProcessController;\n"
                        + UID + "\n.method public unchanged()V\n"
                        + "    .locals 0\n    return-void\n.end method\n")
            path.write_text(original, encoding="utf-8")
            result = patch(Path(temporary))
            changed = path.read_text(encoding="utf-8")
            self.assertTrue(result["reused_package_lookup"])
            self.assertEqual(result["additional_package_lookup"], 0)
            self.assertEqual(result["additional_helper_method"], 1)
            self.assertFalse(result["new_daemon_or_timer"])
            self.assertEqual(changed.count("->getPackageNameByUid("), 1)
            self.assertEqual(changed.count(GMS), 1)
            self.assertEqual(changed.count("->isLockedApplication("), 1)
            self.assertIn("invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z", changed)
            self.assertIn("invoke-static {p0, p1}, " + LOCKED, changed)
            self.assertIn(".method private static tnmIsGmsOrLocked(Ljava/lang/String;I)Z", changed)
            self.assertIn(".method public unchanged()V\n    .locals 0\n    return-void\n.end method", changed)
            with self.assertRaises(ValueError):
                patch(Path(temporary))

    def test_invoke_static_range_is_preserved(self):
        alternate = UID.replace(f"invoke-static {{v8, v3}}, {LOCKED}",
                                f"invoke-static/range {{v3 .. v4}}, {LOCKED}")
        result = patch_method(alternate)
        self.assertIn(f"invoke-static/range {{v3 .. v4}}, {WRAPPER}", result)

    def test_changed_or_ambiguous_call_fails_closed(self):
        bad = [
            UID.replace(LOCKED, "Lother/Class;->unrelated(Ljava/lang/String;I)Z"),
            UID.replace("    move-result-object v8\n", ""),
            UID + "\n" + f"    invoke-static {{v8, v3}}, {LOCKED}\n",
            UID.replace("->getPackageNameByUid(", "->otherLookup("),
        ]
        for method in bad:
            with self.subTest(method=method[-70:]):
                with self.assertRaises(ValueError):
                    patch_method(method)


if __name__ == "__main__":
    unittest.main()
