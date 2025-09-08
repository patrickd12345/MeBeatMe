package com.mebeatme.android

import com.mebeatme.android.data.import.parsers.GPXParser
import org.junit.Test
import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue

class GPXParserTest {
    @Test
    fun parseSample() {
        val parser = GPXParser()
        val input = File("src/test/java/com/mebeatme/android/sample_5k.gpx").inputStream()
        val run = parser.parse(input)
        assertTrue(run.distanceMeters > 800.0 && run.distanceMeters < 1200.0)
        assertEquals(1800, run.elapsedSeconds, 5)
    }
}
