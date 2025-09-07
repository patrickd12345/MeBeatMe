package com.mebeatme.shared.core

import com.mebeatme.shared.model.DistanceBucket
import com.mebeatme.shared.model.RunSession
import kotlinx.datetime.Clock
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class PurdyPointsCalculatorTest {
    
    @Test
    fun testCalculatePPI_ShortDistance() {
        // Test 1km in 4:00 (240 seconds)
        val ppi = PurdyPointsCalculator.calculatePPI(1000.0, 240L)
        assertTrue(ppi > 0, "PPI should be positive")
        assertTrue(ppi < 2000, "PPI should be within reasonable bounds")
    }
    
    @Test
    fun testCalculatePPI_MediumDistance() {
        // Test 5km in 20:00 (1200 seconds)
        val ppi = PurdyPointsCalculator.calculatePPI(5000.0, 1200L)
        assertTrue(ppi > 0, "PPI should be positive")
        assertTrue(ppi < 2000, "PPI should be within reasonable bounds")
    }
    
    @Test
    fun testCalculatePPI_LongDistance() {
        // Test 10km in 45:00 (2700 seconds)
        val ppi = PurdyPointsCalculator.calculatePPI(10000.0, 2700L)
        assertTrue(ppi > 0, "PPI should be positive")
        assertTrue(ppi < 2000, "PPI should be within reasonable bounds")
    }
    
    @Test
    fun testCalculateRequiredPace() {
        val distance = 5000.0 // 5km
        val targetPPI = 500.0
        
        val requiredPace = PurdyPointsCalculator.calculateRequiredPace(distance, targetPPI)
        
        assertTrue(requiredPace > 0, "Required pace should be positive")
        assertTrue(requiredPace < 600, "Required pace should be reasonable") // Less than 10 min/km
    }
    
    @Test
    fun testCalculateRequiredTime() {
        val distance = 5000.0 // 5km
        val targetPPI = 500.0
        
        val requiredTime = PurdyPointsCalculator.calculateRequiredTime(distance, targetPPI)
        
        assertTrue(requiredTime > 0, "Required time should be positive")
        assertTrue(requiredTime < 3600, "Required time should be reasonable") // Less than 1 hour
    }
    
    @Test
    fun testPaceConsistency() {
        val distance = 5000.0
        val targetPPI = 500.0
        
        val requiredPace = PurdyPointsCalculator.calculateRequiredPace(distance, targetPPI)
        val requiredTime = PurdyPointsCalculator.calculateRequiredTime(distance, targetPPI)
        
        // Verify that pace * distance = time
        val calculatedTime = (requiredPace * distance / 1000.0).toLong()
        assertEquals(requiredTime, calculatedTime, "Pace and time calculations should be consistent")
    }
}

class PerformanceBucketManagerTest {
    
    @Test
    fun testGetBucketForDistance() {
        val manager = PerformanceBucketManager()
        
        assertEquals(DistanceBucket.SPRINT, manager.getBucketForDistance(2000.0)) // 2km
        assertEquals(DistanceBucket.SHORT_RUN, manager.getBucketForDistance(5000.0)) // 5km
        assertEquals(DistanceBucket.MEDIUM_RUN, manager.getBucketForDistance(10000.0)) // 10km
        assertEquals(DistanceBucket.LONG_RUN, manager.getBucketForDistance(20000.0)) // 20km
    }
    
    @Test
    fun testUpdateHistoricalBest() {
        val manager = PerformanceBucketManager()
        
        val session1 = RunSession(
            id = "test1",
            distance = 5000.0,
            duration = 1200L, // 20:00
            timestamp = Clock.System.now(),
            pace = 240.0
        )
        
        val ppi1 = manager.updateHistoricalBest(session1)
        assertTrue(ppi1 > 0, "First PPI should be positive")
        
        val bucket = manager.getBucketForDistance(5000.0)
        val historicalBest = manager.getHistoricalBest(bucket)
        assertEquals(ppi1, historicalBest, "Historical best should match first PPI")
        
        // Add a better session
        val session2 = RunSession(
            id = "test2",
            distance = 5000.0,
            duration = 1000L, // 16:40 (faster)
            timestamp = Clock.System.now(),
            pace = 200.0
        )
        
        val ppi2 = manager.updateHistoricalBest(session2)
        assertTrue(ppi2 > ppi1, "Second PPI should be higher than first")
        
        val updatedBest = manager.getHistoricalBest(bucket)
        assertEquals(ppi2, updatedBest, "Historical best should be updated")
    }
    
    @Test
    fun testGetBucketStats() {
        val manager = PerformanceBucketManager()
        
        val stats = manager.getBucketStats()
        assertEquals(DistanceBucket.values().size, stats.size, "Should have stats for all buckets")
        
        // All buckets should initially have no data
        stats.values.forEach { bucketStats ->
            assertTrue(!bucketStats.hasData, "Initially no bucket should have data")
            assertEquals(0.0, bucketStats.historicalBest, "Initially all historical bests should be 0")
        }
    }
}

class ChallengeGeneratorTest {
    
    @Test
    fun testGenerateChallenges() {
        val bucketManager = PerformanceBucketManager()
        val generator = ChallengeGenerator(bucketManager)
        
        // Add some historical data
        val session = RunSession(
            id = "test",
            distance = 5000.0,
            duration = 1200L,
            timestamp = Clock.System.now(),
            pace = 240.0
        )
        bucketManager.updateHistoricalBest(session)
        
        val challenges = generator.generateChallenges()
        
        assertEquals(4, challenges.size, "Should generate 4 challenges")
        
        // Should have one surprise challenge
        val surpriseChallenges = challenges.filter { it.title == "Surprise Me" }
        assertEquals(1, surpriseChallenges.size, "Should have exactly one surprise challenge")
        
        // All challenges should have valid data
        challenges.forEach { challenge ->
            assertTrue(challenge.targetPace > 0, "Target pace should be positive")
            assertTrue(challenge.targetDuration > 0, "Target duration should be positive")
            assertTrue(challenge.targetDistance > 0, "Target distance should be positive")
            assertTrue(challenge.expectedPpi > 0, "Expected PPI should be positive")
        }
    }
    
    @Test
    fun testGenerateDefaultChallenges() {
        val bucketManager = PerformanceBucketManager()
        val generator = ChallengeGenerator(bucketManager)
        
        // No historical data, should generate defaults
        val challenges = generator.generateChallenges()
        
        assertEquals(4, challenges.size, "Should generate 4 default challenges")
        
        val titles = challenges.map { it.title }
        assertTrue(titles.contains("Short & Fierce"), "Should contain Short & Fierce")
        assertTrue(titles.contains("Tempo Boost"), "Should contain Tempo Boost")
        assertTrue(titles.contains("Ease Into It"), "Should contain Ease Into It")
        assertTrue(titles.contains("Surprise Me"), "Should contain Surprise Me")
    }
}

class PaceUtilsTest {
    
    @Test
    fun testFormatPace() {
        assertEquals("4:00", PaceUtils.formatPace(240.0))
        assertEquals("5:30", PaceUtils.formatPace(330.0))
        assertEquals("0:45", PaceUtils.formatPace(45.0))
    }
    
    @Test
    fun testParsePace() {
        assertEquals(240.0, PaceUtils.parsePace("4:00"))
        assertEquals(330.0, PaceUtils.parsePace("5:30"))
        assertEquals(45.0, PaceUtils.parsePace("0:45"))
    }
    
    @Test
    fun testPaceConversion() {
        val secondsPerKm = 300.0
        val minutesPerKm = PaceUtils.secondsPerKmToMinutesPerKm(secondsPerKm)
        val backToSeconds = PaceUtils.minutesPerKmToSecondsPerKm(minutesPerKm)

        assertEquals(secondsPerKm, backToSeconds, "Conversion should be reversible")
    }

    @Test
    fun testSpeedConversions() {
        val mps = 5.0
        val secPerKm = PaceUtils.metersPerSecondToSecondsPerKm(mps)
        assertEquals(200.0, secPerKm, 0.0001, "5 m/s should be 200 sec/km")
        val backToMps = PaceUtils.secondsPerKmToMetersPerSecond(secPerKm)
        assertEquals(mps, backToMps, 0.0001, "Conversion should be reversible")
        val minPerKm = PaceUtils.metersPerSecondToMinutesPerKm(mps)
        assertEquals(200.0 / 60.0, minPerKm, 0.0001, "5 m/s should be 3.333... min/km")
        val mpsAgain = PaceUtils.minutesPerKmToMetersPerSecond(minPerKm)
        assertEquals(mps, mpsAgain, 0.0001, "Conversion should be reversible")
    }
}

class DistanceBucketLabelTest {

    @Test
    fun testLabelRoundTrip() {
        DistanceBucket.values().forEach { bucket ->
            val label = bucket.label
            val parsed = DistanceBucket.fromLabel(label)
            assertEquals(bucket, parsed, "Label should map back to original bucket")
        }
    }
}
