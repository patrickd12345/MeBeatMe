package com.mebeatme.server

import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import com.mebeatme.shared.api.*
import com.mebeatme.shared.core.highestPpiInWindow
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

fun main() {
    embeddedServer(Netty, port = 8080) {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                ignoreUnknownKeys = true
            })
        }
        install(CORS) {
            anyHost()
            allowHeader("Content-Type")
            allowHeader("Authorization")
            allowMethod(io.ktor.http.HttpMethod.Get)
            allowMethod(io.ktor.http.HttpMethod.Post)
            allowMethod(io.ktor.http.HttpMethod.Options)
        }
        
        routing {
            // Health check
            get("/health") {
                call.respond(mapOf("status" to "ok", "version" to "0.2.0"))
            }
            
            // Sync runs endpoint
            post("/sync/runs") {
                try {
                    val runs = call.receive<List<RunDTO>>()
                    
                    // Validate runs
                    runs.forEach { run ->
                        if (run.id.isBlank()) {
                            call.respond(400, ErrorResponse("invalid_payload", "Run ID cannot be blank"))
                            return@post
                        }
                        if (run.distanceMeters <= 0) {
                            call.respond(400, ErrorResponse("invalid_payload", "Distance must be positive"))
                            return@post
                        }
                        if (run.elapsedSeconds <= 0) {
                            call.respond(400, ErrorResponse("invalid_payload", "Elapsed time must be positive"))
                            return@post
                        }
                    }
                    
                    // Store runs (in-memory for now)
                    val storedCount = runRepository.upsertAll(runs)
                    
                    call.respond(SyncRunsResponse("ok", storedCount))
                } catch (e: Exception) {
                    call.respond(500, ErrorResponse("internal_error", "Internal server error: ${e.message}"))
                }
            }
            
            // Get bests endpoint
            get("/bests") {
                try {
                    val since = call.request.queryParameters["since"]?.toLongOrNull() ?: 0L
                    val runs = runRepository.listSince(since)
                    
                    val bests = BestsDTO(
                        best5kSec = findBestTime(runs, 5000.0),
                        best10kSec = findBestTime(runs, 10000.0),
                        bestHalfSec = findBestTime(runs, 21097.0),
                        bestFullSec = findBestTime(runs, 42195.0),
                        highestPPILast90Days = highestPpiInWindow(runs, System.currentTimeMillis())
                    )
                    
                    call.respond(bests)
                } catch (e: Exception) {
                    call.respond(500, ErrorResponse("internal_error", "Internal server error: ${e.message}"))
                }
            }
        }
    }.start(wait = true)
}

// Simple in-memory repository for demo purposes
object runRepository {
    private val runs = ConcurrentHashMap<String, RunDTO>()
    private val idCounter = AtomicLong(1)
    
    fun upsertAll(newRuns: List<RunDTO>): Int {
        var stored = 0
        newRuns.forEach { run ->
            val runWithId = if (run.id.isBlank()) {
                run.copy(id = "run_${idCounter.getAndIncrement()}")
            } else {
                run
            }
            runs[runWithId.id] = runWithId
            stored++
        }
        return stored
    }
    
    fun listSince(sinceMs: Long): List<RunDTO> {
        return runs.values.filter { it.startedAtEpochMs >= sinceMs }
    }
    
    fun getAll(): List<RunDTO> {
        return runs.values.toList()
    }
}

// Helper function to find best time for a specific distance
private fun findBestTime(runs: List<RunDTO>, targetDistance: Double): Int? {
    val tolerance = targetDistance * 0.05 // 5% tolerance
    
    return runs
        .filter { run ->
            val distanceDiff = kotlin.math.abs(run.distanceMeters - targetDistance)
            distanceDiff <= tolerance
        }
        .minOfOrNull { it.elapsedSeconds }
}