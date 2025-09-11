package com.mebeatme.core.ppi

import com.mebeatme.core.Corrections
import kotlin.math.pow

/**
 * Transparent v0 PPI scoring system.
 * Uses simple velocity-based formula with light distance scaling.
 */
object PpiCurveTransparent {
    const val version = "ppi.v0.transparent"
    
    /**
     * Calculate v0 transparent score for a given distance and elapsed time.
     * Formula: 350 * velocity^0.95 * distance^0.05
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @return Points score (0-1200 range)
     */
    fun score(distanceM: Double, elapsedSec: Double): Double {
        val v = distanceM / elapsedSec // m/s
        val base = 350.0 * v.pow(0.95) * distanceM.pow(0.05)
        return base.coerceIn(0.0, 1200.0)
    }
    
    /**
     * Calculate corrected score with elevation and temperature adjustments.
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @param corr Elevation and temperature adjustments
     * @return Corrected points score
     */
    fun correctedScore(distanceM: Double, elapsedSec: Double, corr: Corrections): Double =
        score(distanceM, elapsedSec + corr.elevationAdjSec + corr.temperatureAdjSec + corr.heartRateAdjSec)

    /**
     * Find required pace (sec/km) to reach >= targetScore over given distance/time window.
     * Uses binary search for precision.
     * @param targetScore Target points score
     * @param windowSeconds Time window in seconds (unused in v0)
     * @param distanceForWindowM Distance in meters
     * @return Required pace in seconds per kilometer
     */
    fun requiredPaceSecPerKm(targetScore: Double, windowSeconds: Int, distanceForWindowM: Double): Double {
        var lo = 1.0; var hi = 1e5
        repeat(40) {
            val mid = (lo + hi) / 2
            val s = score(distanceForWindowM, mid)
            if (s >= targetScore) hi = mid else lo = mid
        }
        return hi / (distanceForWindowM / 1000.0)
    }
    
    /**
     * Find the minimum elapsed time needed to reach a target score for a given distance.
     * Uses binary search for precision.
     * @param distanceM Distance in meters
     * @param targetScore Target points score
     * @return Minimum elapsed time in seconds
     */
    fun requiredTimeFor(distanceM: Double, targetScore: Double): Double {
        var lo = 1.0; var hi = 1e5
        repeat(40) {
            val mid = (lo + hi) / 2
            val s = score(distanceM, mid)
            if (s >= targetScore) hi = mid else lo = mid
        }
        return hi
    }
}
