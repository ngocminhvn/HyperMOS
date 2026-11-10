# HyperOS 4 Kashi mods

The OS4 build installs fixed snapshots from `bin/modfile/ModApp/Kashi/` and does **not** run Magisk/KernelSU installation scripts or download modules during ROM builds.

## Active OS4 integrations

- **App Vault V5**, **ColorOS Control Center V4**, **Screenshot V1.1** and **Theme Manager V7** are unchanged.
- **Rust Launcher**: [Mods-Center/HyperOS-Rust-Launcher-Mod](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod) replaces the **old Kashi Launcher V7.5F on OS4 only**. Initial release v1.0 is based on `com.miui.home` 8.01.02.9239.
- **HyperLauncherExt** (`com.miui.home.kashi.ext`) is installed beside it as a privileged system app. Both upstream privileged allowlist XML files are copied into `product/etc/permissions`.

`FreeStyle_CC_mod_V1` is an alternative Control Center and remains inactive. `HyperOS_SecurityV7` stays inactive: SecurityCountdown independently patches the stock Security Center as before.

## Release updates

The **existing** `.github/workflows/update-kashi-apps.yml` tracks the latest stable upstream release of each Kashi source, including `Mods-Center/HyperOS-Rust-Launcher-Mod`. It validates ZIP integrity, package names and required files, plus GitHub's SHA-256 asset digest for the Rust release, before committing the new `HyperOS4_RustLauncherMod_*.zip` to `bin/modfile/ModApp/Kashi/` on `main`. Old snapshots of the same family are replaced, never accumulated. Its initial push trigger is scoped to this OS4 integration; later use **Actions → Update Kashi Apps → Run workflow** for updates.

The OS4 build selects exactly one local `HyperOS4_RustLauncherMod_*.zip` using the shared `modscenter_prepare_fixed` helper. OS3 continues to use the original `HyperOS_Launcher*.zip`. Do not rename the Rust ZIP to a legacy launcher filename.

## Preflight and ROM file layout

Before replacing launcher files, `OS4/kashimod.sh` requires Android 17, `hyos_spawner` and the HyperOS 4 native runtime libraries (`libhyper_os_*.so`). It checks the APK package IDs, three essential embedded native libraries, and parses the two permission XML files. If incompatible it fails the build, rather than falling back to the dex-based launcher.

ROM output:
- `product/priv-app/MiuiHome/MiuiHome.apk` and its app-local native `lib/arm64/*.so`.
- `product/priv-app/HyperLauncherExt/HyperLauncherExt.apk`.
- `product/etc/permissions/privapp-permissions-com.miui.home-mod.xml`.
- `product/etc/permissions/privapp-permissions-com.miui.home.kashi.ext.xml`.

Legacy `MiuiHomeLauncherResOverlay.apk` and the dex-launcher `privapp_whitelist_com.miui.home.xml` are removed on OS4 only.

## Safety

The patched Rust Launcher APK does **not** have Xiaomi's original valid APK signature. Existing HyperMOS CorePatch A17 runs later in `bin/package/patchpackage.sh`. We do **not** re-sign the APK or alter CorePatch, Kaorios, AVB or `.github/workflows/build.yml`. Boot and Android PackageManager acceptance on OS4 China and EU must still be tested on an unlocked, recoverable device; successful CI builds alone do not establish runtime compatibility.

Most HyperLauncherExt controls work without root when installed as a privileged app. Applying icon packs without root may require an additional SELinux allowlist for `/data/system/theme`; that policy relaxation is intentionally not added.
