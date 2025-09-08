package com.mebeatme.shared.persistence

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO
import com.mebeatme.shared.core.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlinx.datetime.Clock

/**
 * Simple in-memory JSON store for testing and development
 * In production, this would be replaced with platform-specific implementations
 */
class JsonRunStore {
    
    private val json = Json { 
        prettyPrint = true
        isLenient = true
    }
    
    private val runs = mutableListOf<RunDTO>()
    
    /**
     * Load all runs from memory
     */
    fun loadRuns(): List<RunDTO> {
        return runs.toList()
    }
    
    /**
     * Save runs to memory
     */
    fun saveRuns(newRuns: List<RunDTO>) {
        runs.clear()
        runs.addAll(newRuns)
    }
    
    /**
     * Add a new run to the store
     */
    fun addRun(run: RunDTO) {
        // Remove existing run with same ID if it exists
        runs.removeAll { it.id == run.id }
        runs.add(run)
    }
    
    /**
     * Add multiple runs to the store
     */
    fun addRuns(newRuns: List<RunDTO>) {
        // Remove existing runs with same IDs
        val idsToUpdate = newRuns.map { it.id }.toSet()
        runs.removeAll { it.id in idsToUpdate }
        runs.addAll(newRuns)
    }
    
    /**
     * Get runs since a specific timestamp
     */
    fun getRunsSince(sinceMs: Long): List<RunDTO> {
        return runs.filter { it.startedAtEpochMs >= sinceMs }
    }
    
    /**
     * Calculate and return bests from stored runs
     */
    fun calculateBests(sinceMs: Long = 0L): BestsDTO {
        val filteredRuns = if (sinceMs > 0) getRunsSince(sinceMs) else loadRuns()
        return com.mebeatme.shared.core.calculateBests(filteredRuns, sinceMs)
    }
    
    /**
     * Get highest PPI in last N days
     */
    fun getHighestPpiLast90Days(): Double? {
        return highestPpiInWindow(runs, Clock.System.now().toEpochMilliseconds(), 90)
    }
    
    /**
     * Clear all runs from the store
     */
    fun clear() {
        runs.clear()
    }
    
    /**
     * Get run count
     */
    fun getRunCount(): Int {
        return runs.size
    }
    
    /**
     * Check if store is empty
     */
    fun isEmpty(): Boolean {
        return runs.isEmpty()
    }
    
    /**
     * Serialize runs to JSON string
     */
    fun serializeRuns(): String {
        return json.encodeToString(runs)
    }
    
    /**
     * Deserialize runs from JSON string
     */
    fun deserializeRuns(jsonString: String) {
        val deserializedRuns = json.decodeFromString<List<RunDTO>>(jsonString)
        runs.clear()
        runs.addAll(deserializedRuns)
    }
}