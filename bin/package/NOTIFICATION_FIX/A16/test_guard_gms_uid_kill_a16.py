#!/usr/bin/env python3
"""Synthetic checks for a single-lookup, no-daemon GMS UID-guard port."""
import tempfile
import unittest
from pathlib import Path
from guard_gms_uid_kill_a16 import patch, patch_method, GMS, PACKAGE_UTIL, LOCKED

UID = f'''\
.method private setUidState(IZ)V
    .registers 9
    invoke-static {{v1, v7}}, {PACKAGE_UTIL}->getPackageNameByUid(Landroid/content/Context;I)Ljava/lang/String;
    move-result-object v8
    invoke-static {{v8, v3}}, {LOCKED}
    move-result v3
    if-nez v3, :cond_skip
    invoke-direct {{p0, p1}}, Lcom/miui/powerkeeper/controller/KillProcessController;->shouldKillByCheckerPolicy(I)Z
    move-result v0
    invoke-static {{v4}}, Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z
    :cond_skip
    return-void
.end method'''


class GuardTest(unittest.TestCase):
    def test_inline_guard_reuses_lookup_and_original_skip_branch(self):
        patched = patch_method(UID)
        self.assertEqual(patched.count('->getPackageNameByUid('), 1)
        self.assertEqual(patched.count('->isLockedApplication('), 1)
        self.assertEqual(patched.count('->shouldKillByCheckerPolicy('), 1)
        self.assertIn(f'const-string v1, "{GMS}"', patched)
        self.assertIn('invoke-virtual {v1, v8}', patched)
        self.assertIn('or-int/2addr v3, v1\n    if-nez v3, :cond_skip', patched)
        self.assertNotIn('const-string v0,', patched)
        self.assertIn('move-result v0', patched)
        self.assertNotIn('tnmIsGmsUid', patched)
        with self.assertRaises(ValueError):
            patch_method(patched)

    def test_changes_only_uid_method(self):
        with tempfile.TemporaryDirectory() as t:
            p = Path(t) / 'KillProcessController.smali'
            p.write_text('.class public Lcom/miui/powerkeeper/controller/KillProcessController;\n' + UID + '\n'
                         '.method public unrelated()V\n    .registers 1\n    return-void\n.end method\n')
            before = p.read_text()
            report = patch(Path(t))
            after = p.read_text()
            self.assertTrue(report['reused_package_lookup'])
            self.assertEqual(report['additional_package_lookup'], 0)
            self.assertEqual(report['additional_helper_method'], 0)
            self.assertFalse(report['new_daemon_or_timer'])
            self.assertEqual(before.split('.method public unrelated()V')[1],
                             after.split('.method public unrelated()V')[1])

    def test_rejects_nonadjacent_or_wrong_registers(self):
        for bad in [
            UID.replace('move-result-object v8\n    invoke-static', 'move-result-object v8\n    const/4 v8, 0x0\n    invoke-static'),
            UID.replace('move-result v3\n    if-nez', 'move-result v3\n    move v0, v3\n    if-nez'),
            UID.replace('invoke-static {v8, v3}', 'invoke-static {v2, v3}'),
            UID.replace('.registers 9', '.registers 8'),
        ]:
            with self.subTest(bad=bad[:80]):
                with self.assertRaises(ValueError):
                    patch_method(bad)


if __name__ == '__main__':
    unittest.main()
