package com.mebeatme.android.ui.import

import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue

@Composable
fun ImportScreen(viewModel: ImportViewModel, onPick: () -> Unit) {
    val importing by viewModel.importing.collectAsState()
    Button(onClick = onPick, enabled = !importing) {
        Text(if (importing) "Importing..." else "Pick GPX")
    }
}
