#!/usr/bin/env python3
"""Skip GMS only in existing UID-kill decision, reusing its package lookup.

No extra PackageUtil/PackageManager call, cache, thread, timer or wakelock.
Insert immediately after the already-existing isLockedApplication() result,
OR the GMS match with that result and retain the original skip-kill branch.
"""
from pathlib import Path
import re

SET_UID = 'setUidState(IZ)V'
PACKAGE_UTIL = 'Lcom/miui/powerkeeper/utils/PackageUtil;'
LOCKED = 'Lmiui/process/ProcessManager;->isLockedApplication(Ljava/lang/String;I)Z'
GMS = 'com.google.android.gms'

# Exact known Android 16 HAOTIAN donor ordering: package lookup, save its
# result, check locked app; then if-nez the locked bit branches around kill.
# Requiring adjacency avoids reusing a register after it may be overwritten.
LOOKUP_AND_LOCKED = re.compile(
    r'(?m)^(?P<indent>[ \t]*)invoke-static[ \t]+\{(?P<context>[vp]\d+),[ \t]*(?P<uid>[vp]\d+)\},[ \t]*'
    + re.escape(PACKAGE_UTIL)
    + r'->getPackageNameByUid\(Landroid/content/Context;I\)Ljava/lang/String;[ \t]*\n'
    r'(?:[ \t]*\.line[ \t]+\d+[ \t]*\n)*'
    r'[ \t]*move-result-object[ \t]+(?P<pkg>v\d+)[ \t]*\n'
    r'(?:[ \t]*\.line[ \t]+\d+[ \t]*\n)*'
    r'[ \t]*invoke-static[ \t]+\{(?P=pkg),[ \t]*(?P<user>[vp]\d+)\},[ \t]*'
    + re.escape(LOCKED)
    + r'[ \t]*\n'
    r'(?:[ \t]*\.line[ \t]+\d+[ \t]*\n)*'
    r'[ \t]*move-result[ \t]+(?P<locked>v\d+)[ \t]*\n'
    r'(?P<debug>(?:[ \t]*\.line[ \t]+\d+[ \t]*\n)*)'
    r'(?P<branch>[ \t]*if-nez[ \t]+(?P=locked),[ \t]*:[\w$]+[ \t]*(?:\n|$))'
)

METHOD = re.compile(r'(?ms)^\.method[^\n]*[ \t]' + re.escape(SET_UID)
                    + r'[ \t]*$.*?^\.end method[ \t]*$')
REGISTERS = re.compile(r'(?m)^\s*\.(?:registers|locals)\s+(\d+)\s*$')


def patch_method(uid_method: str) -> str:
    """Return rewritten method or raise on changed donor ABI / control flow."""
    if 'tnmIsGmsUid' in uid_method or GMS in uid_method:
        raise ValueError('GMS UID guard already present or unexpected')
    if uid_method.count('->getPackageNameByUid(') != 1:
        raise ValueError('Expected exactly one existing UID-to-package lookup')
    hits = list(LOOKUP_AND_LOCKED.finditer(uid_method))
    if len(hits) != 1:
        raise ValueError('Existing package-to-locked-app branch is missing/ambiguous')
    hit = hits[0]
    pkg, locked = hit['pkg'], hit['locked']
    # v0 is the known scratch slot in the HAOTIAN RYU setUidState body:
    # v0 is reassigned by getCurrentIME() before the later integer use.
    if pkg == 'v0' or locked == 'v0' or 'v0' not in uid_method:
        raise ValueError('Expected HAOTIAN spare v0 slot is unavailable')
    regs = list(REGISTERS.finditer(uid_method))
    if len(regs) != 1 or int(regs[0][1]) < 9:
        raise ValueError('Unexpected register allocation for HAOTIAN UID method')
    # The existing locked-app branch now also skips kill for GMS. No
    # short-circuit of unrelated UID state or logging occurs.
    injected = (
        f'{hit["indent"]}const-string v0, "{GMS}"\n'
        f'{hit["indent"]}invoke-virtual {{v0, {pkg}}}, '
        'Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n'
        f'{hit["indent"]}move-result v0\n'
        f'{hit["indent"]}or-int/2addr {locked}, v0\n'
    )
    return uid_method[:hit.start('debug')] + injected + uid_method[hit.start('debug'):]


def patch(root: Path) -> dict:
    matches = list(root.rglob('KillProcessController.smali'))
    if len(matches) != 1:
        raise ValueError('Expected exactly one KillProcessController class')
    path = matches[0]
    source = path.read_text(encoding='utf-8')
    hits = list(METHOD.finditer(source))
    if len(hits) != 1:
        raise ValueError('setUidState method missing or ambiguous')
    original = hits[0].group()
    patched = patch_method(original)
    if patched == original:
        raise ValueError('GMS UID guard was not inserted')
    modified = source[:hits[0].start()] + patched + source[hits[0].end():]
    if modified.count('->getPackageNameByUid(') != source.count('->getPackageNameByUid('):
        raise ValueError('Unexpected UID lookup count change')
    if modified.count('->shouldKillByCheckerPolicy(I)Z') != source.count('->shouldKillByCheckerPolicy(I)Z'):
        raise ValueError('Unexpected UID checker call change')
    path.write_text(modified, encoding='utf-8')
    return {
        'gms_uid_kill_exemption': 'GMS OR existing locked-app check inside setUidState',
        'reused_package_lookup': True,
        'additional_package_lookup': 0,
        'additional_helper_method': 0,
        'new_daemon_or_timer': False,
        'other_uid_policies_unchanged': True,
    }
