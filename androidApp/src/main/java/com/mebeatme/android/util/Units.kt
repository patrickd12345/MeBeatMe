package com.mebeatme.android.util

object Units {
    fun metersPerSecondToSecPerKm(mps: Double): Double = if (mps == 0.0) 0.0 else 1000.0 / mps
    fun secPerKmToMetersPerSecond(sec: Double): Double = if (sec == 0.0) 0.0 else 1000.0 / sec
    fun secPerKmToMinPerKm(sec: Double): Double = sec / 60.0
    fun minPerKmToSecPerKm(min: Double): Double = min * 60.0
    fun mpsToMinPerKm(mps: Double): Double = secPerKmToMinPerKm(metersPerSecondToSecPerKm(mps))
    fun minPerKmToMps(min: Double): Double = secPerKmToMetersPerSecond(minPerKmToSecPerKm(min))
}
