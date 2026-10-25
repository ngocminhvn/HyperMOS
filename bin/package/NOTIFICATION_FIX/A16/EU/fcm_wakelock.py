#!/usr/bin/env python3
"""Xiaomi.eu A16: GMS-owned FCM wakelocks only; preserve PowerKeeper/Greeze for others.

Two entrypoints must be handled: policy evaluation for new/existing locks and
PowerKeeper's immediate setUidPartialWakeLockDisabledState for existing locks.
No hardcoded UID, no PowerKeeper APK edits, no background workers.
"""
import argparse
import json
import re
from pathlib import Path

CLASS = 'com/android/server/power/PowerManagerServiceImpl.smali'
OWNER = 'Lcom/android/server/power/PowerManagerServiceImpl;'
WAKE = 'Lcom/android/server/power/PowerManagerService$WakeLock;'
METHOD = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
SIG_POLICY = f'isWakelockDisabledByPolicy({WAKE})Z'
SIG_DIRECT = 'setUidPartialWakeLockDisabledState(ILjava/lang/String;Z)V'
SIG_GUARD = f'isHypermosGmsFcmWakeLock({WAKE}I)Z'
GUARD_CALL = OWNER + '->' + SIG_GUARD
POLICY_CALL = OWNER + '->' + SIG_POLICY
DIRECT_CALL = OWNER + '->setWakeLockDisabledStateLocked(' + WAKE + 'Z)Z'
PK_CALL = 'Lcom/miui/whetstone/PowerKeeperPolicy;->isWakelockDisabledByPolicy(Ljava/lang/String;I)Z'
GREEZE_CALL = 'Lmiui/greeze/IGreezeManager;->isUidFrozen(I)Z'
MARK = 'HYPERMOS_EU_FCM_WAKELOCK_A16'

# The binder-derived owner UID is compared to the *actual* wakelock owner UID,
# never to a fixed installation-specific number. The package is checked as well.
# No PackageManager IPC occurs while PowerManagerService holds mLock.
HELPER = f'''
.method private {SIG_GUARD}
    .registers 7

    const/4 v0, 0x0
    iget-object v1, p1, {WAKE}->mTag:Ljava/lang/String;
    const-string v2, "GCM_WORK"
    invoke-virtual {{v2, v1}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :hypermos_gms_fcm_tag_ok
    const-string v2, "GCM_CONN_ALARM"
    invoke-virtual {{v2, v1}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :hypermos_gms_fcm_no

    :hypermos_gms_fcm_tag_ok
    iget-object v1, p1, {WAKE}->mPackageName:Ljava/lang/String;
    const-string v2, "com.google.android.gms"
    invoke-virtual {{v2, v1}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :hypermos_gms_fcm_no
    iget v1, p1, {WAKE}->mOwnerUid:I
    if-ne v1, p2, :hypermos_gms_fcm_no
    const/4 v0, 0x1

    :hypermos_gms_fcm_no
    return v0
.end method
'''

POLICY_OLD = '''    move-result v5

    const/4 v6, 0x1

    if-eqz v5, :cond_26
'''
POLICY_NEW = f'''    move-result v5

    const/4 v6, 0x1

    if-eqz v5, :cond_26

    # {MARK}: allow only GMS-owned GCM_WORK/GCM_CONN_ALARM past PowerKeeper;
    # continue into the *original* Greeze UidFrozen / wake-lock-limit tests.
    invoke-direct {{p0, p1, v4}}, {GUARD_CALL}
    move-result v5
    if-nez v5, :cond_26
'''
DIRECT_OLD = f'''    invoke-direct {{p0, v2, p3}}, {DIRECT_CALL}

    move-result v5'''
DIRECT_NEW = f'''    # {MARK}: an existing protected GMS lock must not be disabled by
    # the generic PowerKeeper UID block. Re-evaluate independent Greeze policy.
    move v8, p3
    if-eqz p3, :hypermos_gms_fcm_direct_apply
    invoke-direct {{p0, v2, p1}}, {GUARD_CALL}
    move-result v8
    if-eqz v8, :hypermos_gms_fcm_direct_stock
    invoke-virtual {{p0, v2}}, {POLICY_CALL}
    move-result v8
    goto :hypermos_gms_fcm_direct_apply

    :hypermos_gms_fcm_direct_stock
    move v8, p3

    :hypermos_gms_fcm_direct_apply
    invoke-direct {{p0, v2, v8}}, {DIRECT_CALL}

    move-result v5'''

def locate(src, sig):
    matches = [m for m in METHOD.finditer(src)
               if m.group().splitlines()[0].strip().split()[-1] == sig]
    if len(matches) != 1:
        raise ValueError(f'Expected exactly one {sig}: found {len(matches)}')
    return matches[0]

def checks(src):
    policy = locate(src, SIG_POLICY).group()
    direct = locate(src, SIG_DIRECT).group()
    helper = locate(src, SIG_GUARD).group()
    # Labels may be renamed by baksmali; assert instructions and call order.
    if policy.count(GUARD_CALL) != 1 or PK_CALL not in policy or GREEZE_CALL not in policy:
        raise ValueError('PowerKeeper or Greeze policy/guard missing')
    if not re.search(r'move-result v5\s+if-nez v5,\s*:\w+', policy):
        raise ValueError('GMS guard must branch into original Greeze evaluation')
    if direct.count(GUARD_CALL) != 1 or direct.count(POLICY_CALL) != 1 or direct.count(DIRECT_CALL) != 1:
        raise ValueError('Existing-lock protection or stock setter missing')
    if not re.search(r'invoke-virtual \{p0, v2\}, '+re.escape(POLICY_CALL)+r'\s+move-result v8', direct):
        raise ValueError('Direct setter must re-evaluate Greeze')
    for value in ('"GCM_WORK"', '"GCM_CONN_ALARM"', '"com.google.android.gms"',
                  '->mOwnerUid:I', '->mPackageName:Ljava/lang/String;'):
        if value not in helper:
            raise ValueError('Guard owner/tag check missing: '+value)
    if '10140' in helper:
        raise ValueError('Hardcoded GMS UID')
    return True

def patch_source(src, verify=False):
    if SIG_GUARD in src:
        checks(src)
        return src, ('verified' if verify else 'already_patched')
    if verify:
        raise ValueError('GMS FCM wakelock guard missing')
    policy = locate(src, SIG_POLICY)
    direct = locate(src, SIG_DIRECT)
    p = policy.group()
    d = direct.group()
    if '.registers 9' not in p or '.registers 13' not in d:
        raise ValueError('Unexpected PowerManagerServiceImpl register ABI')
    if p.count(POLICY_OLD) != 1 or p.count(PK_CALL) != 1 or p.count(GREEZE_CALL) != 1:
        raise ValueError('Unexpected stock PowerKeeper/Greeze policy structure')
    if d.count(DIRECT_OLD) != 1 or d.count(DIRECT_CALL) != 1:
        raise ValueError('Unexpected stock existing-lock setter structure')
    src = src[:direct.start()] + d.replace(DIRECT_OLD, DIRECT_NEW) + src[direct.end():]
    policy = locate(src, SIG_POLICY)
    src = src[:policy.start()] + policy.group().replace(POLICY_OLD, POLICY_NEW) + src[policy.end():]
    src += '\n' + HELPER
    checks(src)
    return src, 'patched'

def apply(root, verify=False, report=None):
    paths = list(root.glob('smali*/' + CLASS))
    if len(paths) != 1:
        raise ValueError(f'Expected exactly one PowerManagerServiceImpl, found {len(paths)}')
    path = paths[0]
    src = path.read_text(encoding='utf-8')
    changed, status = patch_source(src, verify=verify)
    if changed != src and not verify:
        path.write_text(changed, encoding='utf-8')
    outcome = {
        'status': status, 'scope': 'xiaomi_eu_android16',
        'powerkeeper_apk': 'unaltered', 'services_jar': 'unaltered',
        'patched_jar': 'system_ext/framework/miui-services.jar',
        'only_owner_package': 'com.google.android.gms',
        'uid': 'actual WakeLock.mOwnerUid (not hardcoded)',
        'tags': ['GCM_WORK', 'GCM_CONN_ALARM'],
        'policy_path': 'PowerKeeper bypass only; Greeze rechecked',
        'direct_existing_lock_path': 'PowerKeeper bypass only; Greeze rechecked',
        'runtime_tested': False,
    }
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(outcome, indent=2)+'\n', encoding='utf-8')
    return outcome

def main():
    a = argparse.ArgumentParser()
    a.add_argument('decoded', type=Path)
    a.add_argument('--verify', action='store_true')
    a.add_argument('--report', type=Path)
    v = a.parse_args()
    try:
        print('[EU GMS FCM WAKELOCK] '+json.dumps(apply(v.decoded, v.verify, v.report)))
    except (ValueError, OSError) as e:
        raise SystemExit('[EU GMS FCM WAKELOCK] FAIL: '+str(e))

if __name__ == '__main__':
    main()
