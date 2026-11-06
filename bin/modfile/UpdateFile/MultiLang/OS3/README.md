# HyperOS 3 (OS3) Vietnamese overlays

This directory identifies the OS3-specific translation track.

For backward compatibility, the 67 prebuilt OS3 RRO APKs are **still stored** in
`../updatesource/` and optional reviewed overlays in `../supplemental/`.
The existing `../update.sh` installer continues to read those original
directories **only for OS3 China builds**.

Do not replace, resign, delete, or migrate the bundled APKs implicitly.
OS4 has a completely separate source under `../OS4/`; OS4 XML files are
not compatible prebuilt OS3 overlay APKs.
