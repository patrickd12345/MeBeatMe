package com.mebeatme.android.models

import kotlinx.serialization.Serializable

@Serializable
data class RunRecord(
    val id: String,
    val source: String,
    val startedAtEpochMs: Long,
    val endedAtEpochMs: Long,
    val distanceMeters: Double,
    val elapsedSeconds: Int,
    val avgPaceSecPerKm: Double,
    val avgHr: Int? = null,
    val ppi: Double? = null,
    val notes: String? = null
)
