# HyperOS 4 Vietnamese module

The root `../update.sh` dispatches only China OS4 here.
`update.sh` currently **validates staged Vietnamese XML sources only**.
It does not rebuild, sign, or install APK/RRO overlays.

`sync_os4_vi.py` is used by `.github/workflows/sync-hyperos4-vi-xml.yml`
to fetch only Xiaomi.eu's `qcom-sdk37/Vietnamese/main` into
`Vietnamese/main/`. A real OS4 language overlay requires separate
version-specific APK/RRO compatibility and signing verification.
