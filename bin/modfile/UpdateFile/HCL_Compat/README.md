# HyperMOS HCL Compat

This directory contains a **read-only compatibility diagnostics** integration
inspired by `minhtritt1996/HCL-Module`.

Installed command after flashing:

```sh
su -c hcl-compatctl all
```

Available commands:

- `status` — device / ROM / kernel identity currently reported by Android.
- `matrix` — identity values reported by each Android partition.
- `security` — reported boot/security state.
- `features` — confirms which HCL-style features are deliberately disabled.
- `all` — prints all sections.

The HyperMOS integration intentionally does **not** include runtime property
spoofing, bootloader/Verified Boot spoofing, fingerprint spoofing, kernel uname
spoofing, Guardian daemon, TrickyStore target changes, HMA hiding, security
cache cleanup, or attestation manipulation.
