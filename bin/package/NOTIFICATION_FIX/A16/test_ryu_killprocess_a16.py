#!/usr/bin/env python3
"""Synthetic RYU policy import tests; no ROM image required."""
import tempfile
import unittest
from pathlib import Path

from ryu_killprocess_a16 import port, check_abi, get_methods, SET_UID, RULE_CHECK, CHECKER_FIELD, protect_gms_uid, GMS_MARKER, GMS_PACKAGE

ROOT = ".class public Lcom/miui/powerkeeper/controller/KillProcessController;\n" \
       ".super Lcom/miui/powerkeeper/controller/Controller;\n" \
       ".field private " + CHECKER_FIELD + "\n\n"
STOCK_UID = """.method private setUidState(IZ)V
    .registers 8
    const/4 v0, 0x0
    return-void
.end method
"""
RYU_UID = """.method private setUidState(IZ)V
    .registers 9
    invoke-direct {p0, p1}, Lcom/miui/powerkeeper/controller/KillProcessController;->shouldKillByCheckerPolicy(I)Z
    move-result v0
    invoke-static {p2, p1}, Lcom/miui/powerkeeper/utils/PackageUtil;->getPackageNameByUid(Landroid/content/Context;I)Ljava/lang/String;
    move-result-object p2
    invoke-static {v1}, Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z
    return-void
.end method
"""
RYU_HELPER = """.method private shouldKillByCheckerPolicy(I)Z
    .registers 4
    const-string v0, "POLICY"
    invoke-interface {p0, p1}, Lcom/miui/powerkeeper/PowerKeeperInterface$l;->getUidPolicy(I)Landroid/os/Bundle;
    const/4 v0, 0x1
    const/4 v1, 0x2
    return v0
.end method
"""
OTHER = """.method public retainZkos()V
    .registers 1
    return-void
.end method
"""


class RyuKillProcessPortTest(unittest.TestCase):
    def roots(self, root, z, r):
        zk, ryu = root / "zk", root / "ryu"
        for name, base, data in (("zk", zk, z), ("ryu", ryu, r)):
            path = base / "smali/classes/com/miui/powerkeeper/controller/KillProcessController.smali"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(data, encoding="utf-8")
        return zk, ryu

    def test_import_and_keep_zkos_other_methods(self):
        with tempfile.TemporaryDirectory() as temporary:
            zk, ryu = self.roots(Path(temporary), ROOT + STOCK_UID + OTHER, ROOT + RYU_UID + RYU_HELPER + OTHER)
            report = port(zk, ryu)
            body = next(zk.rglob("KillProcessController.smali")).read_text()
            self.assertTrue(report["ryu_uid_method_ported"])
            self.assertTrue(report["new_checker_method_added"])
            self.assertEqual(report["untouched_zkos_killprocess_methods"], 1)
            self.assertIn(OTHER, body)
            self.assertEqual(len(get_methods(body)), 3)
            self.assertIn("->kill(", get_methods(body)[SET_UID])
            self.assertIn('"POLICY"', get_methods(body)[RULE_CHECK])
            self.assertTrue(report["gms_policy_exemption_added"])
            self.assertIn('"com.google.android.gms"', get_methods(body)[SET_UID])
            self.assertIn("if-eqz v6, :tnm_gms_uid_continue", get_methods(body)[SET_UID])
            self.assertEqual(get_methods(body)[SET_UID].count(".registers 10"), 1)
            self.assertFalse(port(zk, ryu)["new_checker_method_added"])

    def test_gms_guard_only_after_candidate_package_lookup(self):
        updated, added = protect_gms_uid(RYU_UID)
        self.assertTrue(added)
        self.assertEqual(updated.count(GMS_MARKER), 2)
        self.assertLess(updated.index("move-result-object p2"),
                        updated.index('"' + GMS_PACKAGE + '"'))
        self.assertLess(updated.index('"' + GMS_PACKAGE + '"'),
                        updated.index("Lmiui/process/ProcessManager;->kill("))
        self.assertIn("invoke-virtual {v6, p2}", updated)
        self.assertEqual(updated.count("Lmiui/process/ProcessManager;->kill("), 1)

    def test_gms_guard_rejects_unknown_layout(self):
        for invalid in (
            RYU_UID.replace(".registers 9", ".registers 8"),
            RYU_UID.replace("move-result-object p2", "move-result-object v0"),
            RYU_UID.replace("    move-result-object p2\n", ""),
            RYU_UID.replace("    return-void\n.end method\n", "    move-object v6, v0\n    return-void\n.end method\n"),
        ):
            with self.subTest(invalid=invalid[:60]):
                with self.assertRaises(ValueError):
                    protect_gms_uid(invalid)

    def test_fail_when_checker_field_missing(self):
        with self.assertRaises(ValueError):
            check_abi((ROOT + STOCK_UID).replace(CHECKER_FIELD, "other:I"),
                      ROOT + RYU_UID + RYU_HELPER)

    def test_fail_when_donor_cannot_check_policy(self):
        with tempfile.TemporaryDirectory() as temporary:
            zk, ryu = self.roots(Path(temporary), ROOT + STOCK_UID, ROOT + RYU_UID +
                                  RYU_HELPER.replace('"POLICY"', '"UNKNOWN"'))
            with self.assertRaises(ValueError):
                port(zk, ryu)

    def test_fail_when_donor_missing_conditional_kill(self):
        with tempfile.TemporaryDirectory() as temporary:
            zk, ryu = self.roots(Path(temporary), ROOT + STOCK_UID, ROOT + 
                                  RYU_UID.replace("Lmiui/process/ProcessManager;->kill(", "Lx/Other;->run(") + RYU_HELPER)
            with self.assertRaises(ValueError):
                port(zk, ryu)


if __name__ == "__main__":
    unittest.main()
