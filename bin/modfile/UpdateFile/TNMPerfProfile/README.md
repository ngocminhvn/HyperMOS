# Retired RYU/TNM thermal and performance profiles

For HAOTIAN Android 16, PowerKeeper uses the pinned adapted ZKOS DEX and
Xiaomi base CPU/powerhint/vendor/ODM thermal profiles without RYU PerfHook.
`update.sh` is intentionally a no-op aside from build logging.
No RYU per-app thermal import, KGSL permission overlay, PerfHook initializer,
worker, observer or root control service is staged.

The standalone TNM CPU percentage control remains independent of RYU PerfHook.
The RYU pinned donor DEX is still used solely for the guarded UID kill method
and policy checker; its performance classes are **never** copied into the APK.

This code-level change does not establish lower real-device temperatures:
compare equivalent usage conditions with the previous ROM.
