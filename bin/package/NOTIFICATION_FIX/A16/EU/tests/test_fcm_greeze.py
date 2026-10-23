#!/usr/bin/env python3
"""Scope, idempotence and fail-closed tests for EU A16 FCM policy."""
import sys
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent))
from fcm_greeze import patch_source, OWNER, SIGNATURE

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

class ScopeTest(unittest.TestCase):
    def test_fcm_only(self):
        result,status=patch_source(SOURCE)
        self.assertEqual(status,'patched')
        self.assertEqual(result.count('HYPERMOS_EU_FCM_GREEZE_THAW_A16'),1)
        self.assertIn('"com.google.android.gms"',result)
        self.assertIn('"com.google.android.c2dm.intent.RECEIVE"',result)
        self.assertNotIn('IS_ZK_BUILD',result)
        self.assertEqual(result.split('.method public isRestrictReceiver')[1],
                         SOURCE.split('.method public isRestrictReceiver')[1])
        self.assertEqual(patch_source(result),(result,'already_patched'))
    def test_reject_unknown_abi(self):
        cases=(SOURCE.replace(SIGNATURE,'wrong()Z',1),
               SOURCE.replace('thawUidAsync','wrongThaw'),
               SOURCE.replace('.registers 10','.registers 9',1),
               SOURCE.replace('mBroadcastTargetWhiteList','wrongField'),
               SOURCE.replace('iget-object v0','iget-object v1',1))
        for case in cases:
            with self.subTest(case=case[:70]),self.assertRaises(ValueError):
                patch_source(case)
    def test_locals(self):
        s=SOURCE.replace('.registers 10','.locals 4',1)
        self.assertEqual(patch_source(s)[1],'patched')

if __name__=="__main__":
    unittest.main()
