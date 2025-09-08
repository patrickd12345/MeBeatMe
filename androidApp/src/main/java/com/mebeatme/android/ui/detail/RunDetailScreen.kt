package com.mebeatme.android.ui.detail

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import com.mebeatme.android.models.RunRecord

@Composable
fun RunDetailScreen(run: RunRecord) {
    Column {
        Text("Distance: ${run.distanceMeters}")
        Text("Elapsed: ${run.elapsedSeconds}s")
        Text("PPI: ${run.ppi ?: "--"}")
    }
}
