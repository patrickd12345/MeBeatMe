package com.mebeatme.android.ui.home

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.foundation.clickable
import com.mebeatme.android.models.RunRecord

@Composable
fun HomeScreen(viewModel: HomeViewModel, onImport: () -> Unit, onRun: (RunRecord) -> Unit) {
    val runs by viewModel.runs.collectAsState()
    val highest by viewModel.highestPPILast90Days.collectAsState()
    LaunchedEffect(Unit) { viewModel.load() }
    Scaffold(floatingActionButton = { FloatingActionButton(onClick = onImport) { Text("+") } }) { _ ->
        Column(Modifier.fillMaxSize()) {
            Text("Highest PPI (90 days): ${highest ?: "--"}")
            LazyColumn {
                items(runs) { run ->
                    ListItem(headlineText = { Text(run.distanceMeters.toInt().toString() + " m") },
                        supportingText = { Text("Pace ${"%.1f".format(run.avgPaceSecPerKm)} s/km") },
                        modifier = Modifier.clickable { onRun(run) })
                }
            }
        }
    }
}
