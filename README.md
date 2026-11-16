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
- **Supported Android versions:** **15, 16, and 17**
- **Build sources:** **Xiaomi China (tested)** and **Xiaomi.eu fastboot ZIP (experimental)**
- **Build environment:** GitHub Actions / Ubuntu
- **Build input:** Xiaomi China ROM package URL or Xiaomi.eu fastboot ZIP URL
- **Supported ROM layouts:** `payload.bin`, `super.img`, and `*.new.dat.br`
- **Build process:** Unpack → Debloat → Apply mods → Apply patches → Repack
- **Upload options:** Google Drive via rclone or Pixeldrain
- **Notifications:** Build status and result notifications are supported through Telegram

## Important Notes

**China remains the tested default. Xiaomi.eu source handling is experimental and has not yet passed an end-to-end ROM build and on-device verification.**

Xiaomi.eu ZIP filenames (`xiaomi.eu_<DEVICE>_<VERSION>_...`) select
`rom_source=xiaomi_eu`, independently from the `CNXM` base region tag.
This enables `bin/modfile/UpdateFile/EU/update.sh` to remove only stock
`/product/priv-app/XiaomiEUExt`. All existing China/shared mods are still
applied, but the China-only `NOTIFICATION_FIX` stage is skipped; EU retains
its original notification/PowerKeeper behavior. The final ROM filename uses
`XEU` instead of `CN` to distinguish the build source.

Other Global, EEA, India, Taiwan, Russia, Indonesia, Turkey, and unrelated
non-China ROM bases have not been validated for this pipeline.

Always keep a working backup and make sure you know how to restore the original firmware before flashing a modified ROM.

## Disclaimer

This project is provided for development, testing, and educational purposes. You are responsible for any changes made to your device and for verifying compatibility before flashing.

## License and Attribution

Original HyperMOS code and documentation for which contributors have licensing rights are provided under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for the original project attribution:

- **Project:** HyperMOS
- **Original author / maintainer:** [ngocminhvn](https://github.com/ngocminhvn)
- **Upstream source:** https://github.com/ngocminhvn/HyperMOS

When distributing HyperMOS source or derivative works, you must follow Apache-2.0 Section 4, including providing the license and retaining relevant copyright and attribution notices. Attribution may be included in a NOTICE file, the distributed source/documentation, or another location permitted by the license; it is **not** required to appear in a downstream README specifically. Please credit HyperMOS and link to the upstream repository when publishing a modified project or ROM.

**Third-party rights:** Xiaomi firmware, Xiaomi.eu files, and third-party mods, tools, patches, and other bundled assets are **not automatically relicensed** under Apache-2.0. Their original copyright, license terms, and required notices continue to apply.
