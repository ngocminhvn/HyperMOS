#!/usr/bin/env python3
"""Port only audited Xiaomi.eu NotificationFilterHelper behavior into CN A16.

Donor: user-supplied miui-frameworkEU.jar (Android 16):
- <clinit>()V drops default CN forced-on/cannot-change package lists.
- canSystemNotificationBeBlocked(Ljava/lang/String;)Z returns true.

Every other class, including PowerInsightPolicy, and every other method
remains stock CN (apart from independently configured existing ROM patches).
Fail closed if the expected CN smali structure differs.
"""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

FILTER = 'Lmiui/util/NotificationFilterHelper;'
CAN_BLOCK = 'canSystemNotificationBeBlocked(Ljava/lang/String;)Z'
METHOD_RE = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')


def locate(root: Path) -> Path:
    hits = list(root.rglob('miui/util/NotificationFilterHelper.smali'))
    if len(hits) != 1:
        raise ValueError(f'NotificationFilterHelper: expected one class, got {len(hits)}')
    return hits[0]


def split_methods(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for match in METHOD_RE.finditer(text):
        sig = match.group().splitlines()[0].split()[-1]
        if sig in out:
            raise ValueError('Duplicate method: ' + sig)
        out[sig] = match.group()
    return out


def substitute_method(source: str, sig: str, edit):
    matches = [m for m in METHOD_RE.finditer(source)
               if m.group().splitlines()[0].split()[-1] == sig]
    if len(matches) != 1:
        raise ValueError(f'{sig}: expected one method, got {len(matches)}')
    match = matches[0]
    return source[:match.start()] + edit(match.group()) + source[match.end():]


def patch_notification(text: str) -> tuple[str, dict]:
    if not re.search(r'(?m)^\.class\b[^\n]*' + re.escape(FILTER) + r'[ \t]*$', text):
        raise ValueError('Unexpected NotificationFilterHelper class declaration')
    original = split_methods(text)
    if '<clinit>()V' not in original or CAN_BLOCK not in original:
        raise ValueError('Required NotificationFilterHelper methods missing')

    def clinit(block: str) -> str:
        # CN initializes this unused-by-EU list, EU skips it. Maintain all other
        # collections, dropping only the three-instruction set allocation.
        # Baksmali separates instructions with blank lines, including around
        # debug directives. Skip only those lines, never other instructions.
        spacing = r'(?:[ \t]*\n|[ \t]*\.(?:line|local)\b[^\n]*\n)*'
        allocation = re.compile(
            r'(?m)^[ \t]*new-instance[ \t]+([vp]\d+),[ \t]+Ljava/util/HashSet;[ \t]*\n'
            + spacing +
            r'[ \t]*invoke-direct[ \t]+\{\1\},[ \t]+'
            r'Ljava/util/HashSet;-><init>\(\)V[ \t]*\n'
            + spacing +
            r'[ \t]*sput-object[ \t]+\1,[ \t]+'
            r'Lmiui/util/NotificationFilterHelper;->sNotificationCanBeBlockedList:Ljava/util/HashSet;[ \t]*\n'
        )
        block, count = allocation.subn('', block)
        if count != 1:
            raise ValueError(f'Unexpected CN can-block set initialization count: {count}')

        # EU stops after allocating sNotificationCannotSetImportanceList;
        # CN hard-codes further notification list entries for Xiaomi packages.
        last_allocation = re.search(
            r'(?m)^[ \t]*sput-object[ \t]+[vp]\d+,[ \t]+'
            r'Lmiui/util/NotificationFilterHelper;->sNotificationCannotSetImportanceList:Ljava/util/HashSet;[ \t]*$',
            block)
        if not last_allocation:
            raise ValueError('EU <clinit> stopping point absent')
        tail = block[last_allocation.end():]
        for expected in ('com.miui.securitycenter', 'com.xiaomi.xmsf'):
            if expected not in tail:
                raise ValueError('Unexpected CN notification package list layout')
        if re.search(r'(?m)^\s*:(?:try|catch|cond|goto|pswitch|sswitch)', tail):
            raise ValueError('Unexpected control flow in notification list tail')
        if len(re.findall(r'(?m)^[ \t]*return-void[ \t]*$', tail)) != 1:
            raise ValueError('Unexpected trailing return in CN static initializer')
        return block[:last_allocation.end()] + '\n    return-void\n.end method'

    after = substitute_method(text, '<clinit>()V', clinit)

    def always_true(block: str) -> str:
        if 'sNotificationCanBeBlockedList' not in block:
            raise ValueError('Unknown original CN can-block implementation')
        head = block.splitlines()[0]
        if ' static ' not in head or not head.endswith(' ' + CAN_BLOCK):
            raise ValueError('Unexpected can-block method declaration')
        return head + '\n    .locals 1\n\n    const/4 v0, 0x1\n    return v0\n.end method'

    after = substitute_method(after, CAN_BLOCK, always_true)
    final = split_methods(after)
    if set(final) != set(original):
        raise ValueError('Unexpected NotificationFilterHelper method inventory change')
    for sig in original:
        if sig not in ('<clinit>()V', CAN_BLOCK) and final[sig] != original[sig]:
            raise ValueError('Unrelated NotificationFilterHelper method changed: ' + sig)
    if ('sNotificationCanBeBlockedList' in final['<clinit>()V']
            or 'sNotificationCanBeBlockedList' in final[CAN_BLOCK]):
        raise ValueError('CN notification block set still accessed')
    if 'const/4 v0, 0x1' not in final[CAN_BLOCK]:
        raise ValueError('EU notification-block check not applied')
    return after, {
        'source': 'miui-frameworkEU.jar',
        'class': FILTER,
        'changed_methods': ['<clinit>()V', CAN_BLOCK],
        'power_insight_policy_patched': False,
        'ryu_or_zk_methods_imported': False,
        'thermal_or_cpu_methods_patched': False,
    }


def apply(root: Path, report: Path | None):
    target = locate(root)
    original = target.read_text(encoding='utf-8')
    patched, info = patch_notification(original)
    if patched == original:
        raise ValueError('NotificationFilterHelper patch unexpectedly unchanged')
    target.write_text(patched, encoding='utf-8')
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(info, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('[EU NOTIFICATION FILTER] ' + json.dumps(info))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('decoded_miui_framework', type=Path)
    p.add_argument('--report', type=Path)
    args = p.parse_args()
    apply(args.decoded_miui_framework, args.report)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit('[EU NOTIFICATION FILTER] FAIL: ' + str(exc))
