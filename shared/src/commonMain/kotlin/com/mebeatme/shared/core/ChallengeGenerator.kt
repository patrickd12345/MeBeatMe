package com.mebeatme.shared.core

import com.mebeatme.shared.model.ChallengeOption
import com.mebeatme.shared.model.DistanceBucket
import kotlin.random.Random

/**
 * Generates multiple-choice challenges to beat historical best performance
 */
class ChallengeGenerator(
    private val bucketManager: PerformanceBucketManager
) {
    
    /**
     * Generate 4 challenge options: 3 specific + 1 surprise
     */
    fun generateChallenges(): List<ChallengeOption> {
        val challenges = mutableListOf<ChallengeOption>()
        
        // Get buckets with historical data
        val availableBuckets = bucketManager.getBucketStats()
            .filter { it.value.hasData }
            .keys.toList()
        
        if (availableBuckets.isEmpty()) {
            return generateDefaultChallenges()
        }
        
        // Generate 3 specific challenges
        challenges.addAll(generateSpecificChallenges(availableBuckets))
        
        // Add surprise option
        challenges.add(generateSurpriseChallenge(availableBuckets))
        
        return challenges.shuffled()
    }
    
    private fun generateSpecificChallenges(buckets: List<DistanceBucket>): List<ChallengeOption> {
        val challenges = mutableListOf<ChallengeOption>()
        
        // Challenge 1: Short & Fierce (Sprint bucket)
        val sprintBucket = buckets.find { it == DistanceBucket.SPRINT } 
            ?: buckets.find { it == DistanceBucket.SHORT_SPRINT }
            ?: buckets.first()
        
        if (sprintBucket != null) {
            challenges.add(generateShortFierceChallenge(sprintBucket))
        }
        
        // Challenge 2: Tempo Boost (Short Run bucket)
        val tempoBucket = buckets.find { it == DistanceBucket.SHORT_RUN }
            ?: buckets.find { it == DistanceBucket.MEDIUM_RUN }
            ?: buckets.first()
        
        if (tempoBucket != null) {
            challenges.add(generateTempoBoostChallenge(tempoBucket))
        }
        
        // Challenge 3: Ease Into It (Medium/Long Run bucket)
        val longBucket = buckets.find { it == DistanceBucket.MEDIUM_RUN }
            ?: buckets.find { it == DistanceBucket.LONG_RUN }
            ?: buckets.first()
        
        if (longBucket != null) {
            challenges.add(generateEaseIntoItChallenge(longBucket))
        }
        
        return challenges
    }
    
    private fun generateShortFierceChallenge(bucket: DistanceBucket): ChallengeOption {
        val historicalBest = bucketManager.getHistoricalBest(bucket)
        val targetPPI = historicalBest + 5.0 // Small improvement
        
        val targetDistance = getRandomDistanceInBucket(bucket)
        val targetPace = PurdyPointsCalculator.calculateRequiredPace(targetDistance, targetPPI)
        val targetDuration = PurdyPointsCalculator.calculateRequiredTime(targetDistance, targetPPI)
        
        return ChallengeOption(
            id = "short_fierce_${System.currentTimeMillis()}",
            title = "Short & Fierce",
            description = "Hold ${PaceUtils.formatPace(targetPace)}/km for ${formatDuration(targetDuration)} to top your best ${bucket.name.lowercase()} equivalent",
            targetPace = targetPace,
            targetDuration = targetDuration,
            targetDistance = targetDistance,
            expectedPpi = targetPPI,
            bucket = bucket
        )
    }
    
    private fun generateTempoBoostChallenge(bucket: DistanceBucket): ChallengeOption {
        val historicalBest = bucketManager.getHistoricalBest(bucket)
        val targetPPI = historicalBest + 3.0 // Moderate improvement
        
        val targetDistance = getRandomDistanceInBucket(bucket)
        val targetPace = PurdyPointsCalculator.calculateRequiredPace(targetDistance, targetPPI)
        val targetDuration = PurdyPointsCalculator.calculateRequiredTime(targetDistance, targetPPI)
        
        return ChallengeOption(
            id = "tempo_boost_${System.currentTimeMillis()}",
            title = "Tempo Boost",
            description = "Sustain ${PaceUtils.formatPace(targetPace)}/km for ${formatDuration(targetDuration)} to beat your tempo index",
            targetPace = targetPace,
            targetDuration = targetDuration,
            targetDistance = targetDistance,
            expectedPpi = targetPPI,
            bucket = bucket
        )
    }
    
    private fun generateEaseIntoItChallenge(bucket: DistanceBucket): ChallengeOption {
        val historicalBest = bucketManager.getHistoricalBest(bucket)
        val targetPPI = historicalBest + 2.0 // Small improvement for longer distance
        
        val targetDistance = getRandomDistanceInBucket(bucket)
        val targetPace = PurdyPointsCalculator.calculateRequiredPace(targetDistance, targetPPI)
        val targetDuration = PurdyPointsCalculator.calculateRequiredTime(targetDistance, targetPPI)
        
        return ChallengeOption(
            id = "ease_into_it_${System.currentTimeMillis()}",
            title = "Ease Into It",
            description = "Cruise at ${PaceUtils.formatPace(targetPace)}/km for ${formatDuration(targetDuration)} and still crack your long-run PPI",
            targetPace = targetPace,
            targetDuration = targetDuration,
            targetDistance = targetDistance,
            expectedPpi = targetPPI,
            bucket = bucket
        )
    }
    
    private fun generateSurpriseChallenge(buckets: List<DistanceBucket>): ChallengeOption {
        val randomBucket = buckets.random()
        val historicalBest = bucketManager.getHistoricalBest(randomBucket)
        val targetPPI = historicalBest + Random.nextDouble(1.0, 8.0) // Random improvement
        
        val targetDistance = getRandomDistanceInBucket(randomBucket)
        val targetPace = PurdyPointsCalculator.calculateRequiredPace(targetDistance, targetPPI)
        val targetDuration = PurdyPointsCalculator.calculateRequiredTime(targetDistance, targetPPI)
        
        return ChallengeOption(
            id = "surprise_${System.currentTimeMillis()}",
            title = "Surprise Me",
            description = "Let MeBeatMe choose a playful but beatable run for you",
            targetPace = targetPace,
            targetDuration = targetDuration,
            targetDistance = targetDistance,
            expectedPpi = targetPPI,
            bucket = randomBucket
        )
    }
    
    private fun generateDefaultChallenges(): List<ChallengeOption> {
        return listOf(
            ChallengeOption(
                id = "default_1",
                title = "Short & Fierce",
                description = "Run 1km in 4:30 to establish your baseline",
                targetPace = 270.0, // 4:30/km
                targetDuration = 270,
                targetDistance = 1000.0,
                expectedPpi = 500.0,
                bucket = DistanceBucket.SPRINT
            ),
            ChallengeOption(
                id = "default_2", 
                title = "Tempo Boost",
                description = "Run 5km in 25:00 to establish your baseline",
                targetPace = 300.0, // 5:00/km
                targetDuration = 1500,
                targetDistance = 5000.0,
                expectedPpi = 400.0,
                bucket = DistanceBucket.SHORT_RUN
            ),
            ChallengeOption(
                id = "default_3",
                title = "Ease Into It", 
                description = "Run 10km in 55:00 to establish your baseline",
                targetPace = 330.0, // 5:30/km
                targetDuration = 3300,
                targetDistance = 10000.0,
                expectedPpi = 350.0,
                bucket = DistanceBucket.MEDIUM_RUN
            ),
            ChallengeOption(
                id = "default_4",
                title = "Surprise Me",
                description = "Let MeBeatMe choose a playful run for you",
                targetPace = 300.0,
                targetDuration = 1800,
                targetDistance = 3000.0,
                expectedPpi = 450.0,
                bucket = DistanceBucket.SHORT_RUN
            )
        )
    }
    
    private fun getRandomDistanceInBucket(bucket: DistanceBucket): Double {
        val minKm = bucket.minKm
        val maxKm = bucket.maxKm
        val randomKm = minKm + Random.nextDouble() * (maxKm - minKm)
        return randomKm * 1000.0 // Convert to meters
    }
    
    private fun formatDuration(seconds: Long): String {
        val minutes = seconds / 60
        val remainingSeconds = seconds % 60
        return if (minutes > 0) {
            String.format("%d:%02d", minutes, remainingSeconds)
        } else {
            "${remainingSeconds}s"
        }
    }
}
