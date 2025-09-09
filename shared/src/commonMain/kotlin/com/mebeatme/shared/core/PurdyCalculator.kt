package com.mebeatme.shared.core

import kotlin.math.*

/**
 * Corrected Purdy score calculation implementation
 * Based on the fixed formula from the dashboard/server corrections
 */
object PurdyCalculator {
    
    // Elite baseline times (in seconds) - realistic values
    private val baselines = listOf(
        BaselineAnchor(1500.0, 210.0),    // 3:30
        BaselineAnchor(5000.0, 755.0),     // 12:35 
        BaselineAnchor(10000.0, 1571.0),   // 26:11
        BaselineAnchor(21097.0, 3540.0),  // 59:00
        BaselineAnchor(42195.0, 7460.0)   // 2:04:20
    )
    
    private data class BaselineAnchor(
        val distanceMeters: Double,
        val timeSeconds: Double
    )
    
    /**
     * Calculate Purdy score using corrected formula
     * @param distanceMeters Distance in meters
     * @param durationSec Duration in seconds
     * @return Purdy score (100-2000 range)
     * @throws IllegalArgumentException if inputs are invalid
     */
    @Throws(IllegalArgumentException::class)
    fun purdyScore(distanceMeters: Double, durationSec: Int): Double {
        if (distanceMeters <= 0 || durationSec <= 0) {
            throw IllegalArgumentException("Distance and duration must be positive")
        }
        
        val baselineTime = getInterpolatedBaselineTime(distanceMeters)
        val performanceRatio = durationSec.toDouble() / baselineTime
        
        // Corrected Purdy formula: PPI = 1000 * (actual_time / baseline_time)^(-2.0)
        val rawScore = 1000.0 * performanceRatio.pow(-2.0)
        
        return rawScore.coerceIn(100.0, 2000.0)
    }
    
    /**
     * Calculate target pace to achieve a specific Purdy score
     * @param distanceMeters Distance in meters
     * @param windowSec Duration window in seconds
     * @return Required pace in seconds per kilometer
     * @throws IllegalArgumentException if inputs are invalid
     */
    @Throws(IllegalArgumentException::class)
    fun targetPace(distanceMeters: Double, windowSec: Int): Double {
        if (distanceMeters <= 0 || windowSec <= 0) {
            throw IllegalArgumentException("Distance and window must be positive")
        }
        
        // For now, return a simple calculation
        // This could be enhanced to calculate pace needed for specific PPI targets
        return windowSec.toDouble() / (distanceMeters / 1000.0)
    }
    
    /**
     * Get interpolated baseline time for a given distance
     */
    private fun getInterpolatedBaselineTime(distanceMeters: Double): Double {
        // Handle edge cases
        if (distanceMeters <= baselines.first().distanceMeters) {
            return baselines.first().timeSeconds
        }
        if (distanceMeters >= baselines.last().distanceMeters) {
            return baselines.last().timeSeconds
        }
        
        // Find surrounding anchors and interpolate
        for (i in 0 until baselines.size - 1) {
            val current = baselines[i]
            val next = baselines[i + 1]
            
            if (distanceMeters >= current.distanceMeters && distanceMeters <= next.distanceMeters) {
                // Linear interpolation in log-log space
                val logDist1 = ln(current.distanceMeters)
                val logDist2 = ln(next.distanceMeters)
                val logTime1 = ln(current.timeSeconds)
                val logTime2 = ln(next.timeSeconds)
                val logDistTarget = ln(distanceMeters)
                
                val ratio = (logDistTarget - logDist1) / (logDist2 - logDist1)
                val logTimeTarget = logTime1 + ratio * (logTime2 - logTime1)
                
                return exp(logTimeTarget)
            }
        }
        
        return baselines.last().timeSeconds
    }
}
