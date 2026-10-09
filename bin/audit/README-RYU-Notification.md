# RYUOS HAOTIAN — Full Framework JAR Audit

## Objective

Compare **every defined class, method and field** in three RYUOS JARs against
the same three Xiaomi stock JARs, without restricting the analysis to
notifications or battery optimizations.

ROM being investigated:
`RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip`.

Baseline choices:
- **Preferred**: unmodified Xiaomi 15 Pro OS3.0.309.0.WOBCNXM JARs,
  matching the RYUOS OS version, to isolate actual RYU patches.
- **Secondary**: the three stock JARs attached in the original chat,
  which may have been obtained from OS3.0.308.0; any resulting differences
  would mix Xiaomi firmware updates with RYU edits.

## Audit implementation

Files:
- `ryu_fetch_extract.py`: inspect the SourceForge ZIP and find specific IMG
  partition files without publishing the original ROM.
- `ryu_full_jar_diff.py`: scan **all** DEX classes, methods, and fields.
  This is NOT a notifications-only allowlist. Output is gzip-compressed JSON.
- `ryu_decode_smali.py` / `ryu_semantic_smali.py`: compare all smali
  methods while omitting debug line directives. Output tracks changed method
  bodies, method calls, constants, field declarations and branch structure.
- `ryu_powerkeeper_report.py`: supplementary detailed notification audit.

The DEX scan reports *candidates*. A raw DEX instruction hash can change due
to constant-pool remapping, so a changed DEX hash is not enough to claim
changed behavior. Verify with the smali comparison. The reports group findings
by power/Doze, notifications, process lifecycle, package management, network,
security, input, media, display, location, scheduling and other subsystems.
The report includes each changed class and method, not just totals.

## Using the GitHub workflow

GitHub Actions -> **RYUOS HAOTIAN Full Framework Audit**, from
`audit-ryuos-haotian-notification`.

- By default, scans RYUOS and produces a complete **RYU inventory**.
- Optional workflow input `stock_bundle_url`: HTTPS URL of a ZIP
  containing exactly one each of `framework.jar`, `services.jar`,
  `miui-services.jar`. With that input the workflow executes the
  complete RYU-vs-stock DEX and smali comparisons.
- If no stock bundle is provided the workflow **cannot** truthfully
  identify RYU-vs-stock changes. It publishes a RYU inventory only.
- Repository artifacts include text reports and compressed JSON
  fingerprints. JAR/APK, partition IMG and decompressed smali are
  never included in artifacts.
- The default SourceForge link is stable, avoiding an expiring signed URL.
- Action runtime depends on SourceForge range request support and runner
  free space; a successful CI report is not yet confirmed.

## Review criteria

For every genuine difference:
1. List file, class, method, access/field changes.
2. Show calls/constants/control-flow that changed.
3. Describe what behavior could change and distinguish hypothesis from proof.
4. Classify possible impact on stability, battery life, performance,
   notification delivery and compatibility.
5. Never auto-merge unknown third-party code into HyperMOS main.

The main branch and ROM boot chain are unchanged.
