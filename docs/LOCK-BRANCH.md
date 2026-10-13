# Lock branch

This branch replaces the standalone KernelSU-Next test module with a ROM package. `bin/package/LOCK/update.sh` installs an ARM64 `hypermos-resetprop` binary into `system_ext/xbin` and a separate `system/etc/init/tnm.rc` file. Packaging refuses to overwrite a different existing `tnm.rc` or reuse an image tree containing the old `hypermos-lock.rc` trigger.

During `post-fs-data`, init executes three synchronous, one-shot property writes:

```ini
ro.boot.flash.locked=1
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
```

Kaorios remains enabled with its existing `initGenerateSoftwareKeyPair` and `CertificateChainIfNeeded` hooks. The LOCK package does not patch framework DEX, AVB metadata, `boot`, `vendor_boot`, or `init_boot`; it also does not append commands to the stock `init.rc`. Its SELinux change is limited to the bundled resetprop executable.

Device testing on build #129 found that the init action was parsed but all three commands were denied with `execute_no_trans`: the binary had the generic `system_file` label. The package now assigns only `/system_ext/xbin/hypermos-resetprop` the dedicated `tnm_resetprop_exec` type and permits init to execute that type without a domain transition. It removes stale precompiled policy files so Android compiles the updated split CIL during boot. No permission is granted to the generic `system_file` type.

The Kaorios build patch changes Keystore call sites and related framework/services code; the LOCK package installs a binary and init trigger. The bundled Kaorios DEX contains none of the three boot property names. This static check finds no direct write conflict or hook replacement, but cannot prove how Kaorios behaves on a booted device. The `Lock` branch also enables the same TNMFramework, TNM APK, and RYU performance/thermal checks used on `main`.

Like the old ResetProp package, this uses blocking `exec u:r:init:s0 root root` commands at `post-fs-data`. It does not start a persistent process. The trigger is isolated in a new init file; the old package appended to stock `init.rc`, added a SELinux rule, and invoked `DISABLEavb.sh` again. Only the three properties shown above are written.

Compared with the KernelSU-Next module, this ROM package does not require a module installation or the KernelSU module loader. It is present for every build that runs `patchpackage.sh`, including stock root mode differences. The tradeoff is that removing it requires rebuilding or editing the ROM; it is no longer independently disableable from KernelSU Manager.

Because init waits for each `exec` to finish, a hung binary can delay or block boot. This branch must be boot-tested on HAOTIAN before merging. Check all three `getprop` values, Duck Detector, `/proc/bootconfig`, `/proc/cmdline`, Kaorios attestation, KernelSU-Next root, TNM, PowerKeeper, thermal controls, and Notification Fix. A matching property screen does not change the real bootloader state or hardware Root of Trust.
