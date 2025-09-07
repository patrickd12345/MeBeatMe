package com.mebeatme.core

import kotlinx.serialization.Serializable

@Serializable data class LiveSession(
    val choice: BeatChoice,
    val startTimeMs: Long,
    val currentDistanceM: Double = 0.0,
    val currentElapsedSec: Double = 0.0,
    val currentPaceSecPerKm: Double = 0.0,
    val isActive: Boolean = true
) {
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
}
