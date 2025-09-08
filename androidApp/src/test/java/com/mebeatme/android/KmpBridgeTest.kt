package com.mebeatme.android

import com.mebeatme.android.domain.PerfIndex
import com.mebeatme.shared.core.PurdyPointsCalculator
import org.junit.Test
import org.junit.Assert.assertEquals

class KmpBridgeTest {
    @Test
    fun purdyMatchesShared() {
        val expected = PurdyPointsCalculator.calculatePPI(5000.0, 1500)
        val actual = PerfIndex.purdyScore(5000.0, 1500)
        assertEquals(expected, actual, 0.0001)
    }

    @Test
    fun targetPaceMatchesShared() {
        val expected = PurdyPointsCalculator.calculateRequiredPace(5000.0, 1000.0)
        val actual = PerfIndex.targetPace(5000.0, 3600)
        assertEquals(expected, actual, 0.0001)
    }
}
