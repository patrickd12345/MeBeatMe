package com.mebeatme.wearos.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mebeatme.shared.model.ChallengeOption
import com.mebeatme.shared.model.Score
import com.mebeatme.shared.service.MeBeatMeService
import com.mebeatme.shared.service.PaceZone
import com.mebeatme.shared.service.RealTimeFeedback
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MeBeatMeViewModel : ViewModel() {
    
    private val meBeatMeService = MeBeatMeService()
    
    private val _currentScreen = MutableStateFlow(Screen.ChallengeSelection)
    val currentScreen: StateFlow<Screen> = _currentScreen.asStateFlow()
    
    private val _challenges = MutableStateFlow<List<ChallengeOption>>(emptyList())
    val challenges: StateFlow<List<ChallengeOption>> = _challenges.asStateFlow()
    
    private val _selectedChallenge = MutableStateFlow<ChallengeOption?>(null)
    val selectedChallenge: StateFlow<ChallengeOption?> = _selectedChallenge.asStateFlow()
    
    private val _realTimeFeedback = MutableStateFlow<RealTimeFeedback?>(null)
    val realTimeFeedback: StateFlow<RealTimeFeedback?> = _realTimeFeedback.asStateFlow()
    
    private val _lastScore = MutableStateFlow<Score?>(null)
    val lastScore: StateFlow<Score?> = _lastScore.asStateFlow()
    
    init {
        // Observe service state changes
        viewModelScope.launch {
            meBeatMeService.currentChallenges.collect { challenges ->
                _challenges.value = challenges
            }
        }
        
        viewModelScope.launch {
            meBeatMeService.selectedChallenge.collect { challenge ->
                _selectedChallenge.value = challenge
                if (challenge != null) {
                    _currentScreen.value = Screen.RunningSession
                }
            }
        }
    }
    
    fun generateChallenges() {
        meBeatMeService.generateChallenges()
    }
    
    fun selectChallenge(challenge: ChallengeOption) {
        meBeatMeService.selectChallenge(challenge)
    }
    
    fun updateSession(distance: Double, duration: Long, currentPace: Double) {
        meBeatMeService.updateSession(distance, duration, currentPace)
        
        // Update real-time feedback
        val feedback = meBeatMeService.getRealTimeFeedback()
        _realTimeFeedback.value = feedback
        
        // Trigger haptic feedback based on pace zone
        feedback?.let { fb ->
            when (fb.paceZone) {
                PaceZone.ON_TARGET -> {
                    // Gentle haptic for being on target
                    triggerHapticFeedback(HapticType.SUCCESS)
                }
                PaceZone.TOO_FAST -> {
                    // Warning haptic for going too fast
                    triggerHapticFeedback(HapticType.WARNING)
                }
                PaceZone.TOO_SLOW -> {
                    // Encouraging haptic for being too slow
                    triggerHapticFeedback(HapticType.ENCOURAGEMENT)
                }
            }
        }
    }
    
    fun completeSession() {
        val score = meBeatMeService.completeSession()
        _lastScore.value = score
        _currentScreen.value = Screen.PostRunFeedback
        
        // Celebration haptic if achieved
        score?.let { s ->
            if (s.achieved) {
                triggerHapticFeedback(HapticType.CELEBRATION)
            }
        }
    }
    
    fun startNewSession() {
        _currentScreen.value = Screen.ChallengeSelection
        _lastScore.value = null
        _realTimeFeedback.value = null
        generateChallenges()
    }
    
    private fun triggerHapticFeedback(type: HapticType) {
        // Platform-specific haptic feedback implementation
        // This would be implemented differently for Android vs iOS
        when (type) {
            HapticType.SUCCESS -> {
                // Gentle success vibration
            }
            HapticType.WARNING -> {
                // Warning vibration pattern
            }
            HapticType.ENCOURAGEMENT -> {
                // Encouraging vibration pattern
            }
            HapticType.CELEBRATION -> {
                // Celebration vibration pattern
            }
        }
    }
}

enum class HapticType {
    SUCCESS,
    WARNING,
    ENCOURAGEMENT,
    CELEBRATION
}
