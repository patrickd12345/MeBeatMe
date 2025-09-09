package com.mebeatme.shared.core

import com.mebeatme.shared.api.RunDTO
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

class PurdyCalculatorTest {
    
    @Test
    fun testPurdyScore_5K_Elite() {
        // 5K in 12:35 (755 seconds) should give ~1000 PPI (elite baseline)
        val ppi = PurdyCalculator.purdyScore(5000.0, 755)
        assertTrue(ppi in 990.0..1010.0, "Elite 5K should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_5K_Recreational() {
        // 5K in 25:00 (1500 seconds) should give lower PPI
        val ppi = PurdyCalculator.purdyScore(5000.0, 1500)
        assertTrue(ppi < 500.0, "Recreational 5K should give lower PPI, got $ppi")
        assertTrue(ppi > 100.0, "PPI should be above minimum, got $ppi")
    }
    
    @Test
    fun testPurdyScore_10K_Elite() {
        // 10K in 26:11 (1571 seconds) should give ~1000 PPI (elite baseline)
        val ppi = PurdyCalculator.purdyScore(10000.0, 1571)
        assertTrue(ppi in 990.0..1010.0, "Elite 10K should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_HalfMarathon_Elite() {
        // Half marathon in 59:00 (3540 seconds) should give ~1000 PPI (elite baseline)
        val ppi = PurdyCalculator.purdyScore(21097.0, 3540)
        assertTrue(ppi in 990.0..1010.0, "Elite half marathon should give ~1000 PPI, got $ppi")
    }
    
    @Test
    fun testPurdyScore_InvalidInputs() {
        assertFailsWith<IllegalArgumentException> {
            PurdyCalculator.purdyScore(0.0, 1000)
        }
        
        assertFailsWith<IllegalArgumentException> {
            PurdyCalculator.purdyScore(5000.0, 0)
        }
        
        assertFailsWith<IllegalArgumentException> {
            PurdyCalculator.purdyScore(-100.0, 1000)
        }
    }
    
    @Test
    fun testTargetPace_ValidInputs() {
        val pace = PurdyCalculator.targetPace(5000.0, 1500)
        assertTrue(pace > 0, "Target pace should be positive, got $pace")
        assertTrue(pace < 600, "Target pace should be reasonable, got $pace")
    }
    
    @Test
    fun testTargetPace_InvalidInputs() {
        assertFailsWith<IllegalArgumentException> {
            PurdyCalculator.targetPace(0.0, 1000)
        }
        
        assertFailsWith<IllegalArgumentException> {
            PurdyCalculator.targetPace(5000.0, 0)
        }
    }
}

class HighestPpiInWindowTest {
    
    @Test
    fun testHighestPpiInWindow_90Days() {
        val nowMs = 1757300000000L // Current time
        val runs = listOf(
            RunDTO(
                id = "run1",
                source = "GPX",
                startedAtEpochMs = nowMs - 30L * 24 * 3600 * 1000, // 30 days ago
                endedAtEpochMs = nowMs - 30L * 24 * 3600 * 1000 + 1500 * 1000,
                distanceMeters = 5000.0,
                elapsedSeconds = 1500,
                avgPaceSecPerKm = 300.0,
                ppi = 200.0
            ),
            RunDTO(
                id = "run2", 
                source = "GPX",
                startedAtEpochMs = nowMs - 60L * 24 * 3600 * 1000, // 60 days ago
                endedAtEpochMs = nowMs - 60L * 24 * 3600 * 1000 + 1200 * 1000,
                distanceMeters = 5000.0,
                elapsedSeconds = 1200,
                avgPaceSecPerKm = 240.0,
                ppi = 300.0
            ),
            RunDTO(
                id = "run3",
                source = "GPX", 
                startedAtEpochMs = nowMs - 95L * 24 * 3600 * 1000, // 95 days ago (outside window)
                endedAtEpochMs = nowMs - 95L * 24 * 3600 * 1000 + 1000 * 1000,
                distanceMeters = 5000.0,
                elapsedSeconds = 1000,
                avgPaceSecPerKm = 200.0,
                ppi = 500.0
            )
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(300.0, highestPpi, "Should return highest PPI within 90 days")
    }
    
    @Test
    fun testHighestPpiInWindow_NoRuns() {
        val nowMs = 1757300000000L
        val runs = emptyList<RunDTO>()
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(null, highestPpi, "Should return null when no runs")
    }
    
    @Test
    fun testHighestPpiInWindow_NoPpiValues() {
        val nowMs = 1757300000000L
        val runs = listOf(
            RunDTO(
                id = "run1",
                source = "GPX",
                startedAtEpochMs = nowMs - 30L * 24 * 3600 * 1000,
                endedAtEpochMs = nowMs - 30L * 24 * 3600 * 1000 + 1500 * 1000,
                distanceMeters = 5000.0,
                elapsedSeconds = 1500,
                avgPaceSecPerKm = 300.0,
                ppi = null // No PPI calculated
            )
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(null, highestPpi, "Should return null when no PPI values")
    }
}
