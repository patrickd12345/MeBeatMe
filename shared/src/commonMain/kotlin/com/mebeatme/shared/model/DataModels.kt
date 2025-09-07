package com.mebeatme.shared.model

import kotlinx.serialization.Serializable
import kotlinx.datetime.Instant

@Serializable
data class RunSession(
    val id: String,
    val distance: Double, // in meters
    val duration: Long, // in seconds
    val timestamp: Instant,
    val pace: Double, // seconds per kilometer
    val samples: List<RunSample> = emptyList()
)

@Serializable
data class RunSample(
    val timestamp: Instant,
    val distance: Double,
    val pace: Double
)

@Serializable
data class Score(
    val ppi: Double,
    val bucket: DistanceBucket,
    val targetPace: Double? = null,
    val targetDuration: Long? = null,
    val achieved: Boolean = false
)

@Serializable
enum class DistanceBucket(val minKm: Double, val maxKm: Double) {
    SHORT_SPRINT(0.0, 1.0),
    SPRINT(1.0, 3.0),
    SHORT_RUN(3.0, 8.0),
    MEDIUM_RUN(8.0, 15.0),
    LONG_RUN(15.0, 25.0),
    ULTRA_RUN(25.0, Double.MAX_VALUE);
    
    fun contains(distanceKm: Double): Boolean = distanceKm >= minKm && distanceKm < maxKm
}

@Serializable
data class UserPrefs(
    val units: DistanceUnit = DistanceUnit.METRIC,
    val hapticsEnabled: Boolean = true,
    val privacyMode: Boolean = false
)

@Serializable
enum class DistanceUnit {
    METRIC, IMPERIAL
}

@Serializable
data class ChallengeOption(
    val id: String,
    val title: String,
    val description: String,
    val targetPace: Double, // seconds per km
    val targetDuration: Long, // seconds
    val targetDistance: Double, // meters
    val expectedPpi: Double,
    val bucket: DistanceBucket
)
