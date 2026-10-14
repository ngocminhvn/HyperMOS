# Kashi system-app snapshots

HyperMOS ROM builds use the local ZIP snapshots stored here. Normal ROM builds do not
download latest Mods-Center releases.

To update App Vault, Control Center, Launcher, Security Center and Theme Manager:
1. Open **Actions → Update Kashi Apps → Run workflow** on the `main` branch.
2. Keep `dry_run` off to validate and commit updated ZIPs directly to `main`.
3. Set `dry_run` on to check and verify newer release ZIPs without committing.
4. Read the run summary. Test the updated ROM before flashing daily-use devices.

The updater checks the latest stable GitHub release for each of five upstream apps.
It accepts exactly one matching ZIP per release, validates the published SHA-256,
downloaded size, ZIP CRC and safe file paths, and checks the expected APK package.
Launcher also requires its resource overlay and whitelist XML.
It does not change build scripts, props, framework or root integration.

No update branches or pull requests are created. GitHub Actions needs `contents: write`.
Static ZIP checks cannot guarantee the new app is compatible with the ROM.
