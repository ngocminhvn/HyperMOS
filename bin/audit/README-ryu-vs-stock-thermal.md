# RYU thermal/performance vs Xiaomi stock comparison

1. Run `ryu-extract-thermal.yml` first if its most recent extracted thermal artifact is expired.
2. Open Actions > **Compare RYUOS vs Xiaomi Stock Thermal (HAOTIAN)** > Run workflow.
3. Select the official Xiaomi download mirror (`BIGOTA` or `HUGEOTA`), both hosting the same stock Fastboot file advertised by MiFirm. Optionally supply a direct HTTPS mirror that serves the *identical* archive; MD5 is required.
4. Download the `RYU-vs-Stock-HAOTIAN-Thermal-Audit` artifact. Read `report.md`, `comparison.csv` and `diffs/*.diff`.

Stock: Xiaomi 15 Pro `OS3.0.308.0.WOBCNXM`, Fastboot `haotian_images_OS3.0.308.0.WOBCNXM_20260729.0000.00_16.0_cn_15bf1ee7da.tgz`, MD5 `15bf1ee7da1e5626f77565e212b0d7a9`. MiFirm entry: <https://mifirm.net/download/22509>. The mirror URLs are publicly listed by Xiaomi ROM indexes: <https://mirom.ezbox.idv.tw/en/phone/haotian/>.

RYU: `RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005`. The comparison uses the previous read-only thermal extraction artifact; no RYU APK, kernel, or thermal limit is installed. Differences may reflect separate release baselines, not just customizations. Binary/encrypted thermal profiles are SHA256-compared without pretending to decode them.

This workflow is **manual/read-only**, and does not change the HyperMOS build.