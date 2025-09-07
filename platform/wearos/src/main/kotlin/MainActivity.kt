package com.mebeatme.wearos
import android.content.Context
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.room.Room
import androidx.wear.compose.material.*
import com.mebeatme.core.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { 
            val context = LocalContext.current
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            val database = Room.databaseBuilder(
                context,
                MeBeatMeDatabase::class.java,
                "mebeatme_database"
            ).build()
            
            App(vibrator, database.scoreDao())
        }
    }
}

@Composable
fun App(vibrator: Vibrator, scoreDao: ScoreDao) {
    val viewModel: MeBeatMeViewModel = viewModel { MeBeatMeViewModel(scoreDao) }
    
    when (viewModel.currentScreen.value) {
        Screen.ChallengeSelection -> ChallengeSelectionScreen(viewModel)
        Screen.LiveRun -> LiveRunScreen(viewModel, vibrator)
        Screen.PostRun -> PostRunScreen(viewModel)
    }
}

@Composable
fun ChallengeSelectionScreen(viewModel: MeBeatMeViewModel) {
    val history = remember { HistoryStore() }
    val bucket = Bucket.KM_3_8
    val planner = remember { BeatPlanner(history.all()) }
    val choices = remember { planner.choicesFor(bucket) }
    
    ScalingLazyColumn(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        item {
            Text(
                text = "Beat Your Best",
                style = MaterialTheme.typography.title2,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(16.dp)
            )
        }
        
        items(choices.size) { i ->
            val choice = choices[i]
            ChoiceCard(
                choice = choice,
                onClick = { viewModel.startLiveRun(choice) }
            )
        }
    }
}

@Composable
fun ChoiceCard(choice: BeatChoice, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        onClick = onClick
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = choice.label,
                style = MaterialTheme.typography.title3,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Target: ${formatPace(choice.targetPaceSecPerKm)}/km",
                style = MaterialTheme.typography.body2
            )
            
            Text(
                text = "Duration: ${choice.windowSeconds / 60} min",
                style = MaterialTheme.typography.body2
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Icon(
                imageVector = Icons.Default.PlayArrow,
                contentDescription = "Start",
                tint = MaterialTheme.colors.primary
            )
        }
    }
}

@Composable
fun LiveRunScreen(viewModel: MeBeatMeViewModel, vibrator: Vibrator) {
    val liveSession by viewModel.liveSession.collectAsState()
    val isOnTarget by viewModel.isOnTarget.collectAsState()
    
    LaunchedEffect(isOnTarget) {
        if (isOnTarget) {
            vibrator.vibrate(VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE))
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        liveSession?.let { session ->
            // Challenge info
            Text(
                text = session.choice.label,
                style = MaterialTheme.typography.title2,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Progress ring
            Box(
                modifier = Modifier.size(120.dp),
                contentAlignment = Alignment.Center
            ) {
                ProgressRing(
                    progress = session.progressPercentage().toFloat(),
                    modifier = Modifier.fillMaxSize()
                )
                
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = formatPace(session.currentPaceSecPerKm.toInt()),
                        style = MaterialTheme.typography.h6,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Target: ${formatPace(session.choice.targetPaceSecPerKm)}",
                        style = MaterialTheme.typography.caption
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Pace status
            Text(
                text = if (isOnTarget) "On Target! 🎯" else "Adjust Pace",
                style = MaterialTheme.typography.body1,
                color = if (isOnTarget) Color.Green else Color.Orange
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Stop button
            Button(
                onClick = { viewModel.stopLiveRun() },
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = MaterialTheme.colors.error
                )
            ) {
                Icon(
                    imageVector = Icons.Default.Stop,
                    contentDescription = "Stop",
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Stop Run")
            }
        }
    }
}

@Composable
fun ProgressRing(
    progress: Float,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val strokeWidth = 8.dp.toPx()
        val radius = (size.minDimension - strokeWidth) / 2
        val center = Offset(size.width / 2, size.height / 2)
        
        // Background circle
        drawCircle(
            color = Color.Gray.copy(alpha = 0.3f),
            radius = radius,
            center = center,
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
        )
        
        // Progress arc
        val sweepAngle = progress * 360f
        drawArc(
            color = if (progress >= 1f) Color.Green else Color.Blue,
            startAngle = -90f,
            sweepAngle = sweepAngle,
            useCenter = false,
            topLeft = Offset(center.x - radius, center.y - radius),
            size = Size(radius * 2, radius * 2),
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
        )
    }
}

@Composable
fun PostRunScreen(viewModel: MeBeatMeViewModel) {
    val lastScore by viewModel.lastScore.collectAsState()
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        lastScore?.let { score ->
            if (score.ppi > 0) {
                Text(
                    text = "🎉 Run Complete!",
                    style = MaterialTheme.typography.title2,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Text(
                    text = "Your PPI: ${score.ppi.toInt()}",
                    style = MaterialTheme.typography.h6,
                    fontWeight = FontWeight.Bold
                )
                
                Text(
                    text = "Bucket: ${score.bucket.name}",
                    style = MaterialTheme.typography.body1
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
}

fun formatPace(secPerKm: Int): String {
    val m = secPerKm / 60
    val s = secPerKm % 60
    return "%d:%02d/km".format(m, s)
}

enum class Screen {
    ChallengeSelection,
    LiveRun,
    PostRun
}
