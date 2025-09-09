package com.mebeatme.shared.persistence

import com.mebeatme.shared.api.RunDTO
import com.mebeatme.shared.core.highestPpiInWindow

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
expect class JsonRunStore(dataFile: Any) {
    
    /**
     * Add or update runs in the store
     * @param newRuns List of runs to add/update
     * @return Number of runs stored
     */
    fun upsertAll(newRuns: List<RunDTO>): Int
    
    /**
     * Get all runs since a specific timestamp
     * @param sinceMs Timestamp in milliseconds
     * @return List of runs since the timestamp
     */
    fun listSince(sinceMs: Long): List<RunDTO>
    
    /**
     * Get all runs
     * @return List of all runs
     */
    fun getAll(): List<RunDTO>
    
    /**
     * Get highest PPI in the last 90 days
     * @param nowMs Current time in milliseconds
     * @param days Number of days to look back (default 90)
     * @return Highest PPI or null if no runs
     */
    fun getHighestPpiLast90Days(nowMs: Long, days: Int = 90): Double?
    
    /**
     * Get run by ID
     * @param id Run ID
     * @return Run or null if not found
     */
    fun getById(id: String): RunDTO?
    
    /**
     * Delete run by ID
     * @param id Run ID
     * @return true if deleted, false if not found
     */
    fun deleteById(id: String): Boolean
    
    /**
     * Clear all runs
     */
    fun clear()
    
    /**
     * Get run count
     * @return Number of runs
     */
    fun size(): Int
}