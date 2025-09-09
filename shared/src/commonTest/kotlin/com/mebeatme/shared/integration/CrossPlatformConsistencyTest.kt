package com.mebeatme.shared.integration

import com.mebeatme.shared.core.*
import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO
import kotlinx.datetime.Clock
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * Integration tests to verify cross-platform consistency
 * These tests ensure that PPI calculations and data processing
 * work consistently across all platforms (iOS, watchOS, Android, Wear, Server)
 */
class CrossPlatformConsistencyTest {
    
    @Test
    fun `purdyScore calculations are consistent across platforms`() {
        // Test matrix of standard distances and times
        val testCases = listOf(
            Triple(5000.0, 1500, 140.6), // 5K in 25:00
            Triple(5000.0, 1200, 274.6), // 5K in 20:00
            Triple(5000.0, 780, 1000.0), // 5K in 13:00 (elite)
            Triple(10000.0, 3000, 157.0), // 10K in 50:00
            Triple(10000.0, 2400, 307.5), // 10K in 40:00
            Triple(10000.0, 1620, 1000.0), // 10K in 27:00 (elite)
            Triple(21097.5, 6300, 177.0), // Half in 1:45:00
            Triple(21097.5, 5400, 281.7), // Half in 1:30:00
            Triple(21097.5, 3540, 1000.0), // Half in 59:00 (elite)
            Triple(42195.0, 12600, 191.3), // Full in 3:30:00
            Triple(42195.0, 10800, 303.8), // Full in 3:00:00
            Triple(42195.0, 7260, 1000.0) // Full in 2:01:00 (elite)
        )
        
        testCases.forEach { (distance, duration, expectedScore) ->
            val actualScore = purdyScore(distance, duration)
            assertEquals(expectedScore, actualScore, 1.0, 
                "Distance: ${distance}m, Duration: ${duration}s, Expected: $expectedScore, Actual: $actualScore")
        }
    }
    
    @Test
    fun `targetPace calculations are consistent across platforms`() {
        val testCases = listOf(
            Triple(5000.0, 1200, 240.0), // 5K in 20:00 = 4:00/km
            Triple(10000.0, 2400, 240.0), // 10K in 40:00 = 4:00/km
            Triple(21097.5, 5400, 256.0), // Half in 1:30:00 = 4:16/km
            Triple(42195.0, 10800, 256.0) // Full in 3:00:00 = 4:16/km
        )
        
        testCases.forEach { (distance, window, expectedPace) ->
            val actualPace = targetPace(distance, window)
            assertEquals(expectedPace, actualPace, 0.1,
                "Distance: ${distance}m, Window: ${window}s, Expected: $expectedPace, Actual: $actualPace")
        }
    }
    
    @Test
    fun `highestPpiInWindow calculations are consistent across platforms`() {
        val nowMs = 1700000000000L
        val dayMs = 24L * 3600_000
        
        val runs = listOf(
            RunDTO("1", "GPX", nowMs - 10 * dayMs, nowMs - 10 * dayMs + 1500, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", nowMs - 50 * dayMs, nowMs - 50 * dayMs + 1200, 5000.0, 1200, 240.0, ppi = 600.0),
            RunDTO("3", "GPX", nowMs - 100 * dayMs, nowMs - 100 * dayMs + 1800, 5000.0, 1800, 360.0, ppi = 300.0), // Outside 90 days
            RunDTO("4", "GPX", nowMs - 5 * dayMs, nowMs - 5 * dayMs + 1400, 5000.0, 1400, 280.0, ppi = 500.0),
            RunDTO("5", "GPX", nowMs - 30 * dayMs, nowMs - 30 * dayMs + 1300, 5000.0, 1300, 260.0, ppi = 550.0)
        )
        
        val highest = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(600.0, highest) // Should find the 600 PPI run
        
        // Test with different day windows
        val highest30 = highestPpiInWindow(runs, nowMs, 30)
        assertEquals(550.0, highest30) // Should find the 550 PPI run in 30-day window
        
        val highest5 = highestPpiInWindow(runs, nowMs, 5)
        assertEquals(500.0, highest5) // Should find the 500 PPI run in 5-day window
    }
    
    @Test
    fun `calculateBests calculations are consistent across platforms`() {
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0), // 5K in 25:00
            RunDTO("2", "GPX", 2000, 3000, 5000.0, 1200, 240.0), // 5K in 20:00 (better)
            RunDTO("3", "GPX", 3000, 4000, 10000.0, 3000, 300.0), // 10K in 50:00
            RunDTO("4", "GPX", 4000, 5000, 10000.0, 2400, 240.0), // 10K in 40:00 (better)
            RunDTO("5", "GPX", 5000, 6000, 21097.5, 6300, 300.0), // Half in 1:45:00
            RunDTO("6", "GPX", 6000, 7000, 21097.5, 5400, 256.0), // Half in 1:30:00 (better)
            RunDTO("7", "GPX", 7000, 8000, 42195.0, 12600, 300.0), // Full in 3:30:00
            RunDTO("8", "GPX", 8000, 9000, 42195.0, 10800, 256.0) // Full in 3:00:00 (better)
        )
        
        val bests = calculateBests(runs)
        
        assertEquals(1200, bests.best5kSec) // 20:00
        assertEquals(2400, bests.best10kSec) // 40:00
        assertEquals(5400, bests.bestHalfSec) // 1:30:00
        assertEquals(10800, bests.bestFullSec) // 3:00:00
        
        // Test with since filter
        val bestsSince = calculateBests(runs, 5000L)
        assertEquals(5400, bestsSince.bestHalfSec) // Should only find Half and Full
        assertEquals(10800, bestsSince.bestFullSec)
        assertNull(bestsSince.best5kSec) // Should be null since no 5K runs after timestamp 5000
        assertNull(bestsSince.best10kSec) // Should be null since no 10K runs after timestamp 5000
    }
    
    @Test
    fun `runDTO serialization is consistent across platforms`() {
        val run = RunDTO(
            id = "test-run-1",
            source = "GPX",
            startedAtEpochMs = 1700000000000L,
            endedAtEpochMs = 1700000001500L,
            distanceMeters = 5000.0,
            elapsedSeconds = 1500,
            avgPaceSecPerKm = 300.0,
            avgHr = 162,
            ppi = 140.6,
            notes = "Test run for consistency"
        )
        
        // Test that all fields are properly set
        assertEquals("test-run-1", run.id)
        assertEquals("GPX", run.source)
        assertEquals(1700000000000L, run.startedAtEpochMs)
        assertEquals(1700000001500L, run.endedAtEpochMs)
        assertEquals(5000.0, run.distanceMeters)
        assertEquals(1500, run.elapsedSeconds)
        assertEquals(300.0, run.avgPaceSecPerKm)
        assertEquals(162, run.avgHr)
        assertEquals(140.6, run.ppi)
        assertEquals("Test run for consistency", run.notes)
    }
    
    @Test
    fun `bestsDTO serialization is consistent across platforms`() {
        val bests = BestsDTO(
            best5kSec = 1200,
            best10kSec = 2400,
            bestHalfSec = 5400,
            bestFullSec = 10800,
            highestPPILast90Days = 600.0
        )
        
        // Test that all fields are properly set
        assertEquals(1200, bests.best5kSec)
        assertEquals(2400, bests.best10kSec)
        assertEquals(5400, bests.bestHalfSec)
        assertEquals(10800, bests.bestFullSec)
        assertEquals(600.0, bests.highestPPILast90Days)
    }
    
    @Test
    fun `edge cases are handled consistently across platforms`() {
        // Test empty runs list
        val emptyBests = calculateBests(emptyList())
        assertNotNull(emptyBests)
        
        // Test runs with null PPI
        val runsWithNullPpi = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0, ppi = null),
            RunDTO("2", "GPX", 2000, 3000, 5000.0, 1200, 240.0, ppi = 500.0)
        )
        
        val highest = highestPpiInWindow(runsWithNullPpi, 2000L, 90)
        assertEquals(500.0, highest) // Should ignore null PPI
        
        // Test runs outside time window
        val nowMs = Clock.System.now().toEpochMilliseconds()
        val oldRuns = listOf(
            RunDTO("1", "GPX", nowMs - (200 * 24L * 3600_000), (nowMs - (200 * 24L * 3600_000)) + 1500, 5000.0, 1500, 300.0, ppi = 400.0)
        )
        
        val highestOld = highestPpiInWindow(oldRuns, nowMs, 90)
        assertNull(highestOld) // Should return null for runs outside window
    }
}

