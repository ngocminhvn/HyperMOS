"""Global303 Xiaomi.eu notification filter scope and fail-closed guards."""
import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / 'port_global_notification_filter_a16.py'
spec = importlib.util.spec_from_file_location('global_notification_filter', SCRIPT)
patcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(patcher)
C = patcher.CLASS

# Minimal reconstructed EU309 class layout. Other methods must be untouched.
EU = f'''.class public {C}
.field private static sNotificationCanBeBlockedList:Ljava/util/HashSet;
.method static constructor <clinit>()V
    .registers 14
    new-instance v0, Ljava/util/HashMap;
    invoke-direct {{v0}}, Ljava/util/HashMap;-><init>()V
    sput-object v0, {C}->sIsSystemApp:Ljava/util/HashMap;
    sput-object v0, {C}->sNotificationForcedEnabledPkgList:Ljava/util/HashSet;
    sput-object v0, {C}->sNotificationForcedEnabledAllChannelList:Ljava/util/HashSet;
    sput-object v0, {C}->sNotificationForcedEnabledChannelList:Ljava/util/HashMap;
    sput-object v0, {C}->sNotificationCannotSetImportanceList:Ljava/util/HashSet;
    return-void
.end method
.method public static canSystemNotificationBeBlocked(Ljava/lang/String;)Z
    .registers 2
    const/4 v0, 0x1
    return v0
.end method
.method public static unrelated()Z
    .registers 1
    const/4 v0, 0x0
    return v0
.end method
'''

class GlobalNotificationPolicyTests(unittest.TestCase):
    def test_only_two_methods_are_modified(self):
        updated, report = patcher.patch(EU)
        before = patcher.methods(EU)
        after = patcher.methods(updated)
        self.assertEqual(before.keys(), after.keys())
        self.assertEqual(before['unrelated()Z'], after['unrelated()Z'])
        self.assertIn('HashSet;->contains(Ljava/lang/Object;)Z', after[patcher.CAN_BLOCK])
        self.assertEqual(len(patcher.BLOCKABLE), 3)
        self.assertEqual(len(patcher.FORCED), 8)
        for package in (*patcher.BLOCKABLE, *patcher.FORCED, 'com.xiaomi.xmsf'):
            self.assertEqual(after['<clinit>()V'].count('"' + package + '"'), 1)
        self.assertFalse(report['powerkeeper_apk_modified'])
        self.assertFalse(report['third_party_fcm_exceptions_added'])

    def test_guard_rejects_unexpected_layout_and_repeat(self):
        with self.assertRaises(ValueError):
            patcher.patch(EU.replace('    .registers 14', '    .registers 4'))
        with self.assertRaises(ValueError):
            patcher.patch(EU.replace('    const/4 v0, 0x1', '    const/4 v0, 0x0'))
        with self.assertRaises(ValueError):
            patcher.patch(EU.replace('sIsSystemApp:Ljava/util/HashMap;',
                                     'unknownField:Ljava/util/HashMap;'))
        updated, _ = patcher.patch(EU)
        with self.assertRaises(ValueError):
            patcher.patch(updated)

if __name__ == '__main__':
    unittest.main()
