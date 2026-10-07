# HyperMOS VNeID Compatibility Diagnostics

A small ROM-native, **read-only** inspector focused on `com.vnid`.

It ports the useful diagnostic parts of the previous HCL integration without
bringing back property spoofing, attestation manipulation, root hiding or
background monitoring.

## Included

- Detect `com.vnid`, package path, version and UID.
- Detect HyperOS/MIUI/AOSP-family environment.
- Report Device / Model / Brand / Manufacturer / Android / patch level / kernel.
- Cross-partition identity + fingerprint matrix for system, system_ext, product,
  vendor, odm, bootimage, vendor_dlkm and odm_dlkm.
- Fingerprint consistency audit against the current vendor/top-level fingerprint.
- Scan for generic/custom-ROM property markers such as mainline, missi, qssi,
  xiaomi.eu, HyperTN, EliteROM, MIPA and similar markers.
- Inventory known custom-ROM components and addon.d paths **without hiding them**.
- Report the real boot / Verified Boot properties exposed by Android.
- Detect root backend, resetprop availability, Kaorios, external HMA and SuSFS
  userspace/kernel capabilities.
- Show init service / SELinux state.
- Save a root-only boot snapshot under `/data/adb/vneid_compat/status`.
- Fail-open: the optional one-shot service does not block Android boot.

## Commands

```sh
su -c 'vneid-compatctl status'
su -c 'vneid-compatctl audit'
su -c 'vneid-compatctl matrix'
su -c 'vneid-compatctl security'
su -c 'vneid-compatctl backends'
su -c 'vneid-compatctl components'
su -c 'vneid-compatctl markers'
su -c 'vneid-compatctl service'
su -c 'vneid-compatctl report'
su -c 'vneid-compatctl snapshot'
su -c 'vneid-compatctl features'
```

On the usual HyperMOS layout the command is installed at:

```
/system_ext/bin/vneid-compatctl
```

## Deliberately excluded

This adapter does **not** mutate Android properties or fingerprints, redirect or
hide paths with SuSFS, alter HMA, edit attestation/keystore target policies,
change bootloader or Verified Boot state, clean VNeID security data, run
Guardian, or spoof kernel uname.

The audit output is diagnostic only. A warning does not mean VNeID will reject
the device, and a clean report does not guarantee acceptance.

No separate HCL module is required.
