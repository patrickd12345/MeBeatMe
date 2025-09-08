package com.mebeatme.android.ui.settings

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue

@Composable
fun SettingsScreen(viewModel: SettingsViewModel) {
    val window by viewModel.windowSec.collectAsState()
    Text("Window: ${window / 604800} weeks")
}
