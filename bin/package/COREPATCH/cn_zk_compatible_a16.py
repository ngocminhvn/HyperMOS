#!/usr/bin/env python3
"""Restore pre-ZK CN notification substitutions except the exact ZK JAR gates.

The historical CN fix replaces IS_INTERNATIONAL_BUILD with IS_MIUI across
selected smali classes. With ZK parity enabled, doing so inside ten audited
ZK methods would destroy their original build-gate instructions and break
tnm_zk_power_a16.py. Restore the legacy behavior on all other methods.
"""
import argparse
import json
import re
from pathlib import Path

from tnm_zk_power_a16 import ZK_METHODS

CN_OLD = 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z'
CN_NEW = 'Lmiui/os/Build;->IS_MIUI:Z'
METHOD = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
READ = re.compile(
    r'(?m)(\bsget-boolean\s+[vp]\d+,\s+)' + re.escape(CN_OLD) + r'(?=[ \t]*$)'
)
EXTRA_PROTECTED = {
    # Static setup is also patched by tnm_zk_power_a16.py.
    'com/android/server/notification/NotificationManagerServiceImpl.smali': ('<clinit>()V',),
    'com/miui/server/greeze/PolicyManager.smali': ('<clinit>()V',),
}


def protected_methods(path: Path) -> set[str]:
    normalized = path.as_posix()
    result = set()
    for relative, methods in {**ZK_METHODS, **EXTRA_PROTECTED}.items():
        if normalized.endswith('/' + relative):
            result.update(methods)
    return result


def patch(source: str, path: Path) -> tuple[str, dict]:
    protected = protected_methods(path)
    # Match original CN fix's Gboard package alias substitution.
    source = source.replace('com.baidu.input_mi', 'com.google.android.inputmethod.latin')
    kept = set()
    replaced = 0

    def apply_method(match: re.Match) -> str:
        nonlocal replaced
        body = match.group()
        signature = body.splitlines()[0].split()[-1]
        if signature in protected:
            kept.add(signature)
            return body
        result, count = READ.subn(lambda m: m.group(1) + CN_NEW, body)
        replaced += count
        return result

    output = METHOD.sub(apply_method, source)
    # All executable sget-boolean instructions belong to a smali method.
    if not protected and READ.search(output):
        raise ValueError('Unconverted international build read outside smali method')
    return output, {
        'file': str(path),
        'cn_replaced_reads': replaced,
        'zk_methods_preserved': sorted(kept),
    }


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument('smali', type=Path)
    args = p.parse_args()
    original = args.smali.read_text(encoding='utf-8')
    result, report = patch(original, args.smali)
    if result != original:
        args.smali.write_text(result, encoding='utf-8')
    print('[CN RESTORE] ' + json.dumps(report, sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit('[CN RESTORE] FAIL: ' + str(exc))
