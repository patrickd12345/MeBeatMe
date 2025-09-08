package com.mebeatme.android

import com.mebeatme.android.data.persistence.JsonRunStore
import com.mebeatme.android.models.RunRecord
import kotlinx.coroutines.runBlocking
import org.junit.Test
import java.io.File
import org.junit.Assert.assertEquals

class RunStoreTest {
    @Test
    fun highestPpiInWindow() = runBlocking {
        val file = File.createTempFile("runs", ".json")
        val store = JsonRunStore(file)
        val now = System.currentTimeMillis()
        val day = 24 * 60 * 60 * 1000L
        store.save(RunRecord("1", "GPX", now - day, now - day + 1000, 1000.0, 400, 400.0, ppi = 48.2))
        store.save(RunRecord("2", "GPX", now - 10 * day, now - 10 * day + 1000, 1000.0, 390, 390.0, ppi = 51.9))
        store.save(RunRecord("3", "GPX", now - 91 * day, now - 91 * day + 1000, 1000.0, 390, 390.0, ppi = 49.7))
        val bests = store.bests(now)
        assertEquals(51.9, bests.highestPPILast90Days)
    }
}
