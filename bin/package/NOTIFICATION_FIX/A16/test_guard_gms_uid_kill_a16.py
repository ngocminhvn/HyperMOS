#!/usr/bin/env python3
"""Guard against uncontrolled GMS force-stops and new polling overhead."""
import tempfile
import unittest
from pathlib import Path
from guard_gms_uid_kill_a16 import patch, PACKAGE_UTIL, CONTEXT


class GmsUidGuardTest(unittest.TestCase):
    def fixture(self, root):
        p = root / 'smali/classes/com/miui/powerkeeper/controller/KillProcessController.smali'
        p.parent.mkdir(parents=True)
        p.write_text(
            '.class public Lcom/miui/powerkeeper/controller/KillProcessController;\n'
            '.method public setUidState(IZ)V\n'
            '    .registers 9\n'
            f'    sget-object v0, {CONTEXT}\n'
            f'    invoke-static {{v0, p1}}, {PACKAGE_UTIL}->getPackageNameByUid(Landroid/content/Context;I)Ljava/lang/String;\n'
            '    return-void\n.end method\n'
            '.method private shouldKillByCheckerPolicy(I)Z\n'
            '    .registers 4\n'
            '    invoke-interface {v0, p1}, Lcom/miui/powerkeeper/PowerKeeperInterface$l;->getUidPolicy(I)Landroid/os/Bundle;\n'
            '    const-string v1, "POLICY"\n'
            '    const/4 v0, 0x0\n'
            '    return v0\n.end method\n',
            encoding='utf-8')
        return p

    def test_event_only_guard_and_idempotent_fail_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = self.fixture(Path(tmp))
            result = patch(Path(tmp))
            src = p.read_text()
            self.assertFalse(result['new_daemon'])
            self.assertTrue(result['additional_uid_lookup_only_on_kill_consideration'])
            self.assertIn('tnmIsGmsUid(I)Z', src)
            self.assertIn('com.google.android.gms', src)
            self.assertIn(':tnm_not_gms_uid', src)
            self.assertIn('->getUidPolicy(I)Landroid/os/Bundle;', src)
            with self.assertRaises(ValueError):
                patch(Path(tmp))

    def test_reject_missing_policy_abi(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = self.fixture(Path(tmp))
            p.write_text(p.read_text().replace(
                'getUidPolicy(I)Landroid/os/Bundle;',
                'getAppRule(I)I'))
            with self.assertRaises(ValueError):
                patch(Path(tmp))


if __name__ == '__main__':
    unittest.main()
