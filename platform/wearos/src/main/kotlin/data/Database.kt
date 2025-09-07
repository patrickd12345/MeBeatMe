package com.mebeatme.wearos.data

import androidx.room.*
import com.mebeatme.core.Score
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@Entity(tableName = "scores")
data class ScoreEntity(
    @PrimaryKey val sessionId: String,
    val ppi: Double,
    val bucket: String,
    val curveVersion: String,
    val correctionsJson: String
) {
    fun toScore(): Score {
        return Score(
            sessionId = sessionId,
            ppi = ppi,
            bucket = com.mebeatme.core.Bucket.valueOf(bucket),
            curveVersion = curveVersion,
            corrections = Json.decodeFromString(correctionsJson)
        )
    }
    
    companion object {
        fun fromScore(score: Score): ScoreEntity {
            return ScoreEntity(
                sessionId = score.sessionId,
                ppi = score.ppi,
                bucket = score.bucket.name,
                curveVersion = score.curveVersion,
                correctionsJson = Json.encodeToString(score.corrections)
            )
        }
    }
}

@Dao
interface ScoreDao {
    @Query("SELECT * FROM scores ORDER BY ppi DESC")
    suspend fun getAllScores(): List<ScoreEntity>
    
    @Query("SELECT * FROM scores WHERE bucket = :bucket ORDER BY ppi DESC")
    suspend fun getScoresByBucket(bucket: String): List<ScoreEntity>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertScore(score: ScoreEntity)
    
    @Query("SELECT MAX(ppi) FROM scores WHERE bucket = :bucket")
    suspend fun getBestScoreForBucket(bucket: String): Double?
}

@Database(
    entities = [ScoreEntity::class],
    version = 1,
    exportSchema = false
)
abstract class MeBeatMeDatabase : RoomDatabase() {
    abstract fun scoreDao(): ScoreDao
}
