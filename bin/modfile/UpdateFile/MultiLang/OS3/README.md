# HyperOS 3 (OS3) Vietnamese overlays

This is the canonical home of the existing OS3 China translation assets.

- `updatesource/`: all **67 original prebuilt Nothings RRO APKs**, unchanged.
- `supplemental/`: optional, separately reviewed add-on overlays.
- `owned-additions-batch/`: original reviewed XML additions for the OS3 overlays.

The previous top-level paths (`../updatesource/`, `../supplemental/` and
`../owned-additions-batch/`) are **relative symlinks** maintained for
compatibility with existing audit/merge workflows and external tooling.
No APK bytes, signing certificates, or framework resources were modified
during the directory move.

The normal China OS3 build consumes these RROs via `../update.sh`.
OS4 never consumes the OS3 prebuilt APKs. Its untranslated/raw source
is staged separately under `../OS4/`.
