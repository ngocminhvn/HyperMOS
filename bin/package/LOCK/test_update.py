#!/usr/bin/env python3
"""LOCK installer regression tests. Native compilation is mocked only in unit fixtures."""
import hashlib
import os
from pathlib import Path
import shutil
import stat
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent))
import integrate as lock

BINARY = Path(__file__).resolve().parent / 'system_ext/xbin/ryu_helper'


class LockIntegrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='lock-install-test-')
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.images = self.work / 'images'
        self.init = self.put('system/system/etc/init/hw/init.rc',
                            b'# Xiaomi original\non post-fs\n    mkdir /mnt/example 0755 root root\n')
        self.original_init = self.init.read_bytes()
        self.policy = self.put('system_ext/etc/selinux/system_ext_sepolicy.cil', b'; original CIL\n')
        self.contexts = [self.put(p, b'/system_ext(/.*)? u:object_r:system_file:s0\n') for p in
                         ['config/system_ext_file_contexts',
                          'system_ext/etc/selinux/system_ext_file_contexts']]
        self.dac = self.put('config/system_ext_fs_config', b'system_ext 0 0 0755\n')
        self.put('vendor/etc/selinux/precompiled_sepolicy', b'old compiled policy')
        self.put('odm/etc/selinux/precompiled_sepolicy.plat_sepolicy_and_mapping.sha256', b'old digest')
        self.put('system/system/etc/init/tnm.rc', b'on boot\n    setprop tnm.ready 1\n')
        for relative, target in [
            ('bin/linker64', '/apex/com.android.runtime/bin/linker64'),
            ('lib64/libc.so', '/apex/com.android.runtime/lib64/bionic/libc.so'),
            ('lib64/libdl.so', '/apex/com.android.runtime/lib64/bionic/libdl.so'),
        ]:
            path = self.images / 'system/system' / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.symlink_to(target)
        self.helper = self.images / 'system_ext/xbin/ryu_helper'
        self.helper.parent.mkdir()
        self.binary = self.work / 'ryu_helper'
        shutil.copyfile(BINARY, self.binary)
        self.compiler = patch.object(lock, 'verify_policy', side_effect=self.compile_candidate).start()
        self.init_verifier = patch.object(lock, 'verify_init', return_value={'status': 'unavailable'}).start()
        self.addCleanup(patch.stopall)

    def put(self, relative, data):
        path = self.images / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        return path

    def compile_candidate(self, root, report, candidate):
        self.assertEqual(root, self.images)
        self.assertEqual(candidate.read_bytes().count(lock.POLICY_BLOCK), 1)
        return {'returncode': 0, 'unit_test_mock': True}

    def apply(self, check=False):
        return lock.integrate(self.images, self.binary, self.work / 'reports', check)

    def snapshot(self):
        return {str(p.relative_to(self.images)):
                ('symlink', os.readlink(p)) if p.is_symlink() else
                (p.read_bytes(), stat.S_IMODE(p.stat().st_mode))
                for p in self.images.rglob('*') if p.is_file() or p.is_symlink()}

    def assert_rejected_without_writes(self):
        before = self.snapshot()
        with self.assertRaises((ValueError, OSError)):
            self.apply()
        self.assertEqual(self.snapshot(), before)

    def test_install_preserves_xiaomi_and_tnm_and_stages_exact_donor_action(self):
        tnm = (self.images / 'system/system/etc/init/tnm.rc').read_bytes()
        result = self.apply()
        self.assertEqual(self.init.read_bytes(), self.original_init + b'\n' + lock.INIT_BLOCK)
        self.assertEqual(self.init.read_bytes().count(lock.RUNTIME.encode()), 9)
        self.assertNotIn(b'persist.sys.projectryu.blacklist', self.init.read_bytes())
        self.assertEqual(self.helper.read_bytes(), self.binary.read_bytes())
        self.assertEqual(stat.S_IMODE(self.helper.stat().st_mode), 0o755)
        self.assertIn(b'system_ext/xbin/ryu_helper 0 2000 0755\n', self.dac.read_bytes())
        for path in self.contexts:
            self.assertIn((lock.RUNTIME + ' ' + lock.CONTEXT).encode(), path.read_bytes())
        self.assertEqual((self.images / 'system/system/etc/init/tnm.rc').read_bytes(), tnm)
        self.assertFalse(list(self.images.rglob('precompiled_sepolicy*')))
        self.assertEqual(result['helper_commands'], 9)
        self.assertFalse(result['runtime_tested'])

    def test_repeated_install_and_check_do_not_change_image(self):
        self.apply()
        first = self.snapshot()
        self.apply()
        self.apply(check=True)
        self.assertEqual(self.snapshot(), first)

    def test_compile_failure_keeps_original_image_and_caches(self):
        self.compiler.side_effect = None
        self.compiler.return_value = {'returncode': 1}
        self.assert_rejected_without_writes()

    def test_native_init_failure_rolls_back_installation(self):
        self.init_verifier.return_value = {'status': 'failed'}
        self.assert_rejected_without_writes()

    def test_changed_or_duplicate_managed_block_is_rejected(self):
        self.apply()
        self.init.write_bytes(self.init.read_bytes() + lock.INIT_BLOCK)
        self.assert_rejected_without_writes()

    def test_legacy_standalone_trigger_is_rejected(self):
        self.put('system/system/etc/init/tnm.rc', b'on post-fs\n    exec -- /system_ext/xbin/ryu_helper\n')
        self.assert_rejected_without_writes()

    def test_unmanaged_appended_action_is_rejected(self):
        self.init.write_bytes(self.original_init + b'on post-fs\n    exec -- /system_ext/xbin/ryu_helper\n')
        self.assert_rejected_without_writes()

    def test_unmanaged_custom_type_is_rejected(self):
        self.policy.write_bytes(b'(type ryu_helper_exec)\n')
        self.assert_rejected_without_writes()

    def test_conflicting_context_is_rejected(self):
        self.contexts[0].write_bytes(b'/system_ext/xbin/ryu_helper u:object_r:system_file:s0\n')
        self.assert_rejected_without_writes()

    def test_metadata_symlink_outside_image_is_rejected(self):
        outside = self.work / 'host-contexts'
        outside.write_bytes(b'host file')
        self.contexts[0].unlink()
        self.contexts[0].symlink_to(outside)
        self.assert_rejected_without_writes()

    def test_damaged_bundled_helper_is_rejected(self):
        self.binary.write_bytes(self.binary.read_bytes() + b'x')
        self.assert_rejected_without_writes()

    def test_missing_bionic_dependency_is_rejected(self):
        (self.images / 'system/system/lib64/libdl.so').unlink()
        self.assert_rejected_without_writes()

    def test_partial_installation_is_rejected(self):
        self.init.write_bytes(self.original_init + lock.INIT_BLOCK)
        self.assert_rejected_without_writes()

    def test_check_fails_for_missing_or_modified_staging(self):
        with self.assertRaises(ValueError):
            self.apply(check=True)
        self.apply()
        self.dac.write_bytes(self.dac.read_bytes().replace(b'0 2000 0755', b'0 0 0644'))
        with self.assertRaises(ValueError):
            self.apply(check=True)

    def test_donor_payload_hash(self):
        self.assertEqual(hashlib.sha256(BINARY.read_bytes()).hexdigest(), lock.HASH)


if __name__ == '__main__':
    unittest.main(verbosity=2)
