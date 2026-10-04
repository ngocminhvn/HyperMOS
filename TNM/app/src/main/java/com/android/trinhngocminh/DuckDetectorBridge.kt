package com.android.trinhngocminh

import android.content.Context
import com.eltavine.duckdetector.core.evidence.DetectionSeverity
import com.eltavine.duckdetector.core.evidence.InfoKind
import com.eltavine.duckdetector.core.report.ReportBlock
import com.eltavine.duckdetector.sdk.DuckDetector

data class DuckDetectorItem(
    val id: String,
    val title: String,
    val verdict: String,
    val severity: DetectionSeverity,
    val infoKind: InfoKind?,
    val details: List<String>,
)

data class DuckScanSnapshot(
    val items: List<DuckDetectorItem>,
    val packageVisibility: String,
    val visiblePackages: Int,
    val suspiciouslyLowPackages: Boolean,
    val error: String? = null,
) {
    val dangerCount: Int get() = items.count { it.severity == DetectionSeverity.DANGER }
    val warningCount: Int get() = items.count { it.severity == DetectionSeverity.WARNING }
    val clearCount: Int get() = items.count { it.severity == DetectionSeverity.ALL_CLEAR }
    val infoCount: Int get() = items.count { it.severity == DetectionSeverity.INFO }
}

object DuckDetectorBridge {
    suspend fun scan(context: Context): DuckScanSnapshot {
        return try {
            val packageVisibility = DuckDetector.packageVisibility(context)
            val results = DuckDetector.scan(context)

            val items = results.map { result ->
                val report = result.report
                val details = buildList {
                    report.quickFacts.forEach { fact ->
                        add("${fact.label}: ${fact.value}")
                    }
                    report.blocks.forEach { block ->
                        when (block) {
                            is ReportBlock.Rows -> {
                                if (block.title.isNotBlank()) add("§ ${block.title}")
                                block.rows.forEach { row ->
                                    val suffix = row.detail?.takeIf { it.isNotBlank() }
                                        ?.let { " — $it" }
                                        .orEmpty()
                                    add("${row.label}: ${row.value}$suffix")
                                }
                            }
                            is ReportBlock.Bullets -> {
                                if (block.title.isNotBlank()) add("§ ${block.title}")
                                block.items.forEach { add("• $it") }
                            }
                            is ReportBlock.Verbatim -> {
                                if (block.title.isNotBlank()) add("§ ${block.title}")
                                block.lines.forEach { add(it) }
                            }
                        }
                    }
                }

                DuckDetectorItem(
                    id = result.id.value,
                    title = report.title.ifBlank { prettyName(result.id.value) },
                    verdict = report.verdict.ifBlank { result.status.severity.name },
                    severity = result.status.severity,
                    infoKind = result.status.infoKind,
                    details = details,
                )
            }

            DuckScanSnapshot(
                items = items,
                packageVisibility = packageVisibility.scope.name,
                visiblePackages = packageVisibility.visiblePackageCount,
                suspiciouslyLowPackages = packageVisibility.suspiciouslyLow,
            )
        } catch (t: Throwable) {
            DuckScanSnapshot(
                items = emptyList(),
                packageVisibility = "UNKNOWN",
                visiblePackages = 0,
                suspiciouslyLowPackages = false,
                error = t.message ?: t.javaClass.simpleName,
            )
        }
    }

    private fun prettyName(id: String): String = id
        .split('_')
        .joinToString(" ") { token ->
            token.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
}
