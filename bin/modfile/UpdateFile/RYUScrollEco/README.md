# RYU Scroll Eco (HAOTIAN, Android 16)

Selective, build-time performance hint optimization inspired by **RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005**.

## Implemented

Only `vendor/etc/perf/thermalbreakboostconfig.xml` is inspected. For existing scroll hint **4224**, scenes **0** and **1**, apply a **minimum** between the existing stock CPU6 ceiling and the RYU *Power/Target2* ceiling to Balanced/Target1 and Power/Target2:

| Trigger | RYU Power CPU6 cap | What HyperMOS does |
|---|---:|---|
| 35,000 milli°C | 3,072,000 kHz | Never raise existing cap |
| 37,000 milli°C | 2,438,400 kHz | Never raise existing cap |
| 39,000+ milli°C | unchanged | Keep Xiaomi original |

Source: `RYUOS-HAOTIAN-Thermal-Configs` extraction from RYU image, file `files/vendor/etc/perf/thermalbreakboostconfig.xml`, SHA256 `7e5fbfc12305b5425b85710ebe70083e57a40843eaa4c5f3423182d66061765f`.

**Important:** RYU's `Target1` on scroll scenes 0/1 is NOT lower than `Target0`. The balanced behavior here is a **HyperMOS adaptation of RYU's Power (Target2) values**, not a byte-for-byte port of RYU Balanced. Energy savings and scroll smoothness require on-device measurements.

## Explicitly untouched

- `Target0` Performance mode, launch hint 4225/4226, 39°C+ triggers, other configs and GPU hints
- Thermal-engine/thermal service, encrypted thermal profiles, charge thermal and all other power hints
- FCM/notification patches, GMS exemptions, PowerKeeper, boot chain
- No background service or persistent runtime CPU cost

Patch is text-surgical and idempotent. XML is verified before and after; unrecognized file layout fails before any write. If there is no config at the expected HAOTIAN vendor path, builds keep stock unchanged and log a warning.

## Build switch

Automatically enabled only if `device_f.txt == haotian` and `androidver.txt == 16`. To opt out, set `RYU_SCROLL_ECO_DISABLE=1` in the build environment.

It runs through `bin/modfile/UpdateFile/insupdate.sh` as `update.sh`. The old `ThermalServices/update.sh.0` is NOT executed and no thermal-safety bypass is enabled.

Compare with stock later using `.github/workflows/ryu-vs-stock-thermal.yml` (the audit is independent of this patch).
