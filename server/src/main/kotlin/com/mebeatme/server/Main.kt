package com.mebeatme.server

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO
import com.mebeatme.shared.core.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.calllogging.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.http.*
import kotlinx.serialization.json.Json
import org.slf4j.event.Level

fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0", module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
        })
    }
    
    install(CORS) {
        allowMethod(HttpMethod.Get)
        allowMethod(HttpMethod.Post)
        allowMethod(HttpMethod.Put)
        allowMethod(HttpMethod.Delete)
        allowMethod(HttpMethod.Options)
        allowHeader(HttpHeaders.ContentType)
        allowHeader(HttpHeaders.Authorization)
        allowHeader("X-Requested-With")
        allowCredentials = true
        anyHost() // In production, specify actual origins
    }
    
    install(CallLogging) {
        level = Level.INFO
    }
    
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            call.respond(HttpStatusCode.InternalServerError, mapOf("error" to cause.message))
        }
    }
    
    routing {
        // Health check endpoint
        get("/health") {
            call.respond(mapOf("status" to "ok", "timestamp" to System.currentTimeMillis()))
        }
        
        // API routes
        route("/api/v1") {
            route("/sync") {
                // POST /sync/runs - Upload runs
                post("/runs") {
                    try {
                        val runs = call.receive<List<RunDTO>>()
                        
                        // Calculate PPI for runs that don't have it
                        val runsWithPpi = runs.map { run ->
                            if (run.ppi == null) {
                                run.calculatePpi()
                            } else {
                                run
                            }
                        }
                        
                        // Store runs (in-memory for now, replace with actual storage)
                        RunRepository.upsertAll(runsWithPpi)
                        
                        call.respond(mapOf(
                            "status" to "ok",
                            "stored" to runsWithPpi.size,
                            "message" to "Runs synchronized successfully"
                        ))
                    } catch (e: Exception) {
                        call.respond(HttpStatusCode.BadRequest, mapOf(
                            "error" to "Invalid request format",
                            "details" to e.message
                        ))
                    }
                }
                
                // GET /bests - Get best times and highest PPI
                get("/bests") {
                    try {
                        val since = call.request.queryParameters["since"]?.toLongOrNull() ?: 0L
                        val runs = RunRepository.listSince(since)
                        
                        val bests = calculateBests(runs, since)
                        
                        call.respond(bests)
                    } catch (e: Exception) {
                        call.respond(HttpStatusCode.InternalServerError, mapOf(
                            "error" to "Failed to calculate bests",
                            "details" to e.message
                        ))
                    }
                }
            }
        }
    }
}

/**
 * Simple in-memory repository for runs
 * In production, replace with actual database storage
 */
object RunRepository {
    private val runs = mutableListOf<RunDTO>()
    
    fun upsertAll(newRuns: List<RunDTO>) {
        // Remove existing runs with same IDs
        val idsToUpdate = newRuns.map { it.id }.toSet()
        runs.removeAll { it.id in idsToUpdate }
        
        // Add new runs
        runs.addAll(newRuns)
    }
    
    fun listSince(sinceMs: Long): List<RunDTO> {
        return runs.filter { it.startedAtEpochMs >= sinceMs }
    }
    
    fun getAll(): List<RunDTO> {
        return runs.toList()
    }
    
    fun clear() {
        runs.clear()
    }
}