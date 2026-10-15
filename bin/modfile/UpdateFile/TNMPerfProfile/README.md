# TNM HAOTIAN performance profiles

On Android 16 HAOTIAN main builds, `update.sh` imports the pinned powerhint,
performance XMLs and application thermal profiles from the repository archive.
Each imported file is checked against the archive manifest and SHA-256.
Charging, no-limit profiles and thermal protection services are preserved.

The build uses `TNM_REF_DIR`, installs `tnm-perfhook-access.rc` and
`tnm-thermalctl`, and verifies final profile hashes and split SELinux policy
before packaging. These production checks are retained.

Persisted `projectryu_thermal_*` Settings keys remain an existing ABI with the
PowerKeeper DEX and the externally distributed TNM application. Their spelling
is not a display name and cannot be changed independently in this repository.
