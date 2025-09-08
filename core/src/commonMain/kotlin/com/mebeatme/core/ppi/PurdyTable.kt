package com.mebeatme.core.ppi

/**
 * Data class representing a baseline anchor point for Purdy scoring.
 * @param distanceM Distance in meters
 * @param timeSec Time in seconds for elite performance
 * @param points Points awarded for meeting this baseline (typically 1000)
 */
data class PurdyAnchor(
    val distanceM: Double,
    val timeSec: Double,
    val points: Double
)

/**
 * Loads and provides access to the Purdy baseline anchor points.
 * Uses embedded CSV data to stay multiplatform-compatible.
 */
object PurdyTable {
    
    private val anchors: List<PurdyAnchor> by lazy {
        loadBaselineAnchors()
    }
    
    /**
     * Get all baseline anchor points.
     */
    fun getAnchors(): List<PurdyAnchor> = anchors
    
    /**
     * Find the closest anchor point for a given distance.
     */
    fun findClosestAnchor(distanceM: Double): PurdyAnchor? {
        return anchors.minByOrNull { kotlin.math.abs(it.distanceM - distanceM) }
    }
    
    /**
     * Get baseline time for a given distance using interpolation.
     * Uses piecewise linear interpolation in log-log space.
     */
    fun getBaselineTime(distanceM: Double): Double {
        if (anchors.isEmpty()) return 0.0
        
        // Handle edge cases
        if (distanceM <= anchors.first().distanceM) {
            return anchors.first().timeSec
        }
        if (distanceM >= anchors.last().distanceM) {
            return anchors.last().timeSec
        }
        
        // Find surrounding anchors
        for (i in 0 until anchors.size - 1) {
            val current = anchors[i]
            val next = anchors[i + 1]
            
            if (distanceM >= current.distanceM && distanceM <= next.distanceM) {
                // Linear interpolation in log-log space
                val logDist1 = kotlin.math.ln(current.distanceM)
                val logDist2 = kotlin.math.ln(next.distanceM)
                val logTime1 = kotlin.math.ln(current.timeSec)
                val logTime2 = kotlin.math.ln(next.timeSec)
                val logDistTarget = kotlin.math.ln(distanceM)
                
                val ratio = (logDistTarget - logDist1) / (logDist2 - logDist1)
                val logTimeTarget = logTime1 + ratio * (logTime2 - logTime1)
                
                return kotlin.math.exp(logTimeTarget)
            }
        }
        
        return anchors.last().timeSec
    }
    
    private fun loadBaselineAnchors(): List<PurdyAnchor> {
        // Embedded CSV data for multiplatform compatibility
        val csvData = """
            distance_m,time_sec,points
            1500,230.0,1000
            5000,780.0,1000
            10000,1620.0,1000
            21097,3540.0,1000
            42195,7460.0,1000
        """.trimIndent()
        
        return csvData.lines()
            .drop(1) // Skip header
            .filter { it.isNotBlank() }
            .map { line ->
                val parts = line.split(",")
                PurdyAnchor(
                    distanceM = parts[0].trim().toDouble(),
                    timeSec = parts[1].trim().toDouble(),
                    points = parts[2].trim().toDouble()
                )
            }
            .sortedBy { it.distanceM }
    }
}
