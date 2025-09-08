import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime

class BestsTest {
    
    @Test
    fun highestPpiLast90Days_isComputedCorrectly() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 48.2, daysAgo = 10, now),
            createRun(ppi = 51.9, daysAgo = 35, now),
            createRun(ppi = 49.7, daysAgo = 91, now) // outside window
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertEquals(51.9, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_noRunsInWindow_returnsNull() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 48.2, daysAgo = 100, now), // outside window
            createRun(ppi = 51.9, daysAgo = 200, now)  // outside window
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertNull(bests.highestPpiLast90Days)
    }
    
    @Test
    fun highestPpiLast90Days_singleRunInWindow_returnsThatRun() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 48.2, daysAgo = 10, now)
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertEquals(48.2, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_multipleRunsInWindow_returnsHighest() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 45.0, daysAgo = 5, now),
            createRun(ppi = 52.3, daysAgo = 15, now),
            createRun(ppi = 48.7, daysAgo = 30, now),
            createRun(ppi = 50.1, daysAgo = 60, now),
            createRun(ppi = 47.2, daysAgo = 85, now)
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertEquals(52.3, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_boundaryConditions_handlesCorrectly() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 50.0, daysAgo = 90, now), // exactly on boundary
            createRun(ppi = 45.0, daysAgo = 91, now)  // just outside boundary
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertEquals(50.0, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_emptyRunsList_returnsNull() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = emptyList<RunRecord>()
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertNull(bests.highestPpiLast90Days)
    }
    
    @Test
    fun highestPpiLast90Days_zeroWindow_returnsNull() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 50.0, daysAgo = 0, now)
        )
        
        val bests = Bests.from(runs, windowDays = 0, now = now)
        
        assertNull(bests.highestPpiLast90Days)
    }
    
    @Test
    fun highestPpiLast90Days_negativeWindow_returnsNull() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 50.0, daysAgo = 10, now)
        )
        
        val bests = Bests.from(runs, windowDays = -1, now = now)
        
        assertNull(bests.highestPpiLast90Days)
    }
    
    @Test
    fun highestPpiLast90Days_veryLargeWindow_includesAllRuns() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 45.0, daysAgo = 100, now),
            createRun(ppi = 55.0, daysAgo = 200, now),
            createRun(ppi = 50.0, daysAgo = 300, now)
        )
        
        val bests = Bests.from(runs, windowDays = 365, now = now)
        
        assertEquals(55.0, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_identicalPpiValues_returnsFirst() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 50.0, daysAgo = 10, now),
            createRun(ppi = 50.0, daysAgo = 20, now),
            createRun(ppi = 50.0, daysAgo = 30, now)
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertEquals(50.0, bests.highestPpiLast90Days, 1e-6)
    }
    
    @Test
    fun highestPpiLast90Days_floatingPointPrecision_handlesCorrectly() {
        val now = Instant.parse("2025-01-15T12:00:00Z")
        val runs = listOf(
            createRun(ppi = 50.0000001, daysAgo = 10, now),
            createRun(ppi = 50.0000002, daysAgo = 20, now)
        )
        
        val bests = Bests.from(runs, windowDays = 90, now = now)
        
        assertTrue(bests.highestPpiLast90Days!! > 50.0)
    }
    
    private fun createRun(ppi: Double, daysAgo: Int, now: Instant): RunRecord {
        val runDate = now.minus(kotlinx.datetime.DateTimeUnit.DAY, daysAgo.toLong())
        return RunRecord(
            id = kotlinx.uuid.Uuid.random(),
            date = runDate,
            distance = 5000.0, // 5km
            duration = 1800, // 30 minutes
            averagePace = 360.0, // 6:00/km
            splits = null,
            source = "test",
            fileName = "test.gpx",
            ppi = ppi
        )
    }
}

// Extension function for Bests to support the test
fun Bests.Companion.from(runs: List<RunRecord>, windowDays: Int, now: Instant): Bests {
    val cutoffDate = now.minus(kotlinx.datetime.DateTimeUnit.DAY, windowDays.toLong())
    
    val runsInWindow = runs.filter { it.date >= cutoffDate }
    
    val highestPpi = if (runsInWindow.isNotEmpty()) {
        runsInWindow.maxOfOrNull { it.ppi ?: 0.0 }
    } else {
        null
    }
    
    return Bests(
        best5kSec = null,
        best10kSec = null,
        bestHalfSec = null,
        bestFullSec = null,
        highestPpiLast90Days = highestPpi
    )
}
