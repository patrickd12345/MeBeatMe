package com.mebeatme.core.ppi

import com.mebeatme.core.Corrections
import com.mebeatme.core.HeartRatePoint

/**
 * PPI model types available in the system.
 */
enum class PpiModel {
    /** Original transparent v0 formula */
    TransparentV0,
    /** New Purdy-based SPI-like scoring */
    PurdyV1
}

/**
 * Unified PPI engine that can switch between different scoring models at runtime.
 * Provides a single facade for all PPI calculations.
 */
object PpiEngine {
    /**
     * Currently active PPI model. Defaults to PurdyV1.
     */
    var model: PpiModel = PpiModel.PurdyV1
    
    /**
     * Calculate PPI score using the active model.
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @param corr Elevation and temperature corrections
     * @return Points score
     */
    fun score(distanceM: Double, elapsedSec: Double, corr: Corrections = Corrections()): Double =
        when (model) {
            PpiModel.TransparentV0 -> PpiCurveTransparent.correctedScore(distanceM, elapsedSec, corr)
            PpiModel.PurdyV1 -> PpiCurvePurdy.score(distanceM, elapsedSec + corr.elevationAdjSec + corr.temperatureAdjSec + corr.heartRateAdjSec)
        }
    
    /**
     * Calculate required pace in seconds per kilometer to achieve target score.
     * @param targetScore Target points score
     * @param windowSeconds Time window in seconds (used for Purdy model)
     * @param distanceForWindowM Distance in meters
     * @return Required pace in seconds per kilometer
     */
    fun requiredPaceSecPerKm(targetScore: Double, windowSeconds: Int, distanceForWindowM: Double): Double {
        return when (model) {
            PpiModel.TransparentV0 -> {
                PpiCurveTransparent.requiredPaceSecPerKm(targetScore, windowSeconds, distanceForWindowM)
            }
            PpiModel.PurdyV1 -> {
                PpiCurvePurdy.requiredPaceSecPerKm(distanceForWindowM, targetScore)
            }
        }
    }
    
    /**
     * Find the minimum elapsed time needed to reach a target score for a given distance.
     * @param distanceM Distance in meters
     * @param targetScore Target points score
     * @return Minimum elapsed time in seconds
     */
    fun requiredTimeFor(distanceM: Double, targetScore: Double): Double {
        return when (model) {
            PpiModel.TransparentV0 -> PpiCurveTransparent.requiredTimeFor(distanceM, targetScore)
            PpiModel.PurdyV1 -> PpiCurvePurdy.requiredTimeFor(distanceM, targetScore)
        }
    }
    
    /**
     * Get the version string of the currently active model.
     * @return Model version string
     */
    fun getCurrentModelVersion(): String {
        return when (model) {
            PpiModel.TransparentV0 -> PpiCurveTransparent.version
            PpiModel.PurdyV1 -> PpiCurvePurdy.version
        }
    }
    
    /**
     * Get performance ratio for the current model (Purdy only).
     * @param distanceM Distance in meters
     * @param elapsedSec Elapsed time in seconds
     * @return Performance ratio (1.0 = baseline, >1.0 = slower, <1.0 = faster)
     */
    fun getPerformanceRatio(distanceM: Double, elapsedSec: Double): Double? {
        return when (model) {
            PpiModel.TransparentV0 -> null // Not applicable for transparent model
            PpiModel.PurdyV1 -> PpiCurvePurdy.getPerformanceRatio(distanceM, elapsedSec)
        }
    }
    
    /**
     * Get baseline time for the current model (Purdy only).
     * @param distanceM Distance in meters
     * @return Elite baseline time in seconds, or null if not applicable
     */
    fun getBaselineTime(distanceM: Double): Double? {
        return when (model) {
            PpiModel.TransparentV0 -> null // Not applicable for transparent model
            PpiModel.PurdyV1 -> PpiCurvePurdy.getBaselineTime(distanceM)
        }
    }
    
    /**
     * Calculate PPI score using heart rate-based effort segmentation.
     * This method segments the run based on heart rate variations and applies
     * effort-based corrections to provide more accurate scoring.
     * 
     * @param distanceM Total distance in meters
     * @param elapsedSec Total elapsed time in seconds
     * @param heartRateData List of heart rate points throughout the run
     * @param userMaxHR User's maximum heart rate
     * @param baselineHR User's baseline heart rate (defaults to 60% of max)
     * @param corr Additional corrections (elevation, temperature)
     * @return Weighted average PPI score across heart rate segments
     */
    fun scoreWithHeartRate(
        distanceM: Double,
        elapsedSec: Double,
        heartRateData: List<HeartRatePoint>?,
        userMaxHR: Int,
        baselineHR: Int = (userMaxHR * 0.6).toInt(),
        corr: Corrections = Corrections()
    ): Double {
        return HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, heartRateData, userMaxHR, baselineHR, corr
        )
    }
}
