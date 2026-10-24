# HyperMOS Android 16: independent China and Xiaomi.eu policies

Entry: `bin/package/NOTIFICATION_FIX/A16/patch.sh`.

- China: `CN/frameworkpatcher_cn_a16.py` and `CN/PowerKeeper.sh`. The
  existing China method gates and its separate EU-sourced PowerKeeper DEX
  archive are deliberately left unchanged.
- Xiaomi.eu: `EU/patch.sh`, `EU/PowerKeeper.sh`, `EU/fcm_greeze.py`,
  `EU/policy_delta.py` and `EU/policy_deltas.json`.
  The latter is a roughly 14 KB declarative list of **specific instruction
  edits** derived from original EU309, Global303 and ZK304, not a whole
  donor DEX, ZIP, JAR, or APK.
- EU JAR: original EU MiuiBatteryIntelligence (18 map apps and static MAP_APP),
  ZK getImportantApps caching method, plus scoped Google FCM allow.
- EU PowerKeeper: 7 Global method edits and selected ZK GmsObserver/
  ActiveStateController edits. GmsObserver enableGms/disableGms were already
  bytecode-equivalent and need no added code.
- Scope is enforced by original EU method SHA-256 and exact changed instruction
  spans. Unexpected ROM versions or method changes fail the build.
- No all-app keepalive, thermal replacement, background daemon or runtime
  download added. PowerKeeper non-DEX members and META-INF are preserved,
  but changing DEX still invalidates the original APK cryptographic signature.

A pinned real-ROM preflight passed smali assembly and DEX reassembly at
[GitHub Actions run 40056239788](https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788).
This does not establish on-device boot, heat, battery drain or notification latency.
