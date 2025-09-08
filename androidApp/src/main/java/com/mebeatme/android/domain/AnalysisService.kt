package com.mebeatme.android.domain

import com.mebeatme.android.models.RunRecord
import kotlin.math.max

class AnalysisService(
    private val perf: PerfIndex = PerfIndex
) {
    fun analyze(run: RunRecord, windowSec: Int = 60 * 60 * 24 * 7 * 8): Pair<RunRecord, Recommendation> {
        val ppi = perf.purdyScore(run.distanceMeters, run.elapsedSeconds)
        val targetPace = perf.targetPace(run.distanceMeters, windowSec)
        val rec = Recommendation(
            targetPaceSecPerKm = targetPace,
            projectedGainPPI = max(0.0, targetPace - run.avgPaceSecPerKm),
            notes = "Aim for ~%.1f s/km over %d weeks.".format(targetPace, windowSec / 604800)
        )
        return run.copy(ppi = ppi) to rec
    }
}
