package com.mebeatme.shared.persistence

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.core.highestPpiInWindow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString
import java.io.File
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

/**
 * JVM implementation of JSON-based persistence layer for MeBeatMe
 */
actual class JsonRunStore actual constructor(private val dataFile: Any) {
    
    private val file = dataFile as File
    private val json = Json {
        prettyPrint = true
        ignoreUnknownKeys = true
    }
    
    private val lock = ReentrantReadWriteLock()
    private val runs = mutableListOf<RunDTO>()
    
    init {
        loadFromFile()
    }
    
    actual fun upsertAll(newRuns: List<RunDTO>): Int {
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
    
    actual fun listSince(sinceMs: Long): List<RunDTO> {
        return lock.read {
            runs.filter { it.startedAtEpochMs >= sinceMs }
        }
    }
    
    actual fun getAll(): List<RunDTO> {
        return lock.read {
            runs.toList()
        }
    }
    
    actual fun getHighestPpiLast90Days(nowMs: Long, days: Int): Double? {
        return lock.read {
            highestPpiInWindow(runs, nowMs, days)
        }
    }
    
    actual fun getById(id: String): RunDTO? {
        return lock.read {
            runs.find { it.id == id }
        }
    }
    
    actual fun deleteById(id: String): Boolean {
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
    
    actual fun clear() {
        lock.write {
            runs.clear()
            saveToFile()
        }
    }
    
    actual fun size(): Int {
        return lock.read {
            runs.size
        }
    }
    
    // ===== PRIVATE METHODS =====
    
    private fun loadFromFile() {
        if (!file.exists()) {
            return
        }
        
        try {
            val jsonString = file.readText()
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
            file.parentFile?.mkdirs()
            
            // Write to temporary file first (atomic write)
            val tempFile = File(file.absolutePath + ".tmp")
            val jsonString = json.encodeToString(runs)
            tempFile.writeText(jsonString)
            
            // Move temp file to final location
            tempFile.renameTo(file)
        } catch (e: Exception) {
            throw RuntimeException("Failed to save runs to file", e)
        }
    }
}
