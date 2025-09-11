package com.mebeatme.core.ppi

import com.mebeatme.core.Corrections
import com.mebeatme.core.HeartRatePoint
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class HeartRatePpiCalculatorTest {
    
    @Test
    fun testHeartRateBasedPpiCalculationWithNoHeartRateData() {
        // Given
        val distanceM = 5000.0
        val elapsedSec = 1200.0
        val userMaxHR = 200
        
        // When
        val result = HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, null, userMaxHR
        )
        
        // Then - should fall back to standard calculation
        val standardResult = PpiEngine.score(distanceM, elapsedSec)
        assertEquals(standardResult, result, 0.1)
    }
    
    @Test
    fun testHeartRateBasedPpiCalculationWithSingleHeartRatePoint() {
        // Given
        val distanceM = 5000.0
        val elapsedSec = 1200.0
        val userMaxHR = 200
        val heartRateData = listOf(
            HeartRatePoint(timestampEpochMs = 1000, heartRateBpm = 150)
        )
        
        // When
        val result = HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, heartRateData, userMaxHR
        )
        
        // Then - should create single segment
        assertTrue(result > 0)
    }
    
    @Test
    fun testHeartRateSegmentationWithVaryingHeartRates() {
        // Given
        val distanceM = 10000.0
        val elapsedSec = 2400.0
        val userMaxHR = 200
        val heartRateData = listOf(
            HeartRatePoint(1000, 120), // Low intensity
            HeartRatePoint(2000, 125),
            HeartRatePoint(3000, 130),
            HeartRatePoint(4000, 160), // High intensity jump
            HeartRatePoint(5000, 165),
            HeartRatePoint(6000, 170),
            HeartRatePoint(7000, 140), // Back to moderate
            HeartRatePoint(8000, 135),
            HeartRatePoint(9000, 130),
            HeartRatePoint(10000, 125)
        )
        
        // When
        val result = HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, heartRateData, userMaxHR
        )
        
        // Then
        assertTrue(result > 0)
        
        // Should create multiple segments due to heart rate variations
        val standardResult = PpiEngine.score(distanceM, elapsedSec)
        // Heart rate-based result should be different from standard (due to effort adjustments)
        assertTrue(result != standardResult)
    }
    
    @Test
    fun testHeartRateEffortAdjustmentCalculation() {
        // Given
        val userMaxHR = 200
        val baselineHR = 120
        
        // Test high intensity (should get positive adjustment)
        val highIntensityHR = 180
        val highIntensityAdjustment = calculateEffortAdjustment(highIntensityHR, baselineHR, userMaxHR)
        assertTrue(highIntensityAdjustment > 0, "High intensity should get positive adjustment")
        
        // Test low intensity (should get negative adjustment)
        val lowIntensityHR = 100
        val lowIntensityAdjustment = calculateEffortAdjustment(lowIntensityHR, baselineHR, userMaxHR)
        assertTrue(lowIntensityAdjustment < 0, "Low intensity should get negative adjustment")
        
        // Test moderate intensity (should get minimal adjustment)
        val moderateIntensityHR = 140
        val moderateIntensityAdjustment = calculateEffortAdjustment(moderateIntensityHR, baselineHR, userMaxHR)
        assertTrue(moderateIntensityAdjustment >= 0 && moderateIntensityAdjustment <= 0.05, 
            "Moderate intensity should get minimal adjustment")
    }
    
    @Test
    fun testHeartRateZoneCalculation() {
        // Given
        val maxHR = 200
        
        // Test different zones
        assertEquals(1, HeartRatePpiCalculator.getHeartRateZone(100, maxHR)) // Recovery
        assertEquals(2, HeartRatePpiCalculator.getHeartRateZone(130, maxHR)) // Aerobic Base
        assertEquals(3, HeartRatePpiCalculator.getHeartRateZone(150, maxHR)) // Aerobic Threshold
        assertEquals(4, HeartRatePpiCalculator.getHeartRateZone(170, maxHR)) // Lactate Threshold
        assertEquals(5, HeartRatePpiCalculator.getHeartRateZone(190, maxHR)) // Neuromuscular Power
    }
    
    @Test
    fun testAverageHeartRateCalculation() {
        // Given
        val heartRateData = listOf(
            HeartRatePoint(1000, 120),
            HeartRatePoint(2000, 130),
            HeartRatePoint(3000, 140),
            HeartRatePoint(4000, 150)
        )
        
        // When
        val averageHR = HeartRatePpiCalculator.calculateAverageHeartRate(heartRateData)
        
        // Then
        assertEquals(135, averageHR) // (120 + 130 + 140 + 150) / 4 = 135
    }
    
    @Test
    fun testHeartRateBasedPpiWithElevationAndTemperatureCorrections() {
        // Given
        val distanceM = 5000.0
        val elapsedSec = 1200.0
        val userMaxHR = 200
        val heartRateData = listOf(
            HeartRatePoint(1000, 150),
            HeartRatePoint(2000, 160),
            HeartRatePoint(3000, 170),
            HeartRatePoint(4000, 165),
            HeartRatePoint(5000, 155)
        )
        val corrections = Corrections(
            elevationAdjSec = 30.0,  // 30 seconds elevation penalty
            temperatureAdjSec = 15.0, // 15 seconds temperature penalty
            heartRateAdjSec = 0.0     // Will be calculated by heart rate segments
        )
        
        // When
        val result = HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, heartRateData, userMaxHR, corr = corrections
        )
        
        // Then
        assertTrue(result > 0)
        
        // Should be different from standard calculation due to combined corrections
        val standardResult = PpiEngine.score(distanceM, elapsedSec, corrections)
        assertTrue(result != standardResult)
    }
    
    @Test
    fun testPpiEngineScoreWithHeartRateMethod() {
        // Given
        val distanceM = 5000.0
        val elapsedSec = 1200.0
        val userMaxHR = 200
        val heartRateData = listOf(
            HeartRatePoint(1000, 150),
            HeartRatePoint(2000, 160),
            HeartRatePoint(3000, 170),
            HeartRatePoint(4000, 165),
            HeartRatePoint(5000, 155)
        )
        
        // When
        val result = PpiEngine.scoreWithHeartRate(
            distanceM, elapsedSec, heartRateData, userMaxHR
        )
        
        // Then
        assertTrue(result > 0)
        
        // Should match the calculator result
        val calculatorResult = HeartRatePpiCalculator.calculateHeartRateBasedPPI(
            distanceM, elapsedSec, heartRateData, userMaxHR
        )
        assertEquals(calculatorResult, result, 0.1)
    }
    
    // Helper function to test effort adjustment calculation
    private fun calculateEffortAdjustment(segmentHR: Int, baselineHR: Int, maxHR: Int): Double {
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
}