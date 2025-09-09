package com.mebeatme.shared.persistence

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.core.highestPpiInWindow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString

/**
 * iOS implementation of JSON-based persistence layer for MeBeatMe
 * Uses in-memory storage since iOS doesn't have direct file access in commonMain
 */
actual class JsonRunStore actual constructor(private val dataFile: Any) {
    
    private val json = Json {
        prettyPrint = true
        ignoreUnknownKeys = true
    }
    
    private val runs = mutableListOf<RunDTO>()
    
    actual fun upsertAll(newRuns: List<RunDTO>): Int {
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
        return stored
    }
    
    actual fun listSince(sinceMs: Long): List<RunDTO> {
        return runs.filter { it.startedAtEpochMs >= sinceMs }
    }
    
    actual fun getAll(): List<RunDTO> {
        return runs.toList()
    }
    
    actual fun getHighestPpiLast90Days(nowMs: Long, days: Int): Double? {
        return highestPpiInWindow(runs, nowMs, days)
    }
    
    actual fun getById(id: String): RunDTO? {
        return runs.find { it.id == id }
    }
    
    actual fun deleteById(id: String): Boolean {
        val index = runs.indexOfFirst { it.id == id }
        if (index >= 0) {
            runs.removeAt(index)
            return true
        }
        return false
    }
    
    actual fun clear() {
        runs.clear()
    }
    
    actual fun size(): Int {
        return runs.size
    }
}
