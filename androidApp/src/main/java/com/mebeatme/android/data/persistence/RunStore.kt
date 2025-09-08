package com.mebeatme.android.data.persistence

import com.mebeatme.android.models.Bests
import com.mebeatme.android.models.RunRecord
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json
import java.io.File
import kotlin.math.max

interface RunStore {
    suspend fun save(run: RunRecord)
    suspend fun list(limit: Int? = null): List<RunRecord>
    suspend fun bests(nowMs: Long = System.currentTimeMillis()): Bests
    suspend fun clear()
}

class JsonRunStore(
    private val file: File,
    private val json: Json = Json { encodeDefaults = true; prettyPrint = true }
) : RunStore {
    override suspend fun save(run: RunRecord) = withContext(Dispatchers.IO) {
        val runs = list().toMutableList()
        runs += run
        writeRuns(runs)
    }

    override suspend fun list(limit: Int?): List<RunRecord> = withContext(Dispatchers.IO) {
        if (!file.exists()) return@withContext emptyList()
        val text = file.readText()
        val runs = if (text.isBlank()) emptyList() else json.decodeFromString(ListSerializer(RunRecord.serializer()), text)
        return@withContext if (limit != null) runs.takeLast(limit) else runs
    }

    override suspend fun bests(nowMs: Long): Bests = withContext(Dispatchers.IO) {
        val runs = list()
        val window = nowMs - 90L * 24 * 60 * 60 * 1000
        val highest = runs.filter { it.startedAtEpochMs >= window }.maxOfOrNull { it.ppi ?: Double.MIN_VALUE }
        Bests(highestPPILast90Days = if (highest == Double.MIN_VALUE) null else highest)
    }

    override suspend fun clear() = withContext(Dispatchers.IO) {
        if (file.exists()) file.delete()
    }

    private fun writeRuns(runs: List<RunRecord>) {
        val tmp = File(file.parentFile, file.name + ".tmp")
        tmp.writeText(json.encodeToString(ListSerializer(RunRecord.serializer()), runs))
        if (file.exists()) file.delete()
        tmp.renameTo(file)
    }
}
