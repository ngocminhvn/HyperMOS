package com.android.trinhngocminh

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.StatFs
import java.io.File
import java.util.Locale

data class DeviceInfo(
    val device: String,
    val soc: String,
    val cpuMax: String,
    val cpuCurrent: String,
    val ram: String,
    val storage: String,
    val android: String,
    val hyperos: String,
    val batteryTemp: String,
    val batteryPower: String,
    val socTemp: String,
    val gpuTemp: String,
    val root: String,
    val selinux: String,
    val thermal: String,
    val thermalNotice: String? = null,
)

object SystemInfo {
    private fun prop(name: String): String = try {
        ProcessBuilder("getprop", name).start().inputStream.bufferedReader().readText().trim()
    } catch (_: Throwable) {
        ""
    }

    private fun read(path: String): String = try {
        File(path).readText().trim()
    } catch (_: Throwable) {
        ""
    }

    private fun readFirst(vararg paths: String): String {
        for (path in paths) {
            val value = read(path)
            if (value.isNotBlank()) return value
        }
        return ""
    }

    private fun temperatureValue(rawValue: String): String {
        val raw = rawValue.toDoubleOrNull() ?: return "—"
        val celsius = when {
            raw > 10000 -> raw / 1000.0
            raw > 100 -> raw / 10.0
            else -> raw
        }
        return if (celsius in -20.0..150.0) "%.1f °C".format(celsius) else "—"
    }

    private fun tempFor(vararg keys: String): String {
        val zones = File("/sys/class/thermal").listFiles()
            ?.filter { it.name.startsWith("thermal_zone") }
            .orEmpty()

        for (zone in zones) {
            val type = read(File(zone, "type").path).lowercase()
            if (keys.any { type.contains(it.lowercase()) }) {
                val shown = temperatureValue(read(File(zone, "temp").path))
                if (shown != "—") return shown
            }
        }
        return "—"
    }

    private fun cpuMaxGHz(): String {
        val maxKHz = File("/sys/devices/system/cpu/cpufreq").listFiles()
            ?.filter { it.name.startsWith("policy") }
            ?.mapNotNull {
                read(File(it, "cpuinfo_max_freq").path).toLongOrNull()
                    ?: read(File(it, "scaling_max_freq").path).toLongOrNull()
            }
            ?.maxOrNull()
        val value = maxKHz ?: run {
            if (!RootShell.hasRoot()) null
            else RootShell.run(
                "cat /sys/devices/system/cpu/cpufreq/policy*/cpuinfo_max_freq /sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq 2>/dev/null | sort -n | tail -1"
            ).out.lineSequence().lastOrNull()?.trim()?.toLongOrNull()
        }
        return value?.let { String.format(Locale.US, "%.2f GHz", it / 1_000_000.0) } ?: "—"
    }

    private fun cpuCurrentGHz(): String {
        var currentKHz = File("/sys/devices/system/cpu/cpufreq").listFiles()
            ?.filter { it.name.startsWith("policy") }
            ?.mapNotNull {
                read(File(it, "scaling_cur_freq").path).toLongOrNull()
                    ?: read(File(it, "cpuinfo_cur_freq").path).toLongOrNull()
            }
            ?.filter { it > 0 }
            ?.maxOrNull()

        if (currentKHz == null && RootShell.hasRoot()) {
            currentKHz = RootShell.run(
                "cat /sys/devices/system/cpu/cpufreq/policy*/scaling_cur_freq /sys/devices/system/cpu/cpufreq/policy*/cpuinfo_cur_freq 2>/dev/null | awk '$1>0' | sort -n | tail -1"
            ).out.lineSequence().lastOrNull()?.trim()?.toLongOrNull()
        }

        return currentKHz?.let {
            String.format(Locale.US, "%.2f GHz", it / 1_000_000.0)
        } ?: "—"
    }

    private fun ramUsage(context: Context): String {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo().also(am::getMemoryInfo)
        val total = mem.totalMem / 1024.0 / 1024 / 1024
        val used = (mem.totalMem - mem.availMem) / 1024.0 / 1024 / 1024
        return "%.1f / %.1f GB".format(used, total)
    }

    private fun batteryTemp(context: Context): String {
        try {
            val intent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED),
            )
            val tenthC = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
            if (tenthC != null && tenthC != Int.MIN_VALUE && tenthC != 0) {
                return "%.1f °C".format(tenthC / 10.0)
            }
        } catch (_: Throwable) {
        }

        val sysfs = readFirst(
            "/sys/class/power_supply/battery/temp",
            "/sys/class/power_supply/battery/temperature",
            "/sys/class/power_supply/battery/batt_temp",
            "/sys/class/power_supply/bms/temp",
        )
        return temperatureValue(sysfs)
    }


    private fun batteryPower(context: Context): String {
        return try {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val currentUa = batteryManager
                .getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
                .takeIf { it != Int.MIN_VALUE && it != 0 }
                ?.toLong()
                ?: readFirst(
                    "/sys/class/power_supply/battery/current_now",
                    "/sys/class/power_supply/bms/current_now",
                ).toLongOrNull()
                ?: return "—"

            val batteryIntent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED),
            )
            val voltageMv = batteryIntent
                ?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, Int.MIN_VALUE)
                ?.takeIf { it != Int.MIN_VALUE && it > 0 }
                ?.toLong()
                ?: readFirst(
                    "/sys/class/power_supply/battery/voltage_now",
                    "/sys/class/power_supply/bms/voltage_now",
                ).toLongOrNull()?.let { raw ->
                    if (raw > 100_000L) raw / 1000L else raw
                }
                ?: return "—"

            val status = batteryIntent?.getIntExtra(
                BatteryManager.EXTRA_STATUS,
                BatteryManager.BATTERY_STATUS_UNKNOWN,
            ) ?: BatteryManager.BATTERY_STATUS_UNKNOWN

            val wattsAbs = kotlin.math.abs(currentUa.toDouble()) / 1_000_000.0 *
                (voltageMv.toDouble() / 1000.0)

            val sign = when (status) {
                BatteryManager.BATTERY_STATUS_CHARGING,
                BatteryManager.BATTERY_STATUS_FULL,
                -> "+"
                else -> "-"
            }
            String.format(Locale.US, "%s%.2f W", sign, wattsAbs)
        } catch (_: Throwable) {
            "—"
        }
    }

    private fun selinuxMode(): String {
        val enforce = read("/sys/fs/selinux/enforce")
        if (enforce == "1") return "Enforcing"
        if (enforce == "0") return "Permissive"

        try {
            val direct = ProcessBuilder("getenforce")
                .start()
                .inputStream
                .bufferedReader()
                .readText()
                .trim()
            if (direct.isNotBlank()) return direct
        } catch (_: Throwable) {
        }

        if (RootShell.hasRoot()) {
            val root = RootShell.run(
                "getenforce 2>/dev/null || cat /sys/fs/selinux/enforce 2>/dev/null"
            ).out.trim()
            if (root == "1") return "Enforcing"
            if (root == "0") return "Permissive"
            if (root.isNotBlank()) return root
        }
        return "Không đọc được"
    }

    private fun thermalState(context: Context): Pair<String, String?> {
        val raw = read("/sys/class/thermal/thermal_message/sconfig")
            .lineSequence()
            .firstOrNull()
            ?.trim()
            .orEmpty()

        if (raw.isBlank()) {
            return "Không đọc được" to "Không tìm thấy thermal sconfig trên thiết bị"
        }

        val id = raw.substringBefore(' ').substringBefore(':').trim()
        val selected = ThermalManager.selected(context)

        if (id == "0") {
            return if (selected == "eco") "Eco" to null else "Stock Xiaomi" to null
        }

        val name = when (id) {
            "1" -> "Huanji"
            "2" -> "Abnormal"
            "5" -> "Phone"
            "6" -> "No Limits"
            "7" -> "Class 0"
            "10" -> "Navigation"
            "11" -> "Video"
            "15" -> "Camera"
            "16", "17" -> "4K"
            "18" -> "TGame"
            "19" -> "MGame"
            "27" -> "Charge"
            "50" -> "Performance Normal"
            "57" -> "Performance Class 0"
            "61" -> "Performance Video"
            "500" -> "HP Normal"
            "501" -> "HP MGame"
            "700" -> "CGame"
            else -> "Profile #$id"
        }
        return name to "Phát hiện thermal profile khác Eco/Stock: $name"
    }

    fun readStatic(context: Context): DeviceInfo {
        val stat = StatFs(context.filesDir.absolutePath)
        val totalStorage = stat.totalBytes / 1024.0 / 1024 / 1024

        val soc = prop("ro.soc.model")
            .ifBlank { prop("ro.board.platform") }
            .ifBlank { Build.HARDWARE }

        val hyper = listOf(
            prop("ro.mi.os.version.name"),
            prop("ro.mi.os.version.incremental"),
            prop("ro.build.version.incremental"),
        ).firstOrNull { it.isNotBlank() } ?: "—"

        val base = DeviceInfo(
            device = "${Build.MANUFACTURER} ${Build.MODEL} (${Build.DEVICE})",
            soc = soc,
            cpuMax = cpuMaxGHz(),
            cpuCurrent = "—",
            ram = "—",
            storage = "%.0f GB".format(totalStorage),
            android = "Android ${Build.VERSION.RELEASE} · SDK ${Build.VERSION.SDK_INT}",
            hyperos = hyper,
            batteryTemp = "—",
            batteryPower = "—",
            socTemp = "—",
            gpuTemp = "—",
            root = if (RootShell.hasRoot()) "Có" else "Không",
            selinux = selinuxMode(),
            thermal = "—",
        )
        return readRealtime(context, base)
    }

    fun readRealtime(context: Context, base: DeviceInfo): DeviceInfo {
        val thermal = thermalState(context)
        return base.copy(
            cpuCurrent = cpuCurrentGHz(),
            ram = ramUsage(context),
            batteryTemp = batteryTemp(context),
            batteryPower = batteryPower(context),
            socTemp = tempFor("cpu", "soc", "ap", "quiet_therm"),
            gpuTemp = tempFor("gpu"),
            thermal = thermal.first,
            thermalNotice = thermal.second,
        )
    }
}
