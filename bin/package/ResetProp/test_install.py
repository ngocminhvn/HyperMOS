#!/usr/bin/env python3
"""Validate fake-lock installation, policy compilation and repacking labels."""
import importlib.util
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import sys

spec = importlib.util.spec_from_file_location("fake_lock", Path(__file__).with_name("install.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
REPO = Path(__file__).resolve().parents[3]
POLICY = """
(class file (read write open getattr execute map entrypoint))
(class dir (search read open getattr))
(class process (transition sigchld))
(class capability (dac_override))
(classorder (file dir process capability))
(sid kernel)
(sidorder (kernel))
(sensitivity s0)
(sensitivityorder (s0))
(level low (s0))
(levelrange low_low (low low))
(user system_u)
(role r)
(role object_r)
(userrole system_u r)
(userrole system_u object_r)
(userlevel system_u low)
(userrange system_u low_low)
(type init)
(roletype r init)
(context kernel_context (system_u r init low_low))
(sidcontext kernel kernel_context)
(typeattribute domain)
(typeattribute coredomain)
(typeattribute file_type)
(typeattribute exec_type)
(typeattribute system_file_type)
(typeattributeset domain (init))
(type system_file)
(type system_lib_file)
(type properties_device)
(type property_info)
(type properties_serial)
(type bootloader_prop)
(type secureboot_prop)
(allow init init (process (sigchld)))
"""


def fixture(root):
    images = root / "build/baserom/images"
    files = {
        "system/system/etc/selinux/plat_sepolicy.cil": POLICY,
        "system/system/etc/selinux/mapping/202504.cil": "(typeattribute mapping_fixture)\n",
        "system/system/etc/selinux/plat_property_contexts":
            "ro.boot. u:object_r:bootloader_prop:s0 prefix string\n"
            "ro.secureboot.lockstate u:object_r:secureboot_prop:s0 exact string\n",
        "vendor/etc/selinux/plat_sepolicy_vers.txt": "202504\n",
        "vendor/etc/selinux/plat_pub_versioned.cil": "(typeattribute versioned_fixture)\n",
        "vendor/etc/selinux/vendor_sepolicy.cil": "(typeattribute vendor_fixture)\n",
        "system_ext/etc/selinux/system_ext_sepolicy.cil": "; stock system_ext policy\n",
        "system_ext/etc/selinux/system_ext_sepolicy_and_mapping.sha256": "stock-fingerprint\n",
        "config/system_ext_file_contexts": "/system_ext/xbin/xeutoolbox u:object_r:system_file:s0\n",
        "system_ext/etc/selinux/system_ext_file_contexts": "/system_ext/xbin/xeutoolbox u:object_r:system_file:s0\n",
        "product/etc/cust_prop_white_keys_list": "stock.key\nro.boot.flash.locked\n",
        "vendor_boot.img": "untouched boot image\n",
        "system/system/build.prop": "ro.build.type=user\n",
        "vendor/build.prop": "stock=vendor\n",
        "product/build.prop": "stock=product\n",
        "system_ext/build.prop": "stock=system_ext\n",
    }
    for relative, contents in files.items():
        path = images / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents)
    payload = root / "bin/package/ResetProp/system_ext/xbin/xeutoolbox"
    payload.parent.mkdir(parents=True)
    shutil.copyfile(Path(__file__).parent / "system_ext/xbin/xeutoolbox", payload)
    return images


class InstallTests(unittest.TestCase):
    def test_property_context_specificity_and_conflicts(self):
        with tempfile.TemporaryDirectory() as temp:
            file = Path(temp) / "contexts"
            file.write_text("* u:object_r:default_prop:s0\nro.boot. u:object_r:bootloader_prop:s0 prefix\nro.boot.x u:object_r:specific_prop:s0 exact\n")
            self.assertEqual(module.select_context("ro.boot.x", [file]), "specific_prop")
            self.assertEqual(module.select_context("ro.boot.y", [file]), "bootloader_prop")
            file.write_text(file.read_text() + "ro.boot.x u:object_r:other_prop:s0 exact\n")
            with self.assertRaises(ValueError):
                module.select_context("ro.boot.x", [file])

    @unittest.skipUnless(shutil.which("secilc"), "requires secilc")
    def test_compile_install_and_repacking_preserve_execution_label(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            images = fixture(root)
            protected = {path: path.read_bytes() for path in images.rglob("build.prop")}
            protected[images / "vendor_boot.img"] = (images / "vendor_boot.img").read_bytes()
            module.install(root)
            rc = (images / "system_ext/etc/init/hypermos-fake-lock.rc").read_text()
            self.assertIn("on property:sys.boot_completed=1", rc)
            self.assertIn("on post-fs-data", rc)
            self.assertIn("    timeout_period 5", rc)
            self.assertIn("    disabled\n    oneshot", rc)
            self.assertIn("    capabilities DAC_OVERRIDE\n", rc)
            self.assertEqual(rc.count("    exec_start hypermos_fake_lock"), 2)
            self.assertNotIn("exec u:r:init:s0", rc)
            self.assertIn("xeutoolbox -n -f /system_ext/etc/hypermos-fake-lock.prop", rc)
            props = (images / "system_ext/etc/hypermos-fake-lock.prop").read_text()
            self.assertEqual(props, "".join(f"{key}={value}\n" for key, value in module.PROPERTIES.items()))
            self.assertEqual(set(module.PROPERTIES), {"ro.boot.flash.locked", "ro.boot.vbmeta.device_state",
                             "ro.boot.verifiedbootstate", "ro.secureboot.lockstate"})
            for path, original in protected.items():
                self.assertEqual(path.read_bytes(), original)
            whitelist = (images / "product/etc/cust_prop_white_keys_list").read_text().splitlines()
            for key in module.PROPERTIES:
                self.assertEqual(whitelist.count(key), 1)
            self.assertEqual(module.inject_xiaomi_prop_whitelist(images), 0)
            self.assertIn("stock.key", whitelist)
            cil = (images / "system_ext/etc/selinux/system_ext_sepolicy.cil").read_text()
            self.assertNotIn("execute_no_trans", cil)
            self.assertNotIn("# HyperMOS", cil)
            self.assertNotIn("property_service", cil)  # -n writes the mapped area directly
            self.assertIn("(allow hypermos_fake_lock bootloader_prop (file (read write open getattr map)))", cil)
            self.assertIn("(allow hypermos_fake_lock secureboot_prop (file (read write open getattr map)))", cil)
            self.assertIn("(allow hypermos_fake_lock hypermos_fake_lock (capability (dac_override)))", cil)
            self.assertIn("/system_ext/xbin/xeutoolbox u:object_r:hypermos_fake_lock_exec:s0",
                          (images / "system_ext/etc/selinux/system_ext_file_contexts").read_text())
            self.assertNotEqual((images / "system_ext/etc/selinux/system_ext_sepolicy_and_mapping.sha256").read_text(), "stock-fingerprint\n")
            subprocess.run([sys.executable, str(REPO / "bin/fix_selinux.py"), str(images / "system_ext"),
                            str(images / "config/system_ext_fs_config"), str(images / "config/system_ext_file_contexts")],
                           check=True, stdout=subprocess.DEVNULL)
            self.assertIn("/system_ext/xbin/xeutoolbox u:object_r:hypermos_fake_lock_exec:s0", (images / "config/system_ext_file_contexts").read_text())
            self.assertIn("system_ext/xbin/xeutoolbox 0 0 0755", (images / "config/system_ext_fs_config").read_text())
            with self.assertRaises(ValueError):
                module.install(root)

    @unittest.skipUnless(shutil.which("secilc"), "requires secilc")
    def test_invalid_policy_does_not_install_or_change_fingerprint(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            images = fixture(root)
            original = images / "system_ext/etc/selinux/system_ext_sepolicy.cil"
            original.write_text("(invalid policy syntax)\n")
            with self.assertRaises(ValueError):
                module.install(root)
            self.assertEqual(original.read_text(), "(invalid policy syntax)\n")
            self.assertFalse((images / "system_ext/xbin/xeutoolbox").exists())
            self.assertFalse((images / "system_ext/etc/init/hypermos-fake-lock.rc").exists())
            self.assertEqual((images / "system_ext/etc/selinux/system_ext_sepolicy_and_mapping.sha256").read_text(), "stock-fingerprint\n")

    @unittest.skipUnless(shutil.which("secilc"), "requires secilc")
    def test_unused_backup_context_does_not_affect_runtime_policy(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            images = fixture(root)
            backup = images / "system_ext/etc/backup_property_contexts"
            backup.write_text("ro.boot.flash.locked u:object_r:nonexistent_prop:s0 exact string\n")
            module.install(root)
            self.assertNotIn("nonexistent_prop", (images / "system_ext/etc/selinux/system_ext_sepolicy.cil").read_text())


if __name__ == "__main__":
    unittest.main()
