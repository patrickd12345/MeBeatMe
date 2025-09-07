package com.mebeatme.core
import kotlin.math.pow

object PpiCurve {
    const val version = "ppi.v0"
    
    /** v0 transparent baseline: score(distance,time) with light distance scaling. */
    fun score(distanceM: Double, elapsedSec: Double): Double {
        val v = distanceM / elapsedSec // m/s
        val base = 350.0 * v.pow(0.95) * distanceM.pow(0.05)
        return base.coerceIn(0.0, 1200.0)
    }
    
    fun correctedScore(distanceM: Double, elapsedSec: Double, corr: Corrections): Double =
        score(distanceM, elapsedSec + corr.elevationAdjSec + corr.temperatureAdjSec)

    /** Find required pace (sec/km) to reach >= targetScore over given distance/time window. */
    fun requiredPaceSecPerKm(targetScore: Double, windowSeconds: Int, distanceForWindowM: Double): Double {
        var lo = 1.0; var hi = 1e5
        repeat(40) {
            val mid = (lo + hi) / 2
            val s = score(distanceForWindowM, mid)
            if (s >= targetScore) hi = mid else lo = mid
        }
        return hi / (distanceForWindowM / 1000.0)
    }
}
