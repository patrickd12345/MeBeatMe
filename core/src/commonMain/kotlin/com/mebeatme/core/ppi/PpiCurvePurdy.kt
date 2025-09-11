package com.mebeatme.core.ppi

import com.mebeatme.core.Corrections
import kotlin.math.pow

/**
 * Purdy-based PPI scoring system that produces SPI-like scaling.
 * Uses elite baseline anchors and performance ratios for scoring.
 */
object PpiCurvePurdy {
    const val version = "ppi.purdy.v1"
    
    private const val ALPHA = 2.0 // Exponential scaling factor
    private const val MIN_POINTS = 100.0
    private const val MAX_POINTS = 2000.0
    private const val ELITE_POINTS = 1000.0
    
    /**
     * Calculate SPI-like score for a given distance and elapsed time.
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @return Points score (100-2000 range)
     */
    fun score(distanceM: Double, elapsedSec: Double): Double {
        if (distanceM <= 0 || elapsedSec <= 0) return MIN_POINTS
        
        val baselineTime = PurdyTable.getBaselineTime(distanceM)
        val performanceRatio = baselineTime / elapsedSec
        
        // Map ratio to points using exponential curve
        // ratio = 1.00 → 1000 points (meets elite baseline)
        // ratio = 0.90 → ~1235 points (faster than elite)
        // ratio = 0.80 → ~1562 points (much faster than elite)
        // ratio = 1.20 → ~694 points (slower than elite)
        // ratio = 1.50 → ~444 points (much slower than elite)
        val rawPoints = ELITE_POINTS * performanceRatio.pow(-ALPHA)
        
        return rawPoints.coerceIn(MIN_POINTS, MAX_POINTS)
    }
    
    /**
     * Calculate corrected score with elevation and temperature adjustments.
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @param corrections Elevation and temperature adjustments
     * @return Corrected points score
     */
    fun correctedScore(distanceM: Double, elapsedSec: Double, corrections: Corrections): Double {
        val adjustedTime = elapsedSec + corrections.elevationAdjSec + corrections.temperatureAdjSec + corrections.heartRateAdjSec
        return score(distanceM, adjustedTime)
    }
    
    /**
     * Find the minimum elapsed time needed to reach a target score for a given distance.
     * Uses binary search for precision.
     * @param distanceM Distance in meters
     * @param targetScore Target points score
     * @return Minimum elapsed time in seconds
     */
    fun requiredTimeFor(distanceM: Double, targetScore: Double): Double {
        if (distanceM <= 0 || targetScore <= MIN_POINTS) return Double.MAX_VALUE
        if (targetScore >= MAX_POINTS) return 0.0
        
        val baselineTime = PurdyTable.getBaselineTime(distanceM)
        
        // Binary search bounds
        var low = 0.1 // Very fast time
        var high = baselineTime * 3.0 // Very slow time
        
        // Binary search for required time
        repeat(50) { // Sufficient precision
            val mid = (low + high) / 2.0
            val score = score(distanceM, mid)
            
            if (score >= targetScore) {
                high = mid
            } else {
                low = mid
            }
        }
        
        return high
    }
    
    /**
     * Calculate required pace in seconds per kilometer to achieve target score.
     * @param distanceM Distance in meters
     * @param targetScore Target points score
     * @return Required pace in seconds per kilometer
     */
    fun requiredPaceSecPerKm(distanceM: Double, targetScore: Double): Double {
        val requiredTime = requiredTimeFor(distanceM, targetScore)
        val distanceKm = distanceM / 1000.0
        return requiredTime / distanceKm
    }
    
    /**
     * Get performance ratio for a given distance and time.
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @return Performance ratio (1.0 = elite baseline, >1.0 = slower, <1.0 = faster)
     */
    fun getPerformanceRatio(distanceM: Double, elapsedSec: Double): Double {
        val baselineTime = PurdyTable.getBaselineTime(distanceM)
        return baselineTime / elapsedSec
    }
    
    /**
     * Get baseline time for a given distance.
     * @param distanceM Distance in meters
     * @return Elite baseline time in seconds
     */
    fun getBaselineTime(distanceM: Double): Double {
        return PurdyTable.getBaselineTime(distanceM)
    }
}
