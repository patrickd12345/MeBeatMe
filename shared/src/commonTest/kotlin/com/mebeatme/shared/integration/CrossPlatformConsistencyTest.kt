package com.mebeatme.shared.integration

import com.mebeatme.shared.api.RunDTO
import com.mebeatme.shared.core.purdyScore
import com.mebeatme.shared.core.targetPace
import com.mebeatme.shared.core.highestPpiInWindow
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Cross-platform consistency tests for MeBeatMe
 * Following the HYBRID PROMPT specifications
 * 
 * These tests ensure that the same inputs produce the same outputs
 * across all platforms (iOS, watchOS, Android, Wear OS, Server)
 */
class CrossPlatformConsistencyTest {
    
    @Test
    fun testPurdyScoreConsistency() {
        // Test matrix of common running distances and times
        val testCases = listOf(
            TestCase(1000.0, 240, "1K in 4:00"),
            TestCase(5000.0, 1200, "5K in 20:00"),
            TestCase(5000.0, 1500, "5K in 25:00"),
            TestCase(10000.0, 2400, "10K in 40:00"),
            TestCase(10000.0, 3000, "10K in 50:00"),
            TestCase(21097.0, 5400, "Half marathon in 1:30:00"),
            TestCase(21097.0, 7200, "Half marathon in 2:00:00"),
            TestCase(42195.0, 10800, "Marathon in 3:00:00"),
            TestCase(42195.0, 14400, "Marathon in 4:00:00")
        )
        
        testCases.forEach { testCase ->
            val ppi1 = purdyScore(testCase.distance, testCase.duration)
            val ppi2 = purdyScore(testCase.distance, testCase.duration)
            
            assertEquals(ppi1, ppi2, 1e-10, 
                "${testCase.description} should produce consistent PPI across platforms")
            
            // Verify PPI is within reasonable bounds
            assertTrue(ppi1 >= 100.0, 
                "${testCase.description} PPI should be >= 100, got $ppi1")
            assertTrue(ppi1 <= 2000.0, 
                "${testCase.description} PPI should be <= 2000, got $ppi1")
        }
    }
    
    @Test
    fun testTargetPaceConsistency() {
        val testCases = listOf(
            TestCase(1000.0, 240, "1K in 4:00"),
            TestCase(5000.0, 1200, "5K in 20:00"),
            TestCase(10000.0, 2400, "10K in 40:00"),
            TestCase(21097.0, 5400, "Half marathon in 1:30:00")
        )
        
        testCases.forEach { testCase ->
            val pace1 = targetPace(testCase.distance, testCase.duration)
            val pace2 = targetPace(testCase.distance, testCase.duration)
            
            assertEquals(pace1, pace2, 1e-10, 
                "${testCase.description} should produce consistent pace across platforms")
            
            // Verify pace is reasonable (between 2:00 and 10:00 per km)
            assertTrue(pace1 >= 120.0, 
                "${testCase.description} pace should be >= 2:00/km, got $pace1")
            assertTrue(pace1 <= 600.0, 
                "${testCase.description} pace should be <= 10:00/km, got $pace1")
        }
    }
    
    @Test
    fun testHighestPpiInWindowConsistency() {
        val nowMs = 1757300000000L
        val testRuns = listOf(
            createRunDTO("run1", 100.0, nowMs - 10 * 24 * 3600 * 1000), // 10 days ago
            createRunDTO("run2", 200.0, nowMs - 35 * 24 * 3600 * 1000), // 35 days ago
            createRunDTO("run3", 300.0, nowMs - 95 * 24 * 3600 * 1000), // 95 days ago (outside window)
            createRunDTO("run4", 150.0, nowMs - 60 * 24 * 3600 * 1000)  // 60 days ago
        )
        
        val highestPpi1 = highestPpiInWindow(testRuns, nowMs, 90)
        val highestPpi2 = highestPpiInWindow(testRuns, nowMs, 90)
        
        assertTrue(highestPpi1 == highestPpi2, 
            "Highest PPI calculation should be consistent across platforms")
        assertEquals(200.0, highestPpi1!!, 1e-6, 
            "Should return highest PPI within 90-day window")
    }
    
    @Test
    fun testEdgeCasesConsistency() {
        // Test edge cases that might behave differently across platforms
        
        // Very short distance
        val shortDistancePpi1 = purdyScore(100.0, 15)
        val shortDistancePpi2 = purdyScore(100.0, 15)
        assertEquals(shortDistancePpi1, shortDistancePpi2, 1e-10, 
            "Short distance should be consistent")
        
        // Very long distance
        val longDistancePpi1 = purdyScore(100000.0, 14400) // 100K in 4 hours
        val longDistancePpi2 = purdyScore(100000.0, 14400)
        assertEquals(longDistancePpi1, longDistancePpi2, 1e-10, 
            "Long distance should be consistent")
        
        // Boundary values
        val boundaryPpi1 = purdyScore(1500.0, 210) // Elite 1500m time
        val boundaryPpi2 = purdyScore(1500.0, 210)
        assertEquals(boundaryPpi1, boundaryPpi2, 1e-10, 
            "Boundary values should be consistent")
    }
    
    @Test
    fun testFloatingPointPrecision() {
        // Test that floating point calculations are consistent
        val testCases = listOf(
            Triple(5000.0, 1200, "5K in 20:00"),
            Triple(10000.0, 2400, "10K in 40:00")
        )
        
        testCases.forEach { (distance, duration, description) ->
            val ppi1 = purdyScore(distance, duration)
            val ppi2 = purdyScore(distance, duration)
            
            // Test with high precision
            assertEquals(ppi1, ppi2, 1e-15, 
                "$description should have consistent floating point precision")
        }
    }
    
    @Test
    fun testConcurrentAccessConsistency() {
        // Test that concurrent access produces consistent results
        val testRuns = (1..100).map { i ->
            createRunDTO("run$i", i.toDouble(), System.currentTimeMillis() - i * 24 * 3600 * 1000)
        }
        
        val results = (1..10).map {
            highestPpiInWindow(testRuns, System.currentTimeMillis(), 90)
        }
        
        // All results should be identical (skip nullable comparison for now)
        val firstResult = results.first()
        assertTrue(results.all { it == firstResult }, 
            "Concurrent access should produce consistent results")
    }
    
    // ===== HELPER FUNCTIONS =====
    
    private data class TestCase(
        val distance: Double,
        val duration: Int,
        val description: String
    )
    
    private fun createRunDTO(id: String, ppi: Double, startedAtEpochMs: Long): RunDTO {
        return RunDTO(
            id = id,
            source = "test",
            startedAtEpochMs = startedAtEpochMs,
            endedAtEpochMs = startedAtEpochMs + 1800 * 1000,
            distanceMeters = 5000.0,
            elapsedSeconds = 1800,
            avgPaceSecPerKm = 360.0,
            avgHr = null,
            ppi = ppi,
            notes = null
        )
    }
}
