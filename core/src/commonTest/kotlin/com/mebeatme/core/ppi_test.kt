package com.mebeatme.core
import kotlin.test.*

class PpiTests {
    @Test fun monotonicity() {
        val d = 5000.0
        val slow = PpiCurve.score(d, 1800.0)
        val fast = PpiCurve.score(d, 1500.0)
        assertTrue(fast > slow)
    }
    
    @Test fun inversion() {
        val target = 600.0
        val w = 600; val distM = 2000.0
        val pace = PpiCurve.requiredPaceSecPerKm(target, w, distM)
        val score = PpiCurve.score(distM, pace * (distM/1000.0))
        assertTrue(score >= target - 1.0)
    }
}
