import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from donor_notification_policy_a16 import patch_clinit

DONOR = """.method static constructor <clinit>()V
    .registers 4
    const/4 v0, 0x1
    return-void
.end method
"""
EU = DONOR.replace("    return-void", """    sget-boolean v2, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z
    sput-boolean v2, Lcom/android/server/notification/NotificationManagerServiceImpl;->IS_INTERNATIONAL_BUILD:Z
    return-void""")

class DonorInitializerTests(unittest.TestCase):
    def test_method_port_exact_and_idempotent(self):
        modified, status = patch_clinit(EU, DONOR)
        self.assertEqual(status, "ported_zk304")
        self.assertEqual([x.strip() for x in modified.splitlines() if x.strip()],
                         [x.strip() for x in DONOR.splitlines() if x.strip()])
        self.assertEqual(patch_clinit(modified, DONOR), (modified, "already_zk"))

    def test_fail_closed_wrong_register(self):
        with self.assertRaises(ValueError):
            patch_clinit(EU.replace("sput-boolean v2", "sput-boolean v3"), DONOR)

    def test_fail_closed_extra_behavior(self):
        with self.assertRaises(ValueError):
            patch_clinit(EU.replace("    sput-boolean", "    const/4 v1, 0x0\n    sput-boolean"), DONOR)

    def test_fail_closed_wrong_donor(self):
        with self.assertRaises(ValueError):
            patch_clinit(EU, DONOR.replace("const/4 v0, 0x1", "const/4 v0, 0x0"))
if __name__ == "__main__":
    unittest.main()
