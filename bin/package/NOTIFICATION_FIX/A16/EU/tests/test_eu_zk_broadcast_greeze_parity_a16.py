#!/usr/bin/env python3
"""ZK304 parity: original region/build logic, never force a constant."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from eu_zk_broadcast_greeze_parity_a16 import patch_broadcast, patch_policy

NAMES = ("checkApplicationAutoStart", "checkReceiverAppDealBroadcast",
         "isInternationalSpecialAction", "updateBlockBroadcast")
BROADCAST = "".join(
    f""".method private {name}()Z
    .locals 6
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-eqz v2, :skip
    const/4 v0, 0x1
    :skip
    return v0
.end method
""" for name in NAMES
) + """.method public unrelated()V
    .locals 1
    const/4 v0, 0x0
    return-void
.end method
"""
POLICY = """.method static constructor <clinit>()V
    .locals 2
    const-string v0, "ro.miui.region"
    const-string v1, "CN"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    sput-boolean v0, Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z
    return-void
.end method
"""

class ZkParityTests(unittest.TestCase):
    def test_donor_equivalent_is_unchanged(self):
        out, changes = patch_broadcast(BROADCAST)
        self.assertEqual(out, BROADCAST)
        self.assertEqual(set(changes.values()), {"already_ZK_exact"})
        self.assertEqual(patch_policy(POLICY), POLICY)

    def test_restore_previous_forced_gates(self):
        old = BROADCAST.replace(
            "sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
            "const/4 v2, 0x1  # HYPERMOS_EU_ZK_BROADCAST_A16"
        )
        out, actions = patch_broadcast(old)
        self.assertEqual(out, BROADCAST)
        self.assertEqual(set(actions.values()), {"reverted_forced_true"})
        forced_policy = POLICY.replace(
            "    sput-boolean v0,", 
            "    const/4 v0, 0x0  # HYPERMOS_EU_ZK_GREEZE_A16 (ZK non-CN outcome)\n    sput-boolean v0,"
        )
        self.assertEqual(patch_policy(forced_policy), POLICY)

    def test_rename_is_zk_build(self):
        alias = BROADCAST.replace(
            "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
            "Lmiui/zk/Build;->IS_ZK_BUILD:Z"
        )
        self.assertEqual(patch_broadcast(alias)[0], BROADCAST)

    def test_fail_closed_on_method_layout_drift(self):
        for changed in (
            BROADCAST.replace("sget-boolean v2", "const/4 v2", 1),
            BROADCAST.replace("    if-eqz v2", 
                "    sget-boolean v3, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n    if-eqz v2", 1),
            BROADCAST.replace("checkApplicationAutoStart", "differentMethod"),
        ):
            with self.subTest(changed=changed[:60]), self.assertRaises(ValueError):
                patch_broadcast(changed)
        with self.assertRaises(ValueError):
            patch_policy(POLICY.replace('"CN"', '"EU"'))
        with self.assertRaises(ValueError):
            patch_policy(POLICY.replace("move-result v0", "move-result v1"))

if __name__ == "__main__":
    unittest.main()
