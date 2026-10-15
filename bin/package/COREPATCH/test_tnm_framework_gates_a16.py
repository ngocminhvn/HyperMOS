#!/usr/bin/env python3
"""Gate scope, rejection, transactional writes and branch integration tests."""
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('gates', HERE / 'tnm_framework_gates_a16.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


def entry(name='test/Gate', signature='run()V', regs=None, neighbors=None):
    return {'jar': 'miui-services', 'class': name, 'method': signature,
            'registers': regs or ['v0'], 'next': neighbors or ['if-eqz v0, :LABEL']}


def source(register='v0', flag='IS_INTERNATIONAL_BUILD', decl='.locals 1', signature='run()V'):
    return ('.class public Ltest/Gate;\n.super Ljava/lang/Object;\n'
            '.method public ' + signature + '\n    ' + decl + '\n'
            f'    sget-boolean {register}, Lmiui/os/Build;->{flag}:Z\n'
            f'    if-eqz {register}, :exit\n'
            '    invoke-static {}, Landroid/security/kaorios/KaoriosHook;->initSystemServer()V\n'
            '    :exit\n    return-void\n.end method\n'
            '.method public untouched()Z\n    .locals 1\n'
            '    sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n'
            '    return v0\n.end method\n')


class Gates(unittest.TestCase):
    def test_preserves_other_methods_and_kaorios(self):
        src = source()
        result = m.transform(src, entry())
        self.assertIn('KaoriosHook;->initSystemServer()V', result)
        self.assertEqual(result.split('.method public untouched')[1], src.split('.method public untouched')[1])
        self.assertEqual(m.transform(result, entry()), result)
        self.assertEqual(m.transform(result, entry(), verify=True), result)

    def test_rejects_drift_and_missing_gates(self):
        for src in (source().replace('if-eqz', 'if-nez'),
                    source().replace('sget-boolean v0,', 'sget-boolean v1,'),
                    source().replace('IS_INTERNATIONAL_BUILD', 'IS_TABLET'),
                    source() + source()):
            with self.subTest(src=src), self.assertRaises(ValueError):
                m.transform(src, entry())
        with self.assertRaises(ValueError):
            m.transform(source(), entry(), verify=True)
        changed = m.transform(source(), entry()).replace('0x1', '0x0')
        with self.assertRaises(ValueError):
            m.transform(changed, entry())

    def test_real_param_register_encoding(self):
        src = source('p2', decl='.locals 16', signature='run(J)V')
        e = entry(signature='run(J)V', regs=['p2'], neighbors=['if-eqz p2, :LABEL'])
        self.assertIn('const/16 p2, 0x1', m.transform(src, e))
        with self.assertRaises(ValueError):
            m.transform(source('v0', decl='.registers 0'), entry())

    def test_no_partial_writes_or_duplicate_classes(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            p = root / 'smali/test/Gate.smali'
            p.parent.mkdir(parents=True)
            p.write_text(source())
            with self.assertRaises(ValueError):
                m.apply(root, 'miui-services', entries=[entry(), entry('test/Missing')])
            self.assertEqual(p.read_text(), source())
            # apk_ops.sh exposes classes -> smali solely as a compatibility alias.
            # The patcher must see one physical class, not two path strings.
            compat = root / 'classes'
            compat.symlink_to('smali', target_is_directory=True)
            m.apply(root, 'miui-services', entries=[entry()])
            self.assertIn(m.MARKER, p.read_text())
            compat.unlink()
            other = root / 'smali_classes2/test/Gate.smali'
            other.parent.mkdir(parents=True)
            other.write_text(source())
            with self.assertRaises(ValueError):
                m.apply(root, 'miui-services', entries=[entry()])

    def test_identical_mirrored_dex_copies_are_patched_and_verified(self):
        # apk_ops.sh sometimes creates real copies, not symlinks.
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            primary = root / 'smali/test/Gate.smali'
            mirror = root / 'classes/test/Gate.smali'
            for file in (primary, mirror):
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(source())
            m.apply(root, 'miui-services', entries=[entry()])
            self.assertEqual(primary.read_text(), mirror.read_text())
            self.assertIn(m.MARKER, primary.read_text())
            m.apply(root, 'miui-services', verify=True, entries=[entry()])

    def test_mirrored_dex_divergence_fails_without_writes(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            primary = root / 'smali/test/Gate.smali'
            mirror = root / 'classes/test/Gate.smali'
            for file in (primary, mirror):
                file.parent.mkdir(parents=True, exist_ok=True)
            primary.write_text(source())
            mirror.write_text(source().replace('untouched()Z', 'different()Z'))
            with self.assertRaisesRegex(ValueError, 'divergent DEX alias copies'):
                m.apply(root, 'miui-services', entries=[entry()])
            self.assertEqual(primary.read_text(), source())
            self.assertIn('different()Z', mirror.read_text())
            # Two genuinely different DEX slots are never treated as aliases.
            mirror.unlink()
            other = root / 'smali_classes2/test/Gate.smali'
            other.parent.mkdir(parents=True)
            other.write_text(source())
            with self.assertRaisesRegex(ValueError, 'duplicate class across DEX slots'):
                m.apply(root, 'miui-services', entries=[entry()])

    def test_content_whitelist_requires_entry_guard(self):
        signature = 'updateContentCatcherWhitelist()V'
        src = source(signature=signature).replace(
            'sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z', 'const/4 v0, 0x0')
        src = src.replace('    :exit', '    const-string v0, "update taplus clipboard whitelist error, build international"\n    :exit')
        self.assertIn('const/4 v0, 0x1', m.transform(src, entry(signature=signature)))
        with self.assertRaises(ValueError):
            m.transform(src.replace('    const/4 v0,', '    nop\n    const/4 v0,', 1), entry(signature=signature))

    def test_manifest_and_patch_order(self):
        manifest = json.loads(m.MANIFEST.read_text())
        entries = manifest['entries']
        self.assertEqual(len(entries), 44)
        self.assertEqual(sum(len(e['registers']) for e in entries), 47)
        self.assertEqual(len({(e['jar'], e['class'], e['method']) for e in entries}), 44)
        self.assertTrue(any(e['method'].startswith('checkFullScreenIntent(') for e in entries))
        self.assertTrue(any(e['method'].startswith('isForceStopEnable(') for e in entries))
        patcher = (HERE / 'jar_patcher_a16.sh').read_text()
        self.assertLess(patcher.index('python3 "$SCRIPT_DIR/tnm_policy_a16.py"'),
                        patcher.index('python3 "$SCRIPT_DIR/tnm_framework_gates_a16.py"'))
        update = (HERE / 'update.sh').read_text()
        compat = m.load_entries('hypermos-app-compat')
        self.assertEqual(len(compat), 18)
        self.assertEqual(sum(len(e['registers']) for e in compat), 19)
        self.assertTrue(any(e['method'].startswith('checkFullScreenIntent(') for e in compat))
        self.assertTrue(any(e['method'].startswith('isForceStopEnable(') for e in compat))
        self.assertTrue(any(e['method'].startswith('isAutoStartRestriction(') for e in compat))
        self.assertEqual(4, sum(e['class'].endswith('/PackageManagerServiceImpl') for e in compat))
        self.assertFalse(any('/location/' in e['class'] for e in compat))
        self.assertFalse(any('font/' in e['class'] for e in compat))
        self.assertIn('--tnm-app-compat-gates', update)
        self.assertNotIn('--tnm-framework-gates', update)
        self.assertIn('--profile hypermos-app-compat', patcher)
        for option in ('--disable-signature-verification', '--disable-secure-flag',
                       '--tnm-notification-policy', '--tnm-low-power-doze'):
            self.assertIn(option, update)
        packages = (HERE.parent / 'patchpackage.sh').read_text()
        self.assertLess(packages.index('COREPATCH/update.sh'), packages.index('KAORIOS_TOOLBOX/patch.sh'))
        self.assertIn('DISABLE_AVB/DISABLEavb.sh', packages)


if __name__ == '__main__':
    unittest.main()
