package com.mebeatme.core.ppi

import com.mebeatme.core.Corrections
import com.mebeatme.core.HeartRatePoint
import com.mebeatme.core.HeartRateSegment
import kotlin.math.abs
import kotlin.math.pow

/**
 * Heart rate-based PPI calculator that segments runs based on heart rate variations
 * and applies effort-based corrections to PPI calculations.
 */
object HeartRatePpiCalculator {
    
    /**
     * Calculates PPI score using heart rate-based effort segmentation.
     * 
     * @param distanceM Total distance in meters
     * @param elapsedSec Total elapsed time in seconds
     * @param heartRateData List of heart rate points throughout the run
     * @param userMaxHR User's maximum heart rate
     * @param baselineHR User's baseline/resting heart rate (defaults to 60% of max)
     * @param corr Additional corrections (elevation, temperature)
     * @return Weighted average PPI score across heart rate segments
     */
    fun calculateHeartRateBasedPPI(
        distanceM: Double,
        elapsedSec: Double,
        heartRateData: List<HeartRatePoint>?,
        userMaxHR: Int,
        baselineHR: Int = (userMaxHR * 0.6).toInt(),
        corr: Corrections = Corrections()
    ): Double {
        
        // If no heart rate data, fall back to standard calculation
        if (heartRateData.isNullOrEmpty()) {
            return PpiEngine.score(distanceM, elapsedSec, corr)
        }
        
        // Create heart rate-based segments
        val segments = createHeartRateSegments(heartRateData, distanceM, elapsedSec)
        
        // Calculate weighted PPI across segments
        var totalWeightedPPI = 0.0
        var totalDistance = 0.0
        
        segments.forEach { segment ->
            val hrAdjustment = calculateHeartRateEffortAdjustment(
                segment.averageHeartRate,
                baselineHR,
                userMaxHR
            )
            
            val segmentCorrections = Corrections(
                elevationAdjSec = corr.elevationAdjSec,
                temperatureAdjSec = corr.temperatureAdjSec,
                heartRateAdjSec = segment.durationSec * hrAdjustment
            )
            
            val segmentPPI = PpiEngine.score(segment.distanceM, segment.durationSec, segmentCorrections)
            totalWeightedPPI += segmentPPI * segment.distanceM
            totalDistance += segment.distanceM
        }
        
        return if (totalDistance > 0) totalWeightedPPI / totalDistance else 0.0
    }
    
    /**
     * Creates segments based on heart rate variations.
     * Segments are created when heart rate changes significantly (>10 BPM) or
     * when entering different heart rate zones.
     */
    private fun createHeartRateSegments(
        heartRateData: List<HeartRatePoint>,
        totalDistanceM: Double,
        totalElapsedSec: Double
    ): List<HeartRateSegment> {
        
        if (heartRateData.size < 2) {
            // Single segment for the entire run
            val avgHR = heartRateData.firstOrNull()?.heartRateBpm ?: 0
            return listOf(HeartRateSegment(
                startIndex = 0,
                endIndex = 0,
                averageHeartRate = avgHR,
                distanceM = totalDistanceM,
                durationSec = totalElapsedSec
            ))
        }
        
        val segments = mutableListOf<HeartRateSegment>()
        var currentSegmentStart = 0
        var currentSegmentHRSum = heartRateData[0].heartRateBpm
        var currentSegmentCount = 1
        
        for (i in 1 until heartRateData.size) {
            val currentHR = heartRateData[i].heartRateBpm
            val previousHR = heartRateData[i-1].heartRateBpm
            
            // Check if we should create a new segment
            val shouldCreateSegment = shouldCreateNewSegment(
                currentHR, previousHR, currentSegmentHRSum / currentSegmentCount
            )
            
            if (shouldCreateSegment && i > currentSegmentStart + 1) {
                // Create segment from currentSegmentStart to i-1
                val segmentDuration = calculateSegmentDuration(heartRateData, currentSegmentStart, i-1, totalElapsedSec)
                val segmentDistance = calculateSegmentDistance(currentSegmentStart, i-1, heartRateData.size, totalDistanceM)
                
                segments.add(HeartRateSegment(
                    startIndex = currentSegmentStart,
                    endIndex = i-1,
                    averageHeartRate = currentSegmentHRSum / currentSegmentCount,
                    distanceM = segmentDistance,
                    durationSec = segmentDuration
                ))
                
                // Start new segment
                currentSegmentStart = i
                currentSegmentHRSum = currentHR
                currentSegmentCount = 1
            } else {
                currentSegmentHRSum += currentHR
                currentSegmentCount++
            }
        }
        
        // Add final segment
        if (currentSegmentStart < heartRateData.size) {
            val segmentDuration = calculateSegmentDuration(heartRateData, currentSegmentStart, heartRateData.size-1, totalElapsedSec)
            val segmentDistance = calculateSegmentDistance(currentSegmentStart, heartRateData.size-1, heartRateData.size, totalDistanceM)
            
            segments.add(HeartRateSegment(
                startIndex = currentSegmentStart,
                endIndex = heartRateData.size-1,
                averageHeartRate = currentSegmentHRSum / currentSegmentCount,
                distanceM = segmentDistance,
                durationSec = segmentDuration
            ))
        }
        
        return segments
    }
    
    /**
     * Determines if a new segment should be created based on heart rate changes.
     */
    private fun shouldCreateNewSegment(
        currentHR: Int,
        previousHR: Int,
        segmentAvgHR: Int
    ): Boolean {
        // Create segment for significant heart rate changes
        val hrChange = abs(currentHR - previousHR)
        val hrDeviation = abs(currentHR - segmentAvgHR)
        
        return hrChange > 10 || hrDeviation > 15
    }
    
    /**
     * Calculates the duration of a segment based on heart rate data timestamps.
     */
    private fun calculateSegmentDuration(
        heartRateData: List<HeartRatePoint>,
        startIndex: Int,
        endIndex: Int,
        totalElapsedSec: Double
    ): Double {
        if (startIndex >= endIndex || endIndex >= heartRateData.size) {
            return 0.0
        }
        
        val startTime = heartRateData[startIndex].timestampEpochMs
        val endTime = heartRateData[endIndex].timestampEpochMs
        
        // If timestamps are available, use them
        if (startTime > 0 && endTime > 0) {
            return (endTime - startTime) / 1000.0 // Convert ms to seconds
        }
        
        // Otherwise, estimate based on proportion of total time
        val dataPoints = endIndex - startIndex + 1
        val totalDataPoints = heartRateData.size
        return (dataPoints.toDouble() / totalDataPoints) * totalElapsedSec
    }
    
    /**
     * Calculates the distance of a segment based on proportion of total distance.
     */
    private fun calculateSegmentDistance(
        startIndex: Int,
        endIndex: Int,
        totalDataPoints: Int,
        totalDistanceM: Double
    ): Double {
        val dataPoints = endIndex - startIndex + 1
        return (dataPoints.toDouble() / totalDataPoints) * totalDistanceM
    }
    
    /**
     * Calculates effort adjustment based on heart rate relative to baseline and max HR.
     * 
     * @param segmentHR Average heart rate for the segment
     * @param baselineHR User's baseline heart rate
     * @param maxHR User's maximum heart rate
     * @return Effort adjustment factor (positive = harder effort = time penalty)
     */
    private fun calculateHeartRateEffortAdjustment(
        segmentHR: Int,
        baselineHR: Int,
        maxHR: Int
    ): Double {
        val hrReserve = maxHR - baselineHR
        if (hrReserve <= 0) return 0.0
        
        val relativeIntensity = (segmentHR - baselineHR).toDouble() / hrReserve
        
        return when {
            relativeIntensity > 0.8 -> 0.15  // High intensity: +15% time adjustment
            relativeIntensity > 0.6 -> 0.08  // Moderate-high intensity: +8% time adjustment
            relativeIntensity > 0.4 -> 0.03  // Moderate intensity: +3% time adjustment
            relativeIntensity < 0.2 -> -0.05 // Low intensity: -5% time adjustment
            else -> 0.0  // Normal intensity: no adjustment
        }
    }
    
    /**
     * Gets heart rate zone for a given heart rate.
     */
    fun getHeartRateZone(heartRate: Int, maxHR: Int): Int {
        val percentage = (heartRate.toDouble() / maxHR) * 100
        return when {
            percentage >= 90 -> 5  // Neuromuscular Power
            percentage >= 80 -> 4  // Lactate Threshold
            percentage >= 70 -> 3  // Aerobic Threshold
            percentage >= 60 -> 2  // Aerobic Base
            else -> 1  // Recovery
        }
    }
    
    /**
     * Calculates average heart rate for a list of heart rate points.
     */
    fun calculateAverageHeartRate(heartRateData: List<HeartRatePoint>): Int {
        if (heartRateData.isEmpty()) return 0
        return heartRateData.map { it.heartRateBpm }.average().toInt()
    }
}