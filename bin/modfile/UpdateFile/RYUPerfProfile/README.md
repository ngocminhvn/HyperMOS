# HAOTIAN RYU combined performance experiment

**Only on branch:** test-ryu-performance-haotian. Never merge to main without on-device tests.

## Included in one ROM build

- Existing RYU-inspired notification, Doze and PowerKeeper conditional policy changes on the experimental branch.
- Ten original RYUOS HAOTIAN OS3.0.309 vendor/odm performance XMLs: both powerhint.xml files and the complete supported Qualcomm perf XML group. No approximate Eco values; each source is pinned to a SHA256 from the user-provided RYU thermal artifact.
- The import runs inside the usual HyperMOS build after Xiaomi ROM extraction and before packaging.
- No new daemon, no boot-chain edits and no unbounded CPU/GPU boosting.

## What is deliberately NOT identical to RYU

The private com.projectryu.perf.PerfHook implementation (20 classes) is not yet ported. It references RYU-specific framework classes missing from Xiaomi stock, and copying the full PowerKeeper APK without those dependencies can break boot or power management. Runtime CPU/GPU per-app behavior therefore cannot yet be claimed identical to RYU. ROM base labels also differ (308 Xiaomi vs 309 RYU).

Stock Xiaomi thermal engine, charging safety, temperature cutoffs, encrypted thermal configurations, display safety limits, and firmware remain intact.

## Build workflow

1. A complete, non-expired RYUOS-HAOTIAN-Thermal-Configs artifact is required. Branch workflow ryu-extract-thermal.yml can regenerate one; it starts on test-branch creation/update of the extraction workflow.
2. Go to Actions > HyperMOS ROM Build > Run workflow, select test-ryu-performance-haotian and provide the HAOTIAN Android 16 base download URL.
3. The build verifies all ten XML source hashes and XML root types. Missing or incompatible data fails the build rather than silently substituting stock values.
4. Inspect the build log lines starting with [RYU PERF] to see every file replaced and the original SHA256.

## Device validation

Compare main vs test on identical display brightness, refresh behavior, Wi-Fi/cellular condition and TikTok version. Check scrolling smoothness, video heat, screen-off notifications (Zalo/Messenger/Gmail), idle drain and PowerKeeper stability. A successful GitHub build is not proof of improved battery life or safety.

Related actions: ryu-perfhook-port-preflight.yml for metadata-only PerfHook analysis and ryu-vs-stock-thermal.yml for file-by-file comparison. Neither action makes PerfHook live in HyperMOS.
