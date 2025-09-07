package com.mebeatme.wearos.health

import android.content.Context
import androidx.health.services.client.HealthServicesClient
import androidx.health.services.client.data.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.tasks.await

class HealthServicesManager(private val context: Context) {
    private val healthServicesClient = HealthServicesClient.getOrCreate(context)
    
    suspend fun startWorkout(): Flow<WorkoutData> = flow {
        val capabilities = healthServicesClient.capabilities.await()
        
        if (capabilities.supportedDataTypes.contains(DataType.DISTANCE_TOTAL) &&
            capabilities.supportedDataTypes.contains(DataType.ACTIVE_DURATION)) {
            
            val exerciseConfig = ExerciseConfig.builder()
                .setExerciseType(ExerciseType.RUNNING)
                .setDataTypes(
                    setOf(
                        DataType.DISTANCE_TOTAL,
                        DataType.ACTIVE_DURATION,
                        DataType.SPEED
                    )
                )
                .build()
            
            val exerciseClient = healthServicesClient.exerciseClient
            exerciseClient.startExercise(exerciseConfig).await()
            
            exerciseClient.exerciseMetricsData.collect { metrics ->
                val distance = metrics.latestMetrics[DataType.DISTANCE_TOTAL]?.asDistanceType()?.inMeters ?: 0.0
                val duration = metrics.latestMetrics[DataType.ACTIVE_DURATION]?.asDurationType()?.inSeconds ?: 0.0
                val speed = metrics.latestMetrics[DataType.SPEED]?.asSpeedType()?.inMetersPerSecond ?: 0.0
                
                emit(WorkoutData(
                    distanceMeters = distance,
                    elapsedSeconds = duration,
                    currentPaceSecPerKm = if (speed > 0) 1000.0 / speed else 0.0
                ))
            }
        }
    }
    
    suspend fun stopWorkout() {
        val exerciseClient = healthServicesClient.exerciseClient
        exerciseClient.endExercise().await()
    }
}

data class WorkoutData(
    val distanceMeters: Double,
    val elapsedSeconds: Double,
    val currentPaceSecPerKm: Double
)
