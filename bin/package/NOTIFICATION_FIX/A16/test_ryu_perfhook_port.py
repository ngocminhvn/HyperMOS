#!/usr/bin/env python3
"""Unit tests for the HAOTIAN-only RYU PerfHook APK patcher."""
import json
import tempfile
import unittest
from pathlib import Path
from ryu_perfhook_port import CALL, RYU_SETTING, ANDROID_SETTING, compatible_smali, prepare

class HookTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.ryu = self.root / 'ryu'
        self.stock = self.root / 'stock'
        for d in (self.ryu, self.stock):
            (d / 'smali/com/miui/powerkeeper').mkdir(parents=True, exist_ok=True)
        app = ('.class public Lcom/miui/powerkeeper/PowerKeeperApplication;\n'
               '.super Landroid/app/Application;\n'
               '.method public onCreate()V\n'
               '    .locals 0\n'
               '    invoke-super {p0}, Landroid/app/Application;->onCreate()V\n'
               '    return-void\n'
               '.end method\n')
        (self.stock / 'smali/com/miui/powerkeeper/PowerKeeperApplication.smali').write_text(app)
        (self.ryu / 'smali/com/miui/powerkeeper/PowerKeeperApplication.smali').write_text(
            app.replace('    return-void\n',
                        '    invoke-static {p0}, ' + CALL + '\n'
                        '    move-result-object v0\n'
                        '    invoke-virtual {v0}, Lcom/projectryu/perf/PerfHook;->init()V\n'
                        '    return-void\n'))
        for n in range(20):
            name = 'Lcom/projectryu/perf/PerfHook' + ('$' + str(n) if n else '') + ';'
            dest = self.ryu / 'smali' / (name[1:-1] + '.smali')
            dest.parent.mkdir(parents=True, exist_ok=True)
            extra = ('    invoke-static {v0, v1}, ' + RYU_SETTING + '\n' +
                     '    invoke-static {}, Lcom/projectryu/RyuHelper;->noop()V\n') if n == 0 else ''
            dest.write_text('.class public ' + name + '\n.super Ljava/lang/Object;\n' + extra +
                            ('.method public init()V\n    .locals 0\n    return-void\n.end method\n' if n == 0 else ''))
        extra = self.ryu / 'smali/com/projectryu/RyuHelper.smali'
        extra.write_text('.class public Lcom/projectryu/RyuHelper;\n.super Ljava/lang/Object;\n')
        self.extra = extra

    def test_dependency_closure_and_single_call(self):
        src, classes, app_file, new_text, dex, call = prepare(self.ryu, self.stock)
        self.assertEqual(len(classes), 21)
        self.assertIn(ANDROID_SETTING, compatible_smali(src['Lcom/projectryu/perf/PerfHook;'][1]))
        self.assertNotIn(RYU_SETTING, compatible_smali(src['Lcom/projectryu/perf/PerfHook;'][1]))
        self.assertEqual(new_text.count(CALL), 1)
        self.assertEqual(new_text.count('PerfHook;->init()V'), 1)
        self.assertIn('hypermosInitRyuPerfHook', new_text)
        self.assertEqual(dex.name, 'smali_classes2')
        self.assertTrue(call.startswith('invoke-static {p0}'))
        self.assertNotIn(CALL, app_file.read_text())

    def test_missing_dependency_refused(self):
        self.extra.unlink()
        with self.assertRaisesRegex(ValueError, 'Missing RYU dependency'):
            prepare(self.ryu, self.stock)

    def test_duplicate_perfhook_refused(self):
        path = self.stock / 'smali/com/projectryu/perf/PerfHook.smali'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('.class public Lcom/projectryu/perf/PerfHook;\n')
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            prepare(self.ryu, self.stock)

    def test_missing_oncreate_activation_refused(self):
        f = self.ryu / 'smali/com/miui/powerkeeper/PowerKeeperApplication.smali'
        f.write_text(f.read_text().replace('    invoke-static {p0}, ' + CALL + '\n', ''))
        with self.assertRaisesRegex(ValueError, 'original startup differs'):
            prepare(self.ryu, self.stock)

if __name__ == '__main__':
    unittest.main()
