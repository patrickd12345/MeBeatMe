package com.mebeatme.android.models

import kotlinx.serialization.Serializable

@Serializable
data class Bests(
    val best5kSec: Int? = null,
    val best10kSec: Int? = null,
    val bestHalfSec: Int? = null,
    val bestFullSec: Int? = null,
    val highestPPILast90Days: Double? = null
)
