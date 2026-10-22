#!/usr/bin/env python3
"""Synthetic tests: guard scope, idempotence, and Greeze ABI fail-closed."""
import unittest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from eu_zk_fcm_delivery_a16 import patch_source, OWNER, SIGNATURE

SOURCE = f'''.class public {OWNER}
.method {SIGNATURE}
    .registers 10
    iget-object v0, p0, {OWNER}->mBroadcastTargetWhiteList:Ljava/util/Map;
    monitor-enter v0
    monitor-exit v0
    const/4 v2, 0x0
    return v2
.end method
.method public isRestrictReceiver(Landroid/content/Intent;ILjava/lang/String;ILjava/lang/String;)Z
    .registers 16
    invoke-virtual/range {{v10 .. v15}}, {OWNER}->{SIGNATURE}
    invoke-direct {{p0, p2, p2, p3}}, {OWNER}->thawUidAsync(IILjava/lang/String;)V
    invoke-direct {{p0, p2, p2, p3}}, {OWNER}->isNeedCachedBroadcast(ILjava/lang/String;ILjava/lang/String;)Z
    const/4 v0, 0x0
    return v0
.end method
'''

class ScopedGreezeTest(unittest.TestCase):
    def test_google_fcm_any_app_and_idempotent(self):
        changed, status = patch_source(SOURCE)
        self.assertEqual(status, "patched")
        self.assertEqual(changed.count("HYPERMOS_EU_FCM_GREEZE_THAW_A16"), 1)
        self.assertIn('"com.google.android.gms"', changed)
        self.assertIn('"com.google.android.c2dm.intent.RECEIVE"', changed)
        self.assertNotIn('"com.facebook.orca"', changed)
        self.assertEqual(changed.split('.method public isRestrictReceiver')[1],
                         SOURCE.split('.method public isRestrictReceiver')[1])
        self.assertEqual(patch_source(changed), (changed, "already_patched"))

    def test_abi_mismatch_fails(self):
        for src in (SOURCE.replace(SIGNATURE, "wrong()Z", 1),
                    SOURCE.replace('thawUidAsync', 'otherThaw'),
                    SOURCE.replace('.registers 10', '.registers 7', 1),
                    SOURCE.replace('mBroadcastTargetWhiteList', 'wrongWhitelist', 1),
                    SOURCE.replace('iget-object v0', 'iget-object v1', 1)):
            with self.subTest(src=src[:60]), self.assertRaises(ValueError):
                patch_source(src)

    def test_local_register_declaration(self):
        src = SOURCE.replace('.registers 10', '.locals 4', 1)
        self.assertEqual(patch_source(src)[1], 'patched')

if __name__ == "__main__":
    unittest.main()
