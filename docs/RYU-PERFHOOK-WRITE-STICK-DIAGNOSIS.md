# Diagnosing RYU PerfHook: Write did not stick

Device: Xiaomi 15 Pro (HAOTIAN), HyperOS Android 16. Test branch only.

## Verified from source

- The original RYU PerfHook executable DEX reads/writes CPU cpufreq, KGSL GPU devfreq, and /sys/class/thermal/thermal_message/sconfig.
- The current access patch changes only the KGSL min/max node DAC and SELinux access. CPU and thermal-message write permissions are not verified.
- Previous devices reported Write did not stick; exact failed path, desired value and readback are not available. This is not proof the newest build reproduces the issue.

## Read-only runtime inspection

On a cool idle device with this ROM revision: `su -c '/system_ext/bin/tnm-frameworkctl perfhook.diagnose'`

This records PowerKeeper PID/domain/UID/GID/groups, profile Settings, DAC owner/mode and SELinux file type, CPU min/max, GPU min/max, thermal sconfig and filtered PerfHook and AVC logs. It does not write sysfs or change settings.

## Fix decision after evidence

1. No PowerKeeper PID or init log: verify modified APK actually loaded at runtime.
2. DAC denial: identify the precise sysfs writer UID and node. Do not chmod/chown every CPU/thermal node for all system apps.
3. SELinux denial: inspect exact source domain, target type and denied permission. Do not disable SELinux or write a blanket allow.
4. Frequency range failure: compare desired limit with active scaling_min_freq and available supported frequency values; do not bypass vendor constraints.
5. Write accepted then overwritten: identify which kernel/vendor policy owns the effective cap and use a supported guarded interface rather than a polling root daemon.
6. Settings persisted but no write attempt: investigate PerfHook init and settings observer.

The diagnostic command does not fix frequency control by itself; confirm exact failure on device before a targeted patch.
