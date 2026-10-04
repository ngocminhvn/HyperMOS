package com.android.trinhngocminh

import android.content.Context
import com.eltavine.duckdetector.core.evidence.DetectionSeverity
import com.eltavine.duckdetector.core.evidence.InfoKind
import com.eltavine.duckdetector.core.report.ReportBlock
import com.eltavine.duckdetector.sdk.DuckDetector
import kotlinx.coroutines.flow.collect

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
    suspend fun scan(context: Context): DuckScanSnapshot =
        scanStreaming(context) { _, _, _ -> }

    suspend fun scanStreaming(
        context: Context,
        onProgress: (snapshot: DuckScanSnapshot, done: Int, total: Int) -> Unit,
    ): DuckScanSnapshot {
        return try {
            val packageVisibility = DuckDetector.packageVisibility(context)
            val total = DuckDetector.detectors.size
            val items = mutableListOf<DuckDetectorItem>()
            var done = 0

            val initial = snapshot(
                items = items,
                packageVisibility = packageVisibility.scope.name,
                visiblePackages = packageVisibility.visiblePackageCount,
                suspiciouslyLowPackages = packageVisibility.suspiciouslyLow,
            )
            onProgress(initial, 0, total)

            DuckDetector.results(context).collect { result ->
                items += result.toItem()
                done += 1
                onProgress(
                    snapshot(
                        items = items,
                        packageVisibility = packageVisibility.scope.name,
                        visiblePackages = packageVisibility.visiblePackageCount,
                        suspiciouslyLowPackages = packageVisibility.suspiciouslyLow,
                    ),
                    done,
                    total,
                )
            }

            snapshot(
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

    private fun snapshot(
        items: List<DuckDetectorItem>,
        packageVisibility: String,
        visiblePackages: Int,
        suspiciouslyLowPackages: Boolean,
    ): DuckScanSnapshot = DuckScanSnapshot(
        items = items.toList(),
        packageVisibility = packageVisibility,
        visiblePackages = visiblePackages,
        suspiciouslyLowPackages = suspiciouslyLowPackages,
    )

    private fun com.eltavine.duckdetector.core.report.DetectorResult.toItem(): DuckDetectorItem {
        val report = report
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

        return DuckDetectorItem(
            id = id.value,
            title = report.title.ifBlank { prettyName(id.value) },
            verdict = report.verdict.ifBlank { status.severity.name },
            severity = status.severity,
            infoKind = status.infoKind,
            details = details,
        )
    }

    private fun prettyName(id: String): String = id
        .split('_')
        .joinToString(" ") { token ->
            token.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
}
