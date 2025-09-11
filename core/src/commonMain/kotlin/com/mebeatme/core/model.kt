package com.mebeatme.core

import com.mebeatme.core.ppi.PpiEngine
import kotlinx.serialization.Serializable

@Serializable data class RunSession(
    val id: String,
    val startEpochMs: Long,
    val distanceMeters: Double,
    val elapsedSeconds: Double,
    val elevationGainM: Double? = null,
    val avgTempC: Double? = null,
    val heartRateData: List<HeartRatePoint>? = null
)

@Serializable data class Corrections(
    val elevationAdjSec: Double = 0.0,
    val temperatureAdjSec: Double = 0.0,
    val heartRateAdjSec: Double = 0.0
)

enum class Bucket { KM_1_3, KM_3_8, KM_8_15, KM_15_25, KM_25P }

fun bucketFor(distanceM: Double): Bucket = when {
    distanceM < 3_000 -> Bucket.KM_1_3
    distanceM < 8_000 -> Bucket.KM_3_8
    distanceM < 15_000 -> Bucket.KM_8_15
    distanceM < 25_000 -> Bucket.KM_15_25
    else -> Bucket.KM_25P
}

@Serializable data class Score(
    val sessionId: String,
    val ppi: Double,
    val bucket: Bucket,
    val curveVersion: String = PpiEngine.getCurrentModelVersion(),
    val corrections: Corrections = Corrections()
)

@Serializable data class HeartRatePoint(
    val timestampEpochMs: Long,
    val heartRateBpm: Int
)

@Serializable data class HeartRateSegment(
    val startIndex: Int,
    val endIndex: Int,
    val averageHeartRate: Int,
    val distanceM: Double,
    val durationSec: Double,
    val effortAdjustment: Double = 0.0
)
