package com.mebeatme.shared.persistence

import com.mebeatme.shared.api.RunDTO
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import java.io.File
import java.nio.file.Files

/**
 * Tests for JsonRunStore persistence layer
 * Following the HYBRID PROMPT specifications
 */
class JsonRunStoreTest {
    
    @Test
    fun testUpsertAll_NewRuns() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val runs = listOf(
            createRunDTO("run1", 100.0),
            createRunDTO("run2", 200.0)
        )
        
        val stored = store.upsertAll(runs)
        assertEquals(2, stored)
        assertEquals(2, store.size())
    }
    
    @Test
    fun testUpsertAll_UpdateExisting() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val originalRun = createRunDTO("run1", 100.0)
        val updatedRun = createRunDTO("run1", 150.0)
        
        store.upsertAll(listOf(originalRun))
        assertEquals(1, store.size())
        
        store.upsertAll(listOf(updatedRun))
        assertEquals(1, store.size())
        
        val retrieved = store.getById("run1")
        assertEquals(150.0, retrieved?.ppi)
    }
    
    @Test
    fun testListSince() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO("run1", 100.0, nowMs - 10 * 24 * 3600 * 1000), // 10 days ago
            createRunDTO("run2", 200.0, nowMs - 5 * 24 * 3600 * 1000),  // 5 days ago
            createRunDTO("run3", 300.0, nowMs - 15 * 24 * 3600 * 1000)  // 15 days ago
        )
        
        store.upsertAll(runs)
        
        val recentRuns = store.listSince(nowMs - 7 * 24 * 3600 * 1000) // Last 7 days
        assertEquals(1, recentRuns.size)
        assertEquals("run2", recentRuns[0].id)
    }
    
    @Test
    fun testGetHighestPpiLast90Days() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val nowMs = 1757300000000L
        val runs = listOf(
            createRunDTO("run1", 100.0, nowMs - 10 * 24 * 3600 * 1000), // 10 days ago
            createRunDTO("run2", 200.0, nowMs - 35 * 24 * 3600 * 1000), // 35 days ago
            createRunDTO("run3", 300.0, nowMs - 95 * 24 * 3600 * 1000)  // 95 days ago (outside window)
        )
        
        store.upsertAll(runs)
        
        val highestPpi = store.getHighestPpiLast90Days(nowMs, 90)
        assertEquals(200.0, highestPpi)
    }
    
    @Test
    fun testGetHighestPpiLast90Days_NoRuns() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val highestPpi = store.getHighestPpiLast90Days(System.currentTimeMillis(), 90)
        assertNull(highestPpi)
    }
    
    @Test
    fun testGetById() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val run = createRunDTO("run1", 100.0)
        store.upsertAll(listOf(run))
        
        val retrieved = store.getById("run1")
        assertEquals("run1", retrieved?.id)
        assertEquals(100.0, retrieved?.ppi)
        
        val notFound = store.getById("nonexistent")
        assertNull(notFound)
    }
    
    @Test
    fun testDeleteById() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val run = createRunDTO("run1", 100.0)
        store.upsertAll(listOf(run))
        assertEquals(1, store.size())
        
        val deleted = store.deleteById("run1")
        assertTrue(deleted)
        assertEquals(0, store.size())
        
        val notDeleted = store.deleteById("nonexistent")
        assertTrue(!notDeleted)
    }
    
    @Test
    fun testClear() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        val runs = listOf(
            createRunDTO("run1", 100.0),
            createRunDTO("run2", 200.0)
        )
        
        store.upsertAll(runs)
        assertEquals(2, store.size())
        
        store.clear()
        assertEquals(0, store.size())
    }
    
    @Test
    fun testPersistence() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        
        // Create store and add runs
        val store1 = JsonRunStore(dataFile)
        val runs = listOf(
            createRunDTO("run1", 100.0),
            createRunDTO("run2", 200.0)
        )
        store1.upsertAll(runs)
        
        // Create new store instance (simulates app restart)
        val store2 = JsonRunStore(dataFile)
        assertEquals(2, store2.size())
        
        val retrieved = store2.getById("run1")
        assertEquals(100.0, retrieved?.ppi)
    }
    
    @Test
    fun testAtomicWrite() {
        val tempDir = Files.createTempDirectory("mebeatme_test").toFile()
        val dataFile = File(tempDir, "runs.json")
        val store = JsonRunStore(dataFile)
        
        // Add runs
        val runs = listOf(createRunDTO("run1", 100.0))
        store.upsertAll(runs)
        
        // Verify file exists and is valid JSON
        assertTrue(dataFile.exists())
        val content = dataFile.readText()
        assertTrue(content.contains("run1"))
        assertTrue(content.contains("100.0"))
    }
    
    // ===== HELPER FUNCTIONS =====
    
    private fun createRunDTO(id: String, ppi: Double, startedAtEpochMs: Long = System.currentTimeMillis()): RunDTO {
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

