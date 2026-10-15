#!/usr/bin/env python3
"""Offline LOCK regression checks. Never execute the bundled ARM64 helper."""
import hashlib
import pathlib
import shutil
import struct
import subprocess
import tempfile
import unittest

PACKAGE = pathlib.Path(__file__).resolve().parent
SCRIPT = PACKAGE / "update.sh"
BINARY = PACKAGE / "system_ext/xbin/ryu_helper"
EXPECTED = "6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df"


class LockAuditTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="hypermos-lock-")
        self.addCleanup(self.temp.cleanup)
        self.work = pathlib.Path(self.temp.name)
        self.images = self.work / "build/baserom/images"
        self.stock = self.images / "system/system/etc/init/hw/init.rc"
        self.put("system/system/etc/init/hw/init.rc",
                 "# Xiaomi fixture\non post-fs\n    mkdir /mnt/test 0755 root root\n")
        self.put("system_ext/etc/selinux/system_ext_sepolicy.cil", "; original policy\n")
        self.put("system_ext/etc/selinux/system_ext_file_contexts",
                 "/system_ext(/.*)? u:object_r:system_file:s0\n")
        self.put("config/system_ext_file_contexts",
                 "/system_ext(/.*)? u:object_r:system_file:s0\n")
        self.put("vendor/etc/selinux/precompiled_sepolicy", "original precompiled policy")
        self.put("odm/etc/selinux/precompiled_sepolicy.plat_sepolicy_and_mapping.sha256",
                 "original policy digest")
        self.binary = self.work / "bin/package/LOCK/system_ext/xbin/ryu_helper"
        self.binary.parent.mkdir(parents=True)
        shutil.copyfile(BINARY, self.binary)
        # A log-only substitute, so no other ROM component is invoked.
        (self.work / "functions.sh").write_text(
            'error() { echo "$*" >&2; }\n'
            'mods() { echo "$*"; }\ninfo() { echo "$*"; }\n')

    def put(self, relative, text):
        path = self.images / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def snapshot(self):
        return {
            str(p.relative_to(self.images)): (p.read_bytes(), p.stat().st_mode)
            for p in self.images.rglob("*") if p.is_file()
        }

    def run_audit(self, success, diagnostic=None):
        before = self.snapshot()
        for _ in range(2):
            result = subprocess.run(
                ["bash", str(SCRIPT)], cwd=self.work, text=True,
                capture_output=True, timeout=30, check=False)
            self.assertEqual(result.returncode == 0, success,
                             result.stdout + result.stderr)
            if diagnostic:
                self.assertIn(diagnostic, result.stderr)
            self.assertEqual(self.snapshot(), before)

    def test_payload_identity_and_architecture(self):
        payload = BINARY.read_bytes()
        self.assertEqual(hashlib.sha256(payload).hexdigest(), EXPECTED)
        self.assertEqual(payload[:6], b"\x7fELF\x02\x01")  # ELF64, little endian
        self.assertEqual(struct.unpack_from("<H", payload, 18)[0], 183)  # AArch64

    def test_clean_repeat_preserves_init_selinux_and_unrelated_tnm(self):
        self.put("system/system/etc/init/tnm.rc", "on boot\n    setprop tnm.ready 1\n")
        self.run_audit(True)
        self.assertFalse((self.images / "system_ext/xbin/ryu_helper").exists())

    def test_standalone_lock_trigger(self):
        self.put("system/system/etc/init/tnm.rc",
                 "on post-fs\n    exec -- /system_ext/xbin/ryu_helper -n ro.boot.flash.locked 1\n")
        self.run_audit(False, "existing helper")

    def test_appended_duplicate_actions(self):
        self.stock.write_text(self.stock.read_text() +
                              "\non post-fs\n    exec -- /system_ext/xbin/ryu_helper\n" * 2)
        self.run_audit(False, "existing helper")

    def test_legacy_filename_even_when_empty(self):
        self.put("system/system/etc/init/hypermos-lock.rc", "")
        self.run_audit(False, "existing helper")

    def test_stale_cil(self):
        self.put("system_ext/etc/selinux/system_ext_sepolicy.cil", "(type ryu_helper_exec)\n")
        self.run_audit(False, "existing helper")

    def test_legacy_cil(self):
        self.put("system_ext/etc/selinux/system_ext_sepolicy.cil", "(type tnm_resetprop_exec)\n")
        self.run_audit(False, "existing helper")

    def test_stale_image_context(self):
        self.put("system_ext/etc/selinux/system_ext_file_contexts",
                 "/system_ext/xbin/ryu_helper u:object_r:ryu_helper_exec:s0\n")
        self.run_audit(False, "existing helper")

    def test_stale_repack_context(self):
        self.put("config/system_ext_file_contexts",
                 "/system_ext/xbin/ryu_helper u:object_r:ryu_helper_exec:s0\n")
        self.run_audit(False, "existing helper")

    def test_stale_installed_payloads(self):
        for name in ("ryu_helper", "hypermos-resetprop"):
            with self.subTest(name=name):
                path = "system_ext/xbin/" + name
                self.put(path, "old payload")
                self.run_audit(False, "existing helper")
                (self.images / path).unlink()

    def test_missing_stock_init(self):
        self.stock.unlink()
        self.run_audit(False, "stock /system/etc/init/hw/init.rc missing")

    def test_stale_repack_dac_metadata(self):
        self.put("config/system_ext_fs_config",
                 "system_ext/xbin/ryu_helper 0 0 755 capabilities=0x0\n")
        self.run_audit(False, "existing helper")

    def test_stale_precompiled_policy(self):
        self.put("vendor/etc/selinux/precompiled_sepolicy",
                 "binary-policy\x00ryu_helper_exec\x00")
        self.run_audit(False, "existing helper")

    def test_image_metadata_symlink_cannot_escape_tree(self):
        outside = self.work / "outside_file_contexts"
        outside.write_text("host file, not part of extracted ROM\n")
        metadata = self.images / "config/system_ext_file_contexts"
        metadata.unlink()
        metadata.symlink_to(outside)
        self.run_audit(False, "outside image tree")
        metadata.unlink()
        metadata.write_text("original context\n")
        external_init = self.work / "external_init"
        (external_init / "hw").mkdir(parents=True)
        (external_init / "hw/init.rc").write_text("on post-fs\n    setprop test.ready 1\n")
        shutil.rmtree(self.stock.parent.parent)
        self.stock.parent.parent.symlink_to(external_init, target_is_directory=True)
        self.run_audit(False, "outside image tree")

    def test_missing_system_ext(self):
        shutil.rmtree(self.images / "system_ext")
        self.run_audit(False, "system_ext tree missing")

    def test_missing_binary(self):
        self.binary.unlink()
        self.run_audit(False, "bundled RYU helper missing")

    def test_changed_binary(self):
        self.binary.write_bytes(self.binary.read_bytes() + b"x")
        self.run_audit(False, "RYU helper changed")


if __name__ == "__main__":
    unittest.main(verbosity=2)
