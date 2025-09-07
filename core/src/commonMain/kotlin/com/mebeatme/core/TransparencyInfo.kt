package com.mebeatme.core

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
    val bucket: Bucket
) {
    companion object {
        fun fromRunSession(session: RunSession, score: Score): TransparencyInfo {
            val speedMps = session.distanceMeters / session.elapsedSeconds
            val rawPpi = PpiCurve.score(session.distanceMeters, session.elapsedSeconds)
            val correctedPpi = PpiCurve.correctedScore(session.distanceMeters, session.elapsedSeconds, score.corrections)
            
            return TransparencyInfo(
                sessionId = session.id,
                distanceMeters = session.distanceMeters,
                elapsedSeconds = session.elapsedSeconds,
                averageSpeedMps = speedMps,
                corrections = score.corrections,
                rawPpi = rawPpi,
                correctedPpi = correctedPpi,
                formula = "PPI = 350.0 × (speed^0.95) × (distance^0.05)",
                bucket = score.bucket
            )
        }
    }
}
