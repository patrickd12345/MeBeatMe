package com.mebeatme.android.data.import.parsers

import com.mebeatme.android.models.RunRecord
import java.io.InputStream
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.util.UUID
import javax.xml.parsers.DocumentBuilderFactory
import kotlin.math.*

class GPXParser {
    fun parse(input: InputStream): RunRecord {
        val doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(input)
        val points = doc.getElementsByTagName("trkpt")
        var lastLat = 0.0
        var lastLon = 0.0
        var total = 0.0
        var startTime: Long? = null
        var endTime: Long? = null
        for (i in 0 until points.length) {
            val node = points.item(i)
            val lat = node.attributes.getNamedItem("lat").nodeValue.toDouble()
            val lon = node.attributes.getNamedItem("lon").nodeValue.toDouble()
            val timeNode = node.childNodes
            var timeStr: String? = null
            for (j in 0 until timeNode.length) {
                val c = timeNode.item(j)
                if (c.nodeName == "time") {
                    timeStr = c.textContent
                    break
                }
            }
            val time = timeStr?.let { Instant.from(DateTimeFormatter.ISO_DATE_TIME.parse(it)).toEpochMilli() }
            if (startTime == null) startTime = time
            if (time != null) endTime = time
            if (i > 0) {
                total += haversine(lastLat, lastLon, lat, lon)
            }
            lastLat = lat
            lastLon = lon
        }
        val elapsedSec = ((endTime ?: 0) - (startTime ?: 0)) / 1000
        val pace = if (total > 0) elapsedSec.toDouble() / (total / 1000.0) else 0.0
        return RunRecord(
            id = UUID.randomUUID().toString(),
            source = "GPX",
            startedAtEpochMs = startTime ?: 0,
            endedAtEpochMs = endTime ?: 0,
            distanceMeters = total,
            elapsedSeconds = elapsedSec.toInt(),
            avgPaceSecPerKm = pace
        )
    }

    private fun haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val R = 6371000.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).pow(2.0) + cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLon / 2).pow(2.0)
        val c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
