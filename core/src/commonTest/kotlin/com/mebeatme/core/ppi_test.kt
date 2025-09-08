package com.mebeatme.core

import com.mebeatme.core.ppi.PpiEngine
import com.mebeatme.core.ppi.PpiModel
import kotlin.test.*

class PpiTests {
    @Test fun monotonicity() {
        val d = 5000.0
        val slow = PpiEngine.score(d, 1800.0)
        val fast = PpiEngine.score(d, 1500.0)
        assertTrue(fast > slow)
    }
    
    @Test fun inversion() {
        val target = 600.0
        val w = 600; val distM = 2000.0
        val pace = PpiEngine.requiredPaceSecPerKm(target, w, distM)
        val score = PpiEngine.score(distM, pace * (distM/1000.0))
        assertTrue(score >= target - 1.0)
    }
    
    @Test fun modelSwitching() {
        val d = 5000.0; val t = 1200.0
        
        // Test Purdy model (default)
        PpiEngine.model = PpiModel.PurdyV1
        val purdyScore = PpiEngine.score(d, t)
        assertEquals("ppi.purdy.v1", PpiEngine.getCurrentModelVersion())
        
        // Test Transparent model
        PpiEngine.model = PpiModel.TransparentV0
        val transparentScore = PpiEngine.score(d, t)
        assertEquals("ppi.v0.transparent", PpiEngine.getCurrentModelVersion())
        
        // Scores should be different
        assertTrue(kotlin.math.abs(purdyScore - transparentScore) > 50.0)
    }
}
