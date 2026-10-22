"""Synthetic ABI checks for the EU-preserving ZK304 PowerKeeper policy porter."""
import sys
import tempfile
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from zk304_powerkeeper_port_a16 import dependencies_ok, transform, index

def cls(owner, name, body):
    return f""".class public {owner}
.super Ljava/lang/Object;
.field private important:I
.method public {name}()V
    .registers 2
{body}
    return-void
.end method
"""

class ZkPowerPolicyTests(unittest.TestCase):
    def test_zk_build_flag_is_native(self):
        original="sget-boolean v0, Lmiui/zk/Build;->IS_ZK_BUILD:Z"
        self.assertEqual(transform(original),
                         "sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z")

    def test_missing_policy_field_is_rejected(self):
        owner="Lcom/miui/powerkeeper/utils/GmsObserver;"
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder)/"GmsObserver.smali"
            path.write_text(cls(owner,"updateGoogleSync","    const/4 v0, 0x0"))
            eu=index(Path(folder))
            self.assertIsNone(dependencies_ok("sget v0, "+owner+"->important:I",eu))
            self.assertIn("missing_EU_field",dependencies_ok(
                "sget v0, "+owner+"->removed:I",eu))

    def test_zk_private_ref_rejected(self):
        self.assertEqual(dependencies_ok(
            "invoke-static {}, Lcom/zk/SettingsHelper;->get()V", {}),
            "requires_ZK_private_API")

if __name__ == "__main__":
    unittest.main()
