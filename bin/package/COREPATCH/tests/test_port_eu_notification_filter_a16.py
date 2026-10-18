"""Regression tests for baksmali formatting and fail-closed notification edits.

Run: python3 -m unittest discover -s bin/package/COREPATCH/tests -v
"""
import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / 'port_eu_notification_filter_a16.py'
SPEC = importlib.util.spec_from_file_location('notification_filter', SCRIPT)
patcher = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(patcher)

ALLOCATION = """    new-instance v0, Ljava/util/HashSet;
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V
    sput-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;
"""

# Representative CN layout; the separators below model baksmali output.
CN = """.class public Lmiui/util/NotificationFilterHelper;
.super Ljava/lang/Object;

.field private static sNotificationCanBeBlockedList:Ljava/util/HashSet;
.field private static sNotificationCannotSetImportanceList:Ljava/util/HashSet;

.method static constructor <clinit>()V
    .registers 2
{allocation}
    new-instance v0, Ljava/util/HashSet;

    invoke-direct {{v0}}, Ljava/util/HashSet;-><init>()V

    sput-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCannotSetImportanceList:Ljava/util/HashSet;

    const-string v1, "com.miui.securitycenter"
    invoke-virtual {{v0, v1}}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z
    const-string v1, "com.xiaomi.xmsf"
    invoke-virtual {{v0, v1}}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z
    return-void
.end method

.method public static canSystemNotificationBeBlocked(Ljava/lang/String;)Z
    .registers 2
    sget-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;
    invoke-virtual {{v0, p0}}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z
    move-result v0
    return v0
.end method

.method public static unrelated()Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
"""


def source(allocation=ALLOCATION):
    return CN.format(allocation=allocation)


class NotificationFilterTest(unittest.TestCase):
    def test_instruction_separators(self):
        for separator in ('\n', '\n\n', '\n \t\n',
                          '\n    .line 123\n',
                          '\n\n    .line 123\n\n',
                          '\n\n    .local v0, "list":Ljava/util/HashSet;\n\n'):
            with self.subTest(separator=separator):
                original = source(ALLOCATION.replace('\n', separator))
                patched, report = patcher.patch_notification(original)
                before = patcher.split_methods(original)
                after = patcher.split_methods(patched)
                self.assertEqual(before.keys(), after.keys())
                self.assertEqual(before['unrelated()Z'], after['unrelated()Z'])
                self.assertEqual(original.split('.method', 1)[0],
                                 patched.split('.method', 1)[0])
                self.assertNotIn('sNotificationCanBeBlockedList', after['<clinit>()V'])
                self.assertIn('sNotificationCannotSetImportanceList', after['<clinit>()V'])
                self.assertNotIn('com.miui.securitycenter', after['<clinit>()V'])
                self.assertNotIn('com.xiaomi.xmsf', after['<clinit>()V'])
                self.assertIn('const/4 v0, 0x1', after[patcher.CAN_BLOCK])
                self.assertNotIn('sNotificationCanBeBlockedList', after[patcher.CAN_BLOCK])
                self.assertEqual(report['changed_methods'], ['<clinit>()V', patcher.CAN_BLOCK])

    def test_rejects_missing_duplicate_or_unsafe_allocation(self):
        invalid = {
            'missing': '',
            'duplicate': ALLOCATION * 2,
            'constructor register': ALLOCATION.replace('invoke-direct {v0}', 'invoke-direct {v1}'),
            'store register': ALLOCATION.replace('sput-object v0', 'sput-object v1'),
            'instruction': ALLOCATION.replace('    invoke-direct', '    const/4 v0, 0x0\n\n    invoke-direct'),
            'branch label': ALLOCATION.replace('    invoke-direct', '    :cond_0\n    invoke-direct'),
        }
        for name, allocation in invalid.items():
            with self.subTest(name=name):
                with self.assertRaisesRegex(ValueError, 'initialization count'):
                    patcher.patch_notification(source(allocation))

    def test_rejects_unknown_tail(self):
        for original in (source().replace('com.xiaomi.xmsf', 'unknown'),
                         source().replace('    const-string v1', '    :cond_0\n    const-string v1', 1)):
            with self.subTest(original=original):
                with self.assertRaises(ValueError):
                    patcher.patch_notification(original)

    def test_failed_validation_does_not_write_class_or_report(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / 'smali/miui/util/NotificationFilterHelper.smali'
            target.parent.mkdir(parents=True)
            original = source('').encode()
            target.write_bytes(original)
            report = root / 'reports/notification-filter.json'
            with self.assertRaises(ValueError):
                patcher.apply(root, report)
            self.assertEqual(target.read_bytes(), original)
            self.assertFalse(report.exists())


if __name__ == '__main__':
    unittest.main()
