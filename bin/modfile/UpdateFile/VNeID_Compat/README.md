# HyperMOS VNeID Compatibility Diagnostics

This is a deliberately small ROM-native adapter derived from the diagnostic
ideas of HCL-Module. It keeps only VNeID-focused environment inspection.

## What it keeps

- Detect whether `com.vnid` is installed and report package/version details.
- Report the real device/model/build/fingerprint values currently exposed by Android.
- Report the real boot / Verified Boot properties currently exposed by Android.
- Detect whether Kaorios, HMA and a usable SuSFS userspace/kernel interface are present.
- Save one diagnostic snapshot after boot when the configured root SELinux domain exists.
- Provide a small CLI.

## What was removed

The previous broad HCL compatibility runtime is removed. This adapter does not
normalize Android properties or fingerprints, generate/redirect build.prop,
hide ROM components, change SuSFS rules, change HMA configuration, manage
attestation targets, alter boot/security state, clean application security
cache, run Guardian, or spoof uname.

## Commands

```sh
su -c 'vneid-compatctl status'
su -c 'vneid-compatctl all'
su -c 'vneid-compatctl snapshot'
su -c 'vneid-compatctl features'
```

On the default HyperMOS layout the binary is normally installed at:

```
/system_ext/bin/vneid-compatctl
```

The optional boot snapshot is written to:

```
/data/adb/vneid_compat/status
```

No separate HCL module is needed.
