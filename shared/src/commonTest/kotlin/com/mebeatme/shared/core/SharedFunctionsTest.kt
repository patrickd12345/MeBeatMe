package com.mebeatme.shared.core

import com.mebeatme.shared.model.RunDTO
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

class SharedFunctionsTest {
    
    @Test
    fun `purdyScore calculates correct scores for standard distances`() {
        // Test 5K (5000m) - recreational runner time
        val score5k = purdyScore(5000.0, 1500) // 5K in 25:00
        assertEquals(140.6, score5k, 1.0) // Should be around 140.6 points
        
        // Test 10K (10000m) - recreational runner time  
        val score10k = purdyScore(10000.0, 3000) // 10K in 50:00
        assertEquals(157.0, score10k, 1.0) // Should be around 157 points
        
        // Test Half Marathon (21097.5m) - recreational runner time
        val scoreHalf = purdyScore(21097.5, 6300) // Half in 1:45:00
        assertEquals(177.0, scoreHalf, 1.0) // Should be around 177 points
    }
    
    @Test
    fun `purdyScore handles elite performance correctly`() {
        // Elite 5K time (13:00 = 780 seconds)
        val eliteScore = purdyScore(5000.0, 780)
        assertEquals(1000.0, eliteScore, 1.0) // Should be exactly 1000 points
        
        // Elite 10K time (27:00 = 1620 seconds)
        val elite10kScore = purdyScore(10000.0, 1620)
        assertEquals(1000.0, elite10kScore, 1.0) // Should be exactly 1000 points
    }
    
    @Test
    fun `purdyScore throws exception for invalid inputs`() {
        assertFailsWith<IllegalArgumentException> {
            purdyScore(-100.0, 300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            purdyScore(5000.0, -300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            purdyScore(0.0, 300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            purdyScore(5000.0, 0)
        }
    }
    
    @Test
    fun `targetPace calculates correct pace for different distances`() {
        // 5K in 20 minutes = 4:00/km
        val pace5k = targetPace(5000.0, 1200)
        assertEquals(240.0, pace5k, 0.1) // 4:00 = 240 seconds
        
        // 10K in 40 minutes = 4:00/km
        val pace10k = targetPace(10000.0, 2400)
        assertEquals(240.0, pace10k, 0.1) // 4:00 = 240 seconds
        
        // Half Marathon in 1:30 = 4:16/km
        val paceHalf = targetPace(21097.5, 5400)
        assertEquals(256.0, paceHalf, 1.0) // 4:16 = 256 seconds
    }
    
    @Test
    fun `targetPace throws exception for invalid inputs`() {
        assertFailsWith<IllegalArgumentException> {
            targetPace(-100.0, 300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            targetPace(5000.0, -300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            targetPace(0.0, 300)
        }
        
        assertFailsWith<IllegalArgumentException> {
            targetPace(5000.0, 0)
        }
    }
    
    @Test
    fun `highestPpiInWindow finds correct highest PPI in 90 days`() {
        val nowMs = 1700000000000L // Some timestamp
        val dayMs = 24L * 3600_000
        
        val runs = listOf(
            RunDTO("1", "GPX", nowMs - 10 * dayMs, nowMs - 10 * dayMs + 1500, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", nowMs - 50 * dayMs, nowMs - 50 * dayMs + 1200, 5000.0, 1200, 240.0, ppi = 600.0),
            RunDTO("3", "GPX", nowMs - 100 * dayMs, nowMs - 100 * dayMs + 1800, 5000.0, 1800, 360.0, ppi = 300.0), // Outside 90 days
            RunDTO("4", "GPX", nowMs - 5 * dayMs, nowMs - 5 * dayMs + 1400, 5000.0, 1400, 280.0, ppi = 500.0)
        )
        
        val highest = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(600.0, highest) // Should find the 600 PPI run
    }
    
    @Test
    fun `highestPpiInWindow returns null when no runs in window`() {
        val nowMs = 1700000000000L
        val runs = listOf(
            RunDTO("1", "GPX", nowMs - 100 * 24L * 3600_000, nowMs - 100 * 24L * 3600_000 + 1500, 5000.0, 1500, 300.0, ppi = 400.0)
        )
        
        val highest = highestPpiInWindow(runs, nowMs, 90)
        assertNull(highest) // Should return null
    }
    
    @Test
    fun `highestPpiInWindow ignores runs without PPI`() {
        val nowMs = 1700000000000L
        val dayMs = 24L * 3600_000
        
        val runs = listOf(
            RunDTO("1", "GPX", nowMs - 10 * dayMs, nowMs - 10 * dayMs + 1500, 5000.0, 1500, 300.0, ppi = null),
            RunDTO("2", "GPX", nowMs - 20 * dayMs, nowMs - 20 * dayMs + 1200, 5000.0, 1200, 240.0, ppi = 600.0)
        )
        
        val highest = highestPpiInWindow(runs, nowMs, 90)
        assertEquals(600.0, highest) // Should find the 600 PPI run, ignore null
    }
    
    @Test
    fun `calculateBests finds correct best times`() {
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
    }
    
    @Test
    fun `calculateBests handles no runs gracefully`() {
        val bests = calculateBests(emptyList())
        
        assertNull(bests.best5kSec)
        assertNull(bests.best10kSec)
        assertNull(bests.bestHalfSec)
        assertNull(bests.bestFullSec)
        assertNull(bests.highestPPILast90Days)
    }
    
    @Test
    fun `calculateBests respects sinceMs filter`() {
        val baseTime = 1700000000000L
        val runs = listOf(
            RunDTO("1", "GPX", baseTime - 1000, baseTime - 1000 + 1500, 5000.0, 1500, 300.0), // Old run
            RunDTO("2", "GPX", baseTime + 1000, baseTime + 1000 + 1200, 5000.0, 1200, 240.0) // Recent run
        )
        
        val bests = calculateBests(runs, baseTime)
        
        assertEquals(1200, bests.best5kSec) // Should only find the recent run
    }
}

