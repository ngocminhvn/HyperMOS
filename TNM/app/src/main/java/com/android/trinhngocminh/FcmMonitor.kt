package com.android.trinhngocminh

import android.content.ComponentName
import android.content.Context
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

data class NotificationDelaySample(
    val packageName: String,
    val observedAt: Long,
    val sourceAt: Long?,
    val delayMs: Long?,
    val source: String,
)

data class FcmDiagnosticsSnapshot(
    val enabled: Boolean,
    val totalSamples: Int,
    val fcmSamples: Int,
    val averageDelayMs: Long?,
    val latest: List<NotificationDelaySample>,
)

class FcmMonitorService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val item = sbn ?: return
        FcmDiagnostics.record(this, item)
    }
}

object FcmDiagnostics {
    private const val PREFS = "fcm_diag"
    private const val KEY_SAMPLES = "samples"
    private const val MAX_SAMPLES = 60

    fun isEnabled(context: Context): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ).orEmpty()

        return enabled
            .split(':')
            .mapNotNull { ComponentName.unflattenFromString(it) }
            .any { it.packageName == context.packageName }
    }

    fun record(context: Context, sbn: StatusBarNotification) {
        val now = System.currentTimeMillis()
        val extras = sbn.notification.extras

        fun normalizedTimestamp(raw: Long): Long? {
            if (raw <= 0L) return null
            return when {
                raw < 10_000_000_000L -> raw * 1000L
                else -> raw
            }.takeIf { it in 1_500_000_000_000L..(now + 60_000L) }
        }

        val sentCandidates = listOf(
            "google.sent_time",
            "google.c.a.ts",
            "gcm.sent_time",
            "sent_time",
        )

        var sourceAt: Long? = null
        var source = "notification.when"

        for (key in sentCandidates) {
            if (extras.containsKey(key)) {
                val raw = when (val value = extras.get(key)) {
                    is Number -> value.toLong()
                    is String -> value.toLongOrNull()
                    else -> null
                }
                val normalized = raw?.let(::normalizedTimestamp)
                if (normalized != null) {
                    sourceAt = normalized
                    source = "FCM:$key"
                    break
                }
            }
        }

        if (sourceAt == null) {
            sourceAt = normalizedTimestamp(sbn.notification.`when`)
        }

        val delay = sourceAt?.let { (now - it).coerceAtLeast(0L) }
            ?.takeIf { it <= 7L * 24L * 60L * 60L * 1000L }

        val sample = JSONObject()
            .put("package", sbn.packageName)
            .put("observedAt", now)
            .put("sourceAt", sourceAt ?: JSONObject.NULL)
            .put("delayMs", delay ?: JSONObject.NULL)
            .put("source", source)

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val existing = try {
            JSONArray(prefs.getString(KEY_SAMPLES, "[]"))
        } catch (_: Throwable) {
            JSONArray()
        }

        val next = JSONArray()
        next.put(sample)
        val keep = (MAX_SAMPLES - 1).coerceAtLeast(0)
        for (i in 0 until minOf(existing.length(), keep)) {
            next.put(existing.opt(i))
        }
        prefs.edit().putString(KEY_SAMPLES, next.toString()).apply()
    }

    fun read(context: Context): FcmDiagnosticsSnapshot {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val array = try {
            JSONArray(prefs.getString(KEY_SAMPLES, "[]"))
        } catch (_: Throwable) {
            JSONArray()
        }

        val list = buildList {
            for (i in 0 until array.length()) {
                val item = array.optJSONObject(i) ?: continue
                val sourceAt = item.optLong("sourceAt", Long.MIN_VALUE)
                    .takeIf { it != Long.MIN_VALUE }
                val delay = item.optLong("delayMs", Long.MIN_VALUE)
                    .takeIf { it != Long.MIN_VALUE }
                add(
                    NotificationDelaySample(
                        packageName = item.optString("package"),
                        observedAt = item.optLong("observedAt"),
                        sourceAt = sourceAt,
                        delayMs = delay,
                        source = item.optString("source", "notification.when"),
                    )
                )
            }
        }

        val fcm = list.filter { it.source.startsWith("FCM:") && it.delayMs != null }
        val average = if (fcm.isNotEmpty()) {
            fcm.mapNotNull { it.delayMs }.average().toLong()
        } else {
            null
        }

        return FcmDiagnosticsSnapshot(
            enabled = isEnabled(context),
            totalSamples = list.size,
            fcmSamples = fcm.size,
            averageDelayMs = average,
            latest = list.take(12),
        )
    }

    fun clear(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(KEY_SAMPLES)
            .apply()
    }

    fun formatDelay(ms: Long?): String {
        if (ms == null) return "—"
        return when {
            ms < 1000L -> "${ms} ms"
            ms < 60_000L -> String.format(Locale.US, "%.1f s", ms / 1000.0)
            else -> String.format(Locale.US, "%.1f phút", ms / 60_000.0)
        }
    }
}
