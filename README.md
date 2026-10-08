# HyperMOS

HyperMOS is a Xiaomi HyperOS ROM build and modification project designed to automate ROM unpacking, customization, patching, repacking, and distribution through GitHub Actions.

## Tested Device

| Item | Information |
| --- | --- |
| Device | **Xiaomi 15 Pro** |
| Variant | **China (CN)** |
| Codename | **haotian** |
| Test status | **Tested / Primary test device** |
| ROM base | **Xiaomi HyperOS China ROM** |

> Xiaomi 15 Pro (China) is currently used as the primary device for testing HyperMOS builds.

## Repository Information

- **Project:** HyperMOS
- **Current build script version:** `1.3PS`
- **Platform:** Xiaomi HyperOS
- **Supported ROM region:** **China (CN) only**
- **Build environment:** GitHub Actions / Ubuntu
- **Build input:** Xiaomi China ROM package URL
- **Supported ROM layouts:** `payload.bin`, `super.img`, and `*.new.dat.br`
- **Build process:** Unpack → Debloat → Apply mods → Apply patches → Repack
- **Upload options:** Google Drive via rclone or Pixeldrain
- **Notifications:** Build status and result notifications are supported through Telegram

## Fastboot update without formatting user data

For a **new HyperMOS build on the same supported China ROM base and the same
device** (for example, Xiaomi 15 Pro / `haotian`), the packaged ROM ZIP
includes `UPDATE_NO_WIPE.bat` alongside `FLASH.bat`:

1. Back up important files and app data; confirm the bootloader is already
   unlocked, the ROM matches the device, and the current/base versions are
   compatible. Do not relock the bootloader on a modified ROM.
2. Extract the complete **new** HyperMOS ZIP on a Windows PC. Do not mix
   firmware or `super.img` from different builds.
3. Boot the phone into **bootloader fastboot** and connect it by USB.
4. Run `UPDATE_NO_WIPE.bat`. It calls the existing device-checked flasher in
   explicit `--no-wipe` mode, **without erasing userdata or metadata**.
   The flasher writes the firmware images present in the package and
   `super/super.img` directly through bootloader fastboot; it does not
   require a fastbootd transition.
5. Wait until the flashing process finishes and the device reboots. Verify
   that the device boots and translations work. If the new build changes
   `init_boot` or `boot`, previously installed root may need to be restored
   with the correct matching image.

**Warning:** A no-wipe flash does not guarantee data compatibility or a
successful boot. Incompatible firmware, different Android bases, missing
partitions, and encryption changes can cause boot failure. Never run
`fastboot -w`, `erase userdata`, or the format-data option if the goal is
to keep data. The regular `FLASH.bat` still has an explicit format-data
prompt for users intentionally doing a clean install; use
`UPDATE_NO_WIPE.bat` for a same-base update.

## Important Notes

**HyperMOS only supports Xiaomi HyperOS China (CN) ROMs.**

Global, EEA, India, Taiwan, Russia, Indonesia, Turkey, Xiaomi.eu, and other non-China ROM bases are not supported.

Always keep a working backup and make sure you know how to restore the original firmware before flashing a modified ROM.

## Disclaimer

This project is provided for development, testing, and educational purposes. You are responsible for any changes made to your device and for verifying compatibility before flashing.
