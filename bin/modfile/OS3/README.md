# OS3 Mods Center integration

This directory integrates pinned Mods Center releases into HyperOS 3 ROM images during the build.

Pinned packages:
- HyperOS Theme Manager V7
- HyperOS App Vault V4.5
- HyperOS Security Center V7
- ColorOS Control Center V3

The build downloads the release ZIPs, validates their SHA-256 hashes, extracts only the module system tree, removes matching stock app directories, and copies files into the unpacked ROM partitions.

Magisk/KernelSU runtime scripts such as service.sh, post-fs-data.sh, customize.sh and system.prop are not executed or imported.

The OS3 loader is only invoked when rom_os.txt contains OS3. Package/framework patching still runs afterwards through the existing HyperMOS patchpackage.sh flow.
