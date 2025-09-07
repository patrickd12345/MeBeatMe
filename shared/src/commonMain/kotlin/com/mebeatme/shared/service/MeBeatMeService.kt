package com.mebeatme.shared.service

import com.mebeatme.shared.core.ChallengeGenerator
import com.mebeatme.shared.core.PerformanceBucketManager
import com.mebeatme.shared.core.PurdyPointsCalculator
import com.mebeatme.shared.model.ChallengeOption
import com.mebeatme.shared.model.RunSession
import com.mebeatme.shared.model.Score
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Main service orchestrating MeBeatMe functionality
 */
class MeBeatMeService {
    
    private val bucketManager = PerformanceBucketManager()
    private val challengeGenerator = ChallengeGenerator(bucketManager)
    
    private val _currentChallenges = MutableStateFlow<List<ChallengeOption>>(emptyList())
    val currentChallenges: StateFlow<List<ChallengeOption>> = _currentChallenges.asStateFlow()
    
    private val _selectedChallenge = MutableStateFlow<ChallengeOption?>(null)
    val selectedChallenge: StateFlow<ChallengeOption?> = _selectedChallenge.asStateFlow()
    
    private val _currentSession = MutableStateFlow<RunSession?>(null)
    val currentSession: StateFlow<RunSession?> = _currentSession.asStateFlow()
    
    /**
     * Generate new challenges for the user
     */
    fun generateChallenges() {
        val challenges = challengeGenerator.generateChallenges()
        _currentChallenges.value = challenges
    }
    
    /**
     * Select a challenge to attempt
     */
    fun selectChallenge(challenge: ChallengeOption) {
        _selectedChallenge.value = challenge
        startNewSession(challenge)
    }
    
    /**
     * Start a new running session
     */
    private fun startNewSession(challenge: ChallengeOption) {
        val session = RunSession(
            id = generateSessionId(),
            distance = 0.0,
            duration = 0L,
            timestamp = kotlinx.datetime.Clock.System.now(),
            pace = 0.0
        )
        _currentSession.value = session
    }
    
    /**
     * Update current session with live data
     */
    fun updateSession(distance: Double, duration: Long, currentPace: Double) {
        val session = _currentSession.value ?: return
        
        val updatedSession = session.copy(
            distance = distance,
            duration = duration,
            pace = currentPace
        )
        _currentSession.value = updatedSession
    }
    
    /**
     * Complete the current session and calculate results
     */
    fun completeSession(): Score? {
        val session = _currentSession.value ?: return null
        val challenge = _selectedChallenge.value ?: return null
        
        // Calculate actual PPI
        val actualPPI = PurdyPointsCalculator.calculatePPI(session.distance, session.duration)
        
        // Update historical best
        bucketManager.updateHistoricalBest(session)
        
        // Create score
        val score = Score(
            ppi = actualPPI,
            bucket = challenge.bucket,
            targetPace = challenge.targetPace,
            targetDuration = challenge.targetDuration,
            achieved = actualPPI >= challenge.expectedPpi
        )
        
        // Reset session
        _currentSession.value = null
        _selectedChallenge.value = null
        
        return score
    }
    
    /**
     * Get real-time feedback during the run
     */
    fun getRealTimeFeedback(): RealTimeFeedback? {
        val session = _currentSession.value ?: return null
        val challenge = _selectedChallenge.value ?: return null
        
        val currentPace = session.pace
        val targetPace = challenge.targetPace
        
        val paceDifference = currentPace - targetPace
        val paceZone = when {
            paceDifference <= -5.0 -> PaceZone.TOO_FAST
            paceDifference <= 5.0 -> PaceZone.ON_TARGET
            else -> PaceZone.TOO_SLOW
        }
        
        return RealTimeFeedback(
            currentPace = currentPace,
            targetPace = targetPace,
            paceDifference = paceDifference,
            paceZone = paceZone,
            progressPercentage = calculateProgress(session, challenge)
        )
    }
    
    private fun calculateProgress(session: RunSession, challenge: ChallengeOption): Double {
        val distanceProgress = (session.distance / challenge.targetDistance).coerceAtMost(1.0)
        val timeProgress = (session.duration.toDouble() / challenge.targetDuration).coerceAtMost(1.0)
        
        // Use the minimum of distance or time progress
        return minOf(distanceProgress, timeProgress)
    }
    
    private fun generateSessionId(): String {
        return "session_${System.currentTimeMillis()}_${(1000..9999).random()}"
    }
}

data class RealTimeFeedback(
    val currentPace: Double,
    val targetPace: Double,
    val paceDifference: Double,
    val paceZone: PaceZone,
    val progressPercentage: Double
)

enum class PaceZone {
    TOO_FAST,
    ON_TARGET,
    TOO_SLOW
}
