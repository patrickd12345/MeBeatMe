package com.mebeatme.shared.api

import kotlinx.serialization.Serializable

/**
 * Unified DTOs for MeBeatMe integration across all platforms
 * Following the integration prompt specifications
 */

@Serializable
data class RunDTO(
    val id: String,
    val source: String,                // "GPX"|"TCX"|"FIT"|"Manual"
    val startedAtEpochMs: Long,
    val endedAtEpochMs: Long,
    val distanceMeters: Double,
    val elapsedSeconds: Int,
    val avgPaceSecPerKm: Double,
    val avgHr: Int? = null,
    val ppi: Double? = null,
    val notes: String? = null
)

@Serializable
data class BestsDTO(
    val best5kSec: Int? = null,
    val best10kSec: Int? = null,
    val bestHalfSec: Int? = null,
    val bestFullSec: Int? = null,
    val highestPPILast90Days: Double? = null
)

@Serializable
data class SyncRunsResponse(
    val status: String,
    val stored: Int
)

@Serializable
data class ErrorResponse(
    val error: String,
    val detail: String
)
