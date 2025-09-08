package com.mebeatme.shared.core

import com.mebeatme.shared.api.RunDTO
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class BestsTest {
    
    @Test
    fun highestPpiLast90Days_isComputedCorrectly() {
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
    fun highestPpiLast90Days_noRunsInWindow_returnsNull() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 48.2, daysAgo = 100, nowMs), // outside window
            createRunDTO(ppi = 51.9, daysAgo = 200, nowMs)  // outside window
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertNull(highestPpi)
    }
    
    @Test
    fun highestPpiLast90Days_singleRunInWindow_returnsThatRun() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 48.2, daysAgo = 10, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertEquals(48.2, highestPpi!!, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_multipleRunsInWindow_returnsHighest() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 45.0, daysAgo = 5, nowMs),
            createRunDTO(ppi = 52.3, daysAgo = 15, nowMs),
            createRunDTO(ppi = 48.7, daysAgo = 30, nowMs),
            createRunDTO(ppi = 50.1, daysAgo = 60, nowMs),
            createRunDTO(ppi = 47.2, daysAgo = 85, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertEquals(52.3, highestPpi!!, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_boundaryConditions_handlesCorrectly() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0, daysAgo = 90, nowMs), // exactly on boundary
            createRunDTO(ppi = 45.0, daysAgo = 91, nowMs)  // just outside boundary
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertEquals(50.0, highestPpi!!, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_emptyRunsList_returnsNull() {
        val nowMs = 1757300000000L
        val runs = emptyList<RunDTO>()
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertNull(highestPpi)
    }
    
    @Test
    fun highestPpiLast90Days_zeroWindow_returnsNull() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0, daysAgo = 1, nowMs) // 1 day ago, outside zero window
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 0)
        
        assertNull(highestPpi)
    }
    
    @Test
    fun highestPpiLast90Days_negativeWindow_returnsNull() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0, daysAgo = 10, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, -1)
        
        assertNull(highestPpi)
    }
    
    @Test
    fun highestPpiLast90Days_veryLargeWindow_includesAllRuns() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 45.0, daysAgo = 100, nowMs),
            createRunDTO(ppi = 55.0, daysAgo = 200, nowMs),
            createRunDTO(ppi = 50.0, daysAgo = 300, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 365)
        
        assertEquals(55.0, highestPpi!!, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_identicalPpiValues_returnsFirst() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0, daysAgo = 10, nowMs),
            createRunDTO(ppi = 50.0, daysAgo = 20, nowMs),
            createRunDTO(ppi = 50.0, daysAgo = 30, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertEquals(50.0, highestPpi!!, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_floatingPointPrecision_handlesCorrectly() {
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO(ppi = 50.0000001, daysAgo = 10, nowMs),
            createRunDTO(ppi = 50.0000002, daysAgo = 20, nowMs)
        )
        
        val highestPpi = highestPpiInWindow(runs, nowMs, 90)
        
        assertTrue(highestPpi!! > 50.0)
    }
    
    private fun createRunDTO(ppi: Double, daysAgo: Int, nowMs: Long): RunDTO {
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
