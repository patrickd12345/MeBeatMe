package com.mebeatme.android.models

import kotlinx.serialization.Serializable

@Serializable
data class Split(
    val index: Int,
    val distanceMeters: Double,
    val elapsedSeconds: Int,
    val avgHr: Int? = null
)
