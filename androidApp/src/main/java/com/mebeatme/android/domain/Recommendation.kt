package com.mebeatme.android.domain

data class Recommendation(
    val targetPaceSecPerKm: Double,
    val projectedGainPPI: Double,
    val notes: String
)
