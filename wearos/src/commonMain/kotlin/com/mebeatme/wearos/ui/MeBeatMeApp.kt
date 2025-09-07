package com.mebeatme.wearos.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mebeatme.shared.model.ChallengeOption
import com.mebeatme.shared.service.MeBeatMeService
import com.mebeatme.shared.service.PaceZone

@Composable
fun MeBeatMeApp() {
    val viewModel: MeBeatMeViewModel = viewModel()
    
    when (viewModel.currentScreen.value) {
        Screen.ChallengeSelection -> ChallengeSelectionScreen(viewModel)
        Screen.RunningSession -> RunningSessionScreen(viewModel)
        Screen.PostRunFeedback -> PostRunFeedbackScreen(viewModel)
    }
}

@Composable
fun ChallengeSelectionScreen(viewModel: MeBeatMeViewModel) {
    val challenges by viewModel.challenges.collectAsState()
    
    LaunchedEffect(Unit) {
        viewModel.generateChallenges()
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Beat Your Best",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(challenges) { challenge ->
                ChallengeCard(
                    challenge = challenge,
                    onClick = { viewModel.selectChallenge(challenge) }
                )
            }
        }
    }
}

@Composable
fun ChallengeCard(
    challenge: ChallengeOption,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        ),
        onClick = onClick
    ) {
        Column(
            modifier = Modifier.padding(12.dp)
        ) {
            Text(
                text = challenge.title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(4.dp))
            
            Text(
                text = challenge.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Target: ${formatPace(challenge.targetPace)}/km",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Medium
                )
                
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = "Start",
                    tint = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}

@Composable
fun RunningSessionScreen(viewModel: MeBeatMeViewModel) {
    val feedback by viewModel.realTimeFeedback.collectAsState()
    val selectedChallenge by viewModel.selectedChallenge.collectAsState()
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Challenge info
        selectedChallenge?.let { challenge ->
            Text(
                text = challenge.title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Target: ${formatPace(challenge.targetPace)}/km",
                style = MaterialTheme.typography.bodyMedium
            )
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Current pace
        feedback?.let { fb ->
            Text(
                text = "Current Pace",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )
            
            Text(
                text = formatPace(fb.currentPace),
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold,
                color = getPaceZoneColor(fb.paceZone)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Pace zone indicator
            PaceZoneIndicator(fb.paceZone)
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Progress
            Text(
                text = "Progress: ${(fb.progressPercentage * 100).toInt()}%",
                style = MaterialTheme.typography.bodyMedium
            )
            
            LinearProgressIndicator(
                progress = fb.progressPercentage.toFloat(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
            )
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Stop button
        Button(
            onClick = { viewModel.completeSession() },
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.error
            )
        ) {
            Text("Complete Run")
        }
    }
}

@Composable
fun PaceZoneIndicator(paceZone: PaceZone) {
    val (text, color) = when (paceZone) {
        PaceZone.TOO_FAST -> "Too Fast" to Color.Red
        PaceZone.ON_TARGET -> "On Target" to Color.Green
        PaceZone.TOO_SLOW -> "Too Slow" to Color.Orange
    }
    
    Card(
        colors = CardDefaults.cardColors(
            containerColor = color.copy(alpha = 0.1f)
        )
    ) {
        Text(
            text = text,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            color = color,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
fun PostRunFeedbackScreen(viewModel: MeBeatMeViewModel) {
    val score by viewModel.lastScore.collectAsState()
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        score?.let { s ->
            if (s.achieved) {
                Text(
                    text = "🎉 Congratulations!",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color.Green
                )
            } else {
                Text(
                    text = "Keep Going!",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color.Orange
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "Your PPI: ${s.ppi.toInt()}",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Bucket: ${s.bucket.name}",
                style = MaterialTheme.typography.bodyMedium
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Button(
                onClick = { viewModel.startNewSession() }
            ) {
                Text("New Challenge")
            }
        }
    }
}

private fun formatPace(secondsPerKm: Double): String {
    val minutes = (secondsPerKm / 60).toInt()
    val seconds = (secondsPerKm % 60).toInt()
    return String.format("%d:%02d", minutes, seconds)
}

private fun getPaceZoneColor(paceZone: PaceZone): Color {
    return when (paceZone) {
        PaceZone.TOO_FAST -> Color.Red
        PaceZone.ON_TARGET -> Color.Green
        PaceZone.TOO_SLOW -> Color.Orange
    }
}

enum class Screen {
    ChallengeSelection,
    RunningSession,
    PostRunFeedback
}
