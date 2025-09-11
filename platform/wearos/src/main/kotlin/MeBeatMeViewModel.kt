package com.mebeatme.wearos

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mebeatme.core.ppi.PpiEngine
import com.mebeatme.wearos.data.ScoreDao
import com.mebeatme.wearos.data.ScoreEntity
import com.mebeatme.wearos.health.HealthServicesManager
import com.mebeatme.wearos.health.WorkoutData
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import android.content.Context

class MeBeatMeViewModel(private val scoreDao: ScoreDao) : ViewModel() {
    
    private val _currentScreen = MutableStateFlow(Screen.ChallengeSelection)
    val currentScreen: StateFlow<Screen> = _currentScreen.asStateFlow()
    
    private val _liveSession = MutableStateFlow<LiveSession?>(null)
    val liveSession: StateFlow<LiveSession?> = _liveSession.asStateFlow()
    
    private val _isOnTarget = MutableStateFlow(false)
    val isOnTarget: StateFlow<Boolean> = _isOnTarget.asStateFlow()
    
    private val _lastScore = MutableStateFlow<Score?>(null)
    val lastScore: StateFlow<Score?> = _lastScore.asStateFlow()
    
    private var healthServicesManager: HealthServicesManager? = null
    
    fun initializeHealthServices(context: Context) {
        healthServicesManager = HealthServicesManager(context)
    }
    
    fun startLiveRun(choice: BeatChoice) {
        val session = LiveSession(
            choice = choice,
            startTimeMs = System.currentTimeMillis(),
            targetPPI = getTargetPPI()
        )
        _liveSession.value = session
        _currentScreen.value = Screen.LiveRun
        
        // Start health services workout
        viewModelScope.launch {
            healthServicesManager?.startWorkout()?.collect { workoutData ->
                updateLiveSession(workoutData)
            }
        }
    }
    
    private fun updateLiveSession(workoutData: WorkoutData) {
        val currentSession = _liveSession.value ?: return
        
        val updatedSession = currentSession.copy(
            currentDistanceM = workoutData.distanceMeters,
            currentElapsedSec = workoutData.elapsedSeconds,
            currentPaceSecPerKm = workoutData.currentPaceSecPerKm,
            targetPPI = currentSession.targetPPI
        )
        
        _liveSession.value = updatedSession
        
        // Check if on target pace
        val onTarget = updatedSession.isOnTargetPace()
        _isOnTarget.value = onTarget
    }
    
    fun stopLiveRun() {
        val session = _liveSession.value ?: return
        
        viewModelScope.launch {
            // Stop health services
            healthServicesManager?.stopWorkout()
            
            // Complete the session
            val runSession = session.complete()
            val ppi = PpiEngine.score(runSession.distanceMeters, runSession.elapsedSeconds)
            val bucket = bucketFor(runSession.distanceMeters)
            
            val score = Score(
                sessionId = runSession.id,
                ppi = ppi,
                bucket = bucket
            )
            
            // Save to database
            scoreDao.insertScore(ScoreEntity.fromScore(score))
            
            _lastScore.value = score
            _liveSession.value = null
            _currentScreen.value = Screen.PostRun
        }
    }
    
    fun startNewSession() {
        _currentScreen.value = Screen.ChallengeSelection
        _lastScore.value = null
        _isOnTarget.value = false
    }
    
    fun getTargetPPI(): Double {
        // Get the highest PPI from the last 90 days
        // This would typically come from a database or shared service
        // For now, we'll use a placeholder value
        return 300.0 // This should be injected from a proper data source
    }
}
