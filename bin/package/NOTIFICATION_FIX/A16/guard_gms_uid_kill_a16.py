#!/usr/bin/env python3
"""Event-only GMS exemption from the conditional PowerKeeper UID kill path.

Runs only when KillProcessController is about to evaluate a UID-kill rule;
other background/Doze policies stay intact and no polling/thread is created.
"""
from pathlib import Path
import re

OWNER = 'Lcom/miui/powerkeeper/controller/KillProcessController;'
PACKAGE_UTIL = 'Lcom/miui/powerkeeper/utils/PackageUtil;'
CONTEXT = 'Lcom/miui/powerkeeper/utils/Utils;->APP_CONTEXT:Landroid/content/Context;'
RULE = 'shouldKillByCheckerPolicy(I)Z'
METHOD_RE = re.compile(r'(?ms)^\.method[^\n]*\s' + re.escape(RULE) + r'\s*$.*?^\.end method[ \t]*$')
REG = re.compile(r'(?m)^[ \t]*\.(?:locals|registers)[ \t]+(\d+)[ \t]*$')


def patch(root: Path) -> dict:
    matches = list(root.rglob('KillProcessController.smali'))
    if len(matches) != 1:
        raise ValueError('Expected exactly one KillProcessController class')
    path = matches[0]
    src = path.read_text(encoding='utf-8')
    if CONTEXT not in src or PACKAGE_UTIL + '->getPackageNameByUid(' not in src:
        raise ValueError('Original Xiaomi package lookup dependency has changed')
    hits = list(METHOD_RE.finditer(src))
    if len(hits) != 1:
        raise ValueError('Conditional UID policy helper missing or ambiguous')
    block = hits[0].group()
    if ('->getUidPolicy(I)Landroid/os/Bundle;' not in block
            or '"POLICY"' not in block or 'tnmIsGmsUid' in src):
        raise ValueError('UID policy helper layout changed or already patched')
    registers = list(REG.finditer(block))
    if len(registers) != 1 or int(registers[0].group(1)) < 2:
        raise ValueError('UID helper has insufficient scratch registers')
    guard = f'''
    # One check only when considering a UID kill; not a permanent whitelist.
    invoke-direct {{p0, p1}}, {OWNER}->tnmIsGmsUid(I)Z
    move-result v0
    if-eqz v0, :tnm_not_gms_uid
    const/4 v0, 0x0
    return v0
    :tnm_not_gms_uid
'''
    pos = registers[0].end()
    block = block[:pos] + guard + block[pos:]
    helper = f'''
.method private tnmIsGmsUid(I)Z
    .locals 3
    :try_start_0
    sget-object v0, {CONTEXT}
    if-eqz v0, :tnm_no_gms
    invoke-static {{v0, p1}}, {PACKAGE_UTIL}->getPackageNameByUid(Landroid/content/Context;I)Ljava/lang/String;
    move-result-object v0
    const-string v1, "com.google.android.gms"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    :try_end_0
    .catch Ljava/lang/Exception; {{:try_start_0 .. :try_end_0}} :tnm_error
    return v2
    :tnm_error
    move-exception v0
    :tnm_no_gms
    const/4 v0, 0x0
    return v0
.end method
'''
    src = src[:hits[0].start()] + block + src[hits[0].end():] + '\n' + helper
    path.write_text(src, encoding='utf-8')
    return {'gms_uid_kill_exemption': 'event-only, conditional KillProcessController',
            'other_uid_policies_unchanged': True, 'new_daemon': False,
            'additional_uid_lookup_only_on_kill_consideration': True}
