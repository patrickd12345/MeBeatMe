package com.mebeatme.shared.core

import com.mebeatme.shared.model.DistanceBucket
import kotlin.math.*

/**
 * Implementation of the Purdy Points model for Performance Index calculation
 * Based on elite athlete tables updated in 1974
 */
object PurdyPointsCalculator {
    
    // Purdy Points table for different distances (in meters) and times (in seconds)
    // These are the reference points for elite performance
    private val purdyTable = mapOf(
        100.0 to 1000.0,      // 100m in 10.0s = 1000 points
        200.0 to 1000.0,      // 200m in 20.0s = 1000 points  
        400.0 to 1000.0,      // 400m in 45.0s = 1000 points
        800.0 to 1000.0,      // 800m in 1:45 = 1000 points
        1500.0 to 1000.0,     // 1500m in 3:30 = 1000 points
        3000.0 to 1000.0,     // 3000m in 7:30 = 1000 points
        5000.0 to 1000.0,     // 5000m in 13:00 = 1000 points
        10000.0 to 1000.0,    // 10000m in 27:00 = 1000 points
        21097.5 to 1000.0,    // Half marathon in 1:00:00 = 1000 points
        42195.0 to 1000.0     // Marathon in 2:10:00 = 1000 points
    )
    
    /**
     * Calculate Performance Index (PPI) using Purdy Points model
     * @param distance Distance in meters
     * @param time Time in seconds
     * @return Performance Index score
     */
    fun calculatePPI(distance: Double, time: Long): Double {
        val distanceKm = distance / 1000.0
        val timeMinutes = time / 60.0
        
        // Find the closest reference distance
        val referenceDistance = findClosestReference(distanceKm * 1000)
        val referenceTime = purdyTable[referenceDistance]!!
        
        // Calculate pace ratio
        val actualPace = timeMinutes / distanceKm
        val referencePace = (referenceTime / 60.0) / (referenceDistance / 1000.0)
        
        // Apply power curve adjustment (Purdy model uses power of ~1.07)
        val powerFactor = 1.07
        val paceRatio = actualPace / referencePace
        
        // Calculate PPI with logarithmic scaling
        val ppi = 1000.0 * (paceRatio.pow(-powerFactor))
        
        return ppi.coerceIn(0.0, 2000.0) // Reasonable bounds
    }
    
    /**
     * Calculate required pace to achieve target PPI
     * @param distance Distance in meters
     * @param targetPPI Target Performance Index
     * @return Required pace in seconds per kilometer
     */
    fun calculateRequiredPace(distance: Double, targetPPI: Double): Double {
        val distanceKm = distance / 1000.0
        val referenceDistance = findClosestReference(distance)
        val referenceTime = purdyTable[referenceDistance]!!
        
        val powerFactor = 1.07
        val referencePace = (referenceTime / 60.0) / (referenceDistance / 1000.0)
        
        // Reverse the PPI calculation
        val paceRatio = (1000.0 / targetPPI).pow(1.0 / powerFactor)
        val requiredPace = referencePace * paceRatio
        
        return requiredPace * 60.0 // Convert to seconds per km
    }
    
    /**
     * Calculate required time to achieve target PPI
     * @param distance Distance in meters
     * @param targetPPI Target Performance Index
     * @return Required time in seconds
     */
    fun calculateRequiredTime(distance: Double, targetPPI: Double): Long {
        val requiredPace = calculateRequiredPace(distance, targetPPI)
        val distanceKm = distance / 1000.0
        return (requiredPace * distanceKm).toLong()
    }
    
    private fun findClosestReference(distance: Double): Double {
        return purdyTable.keys.minByOrNull { abs(it - distance) } ?: 5000.0
    }
}

/**
 * Utility functions for pace and time conversions
 */
object PaceUtils {

    fun metersPerSecondToSecondsPerKm(metersPerSecond: Double): Double =
        if (metersPerSecond == 0.0) Double.POSITIVE_INFINITY else 1000.0 / metersPerSecond

    fun secondsPerKmToMetersPerSecond(secondsPerKm: Double): Double =
        if (secondsPerKm == 0.0) 0.0 else 1000.0 / secondsPerKm

    fun metersPerSecondToMinutesPerKm(metersPerSecond: Double): Double =
        secondsPerKmToMinutesPerKm(metersPerSecondToSecondsPerKm(metersPerSecond))

    fun minutesPerKmToMetersPerSecond(minutesPerKm: Double): Double =
        secondsPerKmToMetersPerSecond(minutesPerKmToSecondsPerKm(minutesPerKm))

    fun secondsPerKmToMinutesPerKm(secondsPerKm: Double): Double = secondsPerKm / 60.0

    fun minutesPerKmToSecondsPerKm(minutesPerKm: Double): Double = minutesPerKm * 60.0
    
    fun formatPace(secondsPerKm: Double): String {
        val minutes = (secondsPerKm / 60).toInt()
        val seconds = (secondsPerKm % 60).toInt()
        return String.format("%d:%02d", minutes, seconds)
    }
    
    fun parsePace(paceString: String): Double {
        val parts = paceString.split(":")
        if (parts.size != 2) return 0.0
        
        val minutes = parts[0].toIntOrNull() ?: 0
        val seconds = parts[1].toIntOrNull() ?: 0
        
        return minutes * 60.0 + seconds
    }
}
