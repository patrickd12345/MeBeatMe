package com.mebeatme.core

import com.mebeatme.core.ppi.PpiEngine
import com.mebeatme.core.ppi.PpiModel
import kotlinx.serialization.Serializable

@Serializable data class TransparencyInfo(
    val sessionId: String,
    val distanceMeters: Double,
    val elapsedSeconds: Double,
    val averageSpeedMps: Double,
    val corrections: Corrections,
    val rawPpi: Double,
    val correctedPpi: Double,
    val formula: String,
    val bucket: Bucket,
    val modelVersion: String,
    val modelType: String,
    val performanceRatio: Double? = null,
    val baselineTime: Double? = null
) {
    companion object {
        fun fromRunSession(session: RunSession, score: Score): TransparencyInfo {
            val speedMps = session.distanceMeters / session.elapsedSeconds
            val rawPpi = PpiEngine.score(session.distanceMeters, session.elapsedSeconds)
            val correctedPpi = PpiEngine.score(session.distanceMeters, session.elapsedSeconds, score.corrections)
            
            val modelVersion = PpiEngine.getCurrentModelVersion()
            val modelType = when (PpiEngine.model) {
                PpiModel.TransparentV0 -> "Transparent v0"
                PpiModel.PurdyV1 -> "Purdy v1"
            }
            
            val formula = when (PpiEngine.model) {
                PpiModel.TransparentV0 -> "PPI = 350.0 × (speed^0.95) × (distance^0.05)"
                PpiModel.PurdyV1 -> "PPI = 1000.0 × (baseline_time / actual_time)^5.0"
            }
            
            val performanceRatio = PpiEngine.getPerformanceRatio(session.distanceMeters, session.elapsedSeconds)
            val baselineTime = PpiEngine.getBaselineTime(session.distanceMeters)
            
            return TransparencyInfo(
                sessionId = session.id,
                distanceMeters = session.distanceMeters,
                elapsedSeconds = session.elapsedSeconds,
                averageSpeedMps = speedMps,
                corrections = score.corrections,
                rawPpi = rawPpi,
                correctedPpi = correctedPpi,
                formula = formula,
                bucket = score.bucket,
                modelVersion = modelVersion,
                modelType = modelType,
                performanceRatio = performanceRatio,
                baselineTime = baselineTime
            )
        }
    }
}
