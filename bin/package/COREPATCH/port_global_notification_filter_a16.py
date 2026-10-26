#!/usr/bin/env python3
"""Global303 NotificationFilterHelper policy port for Xiaomi.eu A16.

Only the two audited EU/Global-different methods are modified. System-app
notification lists only; no GMS/FCM wakelock exceptions or APK changes.
"""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

CLASS = 'Lmiui/util/NotificationFilterHelper;'
CAN_BLOCK = 'canSystemNotificationBeBlocked(Ljava/lang/String;)Z'
METHOD = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
BLOCKABLE = ('com.miui.fm', 'com.miui.antispam', 'com.miui.securitycenter')
FORCED = ('android', 'com.android.incallui', 'com.android.deskclock',
          'com.android.mms', 'com.android.bluetooth', 'com.android.updater',
          'com.android.providers.downloads', 'com.miui.hybrid')
SET_ADD = 'Ljava/util/HashSet;->add(Ljava/lang/Object;)Z'


def methods(data: str) -> dict[str, str]:
    result = {}
    for match in METHOD.finditer(data):
        name = match.group().splitlines()[0].split()[-1]
        if name in result:
            raise ValueError('Duplicate method: ' + name)
        result[name] = match.group()
    return result


def replace_method(src: str, key: str, edit):
    hits = [m for m in METHOD.finditer(src)
            if m.group().splitlines()[0].split()[-1] == key]
    if len(hits) != 1:
        raise ValueError(f'{key}: expected exactly one occurrence')
    m = hits[0]
    return src[:m.start()] + edit(m.group()) + src[m.end():]


def patch(data: str) -> tuple[str, dict]:
    if not re.search(r'(?m)^\.class\s+[^\n]*' + re.escape(CLASS) + r'\s*$', data):
        raise ValueError('Unexpected class declaration')
    if len(re.findall(r'(?m)^\.field[^\n]*sNotificationCanBeBlockedList:Ljava/util/HashSet;', data)) != 1:
        raise ValueError('Missing original EU field sNotificationCanBeBlockedList')
    before = methods(data)
    if '<clinit>()V' not in before or CAN_BLOCK not in before:
        raise ValueError('Missing required Global-policy methods')

    def init(block: str) -> str:
        if 'sNotificationCanBeBlockedList' in block:
            raise ValueError('Not original EU309: blockable list is initialized')
        if not re.search(r'(?m)^\s*\.registers\s+14\s*$', block):
            raise ValueError('Unknown initializer register layout')
        required = ('sIsSystemApp:Ljava/util/HashMap;',
                    'sNotificationForcedEnabledPkgList:Ljava/util/HashSet;',
                    'sNotificationForcedEnabledAllChannelList:Ljava/util/HashSet;',
                    'sNotificationForcedEnabledChannelList:Ljava/util/HashMap;',
                    'sNotificationCannotSetImportanceList:Ljava/util/HashSet;')
        for name in required:
            if block.count(name) != 1:
                raise ValueError('Unknown EU init fields: ' + name)
        if block.count('    return-void') != 1 or any(pkg in block for pkg in BLOCKABLE):
            raise ValueError('Unexpected original initializer tail')
        anchor = re.compile(r'(?m)^(\s*sput-object\s+v0,\s*' +
                            re.escape(CLASS) +
                            r'->sIsSystemApp:Ljava/util/HashMap;\s*)$')
        allocation = ('\n    new-instance v0, Ljava/util/HashSet;\n'
                      '    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V\n'
                      '    sput-object v0, ' + CLASS +
                      '->sNotificationCanBeBlockedList:Ljava/util/HashSet;')
        block, n = anchor.subn(lambda m: m.group(1) + allocation, block)
        if n != 1:
            raise ValueError('EU init map allocation anchor changed')

        def add(set_name: str, package: str, dst: str):
            return ('    sget-object v0, ' + CLASS + '->' + set_name +
                    ':Ljava/util/HashSet;\n' +
                    f'    const-string {dst}, "{package}"\n' +
                    f'    invoke-virtual {{v0, {dst}}}, {SET_ADD}\n')

        tail = '\n'
        for package in BLOCKABLE:
            tail += add('sNotificationCanBeBlockedList', package, 'v1')
        for i, package in enumerate(FORCED):
            tail += add('sNotificationForcedEnabledPkgList', package,
                        'v2' if i == 0 else 'v3')
        tail += add('sNotificationForcedEnabledAllChannelList', 'com.xiaomi.xmsf', 'v3')
        # Donor Global303 register liveness: v1=securitycenter, v2=android.
        tail += (
            '    new-instance v0, Ljava/util/HashSet;\n'
            '    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V\n'
            f'    invoke-virtual {{v0, v1}}, {SET_ADD}\n'
            '    sget-object v3, ' + CLASS + '->sNotificationForcedEnabledChannelList:Ljava/util/HashMap;\n'
            '    invoke-virtual {v3, v1, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;\n'
            '    sget-object v1, ' + CLASS + '->sNotificationCannotSetImportanceList:Ljava/util/HashSet;\n'
            f'    invoke-virtual {{v1, v2}}, {SET_ADD}\n')
        if not re.search(r'(?m)^\s*return-void\s*\n\.end method\s*$', block):
            raise ValueError('Unexpected EU initializer return')
        return re.sub(r'(?m)^(\s*return-void\s*\n\.end method\s*)$',
                      lambda m: tail + m.group(1), block, count=1)

    after = replace_method(data, '<clinit>()V', init)

    def can_block(block: str) -> str:
        if 'sNotificationCanBeBlockedList' in block:
            raise ValueError('Already has a Global can-block method')
        if not re.search(r'(?m)^\s*const/4\s+v0,\s*0x1\s*$', block):
            raise ValueError('Unexpected EU can-block policy')
        head = block.splitlines()[0]
        if ' static ' not in head or not head.endswith(CAN_BLOCK):
            raise ValueError('Unexpected can-block signature')
        return (head + '\n    .registers 2\n'
                '    sget-object v0, ' + CLASS + '->sNotificationCanBeBlockedList:Ljava/util/HashSet;\n'
                '    invoke-virtual {v0, p0}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z\n'
                '    move-result v0\n    return v0\n.end method')

    after = replace_method(after, CAN_BLOCK, can_block)
    updated = methods(after)
    if set(updated) != set(before):
        raise ValueError('Method inventory changed')
    for key in before:
        if key not in ('<clinit>()V', CAN_BLOCK) and before[key] != updated[key]:
            raise ValueError('Unrelated notification method changed: ' + key)
    if any(updated['<clinit>()V'].count(f'"{p}"') != 1
           for p in (*BLOCKABLE, *FORCED, 'com.xiaomi.xmsf')):
        raise ValueError('Global notification system-app entries not exact')
    return after, {'donor': 'DADA Global303', 'base': 'HAOTIAN EU309',
                   'class': CLASS, 'methods': ['<clinit>()V', CAN_BLOCK],
                   'system_app_blockable': list(BLOCKABLE),
                   'system_app_forced': list(FORCED),
                   'all_channel_forced': ['com.xiaomi.xmsf'],
                   'powerkeeper_apk_modified': False,
                   'third_party_fcm_exceptions_added': False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('decoded_jar', type=Path)
    parser.add_argument('--report', type=Path)
    a = parser.parse_args()
    found = list(a.decoded_jar.rglob('miui/util/NotificationFilterHelper.smali'))
    if len(found) != 1:
        raise SystemExit('Expected exactly one NotificationFilterHelper.smali')
    path = found[0]
    original = path.read_text(encoding='utf-8')
    patched, report = patch(original)
    if patched == original:
        raise SystemExit('Global filter patch changed nothing')
    path.write_text(patched, encoding='utf-8')
    if a.report:
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('[EU GLOBAL NOTIFICATION FILTER] ' + json.dumps(report))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit('[EU GLOBAL NOTIFICATION FILTER] FAIL: ' + str(exc))
