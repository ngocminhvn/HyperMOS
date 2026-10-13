# HAOTIAN boot property synchronization

Rooted builds stage `sync_boot_properties.sh` in `system_ext/bin` and its init trigger in `system_ext/etc/init`. Android init starts the script in the background only when `sys.boot_completed=1`. It uses KernelSU-Next's `resetprop -n` to set:

```ini
ro.boot.flash.locked=1
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
```

The task exits if the KernelSU-Next binary is unavailable or cannot set a property. It never runs in `post-fs-data`, modifies AVB metadata, changes SELinux policy, or edits the stock `init.rc`. Stock builds do not stage the task. Kaorios hooks are unchanged.

This is an Android property override. It does not change the bootloader's real lock state, the kernel bootconfig/cmdline, AVB verification, or the hardware root of trust. A matching Duck Detector screen is not evidence that the device is securely locked.

The former `ResetProp/update.sh` in the upstream build tool sourced `DISABLEavb.sh`, appended blocking `exec` commands to stock `init.rc` at `post-fs-data`, and appended SELinux CIL rules. This integration does none of those operations. The old script also did not set `ro.boot.flash.locked`.

## Device validation before merging into main

1. Remove the manually installed `hypermos_boot_state_sync_test` module and reboot; verify the three properties return to their baseline values.
2. Build the HAOTIAN rooted ROM from the test branch and inspect the packed `system_ext` image for `hypermos-sync-boot-properties` and `hypermos-sync-boot-properties.rc`.
3. Flash only with the user's normal manual recovery process. Confirm the ROM boots, then read the three properties with `adb shell getprop` and compare Duck Detector.
4. Read `/proc/bootconfig` and `/proc/cmdline` separately. Check `logcat -d -s HyperMOSBootState` for success or failure. Verify Kaorios attestation with a fresh challenge and an external chain verifier.
5. Check KernelSU-Next, TNM, PowerKeeper, thermal controls, and Notification Fix on the device.

If this task causes a device-specific issue, boot a known working ROM image or a build without this change. Do not use `fastboot flashing lock` or `fastboot oem lock`.
