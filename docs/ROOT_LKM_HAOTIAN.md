# HyperMOS HAOTIAN — SukiSU Ultra v4.2.1 (LKM)

The HyperMOS ROM builder supports two modes, selected in `.github/workflows/build.yml`:
- `root_mode=root` (default): use SukiSU Ultra **v4.2.1** from pinned upstream source, patch stock `init_boot.img`, and **bundle the matching SukiSU manager APK for manual installation**.
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

## Manager APK — no automatic installation or boot-time checks

The manager is pinned to the official SukiSU Ultra v4.2.1 release and
packaged as `Root/RootManager.apk` inside the ROM ZIP.
The installer deliberately does **not** run at startup. There is no
`sys.boot_completed` trigger, `/data/adb` hook, package query, APK install
attempt, background service, or automatic reinstall after removal.

To install it as an ordinary user app after flashing the rooted ROM,
extract `Root/RootManager.apk` from the ROM ZIP to your current directory and run:

```sh
adb install -r RootManager.apk
adb shell pm path --user 0 com.sukisu.ultra
```

The installed path must start with `/data/app/` (not `/product/app/`);
the SukiSU kernel/root provider remains integrated in patched `init_boot.img`
independently of the APK's installation status.
## ZIP output and recovery

Root ZIPs end in `_SUKISU.zip`; stock ZIP names are unchanged. A rooted
ROM ZIP has these top-level entries:
- `FLASH.bat` — Windows fastboot script (does not use legacy `.install` metadata);
- `Root/` — contains `init_boot.stock.img` (original firmware backup),
  `ROOT-INFO.txt` (root build metadata), and `RootManager.apk` (official SukiSU
  v4.2.1 manager for manual installation as a user app);
- `images/` — includes SukiSU-patched `init_boot.img` and other firmware images;
- `META-INF/` — bundled flash tools/metadata;
- `super/` — contains `super.img`.

The legacy `HAOTIAN.install` file is not generated or included. The old
`RootBackup/` directory and loose `RootManager.apk` / `ROOT-INFO.txt`
at the ZIP root are not included.

This integration does **not** include SUSFS, a custom GKI kernel replacement,
KPM, changed bootloader state, or app/identity spoofing.

**Bootability and runtime root require testing on the Xiaomi 15 Pro.** A successful
build and static ramdisk validation do not prove the device boots. Keep the
matching stock `init_boot.img` and know the stock recovery procedure before
testing a new root provider.
