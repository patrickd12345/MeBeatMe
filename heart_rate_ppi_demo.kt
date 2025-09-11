#!/usr/bin/env kotlin

// Heart Rate-Based PPI Calculation Demo
// This script demonstrates the new heart rate-based PPI calculation system

import com.mebeatme.core.HeartRatePoint
import com.mebeatme.core.Corrections
import com.mebeatme.core.ppi.PpiEngine
import com.mebeatme.core.ppi.HeartRatePpiCalculator

fun main() {
    println("=== Heart Rate-Based PPI Calculation Demo ===\n")
    
    // Sample run data
    val distanceM = 5000.0  // 5K run
    val elapsedSec = 1200.0  // 20 minutes
    val userMaxHR = 200
    val baselineHR = 120
    
    // Sample heart rate data showing effort variation
    val heartRateData = listOf(
        HeartRatePoint(1000, 120),  // Warm-up: low intensity
        HeartRatePoint(2000, 125),
        HeartRatePoint(3000, 130),
        HeartRatePoint(4000, 160),  // High intensity section
        HeartRatePoint(5000, 165),
        HeartRatePoint(6000, 170),
        HeartRatePoint(7000, 140),  // Recovery: moderate intensity
        HeartRatePoint(8000, 135),
        HeartRatePoint(9000, 130),
        HeartRatePoint(10000, 125)
    )
    
    println("Run Details:")
    println("- Distance: ${distanceM/1000}km")
    println("- Time: ${elapsedSec/60} minutes")
    println("- Max HR: $userMaxHR bpm")
    println("- Baseline HR: $baselineHR bpm")
    println()
    
    println("Heart Rate Profile:")
    heartRateData.forEachIndexed { index, point ->
        val time = point.timestampEpochMs / 1000.0
        val zone = HeartRatePpiCalculator.getHeartRateZone(point.heartRateBpm, userMaxHR)
        println("- ${time}s: ${point.heartRateBpm} bpm (Zone $zone)")
    }
    println()
    
    // Calculate standard PPI (without heart rate)
    val standardPPI = PpiEngine.score(distanceM, elapsedSec)
    println("Standard PPI Score: ${String.format("%.1f", standardPPI)}")
    
    // Calculate heart rate-based PPI
    val hrBasedPPI = PpiEngine.scoreWithHeartRate(
        distanceM, elapsedSec, heartRateData, userMaxHR, baselineHR
    )
    println("Heart Rate-Based PPI Score: ${String.format("%.1f", hrBasedPPI)}")
    
    val difference = hrBasedPPI - standardPPI
    val percentageChange = (difference / standardPPI) * 100
    println("Difference: ${String.format("%+.1f", difference)} (${String.format("%+.1f", percentageChange)}%)")
    println()
    
    // Show heart rate zones
    println("Heart Rate Zones:")
    println("- Zone 1 (Recovery): 50-60% max HR")
    println("- Zone 2 (Aerobic Base): 60-70% max HR")
    println("- Zone 3 (Aerobic Threshold): 70-80% max HR")
    println("- Zone 4 (Lactate Threshold): 80-90% max HR")
    println("- Zone 5 (Neuromuscular Power): 90-100% max HR")
    println()
    
    // Show effort adjustments
    println("Effort Adjustments Applied:")
    val avgHR = HeartRatePpiCalculator.calculateAverageHeartRate(heartRateData)
    val relativeIntensity = (avgHR - baselineHR).toDouble() / (userMaxHR - baselineHR)
    val adjustment = when {
        relativeIntensity > 0.8 -> 0.15  // High intensity: +15% time penalty
        relativeIntensity > 0.6 -> 0.08  // Moderate-high: +8% time penalty
        relativeIntensity > 0.4 -> 0.03  // Moderate: +3% time penalty
        relativeIntensity < 0.2 -> -0.05 // Low intensity: -5% time bonus
        else -> 0.0  // Normal intensity: no adjustment
    }
    
    println("- Average HR: $avgHR bpm")
    println("- Relative Intensity: ${String.format("%.1f", relativeIntensity * 100)}%")
    println("- Time Adjustment: ${String.format("%+.1f", adjustment * 100)}%")
    println()
    
    println("Benefits of Heart Rate-Based PPI:")
    println("✓ Accounts for actual physiological effort")
    println("✓ Normalizes for individual fitness levels")
    println("✓ Captures effort variations throughout the run")
    println("✓ Provides more accurate performance assessment")
    println("✓ Enables fair comparison across different courses")
}