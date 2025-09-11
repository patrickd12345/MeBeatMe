package com.mebeatme.core

import kotlinx.serialization.Serializable

@Serializable data class LiveSession(
    val choice: BeatChoice,
    val startTimeMs: Long,
    val currentDistanceM: Double = 0.0,
    val currentElapsedSec: Double = 0.0,
    val currentPaceSecPerKm: Double = 0.0,
    val isActive: Boolean = true,
    val targetPPI: Double = 0.0
) {
    // Current PPI based on current distance and elapsed time
    val currentPPI: Double
        get() = if (currentDistanceM > 0 && currentElapsedSec > 0) {
            com.mebeatme.core.ppi.PpiEngine.score(currentDistanceM, currentElapsedSec)
        } else {
            0.0
        }
    
    // Time to reach target PPI at current pace
    val timeToBeatTargetPPI: String
        get() = calculateTimeToBeat()
    fun progressPercentage(): Double {
        val timeProgress = currentElapsedSec / choice.windowSeconds
        val distanceProgress = currentDistanceM / (choice.targetPaceSecPerKm * choice.windowSeconds / 1000.0)
        return minOf(timeProgress, distanceProgress, 1.0)
    }
    
    fun isOnTargetPace(toleranceSecPerKm: Int = 10): Boolean {
        val diff = kotlin.math.abs(currentPaceSecPerKm - choice.targetPaceSecPerKm)
        return diff <= toleranceSecPerKm
    }
    
    fun complete(): RunSession {
        return RunSession(
            id = "session_${startTimeMs}",
            startEpochMs = startTimeMs,
            distanceMeters = currentDistanceM,
            elapsedSeconds = currentElapsedSec
        )
    }
    
    private fun calculateTimeToBeat(): String {
        if (targetPPI <= 0 || currentDistanceM <= 0 || currentElapsedSec <= 0) {
            return "--"
        }
        
        // If we're already at or above target, show "ACHIEVED"
        if (currentPPI >= targetPPI) {
            return "ACHIEVED"
        }
        
        // Calculate how much more distance/time we need to reach target PPI
        // Using the PPI engine to find required time for target score
        
        // Calculate required time for target PPI at current distance
        val requiredTimeForCurrentDistance = com.mebeatme.core.ppi.PpiEngine.requiredTimeFor(currentDistanceM, targetPPI)
        
        if (requiredTimeForCurrentDistance <= currentElapsedSec) {
            return "ACHIEVED"
        }
        
        // Calculate remaining time needed
        val remainingTimeSeconds = requiredTimeForCurrentDistance - currentElapsedSec
        
        // Convert to minutes/hours
        val remainingTimeMinutes = (remainingTimeSeconds / 60).toInt()
        
        return when {
            remainingTimeMinutes < 60 -> "${remainingTimeMinutes}m"
            else -> {
                val hours = remainingTimeMinutes / 60
                val minutes = remainingTimeMinutes % 60
                "${hours}h ${minutes}m"
            }
        }
    }
}
