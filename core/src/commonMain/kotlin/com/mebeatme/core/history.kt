package com.mebeatme.core

/** Minimal in-memory store; replace with real persistence per platform later. */
class HistoryStore {
    private val scores = mutableListOf<Score>()
    fun add(score: Score) { scores += score }
    fun all(): List<Score> = scores.toList()
    fun bestByBucket(): Map<Bucket, Double> =
        scores.groupBy { it.bucket }.mapValues { it.value.maxOf { s -> s.ppi } }
}
