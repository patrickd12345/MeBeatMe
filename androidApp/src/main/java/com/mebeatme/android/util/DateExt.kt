package com.mebeatme.android.util

fun Long.isWithinDays(days: Int, now: Long = System.currentTimeMillis()): Boolean {
    val window = now - days * 24 * 60 * 60 * 1000L
    return this >= window
}
