"""Android 16 scoped RYU Doze class-initializer regression tests.

Run: python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/tests -v
"""
import importlib.util
from pathlib import Path
import unittest

PATCHER = Path(__file__).resolve().parents[1] / "frameworkpatcher_cn_a16.py"
spec = importlib.util.spec_from_file_location("frameworkpatcher_cn_a16", PATCHER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class TestRyuDozeGate(unittest.TestCase):
    SOURCE = """.class public Lcom/android/server/DeviceIdleControllerStubImpl;
.method static constructor <clinit>()V
    .registers 1
    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    if-nez v0, :goto_0
    const/4 v0, 0x1
    goto :done
:goto_0
    const/4 v0, 0x0
:done
    sput-boolean v0, Lcom/android/server/DeviceIdleControllerStubImpl;->mIsLowPowerDozeDevice:Z
    return-void
.end method
.method public otherMethod()V
    return-void
.end method
"""

    def test_forces_false_at_final_assignment_only(self):
        patched = module.patch_ryu_doze_flag(self.SOURCE)
        self.assertIn(
            ":done\n    const/4 v0, 0x0\n    sput-boolean v0,",
            patched,
        )
        self.assertIn(".method public otherMethod()V\n    return-void\n.end method", patched)
        self.assertEqual(len(patched) - len(self.SOURCE), len("    const/4 v0, 0x0\n"))

    def test_absent_field_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "expected one low-power flag write"):
            module.patch_ryu_doze_flag(self.SOURCE.replace("mIsLowPowerDozeDevice", "otherFlag"))

    def test_duplicate_field_write_fails_closed(self):
        repeated = self.SOURCE.replace(
            "    return-void\n.end method",
            "    sput-boolean v0, Lcom/android/server/DeviceIdleControllerStubImpl;->mIsLowPowerDozeDevice:Z\n    return-void\n.end method",
            1,
        )
        with self.assertRaisesRegex(ValueError, "expected one low-power flag write"):
            module.patch_ryu_doze_flag(repeated)

    def test_missing_initializer_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "expected one <clinit>"):
            module.patch_ryu_doze_flag(self.SOURCE.replace("<clinit>", "notClinit"))


if __name__ == "__main__":
    unittest.main()
