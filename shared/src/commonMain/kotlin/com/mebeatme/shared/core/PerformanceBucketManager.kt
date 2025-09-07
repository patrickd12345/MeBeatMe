package com.mebeatme.shared.core

import com.mebeatme.shared.model.DistanceBucket
import com.mebeatme.shared.model.RunSession
import com.mebeatme.shared.model.Score

/**
 * Manages comparable performance bins and historical best tracking
 */
class PerformanceBucketManager {
    
    private val historicalBests = mutableMapOf<DistanceBucket, Double>()
    
    /**
     * Update historical best PPI for a given bucket
     */
    fun updateHistoricalBest(session: RunSession): Double {
        val bucket = getBucketForDistance(session.distance)
        val ppi = PurdyPointsCalculator.calculatePPI(session.distance, session.duration)
        
        val currentBest = historicalBests[bucket] ?: 0.0
        if (ppi > currentBest) {
            historicalBests[bucket] = ppi
        }
        
        return ppi
    }
    
    /**
     * Get historical best PPI for a bucket
     */
    fun getHistoricalBest(bucket: DistanceBucket): Double {
        return historicalBests[bucket] ?: 0.0
    }
    
    /**
     * Get all historical bests
     */
    fun getAllHistoricalBests(): Map<DistanceBucket, Double> {
        return historicalBests.toMap()
    }
    
    /**
     * Determine which bucket a distance falls into
     */
    fun getBucketForDistance(distance: Double): DistanceBucket {
        val distanceKm = distance / 1000.0
        return DistanceBucket.values().find { it.contains(distanceKm) } ?: DistanceBucket.MEDIUM_RUN
    }
    
    /**
     * Get bucket statistics
     */
    fun getBucketStats(): Map<DistanceBucket, BucketStats> {
        return DistanceBucket.values().associateWith { bucket ->
            BucketStats(
                bucket = bucket,
                historicalBest = getHistoricalBest(bucket),
                hasData = historicalBests.containsKey(bucket)
            )
        }
    }
}

data class BucketStats(
    val bucket: DistanceBucket,
    val historicalBest: Double,
    val hasData: Boolean
)
