# OS3 Mods Center integration

This directory integrates Mods Center releases into HyperOS 3 ROM images during the build.

Packages:
- HyperOS Theme Manager
- HyperOS App Vault
- HyperOS Security Center
- ColorOS Control Center

Each build resolves the repository's GitHub `/releases/latest` endpoint, selects the uploaded ZIP asset, downloads it, and verifies GitHub's SHA-256 asset digest when one is provided.

The integration copies the complete Magisk module `system/` tree into the unpacked ROM. This means files such as:
- `product/etc/permissions/*.xml`
- `priv-app/<app>/lib/arm64/*.so` and other native libraries
- `system_ext`, `vendor`, `odm`, overlays, and other module-owned system files

are preserved automatically when they exist in the latest module.

Magisk/KernelSU runtime scripts such as `service.sh`, `post-fs-data.sh`, `customize.sh` and `system.prop` are not executed or imported.

The OS3 loader only runs when `rom_os.txt` contains `OS3`. Package/framework patching still runs afterwards through the existing HyperMOS `patchpackage.sh` flow.
