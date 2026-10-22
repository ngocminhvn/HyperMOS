#!/usr/bin/env python3
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from greeze_eu_fcm_guard_a16 import patch_text, GUARD

SOURCE = """.class public Lcom/miui/server/greeze/GreezeManagerService;
.method private isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z
    .locals 4
    iget-object v0, p0, Lcom/miui/server/greeze/GreezeManagerService;->mBroadcastTargetWhiteList:Ljava/util/Map;
    iget-object v0, p0, Lcom/miui/server/greeze/GreezeManagerService;->mBroadcastCallerWhiteList:Ljava/util/Map;
    sget-boolean v0, Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z
    iget-boolean v0, p0, Lcom/miui/server/greeze/GreezeManagerService;->mScreenOn:Z
    return v0
.end method
.method private isRestrictReceiver(Landroid/content/Intent;ILjava/lang/String;ILjava/lang/String;)Z
    .locals 10
    invoke-direct {p0, p2, p3, p4, p5}, Lcom/miui/server/greeze/GreezeManagerService;->isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z
    invoke-direct {p0, p3, p3, p4}, Lcom/miui/server/greeze/GreezeManagerService;->thawUidAsync(IILjava/lang/String;)V
    invoke-direct {p0}, Lcom/miui/server/greeze/GreezeManagerService;->isNeedCachedBroadcast()Z
    return v0
.end method
.method public unrelatedMethod()V
    .locals 0
    return-void
.end method
"""

class GreezeEuFcmTests(unittest.TestCase):
    def test_only_one_method_and_idempotence(self):
        edited, status = patch_text(SOURCE)
        self.assertEqual(status, "patched")
        self.assertEqual(edited.count(GUARD), 1)
        self.assertEqual(edited.count(".method"), SOURCE.count(".method"))
        self.assertIn(SOURCE.split(".method private isRestrictReceiver", 1)[1], edited)
        for s in ("com.google.android.c2dm.intent.RECEIVE", "com.google.android.gms",
                  "com.facebook.orca", "->mScreenOn:Z"):
            self.assertIn(s, edited)
        again, status = patch_text(edited)
        self.assertEqual((again, status), (edited, "already_patched"))

    def test_missing_thaw_fails(self):
        for marker in ("->isAllowBroadcast(", "->thawUidAsync(",
                       "->isNeedCachedBroadcast("):
            with self.subTest(marker=marker), self.assertRaises(ValueError):
                patch_text(SOURCE.replace(marker, "->missing(", 1))

    def test_changed_abi_fails(self):
        for before, after in (
            ("->CN_MODEL:Z", "->OTHER:Z"),
            ("->mScreenOn:Z", "->OTHER:Z"),
            (".locals 4", ".locals 0"),
            ("iget-object v0, p0,", "iget-object v1, p0,"),
        ):
            with self.subTest(before=before), self.assertRaises(ValueError):
                patch_text(SOURCE.replace(before, after, 1))

if __name__ == "__main__":
    unittest.main()
