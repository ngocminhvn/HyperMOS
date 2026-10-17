#!/usr/bin/env python3
"""Synthetic tests of the ZK -> EU/RYU policy interface repair."""
import tempfile
import unittest
from pathlib import Path
from restore_uid_policy_abi_a16 import patch, INTERFACE, CHECKER, RECORD, STATE


class UIDPolicyABITest(unittest.TestCase):
    def fixtures(self, root):
        d = root / 'smali/classes/com/miui/powerkeeper'
        d.mkdir(parents=True)
        data = {
            'PowerKeeperInterface$l.smali':
                f'.class public interface abstract {INTERFACE}\n.super Ljava/lang/Object;\n',
            'AppRuleChecker.smali':
                f'.class public {CHECKER}\n.super Ljava/lang/Object;\n'
                f'.implements {INTERFACE}\n.field private n:Ljava/lang/Object;\n'
                f'.method private q(I){RECORD}\n.end method\n',
            'AppRuleChecker$j.smali':
                f'.class public {RECORD}\n.super Ljava/lang/Object;\n'
                f'.field private e:{STATE}\n',
            'AppRuleChecker$i.smali':
                f'.class public {STATE}\n.super Ljava/lang/Object;\n.field private a:I\n',
            'appcontrol/HideModeStateMachineWrapper.smali':
                '.class public Lcom/miui/powerkeeper/appcontrol/HideModeStateMachineWrapper;\n'
                f'.super Ljava/lang/Object;\n.implements {INTERFACE}\n'
                '.method public getUidPolicy(I)Landroid/os/Bundle;\n.end method\n',
        }
        for relative, body in data.items():
            p = d / relative
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(body, encoding='utf-8')
        return d

    def test_restores_interface_and_concrete_reader(self):
        with tempfile.TemporaryDirectory() as tmp:
            d = self.fixtures(Path(tmp))
            status = patch(d)
            self.assertTrue(status['uid_policy_interface_restored'])
            self.assertEqual(status['policy_bundle_keys'], ['POLICY'])
            self.assertFalse(status['background_thread_added'])
            self.assertIn('getUidPolicy(I)Landroid/os/Bundle;',
                          (d / 'PowerKeeperInterface$l.smali').read_text())
            checker = (d / 'AppRuleChecker.smali').read_text()
            self.assertIn('monitor-enter v0', checker)
            self.assertIn('putInt(Ljava/lang/String;I)V', checker)
            reader = (d / 'AppRuleChecker$j.smali').read_text()
            self.assertIn('tnmReadKillPolicy()I', reader)
            self.assertIn('->e:', reader)
            with self.assertRaises(ValueError):
                patch(d)

    def test_real_zk_unqualified_fields(self):
        # APKEditor's real HAOTIAN ZK disassembly uses ".field e:..." and
        # ".field a:I", without the synthetic fixture's "private" modifier.
        with tempfile.TemporaryDirectory() as tmp:
            d = self.fixtures(Path(tmp))
            record = d / 'AppRuleChecker$j.smali'
            state = d / 'AppRuleChecker$i.smali'
            record.write_text(record.read_text().replace('.field private e:', '.field e:'))
            state.write_text(state.read_text().replace('.field private a:', '.field a:'))
            result = patch(d)
            self.assertTrue(result['uid_policy_record_reader_added'])

    def test_other_implementor_must_exist(self):
        with tempfile.TemporaryDirectory() as tmp:
            d = self.fixtures(Path(tmp))
            (d / 'appcontrol/HideModeStateMachineWrapper.smali').unlink()
            with self.assertRaises(ValueError):
                patch(d)

    def test_policy_storage_must_match(self):
        with tempfile.TemporaryDirectory() as tmp:
            d = self.fixtures(Path(tmp))
            f = d / 'AppRuleChecker$j.smali'
            f.write_text(f.read_text().replace('.field private e:', '.field private x:'))
            with self.assertRaises(ValueError):
                patch(d)


if __name__ == '__main__':
    unittest.main()
