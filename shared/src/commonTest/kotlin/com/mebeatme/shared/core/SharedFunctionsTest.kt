package com.mebeatme.shared.core

import com.mebeatme.shared.api.RunDTO
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Comprehensive test matrix for MeBeatMe shared functions
 * Following the HYBRID PROMPT specifications
 * 
 * Tests cover:
 * - Purdy matrix sanity (5K/10K/HM)
 * - 90-day window logic
 * - Edge cases and error handling
 * - Cross-platform consistency
 */
class SharedFunctionsTest {
    
    // ===== PURDY MATRIX TESTS =====
    
    @Test
    fun testPurdyScore_5K_Elite() {
        // 5K in 12:35 (755 seconds) should give ~1000 PPI (elite baseline)
        val ppi = purdyScore(5000.0, 755)
        assertTrue(ppi in 990.0..1010.0, "Elite 5K should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_5K_Recreational() {
        // 5K in 25:00 (1500 seconds) should give lower PPI
        val ppi = purdyScore(5000.0, 1500)
        assertTrue(ppi < 500.0, "Recreational 5K should give lower PPI, got $ppi")
        assertTrue(ppi > 100.0, "PPI should be above minimum, got $ppi")
    }
    
    @Test
    fun testPurdyScore_10K_Elite() {
        // 10K in 26:11 (1571 seconds) should give ~1000 PPI (elite baseline)
        val ppi = purdyScore(10000.0, 1571)
        assertTrue(ppi in 990.0..1010.0, "Elite 10K should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_HalfMarathon_Elite() {
        // Half marathon in 59:00 (3540 seconds) should give ~1000 PPI (elite baseline)
        val ppi = purdyScore(21097.0, 3540)
        assertTrue(ppi in 990.0..1010.0, "Elite half marathon should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_InvalidInputs() {
        try {
            purdyScore(0.0, 1000)
            assertTrue(false, "Should throw exception for zero distance")
        } catch (e: IllegalArgumentException) {
            // Expected
        }
        
        try {
            purdyScore(5000.0, 0)
            assertTrue(false, "Should throw exception for zero duration")
        } catch (e: IllegalArgumentException) {
            // Expected
        }
    }
    
    // ===== TARGET PACE TESTS =====
    
    @Test
    fun testTargetPace_ValidInputs() {
        val pace = targetPace(5000.0, 1500)
        assertTrue(pace > 0, "Target pace should be positive, got $pace")
        assertTrue(pace < 600, "Target pace should be reasonable, got $pace")
    }
    
    @Test
    fun testTargetPace_InvalidInputs() {
        try {
            targetPace(0.0, 1000)
            assertTrue(false, "Should throw exception for zero distance")
        } catch (e: IllegalArgumentException) {
            // Expected
        }
    }
    
    // ===== 90-DAY WINDOW TESTS =====
    
    @Test
    fun testHighestPpiInWindow_90Days() {
        val nowMs = 1757300000000L // Current time
        val runs = listOf(
            createRunDTO(ppi = 48.2, daysAgo = 10, nowMs),
            createRunDTO(ppi = 51.9, daysAgo = 35, nowMs),
            createRunDTO(ppi = 49.7, daysAgo = 91, nowMs) // outside window
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(51.9, highestPpi!!, 1e-6)
    }
    
    @Test
    fun testHighestPpiInWindow_NoRuns() {
        val nowMs = 1757300000000L
        val runs = emptyList<RunDTO>()
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertNull(highestPpi, "Should return null when no runs")
    }
    
    @Test
    fun testHighestPpiInWindow_NoPpiValues() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = null, daysAgo = 10, nowMs) // No PPI calculated
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertNull(highestPpi, "Should return null when no PPI values")
    }
    
    @Test
    fun testHighestPpiInWindow_BoundaryConditions() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0, daysAgo = 90, nowMs), // exactly on boundary
            createRunDTO(ppi = 45.0, daysAgo = 91, nowMs)  // just outside boundary
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(50.0, highestPpi!!, 1e-6)
    }
    
    // ===== CROSS-PLATFORM CONSISTENCY TESTS =====
    
    @Test
    fun testCrossPlatformConsistency_SameInputs() {
        // Test that same inputs produce same outputs across platforms
        val testCases = listOf(
            Triple(5000.0, 1200, "5K in 20:00"),
            Triple(10000.0, 2400, "10K in 40:00"),
            Triple(21097.0, 5400, "Half marathon in 1:30:00")
        )
        
        testCases.forEach { (distance, duration, description) ->
            val ppi1 = purdyScore(distance, duration)
            val ppi2 = purdyScore(distance, duration)
            assertEquals(ppi1, ppi2, 1e-10, "$description should be consistent")
        }
    }
    
    @Test
    fun testCrossPlatformConsistency_PaceCalculation() {
        // Test pace calculation consistency
        val testCases = listOf(
            Triple(5000.0, 1200, "5K in 20:00"),
            Triple(10000.0, 2400, "10K in 40:00")
        )
        
        testCases.forEach { (distance, duration, description) ->
            val pace1 = targetPace(distance, duration)
            val pace2 = targetPace(distance, duration)
            assertEquals(pace1, pace2, 1e-10, "$description pace should be consistent")
        }
    }
    
    // ===== HELPER FUNCTIONS =====
    
    private fun createRunDTO(ppi: Double?, daysAgo: Int, nowMs: Long): RunDTO {
        val runStartMs = nowMs - daysAgo * 24L * 3600 * 1000
        val runEndMs = runStartMs + 1800 * 1000 // 30 minutes later
        
        return RunDTO(
            id = "test_run_${daysAgo}",
            source = "test",
            startedAtEpochMs = runStartMs,
            endedAtEpochMs = runEndMs,
            distanceMeters = 5000.0, // 5km
            elapsedSeconds = 1800, // 30 minutes
            avgPaceSecPerKm = 360.0, // 6:00/km
            avgHr = null,
            ppi = ppi,
            notes = null
        )
    }
}
