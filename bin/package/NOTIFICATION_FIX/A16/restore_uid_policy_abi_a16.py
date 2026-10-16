#!/usr/bin/env python3
"""Restore EU/RYU getUidPolicy ABI on the pinned ZKOS PowerKeeper layout.

The imported UID-kill decision reads only Bundle.getInt("POLICY", 0).
Keep existing ZK setters, background controls and hot/delay semantics.
"""
from pathlib import Path
import re

INTERFACE = 'Lcom/miui/powerkeeper/PowerKeeperInterface$l;'
CHECKER = 'Lcom/miui/powerkeeper/AppRuleChecker;'
RECORD = 'Lcom/miui/powerkeeper/AppRuleChecker$j;'
STATE = 'Lcom/miui/powerkeeper/AppRuleChecker$i;'
METHOD = 'getUidPolicy(I)Landroid/os/Bundle;'


def one(root: Path, basename: str) -> Path:
    hits = list(root.rglob(basename + '.smali'))
    if len(hits) != 1:
        raise ValueError(f'Expected one {basename}.smali in {root}, got {len(hits)}')
    return hits[0]


def patch(root: Path) -> dict:
    interface = one(root, 'PowerKeeperInterface$l')
    checker = one(root, 'AppRuleChecker')
    record = one(root, 'AppRuleChecker$j')
    wrapper = one(root, 'HideModeStateMachineWrapper')
    files = (interface, checker, record, wrapper)
    original = {p: p.read_text(encoding='utf-8') for p in files}
    a, b, c, w = (original[p] for p in files)

    if not re.search(r'(?m)^\.class[^\n]*\binterface\b[^\n]*' + re.escape(INTERFACE) + r'$', a):
        raise ValueError('Unknown policy interface descriptor')
    if f'.implements {INTERFACE}' not in b or f'.implements {INTERFACE}' not in w:
        raise ValueError('Known policy interface implementations changed')
    implementors = [p for p in root.rglob('*.smali')
                    if f'.implements {INTERFACE}' in p.read_text(encoding='utf-8')]
    if set(implementors) != {checker, wrapper}:
        raise ValueError('Unrecognized policy interface implementor')
    if f'.method public {METHOD}' not in w:
        raise ValueError('HideMode wrapper does not implement getUidPolicy')
    if METHOD in a or METHOD in b or 'tnmReadKillPolicy()I' in c:
        raise ValueError('ABI already restored or conflicting method exists')
    if not all(token in b for token in (
            CHECKER, 'n:Ljava/lang/Object;',
            'q(I)Lcom/miui/powerkeeper/AppRuleChecker$j;',
    )):
        raise ValueError('ZK AppRuleChecker lock or UID record layout changed')
    if RECORD not in c or '.class ' not in c:
        raise ValueError('Unexpected per-UID policy record descriptor')
    if not re.search(r'(?m)^\.field .* e:' + re.escape(STATE), c):
        raise ValueError('Missing per-UID standard policy state')
    state = one(root, 'AppRuleChecker$i').read_text(encoding='utf-8')
    if not re.search(r'(?m)^\.field .* a:I$', state):
        raise ValueError('Missing per-UID integer policy')

    interface_method = f'''
.method public abstract {METHOD}
.end method
'''
    checker_method = f'''
.method public {METHOD}
    .locals 4
    iget-object v0, p0, {CHECKER}->n:Ljava/lang/Object;
    monitor-enter v0
    :try_start_0
    invoke-direct {{p0, p1}}, {CHECKER}->q(I){RECORD}
    move-result-object v1
    invoke-virtual {{v1}}, {RECORD}->tnmReadKillPolicy()I
    move-result v1
    new-instance v2, Landroid/os/Bundle;
    invoke-direct {{v2}}, Landroid/os/Bundle;-><init>()V
    const-string v3, "POLICY"
    invoke-virtual {{v2, v3, v1}}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    monitor-exit v0
    :try_end_0
    .catchall {{:try_start_0 .. :try_end_0}} :catchall_0
    return-object v2
    :catchall_0
    move-exception v1
    monitor-exit v0
    throw v1
.end method
'''
    record_method = f'''
.method public tnmReadKillPolicy()I
    .locals 1
    iget-object v0, p0, {RECORD}->e:{STATE}
    if-eqz v0, :no_policy
    iget v0, v0, {STATE}->a:I
    return v0
    :no_policy
    const/4 v0, 0x0
    return v0
.end method
'''
    replacements = {interface: a + interface_method,
                    checker: b + checker_method,
                    record: c + record_method}
    for path, data in replacements.items():
        path.write_text(data, encoding='utf-8')
    return {'uid_policy_interface_restored': True,
            'uid_policy_checker_implemented': True,
            'uid_policy_record_reader_added': True,
            'existing_wrapper_verified': True,
            'policy_bundle_keys': ['POLICY'],
            'background_thread_added': False}
