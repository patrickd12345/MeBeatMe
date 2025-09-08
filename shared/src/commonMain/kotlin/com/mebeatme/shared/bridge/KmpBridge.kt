package com.mebeatme.shared.bridge

import com.mebeatme.shared.core.*
import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO

/**
 * Bridge between Android/Wear and Kotlin Multiplatform Shared module
 * Provides access to core PPI calculations and shared functions
 */
object PerfIndex {
    
    /**
     * Calculate Purdy score using the cubic relationship: P = 1000 × (T₀/T)³
     * @param distanceMeters Distance in meters
     * @param durationSec Duration in seconds
     * @return Purdy score (1-1000+ points)
     * @throws IllegalArgumentException if inputs are invalid
     */
    fun purdyScore(distanceMeters: Double, durationSec: Int): Double {
        return com.mebeatme.shared.core.purdyScore(distanceMeters, durationSec)
    }
    
    /**
     * Calculate target pace in seconds per kilometer
     * @param distanceMeters Distance in meters
     * @param windowSec Time window in seconds
     * @return Target pace in seconds per kilometer
     * @throws IllegalArgumentException if inputs are invalid
     */
    fun targetPace(distanceMeters: Double, windowSec: Int): Double {
        return com.mebeatme.shared.core.targetPace(distanceMeters, windowSec)
    }
    
    /**
     * Calculate the highest PPI in the last N days from a list of runs
     * @param runs List of runs to analyze
     * @param nowMs Current timestamp in milliseconds
     * @param days Number of days to look back (default 90)
     * @return Highest PPI in the window, or null if no runs found
     */
    fun highestPpiInWindow(runs: List<RunDTO>, nowMs: Long, days: Int = 90): Double? {
        return com.mebeatme.shared.core.highestPpiInWindow(runs, nowMs, days)
    }
    
    /**
     * Calculate best times for standard distances
     * @param runs List of runs to analyze
     * @param sinceMs Only consider runs after this timestamp (default 0 = all time)
     * @return BestsDTO with best times for 5K, 10K, Half, Full
     */
    fun calculateBests(runs: List<RunDTO>, sinceMs: Long = 0L): BestsDTO {
        return com.mebeatme.shared.core.calculateBests(runs, sinceMs)
    }
    
    /**
     * Calculate PPI for a RunDTO using the Purdy score function
     * @param runDTO Run to calculate PPI for
     * @return RunDTO with PPI calculated
     */
    fun calculatePpiForRun(runDTO: RunDTO): RunDTO {
        return runDTO.calculatePpi()
    }
    
    /**
     * Convert RunSession to RunDTO for cross-platform compatibility
     * @param runSession RunSession to convert
     * @return RunDTO equivalent
     */
    fun runSessionToDto(runSession: com.mebeatme.shared.model.RunSession): RunDTO {
        return runSession.toRunDTO()
    }
}

