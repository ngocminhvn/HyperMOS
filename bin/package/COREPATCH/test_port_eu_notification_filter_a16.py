#!/usr/bin/env python3
"""Offline tests for the EU NotificationFilterHelper-only port."""
import importlib.util
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).with_name('port_eu_notification_filter_a16.py')
spec = importlib.util.spec_from_file_location('eu_notification_filter', SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

SAMPLE = '''.class public Lmiui/util/NotificationFilterHelper;
.super Ljava/lang/Object;
.field private static sNotificationCanBeBlockedList:Ljava/util/HashSet;
.field private static sNotificationForcedEnabledPkgList:Ljava/util/HashSet;
.method static constructor <clinit>()V
    .locals 3
    new-instance v0, Ljava/util/HashSet;
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V
    sput-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;
    new-instance v0, Ljava/util/HashSet;
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V
    sput-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationForcedEnabledPkgList:Ljava/util/HashSet;
    new-instance v0, Ljava/util/HashSet;
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V
    sput-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCannotSetImportanceList:Ljava/util/HashSet;
    sget-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;
    const-string v1, "com.miui.securitycenter"
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z
    const-string v1, "com.xiaomi.xmsf"
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z
    return-void
.end method
.method public static canSystemNotificationBeBlocked(Ljava/lang/String;)Z
    .locals 1
    sget-object v0, Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;
    invoke-virtual {v0, p0}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z
    move-result v0
    return v0
.end method
.method public static stable()I
    .locals 1
    const/4 v0, 0x3
    return v0
.end method
'''

output, info = mod.patch_notification(SAMPLE)
assert info['power_insight_policy_patched'] is False
assert set(info['changed_methods']) == {'<clinit>()V', mod.CAN_BLOCK}
old = mod.split_methods(SAMPLE)
new = mod.split_methods(output)
assert new['stable()I'] == old['stable()I']
assert 'sNotificationForcedEnabledPkgList' in new['<clinit>()V']
assert 'sNotificationCanBeBlockedList' not in new['<clinit>()V']
assert 'com.miui.securitycenter' not in new['<clinit>()V']
assert 'const/4 v0, 0x1' in new[mod.CAN_BLOCK]
assert 'com/miui/whetstone/PowerInsightPolicy' not in output

with tempfile.TemporaryDirectory() as tmp:
    folder = Path(tmp)
    nf = folder / 'smali/miui/util/NotificationFilterHelper.smali'
    pi = folder / 'smali/com/miui/whetstone/PowerInsightPolicy.smali'
    nf.parent.mkdir(parents=True)
    pi.parent.mkdir(parents=True)
    nf.write_text(SAMPLE)
    pi.write_text('POWER_INSIGHT_ORIGINAL_CN', encoding='utf-8')
    mod.apply(folder, folder / 'report.json')
    assert pi.read_text(encoding='utf-8') == 'POWER_INSIGHT_ORIGINAL_CN'
    assert (folder / 'report.json').exists()
    try:
        mod.apply(folder, None)
    except ValueError:
        pass
    else:
        raise AssertionError('Double-patch not rejected')

for changed in [SAMPLE.replace('com.xiaomi.xmsf', 'com.example.other'), SAMPLE.replace('sNotificationCanBeBlockedList:Ljava/util/HashSet;\n    new-instance', 'other:Ljava/util/HashSet;\n    new-instance')]:
    try:
        mod.patch_notification(changed)
    except ValueError:
        pass
    else:
        raise AssertionError('Unknown CN layout not rejected')
print('[PASS] EU NotificationFilterHelper only; PowerInsightPolicy unchanged')