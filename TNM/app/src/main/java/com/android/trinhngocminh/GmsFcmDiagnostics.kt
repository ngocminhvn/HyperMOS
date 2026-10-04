package com.android.trinhngocminh

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import java.util.Locale

object GmsFcmDiagnostics {
    fun open(context: Context): String? {
        val known = listOf(
            "com.google.android.gms.gcm.GcmDiagnostics",
            "com.google.android.gms.gtalkservice.diagnostics.GTalkServiceDiagnostics",
        )

        known.forEach { className ->
            if (start(context, className)) return null
        }

        return try {
            @Suppress("DEPRECATION")
            val info = context.packageManager.getPackageInfo(
                "com.google.android.gms",
                PackageManager.GET_ACTIVITIES,
            )
            val candidate = info.activities
                ?.mapNotNull { it.name }
                ?.firstOrNull { name ->
                    val lower = name.lowercase(Locale.ROOT)
                    (lower.contains("gcm") || lower.contains("fcm") || lower.contains("gtalk")) &&
                        lower.contains("diagnostic")
                }

            if (candidate != null && start(context, candidate)) {
                null
            } else {
                "Không tìm thấy FCM Diagnostics trong Google Play services hiện tại"
            }
        } catch (t: Throwable) {
            "Không mở được FCM Diagnostics: ${t.message ?: t.javaClass.simpleName}"
        }
    }

    private fun start(context: Context, className: String): Boolean {
        return try {
            val intent = Intent().apply {
                setClassName("com.google.android.gms", className)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            context.startActivity(intent)
            true
        } catch (_: Throwable) {
            false
        }
    }
}
