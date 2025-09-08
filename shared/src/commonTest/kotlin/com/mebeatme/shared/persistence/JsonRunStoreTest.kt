package com.mebeatme.shared.persistence

import com.mebeatme.shared.model.RunDTO
import kotlinx.datetime.Clock
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class JsonRunStoreTest {
    
    @Test
    fun `store can save and load runs`() {
        val store = JsonRunStore()
        
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", 2000, 3000, 10000.0, 3000, 300.0, ppi = 500.0)
        )
        
        // Save runs
        store.saveRuns(runs)
        
        // Load runs
        val loadedRuns = store.loadRuns()
        
        assertEquals(2, loadedRuns.size)
        assertEquals("1", loadedRuns[0].id)
        assertEquals("2", loadedRuns[1].id)
        assertEquals(400.0, loadedRuns[0].ppi)
        assertEquals(500.0, loadedRuns[1].ppi)
    }
    
    @Test
    fun `store handles empty list gracefully`() {
        val store = JsonRunStore()
        
        // Should initialize with empty list
        assertTrue(store.isEmpty())
        assertEquals(0, store.getRunCount())
    }
    
    @Test
    fun `addRun adds new run and updates existing`() {
        val store = JsonRunStore()
        
        val run1 = RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0, ppi = 400.0)
        val run2 = RunDTO("2", "GPX", 2000, 3000, 10000.0, 3000, 300.0, ppi = 500.0)
        val run1Updated = RunDTO("1", "GPX", 1000, 2000, 5000.0, 1200, 240.0, ppi = 600.0)
        
        // Add initial runs
        store.addRun(run1)
        store.addRun(run2)
        
        assertEquals(2, store.getRunCount())
        
        // Update existing run
        store.addRun(run1Updated)
        
        assertEquals(2, store.getRunCount()) // Should still be 2 runs
        
        val loadedRuns = store.loadRuns()
        val updatedRun = loadedRuns.find { it.id == "1" }
        assertNotNull(updatedRun)
        assertEquals(600.0, updatedRun.ppi) // Should have updated PPI
        
        // Cleanup
        store.clear()
    }
    
    @Test
    fun `addRuns adds multiple runs`() {
        val store = JsonRunStore()
        
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", 2000, 3000, 10000.0, 3000, 300.0, ppi = 500.0),
            RunDTO("3", "GPX", 3000, 4000, 21097.5, 6300, 300.0, ppi = 600.0)
        )
        
        store.addRuns(runs)
        
        assertEquals(3, store.getRunCount())
        
        val loadedRuns = store.loadRuns()
        assertEquals(3, loadedRuns.size)
        
        // Cleanup
        store.clear()
    }
    
    @Test
    fun `getRunsSince filters correctly`() {
        val store = JsonRunStore()
        
        val baseTime = 1700000000000L
        val runs = listOf(
            RunDTO("1", "GPX", baseTime - 1000, baseTime - 1000 + 1500, 5000.0, 1500, 300.0, ppi = 400.0), // Old
            RunDTO("2", "GPX", baseTime + 1000, baseTime + 1000 + 1200, 5000.0, 1200, 240.0, ppi = 500.0), // Recent
            RunDTO("3", "GPX", baseTime + 2000, baseTime + 2000 + 1800, 10000.0, 1800, 180.0, ppi = 600.0) // Recent
        )
        
        store.addRuns(runs)
        
        val recentRuns = store.getRunsSince(baseTime)
        assertEquals(2, recentRuns.size)
        assertEquals("2", recentRuns[0].id)
        assertEquals("3", recentRuns[1].id)
        
        // Cleanup
        store.clear()
    }
    
    @Test
    fun `calculateBests works correctly`() {
        val store = JsonRunStore()
        
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
        
        store.addRuns(runs)
        
        val bests = store.calculateBests()
        
        assertEquals(1200, bests.best5kSec) // 20:00
        assertEquals(2400, bests.best10kSec) // 40:00
        assertEquals(5400, bests.bestHalfSec) // 1:30:00
        assertEquals(10800, bests.bestFullSec) // 3:00:00
        
        // Cleanup
        store.clear()
    }
    
    @Test
    fun `getHighestPpiLast90Days works correctly`() {
        val store = JsonRunStore()
        
        val nowMs = Clock.System.now().toEpochMilliseconds()
        val dayMs = 24L * 3600_000
        
        val runs = listOf(
            RunDTO("1", "GPX", nowMs - 10 * dayMs, nowMs - 10 * dayMs + 1500, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", nowMs - 50 * dayMs, nowMs - 50 * dayMs + 1200, 5000.0, 1200, 240.0, ppi = 600.0),
            RunDTO("3", "GPX", nowMs - 100 * dayMs, nowMs - 100 * dayMs + 1800, 5000.0, 1800, 360.0, ppi = 300.0), // Outside 90 days
            RunDTO("4", "GPX", nowMs - 5 * dayMs, nowMs - 5 * dayMs + 1400, 5000.0, 1400, 280.0, ppi = 500.0)
        )
        
        store.addRuns(runs)
        
        val highest = store.getHighestPpiLast90Days()
        assertEquals(600.0, highest) // Should find the 600 PPI run
        
        // Cleanup
        store.clear()
    }
    
    @Test
    fun `clear removes all runs`() {
        val store = JsonRunStore()
        
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0, ppi = 400.0),
            RunDTO("2", "GPX", 2000, 3000, 10000.0, 3000, 300.0, ppi = 500.0)
        )
        
        store.addRuns(runs)
        assertEquals(2, store.getRunCount())
        
        store.clear()
        assertTrue(store.isEmpty())
        assertEquals(0, store.getRunCount())
    }
}

