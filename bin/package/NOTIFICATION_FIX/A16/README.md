# HyperMOS A16 notification policy

- **China:** existing CN FrameworkPatcher and PowerKeeper behavior unchanged.
- **Xiaomi.eu:** three ZK304-source-backed method-level changes are applied
  by the single standalone `EU/zk_patch.py` (no ZK ZIP/JAR/DEX donor at build):
  `InternationalPolicyManager.getImportantApps` (nonempty cache),
  `NotificationManagerServiceImpl.<clinit>` (drop cached international flag),
  `KillProcessController.setUidState` (remove EU-only UID kill invocation).
- The EU PowerKeeper APK is rebuilt from original EU APK; all non-DEX
  entries, including AndroidManifest.xml, resources and META-INF, are checked
  byte-for-byte; no resign. **Its original cryptographic signature is invalid
  after DEX edits.** This experiment needs package-scan and device boot testing.
- Original GmsObserver, Greeze core, Doze, thermal, CPU and unrelated EU JAR
  methods remain unchanged. This is deliberately **not full ZKOS parity**.
- The original ZK304 reference is retained outside the repo in historical
  GitHub Actions run 39751679932 (artifact name
  `zk-haotian-304-framework-powerkeeper-39751679932`).
- No extra runtime service or daemon; no RYU PerfHook. China and A17 unchanged.
