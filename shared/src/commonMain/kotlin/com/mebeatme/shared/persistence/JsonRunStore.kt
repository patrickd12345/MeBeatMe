package com.mebeatme.shared.persistence

import com.mebeatme.shared.api.RunDTO
import com.mebeatme.shared.core.highestPpiInWindow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString
import java.io.File
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

/**
 * JSON-based persistence layer for MeBeatMe
 * Following the HYBRID PROMPT specifications
 * 
 * Features:
 * - Append-only JSON storage
 * - Atomic writes (temp file → move)
 * - Thread-safe operations
 * - 90-day computation support
 */
class JsonRunStore(private val dataFile: File) {
    
    private val json = Json {
        prettyPrint = true
        ignoreUnknownKeys = true
    }
    
    private val lock = ReentrantReadWriteLock()
    private val runs = mutableListOf<RunDTO>()
    
    init {
        loadFromFile()
    }
    
    /**
     * Add or update runs in the store
     * @param newRuns List of runs to add/update
     * @return Number of runs stored
     */
    fun upsertAll(newRuns: List<RunDTO>): Int {
        return lock.write {
            var stored = 0
            newRuns.forEach { newRun ->
                val existingIndex = runs.indexOfFirst { it.id == newRun.id }
                if (existingIndex >= 0) {
                    runs[existingIndex] = newRun
                } else {
                    runs.add(newRun)
                }
                stored++
            }
            saveToFile()
            stored
        }
    }
    
    /**
     * Get all runs since a specific timestamp
     * @param sinceMs Timestamp in milliseconds
     * @return List of runs since the timestamp
     */
    fun listSince(sinceMs: Long): List<RunDTO> {
        return lock.read {
            runs.filter { it.startedAtEpochMs >= sinceMs }
        }
    }
    
    /**
     * Get all runs
     * @return List of all runs
     */
    fun getAll(): List<RunDTO> {
        return lock.read {
            runs.toList()
        }
    }
    
    /**
     * Get highest PPI in the last 90 days
     * @param nowMs Current time in milliseconds
     * @param days Number of days to look back (default 90)
     * @return Highest PPI or null if no runs
     */
    fun getHighestPpiLast90Days(nowMs: Long, days: Int = 90): Double? {
        return lock.read {
            highestPpiInWindow(runs, nowMs, days)
        }
    }
    
    /**
     * Get run by ID
     * @param id Run ID
     * @return Run or null if not found
     */
    fun getById(id: String): RunDTO? {
        return lock.read {
            runs.find { it.id == id }
        }
    }
    
    /**
     * Delete run by ID
     * @param id Run ID
     * @return true if deleted, false if not found
     */
    fun deleteById(id: String): Boolean {
        return lock.write {
            val index = runs.indexOfFirst { it.id == id }
            if (index >= 0) {
                runs.removeAt(index)
                saveToFile()
                true
            } else {
                false
            }
        }
    }
    
    /**
     * Clear all runs
     */
    fun clear() {
        lock.write {
            runs.clear()
            saveToFile()
        }
    }
    
    /**
     * Get run count
     * @return Number of runs
     */
    fun size(): Int {
        return lock.read {
            runs.size
        }
    }
    
    // ===== PRIVATE METHODS =====
    
    private fun loadFromFile() {
        if (!dataFile.exists()) {
            return
        }
        
        try {
            val jsonString = dataFile.readText()
            val loadedRuns = json.decodeFromString<List<RunDTO>>(jsonString)
            runs.clear()
            runs.addAll(loadedRuns)
        } catch (e: Exception) {
            // If file is corrupted, start fresh
            runs.clear()
        }
    }
    
    private fun saveToFile() {
        try {
            // Create parent directories if they don't exist
            dataFile.parentFile?.mkdirs()
            
            // Write to temporary file first (atomic write)
            val tempFile = File(dataFile.absolutePath + ".tmp")
            val jsonString = json.encodeToString(runs)
            tempFile.writeText(jsonString)
            
            // Move temp file to final location
            tempFile.renameTo(dataFile)
        } catch (e: Exception) {
            throw RuntimeException("Failed to save runs to file", e)
        }
    }
}
