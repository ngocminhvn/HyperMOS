"""Regression tests for the two Xiaomi.eu GMS FCM delivery guards."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

BASE = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, BASE / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


auto = load("fcm_autostart")
greezer = load("fcm_greeze")

AUTOSTART = """.method public checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z
    .locals 3
    .param p1, "q"  # Lcom/android/server/am/BroadcastQueue;
    .line 1
    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    const/4 v0, 0x0
    return v0
.end method"""

ALLOW = """.method public isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z
    .locals 4
    iget-object v0, p0, Lcom/miui/server/greeze/GreezeManagerService;->mBroadcastTargetWhiteList:Ljava/util/Map;
    const/4 v0, 0x0
    return v0
.end method"""

RESTRICT = """.method public isRestrictReceiver(Landroid/content/Intent;ILjava/lang/String;ILjava/lang/String;)Z
    .locals 2
    invoke-direct {p0}, Lcom/miui/server/greeze/GreezeManagerService;->isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z
    invoke-direct {p0}, Lcom/miui/server/greeze/GreezeManagerService;->thawUidAsync(IILjava/lang/String;)V
    invoke-direct {p0}, Lcom/miui/server/greeze/GreezeManagerService;->isNeedCachedBroadcast(Ljava/lang/String;)Z
    const/4 v0, 0x0
    return v0
.end method"""


class FcmPathsTests(unittest.TestCase):
    def test_autostart_allows_only_GMS_FCM_and_keeps_EU_code(self):
        changed, status = auto.patch_source(AUTOSTART)
        self.assertEqual("patched", status)
        self.assertIn('com.google.android.gms', changed)
        self.assertIn('com.google.android.c2dm.intent.RECEIVE', changed)
        self.assertIn('->callerPackage:Ljava/lang/String;', changed)
        self.assertIn("IS_INTERNATIONAL_BUILD:Z", changed)
        self.assertEqual("verified", auto.patch_source(changed, True)[1])

    def test_autostart_survives_smali_round_trip(self):
        changed, _ = auto.patch_source(AUTOSTART)
        changed = changed.replace("eu_fcm_stock_autostart", "cond_47")
        changed = "\n".join(x for x in changed.splitlines() if auto.MARKER not in x)
        self.assertEqual("verified", auto.patch_source(changed, True)[1])

    def test_autostart_rejects_unsafe_vendor_change(self):
        with self.assertRaisesRegex(ValueError, "international gate"):
            auto.patch_source(AUTOSTART.replace("IS_INTERNATIONAL_BUILD", "IS_CHINA_BUILD"))
        with self.assertRaisesRegex(ValueError, "two local"):
            auto.patch_source(AUTOSTART.replace(".locals 3", ".locals 1"))

    def test_greeze_preserves_stock_thaw_and_broadcast_policy(self):
        changed, status = greezer.patch_source(ALLOW + "\n" + RESTRICT)
        self.assertEqual("patched", status)
        self.assertIn("thawUidAsync", changed)
        self.assertIn("mBroadcastTargetWhiteList", changed)
        self.assertEqual("verified", greezer.patch_source(changed, True)[1])

    def test_greeze_survives_smali_round_trip(self):
        changed, _ = greezer.patch_source(ALLOW + "\n" + RESTRICT)
        changed = changed.replace("hypermos_eu_greeze_original", "cond_60")
        changed = "\n".join(x for x in changed.splitlines() if greezer.MARKER not in x)
        self.assertEqual("verified", greezer.patch_source(changed, True)[1])

    def test_greeze_refuses_changed_native_thaw_call_graph(self):
        with self.assertRaisesRegex(ValueError, "chain changed"):
            greezer.patch_source(ALLOW + "\n" + RESTRICT.replace("thawUidAsync", "disableUid"))

    def test_file_patches_and_post_assembly_verification(self):
        with tempfile.TemporaryDirectory() as tmp:
            for name, text in ((auto.CLASS, AUTOSTART),
                               (greezer.SERVICE, ALLOW + "\n" + RESTRICT)):
                file = Path(tmp) / "smali_classes3" / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(text + "\n")
            self.assertEqual("patched", auto.apply(Path(tmp))["status"])
            self.assertEqual("patched", greezer.apply(Path(tmp), None)["status"])
            self.assertEqual("verified", auto.apply(Path(tmp), True)["status"])
            self.assertEqual("verified", greezer.apply(Path(tmp), None, True)["status"])


if __name__ == "__main__":
    unittest.main()
