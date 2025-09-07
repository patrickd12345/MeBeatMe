package com.mebeatme.server
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import kotlinx.serialization.json.Json
import io.ktor.serialization.kotlinx.json.*
import com.mebeatme.core.*

fun main() {
    embeddedServer(Netty, port = 8080) {
        install(ContentNegotiation) { json(Json { prettyPrint = true }) }
        routing {
            get("/health") { 
                call.respond(mapOf("status" to "ok", "version" to "0.2.0")) 
            }
            
            post("/sync/upload") {
                try {
                    val session = call.receive<RunSession>()
                    val score = Score(
                        sessionId = session.id,
                        ppi = PpiCurve.score(session.distanceMeters, session.elapsedSeconds),
                        bucket = bucketFor(session.distanceMeters)
                    )
                    
                    // In a real app, save to database
                    call.respond(mapOf(
                        "status" to "success",
                        "score" to score,
                        "message" to "Session uploaded successfully"
                    ))
                } catch (e: Exception) {
                    call.respond(mapOf(
                        "status" to "error",
                        "message" to e.message
                    ))
                }
            }
            
            get("/sync/bests") {
                // Mock data - in real app, fetch from database
                val bests = mapOf(
                    "KM_1_3" to 450.0,
                    "KM_3_8" to 380.0,
                    "KM_8_15" to 320.0,
                    "KM_15_25" to 280.0,
                    "KM_25P" to 250.0
                )
                
                call.respond(mapOf(
                    "status" to "success",
                    "bests" to bests,
                    "lastUpdated" to System.currentTimeMillis()
                ))
            }
            
            get("/sync/sessions") {
                // Mock recent sessions
                val sessions = listOf(
                    RunSession(
                        id = "session_1",
                        startEpochMs = System.currentTimeMillis() - 86400000,
                        distanceMeters = 5000.0,
                        elapsedSeconds = 1200.0
                    ),
                    RunSession(
                        id = "session_2", 
                        startEpochMs = System.currentTimeMillis() - 172800000,
                        distanceMeters = 3000.0,
                        elapsedSeconds = 600.0
                    )
                )
                
                call.respond(mapOf(
                    "status" to "success",
                    "sessions" to sessions,
                    "count" to sessions.size
                ))
            }
        }
    }.start(wait = true)
}
