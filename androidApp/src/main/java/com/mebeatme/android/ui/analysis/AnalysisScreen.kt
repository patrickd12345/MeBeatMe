package com.mebeatme.android.ui.analysis

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import com.mebeatme.android.domain.Recommendation

@Composable
fun AnalysisScreen(rec: Recommendation) {
    Column {
        Text("Target pace: ${"%.1f".format(rec.targetPaceSecPerKm)} s/km")
        Text("Projected gain: ${"%.1f".format(rec.projectedGainPPI)}")
        Text(rec.notes)
    }
}
