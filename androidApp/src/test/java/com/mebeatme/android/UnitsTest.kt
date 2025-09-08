package com.mebeatme.android

import com.mebeatme.android.util.Units
import org.junit.Test
import org.junit.Assert.assertEquals

class UnitsTest {
    @Test
    fun conversionRoundTrip() {
        val mps = 3.0
        val min = Units.mpsToMinPerKm(mps)
        val back = Units.minPerKmToMps(min)
        assertEquals(mps, back, 1e-6)
    }
}
