package com.mebeatme.server

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.net.ServerSocket
import java.net.Socket
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter

@Serializable
data class HealthResponse(val status: String, val version: String)

@Serializable
data class SessionResponse(val status: String, val message: String)

fun main() {
    val server = ServerSocket(8080)
    println("🚀 MeBeatMe Server running on http://localhost:8080")
    println("📊 Health endpoint: http://localhost:8080/health")
    println("📤 Upload endpoint: http://localhost:8080/sync/upload")
    println("🏆 Bests endpoint: http://localhost:8080/sync/bests")
    
    while (true) {
        val client = server.accept()
        Thread {
            handleClient(client)
        }.start()
    }
}

fun handleClient(client: Socket) {
    val reader = BufferedReader(InputStreamReader(client.getInputStream()))
    val writer = PrintWriter(client.getOutputStream(), true)
    
    try {
        val request = reader.readLine()
        val (method, path) = request.split(" ")
        
        when {
            path.startsWith("/health") -> {
                val response = HealthResponse("ok", "0.2.0")
                sendJsonResponse(writer, response)
            }
            path.startsWith("/sync/bests") -> {
                val bests = mapOf(
                    "KM_1_3" to 450.0,
                    "KM_3_8" to 380.0,
                    "KM_8_15" to 320.0,
                    "KM_15_25" to 280.0,
                    "KM_25P" to 250.0
                )
                val response = mapOf(
                    "status" to "success",
                    "bests" to bests,
                    "lastUpdated" to System.currentTimeMillis()
                )
                sendJsonResponse(writer, response)
            }
            path.startsWith("/sync/upload") -> {
                val response = SessionResponse("success", "Session uploaded successfully")
                sendJsonResponse(writer, response)
            }
            else -> {
                send404Response(writer)
            }
        }
    } catch (e: Exception) {
        send500Response(writer, e.message ?: "Unknown error")
    } finally {
        client.close()
    }
}

fun sendJsonResponse(writer: PrintWriter, data: Any) {
    val json = Json.encodeToString(Any.serializer(), data)
    writer.println("HTTP/1.1 200 OK")
    writer.println("Content-Type: application/json")
    writer.println("Access-Control-Allow-Origin: *")
    writer.println("Content-Length: ${json.length}")
    writer.println()
    writer.println(json)
}

fun send404Response(writer: PrintWriter) {
    writer.println("HTTP/1.1 404 Not Found")
    writer.println("Content-Type: text/plain")
    writer.println()
    writer.println("Not Found")
}

fun send500Response(writer: PrintWriter, message: String) {
    writer.println("HTTP/1.1 500 Internal Server Error")
    writer.println("Content-Type: text/plain")
    writer.println()
    writer.println("Error: $message")
}

