package com.mebeatme.core.ppi

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class PurdyTableTest {
    
    @Test
    fun `should load baseline anchors correctly`() {
        val anchors = PurdyTable.getAnchors()
        
        assertEquals(5, anchors.size)
        
        // Check first anchor (1500m)
        val first = anchors[0]
        assertEquals(1500.0, first.distanceM)
        assertEquals(230.0, first.timeSec)
        assertEquals(1000.0, first.points)
        
        // Check last anchor (42195m)
        val last = anchors[4]
        assertEquals(42195.0, last.distanceM)
        assertEquals(7460.0, last.timeSec)
        assertEquals(1000.0, last.points)
    }
    
    @Test
    fun `should find closest anchor correctly`() {
        val closest = PurdyTable.findClosestAnchor(3000.0)
        assertNotNull(closest)
        assertEquals(1500.0, closest.distanceM) // Should find 1500m as closest to 3000m
        
        val closest2 = PurdyTable.findClosestAnchor(6000.0)
        assertNotNull(closest2)
        assertEquals(5000.0, closest2.distanceM) // Should find 5000m as closest to 6000m
    }
    
    @Test
    fun `should interpolate baseline time correctly`() {
        // Test exact anchor points
        assertEquals(230.0, PurdyTable.getBaselineTime(1500.0), 0.1)
        assertEquals(780.0, PurdyTable.getBaselineTime(5000.0), 0.1)
        assertEquals(1620.0, PurdyTable.getBaselineTime(10000.0), 0.1)
        
        // Test interpolation between anchors
        val time3000 = PurdyTable.getBaselineTime(3000.0)
        assertTrue(time3000 > 230.0 && time3000 < 780.0) // Between 1500m and 5000m times
        
        val time7500 = PurdyTable.getBaselineTime(7500.0)
        assertTrue(time7500 > 780.0 && time7500 < 1620.0) // Between 5000m and 10000m times
    }
    
    @Test
    fun `should handle edge cases`() {
        // Very short distance
        val shortTime = PurdyTable.getBaselineTime(100.0)
        assertEquals(230.0, shortTime, 0.1) // Should clamp to first anchor
        
        // Very long distance
        val longTime = PurdyTable.getBaselineTime(100000.0)
        assertEquals(7460.0, longTime, 0.1) // Should clamp to last anchor
    }
}

class PpiCurvePurdyTest {
    
    @Test
    fun `should score elite baseline correctly`() {
        // Elite 5K time should score ~1000 points
        val score = PpiCurvePurdy.score(5000.0, 780.0)
        assertEquals(1000.0, score, 1.0) // Allow small tolerance
    }
    
    @Test
    fun `should score faster than elite higher`() {
        // Faster than elite should score higher
        val eliteScore = PpiCurvePurdy.score(5000.0, 780.0)
        val fasterScore = PpiCurvePurdy.score(5000.0, 700.0) // 10% faster
        
        assertTrue(fasterScore > eliteScore)
        assertTrue(fasterScore > 1000.0)
    }
    
    @Test
    fun `should score slower than elite lower`() {
        // Slower than elite should score lower
        val eliteScore = PpiCurvePurdy.score(5000.0, 780.0)
        val slowerScore = PpiCurvePurdy.score(5000.0, 900.0) // ~15% slower
        
        assertTrue(slowerScore < eliteScore)
        assertTrue(slowerScore < 1000.0)
    }
    
    @Test
    fun `should respect score bounds`() {
        // Very slow time should hit minimum
        val slowScore = PpiCurvePurdy.score(5000.0, 2000.0) // Very slow
        assertTrue(slowScore >= 100.0)
        
        // Very fast time should hit maximum
        val fastScore = PpiCurvePurdy.score(5000.0, 300.0) // Very fast
        assertTrue(fastScore <= 2000.0)
    }
    
    @Test
    fun `should calculate performance ratio correctly`() {
        val ratio = PpiCurvePurdy.getPerformanceRatio(5000.0, 780.0)
        assertEquals(1.0, ratio, 0.01) // Elite baseline should be 1.0
        
        val fasterRatio = PpiCurvePurdy.getPerformanceRatio(5000.0, 700.0)
        assertTrue(fasterRatio > 1.0) // Faster should be > 1.0
        
        val slowerRatio = PpiCurvePurdy.getPerformanceRatio(5000.0, 900.0)
        assertTrue(slowerRatio < 1.0) // Slower should be < 1.0
    }
    
    @Test
    fun `should invert score to required time correctly`() {
        val targetScore = 1000.0
        val requiredTime = PpiCurvePurdy.requiredTimeFor(5000.0, targetScore)
        
        // Required time should produce the target score
        val actualScore = PpiCurvePurdy.score(5000.0, requiredTime)
        assertEquals(targetScore, actualScore, 1.0) // Allow small tolerance
    }
    
    @Test
    fun `should calculate required pace correctly`() {
        val targetScore = 1000.0
        val requiredPace = PpiCurvePurdy.requiredPaceSecPerKm(5000.0, targetScore)
        
        // Elite 5K pace should be around 2:36/km (156 sec/km)
        assertTrue(requiredPace > 150.0 && requiredPace < 160.0)
    }
    
    @Test
    fun `should handle corrections correctly`() {
        val baseScore = PpiCurvePurdy.score(5000.0, 780.0)
        val correctedScore = PpiCurvePurdy.correctedScore(5000.0, 780.0, Corrections())
        
        assertEquals(baseScore, correctedScore, 0.1) // No corrections should be same
    }
}

class PpiEngineTest {
    
    @Test
    fun `should switch between models correctly`() {
        // Test Purdy model (default)
        PpiEngine.model = PpiModel.PurdyV1
        val purdyScore = PpiEngine.score(5000.0, 780.0)
        assertEquals("ppi.purdy.v1", PpiEngine.getCurrentModelVersion())
        
        // Test Transparent model
        PpiEngine.model = PpiModel.TransparentV0
        val transparentScore = PpiEngine.score(5000.0, 780.0)
        assertEquals("ppi.v0.transparent", PpiEngine.getCurrentModelVersion())
        
        // Scores should be different
        assertTrue(kotlin.math.abs(purdyScore - transparentScore) > 100.0)
    }
    
    @Test
    fun `should provide performance ratio for Purdy model only`() {
        PpiEngine.model = PpiModel.PurdyV1
        val ratio = PpiEngine.getPerformanceRatio(5000.0, 780.0)
        assertNotNull(ratio)
        assertEquals(1.0, ratio!!, 0.01)
        
        PpiEngine.model = PpiModel.TransparentV0
        val ratioNull = PpiEngine.getPerformanceRatio(5000.0, 780.0)
        assertTrue(ratioNull == null)
    }
    
    @Test
    fun `should provide baseline time for Purdy model only`() {
        PpiEngine.model = PpiModel.PurdyV1
        val baseline = PpiEngine.getBaselineTime(5000.0)
        assertNotNull(baseline)
        assertEquals(780.0, baseline!!, 0.1)
        
        PpiEngine.model = PpiModel.TransparentV0
        val baselineNull = PpiEngine.getBaselineTime(5000.0)
        assertTrue(baselineNull == null)
    }
    
    @Test
    fun `should calculate required pace for both models`() {
        val targetScore = 1000.0
        
        PpiEngine.model = PpiModel.PurdyV1
        val purdyPace = PpiEngine.requiredPaceSecPerKm(targetScore, 0, 5000.0)
        
        PpiEngine.model = PpiModel.TransparentV0
        val transparentPace = PpiEngine.requiredPaceSecPerKm(targetScore, 0, 5000.0)
        
        // Both should return valid paces
        assertTrue(purdyPace > 0)
        assertTrue(transparentPace > 0)
        
        // Paces should be different between models
        assertTrue(kotlin.math.abs(purdyPace - transparentPace) > 10.0)
    }
}

class CalibrationTest {
    
    @Test
    fun `should calibrate recreational runner scores correctly`() {
        // Test recreational 10K times (should score 300-500 range with new scaling)
        val recreational10k = PpiCurvePurdy.score(10000.0, 2400.0) // 40:00 10K
        assertTrue(recreational10k >= 300.0 && recreational10k <= 500.0)
        
        val recreational5k = PpiCurvePurdy.score(5000.0, 1200.0) // 20:00 5K
        assertTrue(recreational5k >= 300.0 && recreational5k <= 500.0)
        
        val recreationalHalf = PpiCurvePurdy.score(21097.0, 5400.0) // 1:30:00 half
        assertTrue(recreationalHalf >= 300.0 && recreationalHalf <= 500.0)
    }
    
    @Test
    fun `should maintain elite baseline at 1000 points`() {
        // All elite baseline times should score ~1000 points
        val elite1500 = PpiCurvePurdy.score(1500.0, 230.0)
        val elite5k = PpiCurvePurdy.score(5000.0, 780.0)
        val elite10k = PpiCurvePurdy.score(10000.0, 1620.0)
        val eliteHalf = PpiCurvePurdy.score(21097.0, 3540.0)
        val eliteMarathon = PpiCurvePurdy.score(42195.0, 7460.0)
        
        assertEquals(1000.0, elite1500, 1.0)
        assertEquals(1000.0, elite5k, 1.0)
        assertEquals(1000.0, elite10k, 1.0)
        assertEquals(1000.0, eliteHalf, 1.0)
        assertEquals(1000.0, eliteMarathon, 1.0)
    }
}
