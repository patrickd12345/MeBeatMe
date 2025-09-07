package com.mebeatme.core

import kotlinx.serialization.Serializable
import kotlin.random.Random

@Serializable data class BeatChoice(
    val label: String,
    val targetPaceSecPerKm: Int,
    val windowSeconds: Int,
    val targetBucket: Bucket,
    val willExceedScore: Double
)

class BeatPlanner(private val history: List<Score>) {
    fun bestFor(bucket: Bucket): Double =
        history.filter { it.bucket == bucket }.maxByOrNull { it.ppi }?.ppi ?: 0.0

    fun choicesFor(bucket: Bucket): List<BeatChoice> {
        val best = bestFor(bucket)
        val windows = listOf(300, 600, 1200) // 5/10/20 min
        val kmWindows = mapOf(300 to 1.0, 600 to 2.0, 1200 to 4.0)
        val out = windows.map { w ->
            val km = kmWindows.getValue(w)
            val distM = km * 1000
            val secPerKm = PpiCurve.requiredPaceSecPerKm(best + 1.0, w, distM)
            val projected = PpiCurve.score(distM, secPerKm * km)
            BeatChoice(
                label = when (w) { 300 -> "Short & Fierce"; 600 -> "Tempo Boost"; else -> "Ease Into It" },
                targetPaceSecPerKm = secPerKm.toInt(),
                windowSeconds = w,
                targetBucket = bucket,
                willExceedScore = projected
            )
        }
        val surprise = out[Random.nextInt(out.size)].copy(label = "Surprise Me")
        return out + surprise
    }
}
