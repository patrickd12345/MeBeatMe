package com.mebeatme.wear.ui.home

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

@Composable
fun WearHomeScreen(highestPpi: Double?) {
    Text("Highest PPI (90d): ${highestPpi ?: "--"}")
}
