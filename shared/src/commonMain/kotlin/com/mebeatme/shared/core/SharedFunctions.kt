package com.mebeatme.shared.core

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO
import com.mebeatme.shared.model.RunSession
import kotlinx.datetime.Clock
import kotlin.math.*

/**
 * Core shared functions for cross-platform PPI calculations.
 * These functions are used by all clients (iOS, watchOS, Android, Wear) and the server.
 */

/**
 * Calculate Purdy score using the cubic relationship: P = 1000 × (T₀/T)³
 * @param distanceMeters Distance in meters
 * @param durationSec Duration in seconds
 * @return Purdy score (1-1000+ points)
 * @throws IllegalArgumentException if distance or duration is invalid
 */
@Throws(IllegalArgumentException::class)
fun purdyScore(distanceMeters: Double, durationSec: Int): Double {
    if (distanceMeters <= 0.0) {
        throw IllegalArgumentException("Distance must be positive")
    }
    if (durationSec <= 0) {
        throw IllegalArgumentException("Duration must be positive")
    }
    
    // Purdy baseline times for different distances (in seconds)
    val baselineTimes = mapOf(
        100.0 to 10.0,      // 100m in 10.0s
        200.0 to 20.0,      // 200m in 20.0s
        400.0 to 45.0,      // 400m in 45.0s
        800.0 to 105.0,     // 800m in 1:45
        1500.0 to 210.0,    // 1500m in 3:30
        3000.0 to 450.0,    // 3000m in 7:30
        5000.0 to 780.0,    // 5000m in 13:00
        10000.0 to 1620.0,  // 10000m in 27:00
        21097.5 to 3540.0,  // Half marathon in 59:00
        42195.0 to 7260.0   // Marathon in 2:01:00
    )
    
    // Find closest baseline distance
    val closestDistance = baselineTimes.keys.minByOrNull { abs(it - distanceMeters) } ?: 5000.0
    val baselineTime = baselineTimes[closestDistance]!!
    
    // Calculate cubic relationship: P = 1000 × (T₀/T)³
    val ratio = baselineTime.toDouble() / durationSec.toDouble()
    val score = 1000.0 * (ratio * ratio * ratio)
    
    return score.coerceAtLeast(0.0)
}

/**
 * Calculate target pace in seconds per kilometer for a given distance and time window.
 * @param distanceMeters Distance in meters
 * @param windowSec Time window in seconds
 * @return Target pace in seconds per kilometer
 * @throws IllegalArgumentException if distance or window is invalid
 */
@Throws(IllegalArgumentException::class)
fun targetPace(distanceMeters: Double, windowSec: Int): Double {
    if (distanceMeters <= 0.0) {
        throw IllegalArgumentException("Distance must be positive")
    }
    if (windowSec <= 0) {
        throw IllegalArgumentException("Time window must be positive")
    }
    
    val distanceKm = distanceMeters / 1000.0
    return windowSec.toDouble() / distanceKm
}

/**
 * Calculate the highest PPI in the last N days from a list of runs.
 * @param runs List of runs to analyze
 * @param nowMs Current timestamp in milliseconds
 * @param days Number of days to look back (default 90)
 * @return Highest PPI in the window, or null if no runs found
 */
fun highestPpiInWindow(runs: List<RunDTO>, nowMs: Long, days: Int = 90): Double? {
    val cutoffMs = nowMs - (days * 24L * 3600_000)
    
    return runs
        .filter { it.startedAtEpochMs >= cutoffMs }
        .mapNotNull { it.ppi }
        .maxOrNull()
}

/**
 * Calculate best times for standard distances from a list of runs.
 * @param runs List of runs to analyze
 * @param sinceMs Only consider runs after this timestamp (default 0 = all time)
 * @return BestsDTO with best times for 5K, 10K, Half, Full
 */
fun calculateBests(runs: List<RunDTO>, sinceMs: Long = 0L): BestsDTO {
    val filteredRuns = runs.filter { it.startedAtEpochMs >= sinceMs }
    
    val best5k = filteredRuns
        .filter { it.distanceMeters >= 4900 && it.distanceMeters <= 5100 }
        .minByOrNull { it.elapsedSeconds }
        ?.elapsedSeconds
    
    val best10k = filteredRuns
        .filter { it.distanceMeters >= 9900 && it.distanceMeters <= 10100 }
        .minByOrNull { it.elapsedSeconds }
        ?.elapsedSeconds
    
    val bestHalf = filteredRuns
        .filter { it.distanceMeters >= 20900 && it.distanceMeters <= 21100 }
        .minByOrNull { it.elapsedSeconds }
        ?.elapsedSeconds
    
    val bestFull = filteredRuns
        .filter { it.distanceMeters >= 41900 && it.distanceMeters <= 42200 }
        .minByOrNull { it.elapsedSeconds }
        ?.elapsedSeconds
    
    val highestPPILast90Days = highestPpiInWindow(runs, Clock.System.now().toEpochMilliseconds(), 90)
    
    return BestsDTO(
        best5kSec = best5k,
        best10kSec = best10k,
        bestHalfSec = bestHalf,
        bestFullSec = bestFull,
        highestPPILast90Days = highestPPILast90Days
    )
}

/**
 * Convert RunSession to RunDTO for cross-platform compatibility.
 */
fun RunSession.toRunDTO(): RunDTO {
    return RunDTO(
        id = this.id,
        source = "Manual", // Default source
        startedAtEpochMs = this.timestamp.toEpochMilliseconds(),
        endedAtEpochMs = this.timestamp.toEpochMilliseconds() + this.duration * 1000,
        distanceMeters = this.distance,
        elapsedSeconds = this.duration.toInt(),
        avgPaceSecPerKm = this.pace,
        ppi = null // Will be calculated separately
    )
}

/**
 * Calculate PPI for a RunDTO using the Purdy score function.
 */
fun RunDTO.calculatePpi(): RunDTO {
    return this.copy(ppi = purdyScore(this.distanceMeters, this.elapsedSeconds))
}

