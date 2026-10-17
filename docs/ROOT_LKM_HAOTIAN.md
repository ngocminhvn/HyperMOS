# HyperMOS HAOTIAN — SukiSU Ultra v4.2.1 (LKM)

The HyperMOS ROM builder supports two modes, selected in `.github/workflows/build.yml`:
- `root_mode=root` (default): use SukiSU Ultra **v4.2.1** from pinned upstream source, patch stock `init_boot.img`, and **install the matching SukiSU manager as a normal user app after first boot**.
- `root_mode=stock`: preserve stock `init_boot.img` and do not insert the SukiSU manager.

## Root source, KMI and integrity

Source: https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/tag/v4.2.1

The Actions job builds from the pinned signed upstream tag `v4.2.1` at commit
`fd2a85151c8312fd9b4237db9ba827dcea692228`, not its mutable `main` branch.

The stock ROM kernel KMI is detected from `boot.img` and vendor/odm module
metadata using `bin/root/detect_kernel_kmi.py`. Currently only HAOTIAN's
verified `android15-6.6` KMI is supported. Build aborts if detection differs.

`bin/root/prepare_sukisu.sh` compiles:
- `kernelsu.ko`: ARM64 GKI `android15-6.6` using the upstream DDK image.
- `ksuinit`: ARM64 Android from the same upstream tag.
- `ksud`: Linux x86_64 from that tag for offline image patching.

This intentionally costs more build time than using prebuilt KernelSU Next assets,
but avoids mixing the SukiSU **v4.2.1 manager** with a mismatched older kernel
module. Version identifiers in `ksud` rely on upstream Git history and must not
be synthesized with a shallow clone.

The SukiSU manager is pinned to official asset
`SukiSU_v4.2.1_40994-release.apk`. Its SHA-256 is verified against the
official release metadata:

`c7f69280cf468e8415c585ff31f963d0147386831217a1e89b822afddc5f40ed`

The builder preserves stock `boot.img` and patches **only** `init_boot.img`,
using upstream `ksud boot-patch --module --init`. It unpacks the result and
refuses to package an empty, unchanged, or unreadable image.

## Manager installation — ordinary user app (NOT system app)

**Why:** SukiSU v4.2.1's `kernel/manager/throne_tracker.c` scans
`/data/app` to recognize the built-in manager UID/signature. Placing
`SukiSUUltra.apk` directly in `/product/app` causes the manager to be seen
by Android as a system app while SukiSU may not grant it Manager privileges.
Clearing the app data does not change this path. Reinstalling a user APK works
because its actual installed APK resides in `/data/app`.

In `root_mode=root`, the ROM carries a **verified, read-only payload**, NOT
a system-scanned app, under:

`/system_ext/etc/hypermos-root/RootManager.apk`

The ROM also stages:
- `/system_ext/etc/hypermos-root/install-user-manager.sh` — one-shot installer.
- `/system_ext/bin/hypermos-root-manager-stage` — lightweight staging helper.
- `/system_ext/etc/init/hypermos-root-manager.rc` — copies the installer hook
  into SukiSU's `/data/adb/boot-completed.d` at `post-fs-data`.

After Android's PackageManager is ready, SukiSU's existing `boot-completed.d`
runner executes the hook. It verifies the pinned APK SHA-256 and requests an
ordinary PackageManager install for user 0. **The resulting installed app path
must begin with `/data/app/`**. It does not auto-grant root privileges or
automatically uninstall an existing APK.

The helper writes `/data/adb/hypermos-root/sukisu-manager-installed` and
removes its one-time hook only once a user-app installation is confirmed.
Subsequent boots do not reinstall SukiSU. If the app is already installed under
`/data/app`, the hook leaves it alone and marks installation complete. If
PackageManager/SELinux prevents installation, it logs an error and exits without
blocking boot; on a later boot the hook can retry.

**Dirty flash caveat:** The previous ROM included SukiSU in `/product/app`.
The new root ROM no longer contains that system app. PackageManager may require
a reboot before it stops treating the old package as a system app. The installer
will refuse to silently update a non-user APK path. If an installed APK has a
conflicting signature, uninstalling it manually may be necessary; the installer
never deletes user app data without consent.

### Runtime checks

```sh
adb shell pm path --user 0 com.sukisu.ultra
adb shell dumpsys package com.sukisu.ultra | grep -E 'codePath|pkgFlags|PRIVATE_FLAG'
adb shell su -c id
adb shell logcat -d -s HyperMOSRoot
```

Expected manager APK path: `package:/data/app/...`, not `/product/app/...`.
The SukiSU manager should report that its version matches the running kernel.

This mechanism is **code-reviewed but not yet validated on a booted HAOTIAN**;
an init/SELinux restriction or delayed SukiSU `boot-completed.d` callback may
require a device-specific adjustment. The ROM ZIP also retains `RootManager.apk`
for manual install if the one-time automatic installer cannot run.

## ZIP output and recovery

Root ZIPs end in `_SUKISU.zip`; stock ZIP names are unchanged. A root ZIP contains:
- `images/init_boot.img` — SukiSU-patched init_boot;
- `RootBackup/init_boot.stock.img` — original firmware init_boot;
- `RootManager.apk` — official SukiSU v4.2.1 APK as an additional manual fallback;
- `ROOT-INFO.txt` — KMI, upstream commit, manager name and hashes.

This integration does **not** include SUSFS, a custom GKI kernel replacement,
KPM, changed bootloader state, or app/identity spoofing.

**Bootability and runtime root require testing on the Xiaomi 15 Pro.** A successful
build and static ramdisk validation do not prove the device boots. Keep the
matching stock `init_boot.img` and know the stock recovery procedure before
testing a new root provider.
