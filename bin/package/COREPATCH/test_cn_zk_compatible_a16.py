#!/usr/bin/env python3
"""Offline regression test for legacy CN fix with exact ZK method isolation."""
from pathlib import Path
from cn_zk_compatible_a16 import CN_NEW, CN_OLD, ZK_METHODS, EXTRA_PROTECTED, patch


def block(signature: str) -> str:
    return (
        f'.method public {signature}\n'
        '    .locals 1\n'
        f'    sget-boolean v0, {CN_OLD}\n'
        '    return v0\n'
        '.end method\n'
    )


for suffix, signatures in {**ZK_METHODS, **EXTRA_PROTECTED}.items():
    path = Path('/tmp/decompile/smali') / suffix
    for protected in signatures:
        original = block(protected) + block('anotherMethod()Z')
        output, report = patch(original, path)
        assert output.startswith(block(protected)), (path, protected)
        assert output.count(CN_OLD) == 1, (path, protected)
        assert output.count(CN_NEW) == 1, (path, protected)
        assert report['cn_replaced_reads'] == 1, (path, protected)
        rerun, _ = patch(output, path)
        assert output == rerun, (path, protected)

plain_path = Path('/tmp/decompile/smali/com/miui/server/OtherController.smali')
original = block('original()V') + block('second()V')
output, report = patch(original, plain_path)
assert output.count(CN_OLD) == 0
assert output.count(CN_NEW) == 2
assert report['cn_replaced_reads'] == 2
assert output == patch(output, plain_path)[0]

alias, _ = patch('com.baidu.input_mi\n' + block('other()Z'), plain_path)
assert 'com.google.android.inputmethod.latin' in alias
assert 'com.baidu.input_mi' not in alias
print('[CN RESTORE TEST] legacy CN gates restored, ZK methods protected, idempotent')
