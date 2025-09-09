package com.mebeatme.shared.bridge

import com.mebeatme.shared.core.purdyScore
import com.mebeatme.shared.core.targetPace
import com.mebeatme.shared.core.highestPpiInWindow
import com.mebeatme.shared.api.RunDTO

/**
 * Android/Wear OS bridge to KMP shared module
 * Following the HYBRID PROMPT specifications
 * 
 * This object provides a clean interface for Android and Wear OS apps
 * to access the unified Purdy/PPI calculations from the shared module.
 */
object PerfIndex {
    
    /**
     * Calculate Purdy score using shared KMP implementation
     * @param distanceMeters Distance in meters
     * @param durationSec Duration in seconds
     * @return Purdy score (100-2000 range)
     * @throws IllegalArgumentException if inputs are invalid
     */
    fun purdyScore(distanceMeters: Double, durationSec: Int): Double {
        return purdyScore(distanceMeters, durationSec)
    }
    
    /**
     * Calculate target pace using shared KMP implementation
     * @param distanceMeters Distance in meters
     * @param windowSec Duration window in seconds
     * @return Required pace in seconds per kilometer
     * @throws IllegalArgumentException if inputs are invalid
     */
    fun targetPace(distanceMeters: Double, windowSec: Int): Double {
        return targetPace(distanceMeters, windowSec)
    }
    
    /**
     * Calculate highest PPI in 90-day window
     * @param runs List of runs to analyze
     * @param nowMs Current time in milliseconds
     * @param days Number of days to look back (default 90)
     * @return Highest PPI in the window, or null if no runs
     */
    fun highestPpiInWindow(runs: List<RunDTO>, nowMs: Long, days: Int = 90): Double? {
        return highestPpiInWindow(runs, nowMs, days)
    }
}