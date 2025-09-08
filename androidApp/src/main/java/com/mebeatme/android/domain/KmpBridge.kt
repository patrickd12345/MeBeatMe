package com.mebeatme.android.domain

import com.mebeatme.shared.core.PurdyPointsCalculator

object PerfIndex {
    fun purdyScore(distanceMeters: Double, durationSec: Int): Double =
        PurdyPointsCalculator.calculatePPI(distanceMeters, durationSec.toLong())

    fun targetPace(distanceMeters: Double, windowSec: Int): Double =
        PurdyPointsCalculator.calculateRequiredPace(distanceMeters, 1000.0)
}
