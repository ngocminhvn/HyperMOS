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

## Important Notes

**HyperMOS only supports Xiaomi HyperOS China (CN) ROMs.**

Global, EEA, India, Taiwan, Russia, Indonesia, Turkey, Xiaomi.eu, and other non-China ROM bases are not supported.

Always keep a working backup and make sure you know how to restore the original firmware before flashing a modified ROM.

## Disclaimer

This project is provided for development, testing, and educational purposes. You are responsible for any changes made to your device and for verifying compatibility before flashing.
