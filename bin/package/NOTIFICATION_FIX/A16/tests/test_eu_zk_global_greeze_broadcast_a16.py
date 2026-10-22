#!/usr/bin/env python3
"""Synthetic fail-closed tests for the EU A16 global ZK policy port."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from eu_zk_global_greeze_broadcast_a16 import patch_broadcast, patch_policy

NAMES = ("checkApplicationAutoStart", "checkReceiverAppDealBroadcast",
         "isInternationalSpecialAction", "updateBlockBroadcast")
BROADCAST = ".class Lcom/android/server/am/BroadcastQueueModernStubImpl;\n" + "".join(
    f""".method private {name}()Z
    .locals 6
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v2, :skip
    const/4 v0, 0x1
    return v0
    :skip
    const/4 v0, 0x0
    return v0
.end method
""" for name in NAMES
) + """.method private unrelated()Z
    .locals 1
    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    return v0
.end method
"""
POLICY = """.class Lcom/miui/server/greeze/PolicyManager;
.method static constructor <clinit>()V
    .locals 2
    const-string v0, "ro.miui.region"
    const-string v1, "CN"
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    sput-boolean v0, Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z
    return-void
.end method
"""

class GlobalPolicyTests(unittest.TestCase):
    def test_all_apps_and_no_other_methods(self):
        changed, counts = patch_broadcast(BROADCAST)
        self.assertEqual(counts, dict.fromkeys(NAMES, 1))
        self.assertEqual(changed.count("HYPERMOS_EU_ZK_BROADCAST_A16"), 4)
        self.assertIn("unrelated()Z\n    .locals 1\n    sget-boolean v0", changed)
        self.assertEqual(patch_broadcast(changed)[0], changed)

    def test_missing_field_fails_closed(self):
        with self.assertRaises(ValueError):
            patch_broadcast(BROADCAST.replace("sget-boolean v2", "nop  # v2", 1))

    def test_region_false_is_idempotent(self):
        changed = patch_policy(POLICY)
        self.assertIn("const/4 v0, 0x0", changed)
        self.assertEqual(changed.count("HYPERMOS_EU_ZK_GREEZE_A16"), 1)
        self.assertEqual(patch_policy(changed), changed)

    def test_region_layout_drift_fails_closed(self):
        with self.assertRaises(ValueError):
            patch_policy(POLICY.replace('"CN"', '"EU"'))


if __name__ == "__main__":
    unittest.main()
