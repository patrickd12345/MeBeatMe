package com.mebeatme.shared.bridge

import com.mebeatme.shared.core.PurdyCalculator
import com.mebeatme.shared.api.RunDTO
import com.mebeatme.shared.core.highestPpiInWindow

/**
 * Android/Wear bridge to KMP shared module
 * Following the integration prompt specifications
 */
object PerfIndex {
    
    /**
     * Calculate Purdy score using shared KMP implementation
     */
    fun purdyScore(distanceMeters: Double, durationSec: Int): Double {
        return PurdyCalculator.purdyScore(distanceMeters, durationSec)
    }
    
    /**
     * Calculate target pace using shared KMP implementation
     */
    fun targetPace(distanceMeters: Double, windowSec: Int): Double {
        return PurdyCalculator.targetPace(distanceMeters, windowSec)
    }
    
    /**
     * Calculate highest PPI in 90-day window
     */
    fun highestPpiInWindow(runs: List<RunDTO>, nowMs: Long, days: Int = 90): Double? {
        return highestPpiInWindow(runs, nowMs, days)
    }
}
