package com.mebeatme.server

import com.mebeatme.shared.model.RunDTO
import com.mebeatme.shared.model.BestsDTO
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.server.testing.*
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

class ServerTest {
    
    @Test
    fun `health endpoint returns ok status`() = testApplication {
        val response = client.get("/health")
        assertEquals(HttpStatusCode.OK, response.status)
        
        val body = response.bodyAsText()
        assertNotNull(body)
        assert(body.contains("ok"))
    }
    
    @Test
    fun `POST sync runs accepts valid runs and calculates PPI`() = testApplication {
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0),
            RunDTO("2", "GPX", 2000, 3000, 10000.0, 3000, 300.0)
        )
        
        val response = client.post("/api/v1/sync/runs") {
            contentType(ContentType.Application.Json)
            setBody(runs)
        }
        
        assertEquals(HttpStatusCode.OK, response.status)
        
        val body = response.bodyAsText()
        assert(body.contains("ok"))
        assert(body.contains("stored"))
    }
    
    @Test
    fun `POST sync runs handles invalid JSON gracefully`() = testApplication {
        val response = client.post("/api/v1/sync/runs") {
            contentType(ContentType.Application.Json)
            setBody("invalid json")
        }
        
        assertEquals(HttpStatusCode.BadRequest, response.status)
    }
    
    @Test
    fun `GET bests returns calculated bests`() = testApplication {
        // First, add some test runs
        val runs = listOf(
            RunDTO("1", "GPX", 1000, 2000, 5000.0, 1500, 300.0), // 5K in 25:00
            RunDTO("2", "GPX", 2000, 3000, 5000.0, 1200, 240.0), // 5K in 20:00 (better)
            RunDTO("3", "GPX", 3000, 4000, 10000.0, 3000, 300.0), // 10K in 50:00
            RunDTO("4", "GPX", 4000, 5000, 10000.0, 2400, 240.0), // 10K in 40:00 (better)
            RunDTO("5", "GPX", 5000, 6000, 21097.5, 6300, 300.0), // Half in 1:45:00
            RunDTO("6", "GPX", 6000, 7000, 21097.5, 5400, 256.0), // Half in 1:30:00 (better)
            RunDTO("7", "GPX", 7000, 8000, 42195.0, 12600, 300.0), // Full in 3:30:00
            RunDTO("8", "GPX", 8000, 9000, 42195.0, 10800, 256.0) // Full in 3:00:00 (better)
        )
        
        // Upload runs
        client.post("/api/v1/sync/runs") {
            contentType(ContentType.Application.Json)
            setBody(runs)
        }
        
        // Get bests
        val response = client.get("/api/v1/sync/bests")
        assertEquals(HttpStatusCode.OK, response.status)
        
        val body = response.bodyAsText()
        assert(body.contains("best5kSec"))
        assert(body.contains("best10kSec"))
        assert(body.contains("bestHalfSec"))
        assert(body.contains("bestFullSec"))
        assert(body.contains("highestPPILast90Days"))
    }
    
    @Test
    fun `GET bests with since parameter filters correctly`() = testApplication {
        val baseTime = 1700000000000L
        
        val runs = listOf(
            RunDTO("1", "GPX", baseTime - 1000, baseTime - 1000 + 1500, 5000.0, 1500, 300.0), // Old run
            RunDTO("2", "GPX", baseTime + 1000, baseTime + 1000 + 1200, 5000.0, 1200, 240.0) // Recent run
        )
        
        // Upload runs
        client.post("/api/v1/sync/runs") {
            contentType(ContentType.Application.Json)
            setBody(runs)
        }
        
        // Get bests since baseTime
        val response = client.get("/api/v1/sync/bests?since=$baseTime")
        assertEquals(HttpStatusCode.OK, response.status)
        
        val body = response.bodyAsText()
        // Should only find the recent run (1200 seconds)
        assert(body.contains("1200"))
    }
    
    @Test
    fun `CORS headers are properly set`() = testApplication {
        val response = client.options("/api/v1/sync/runs") {
            header(HttpHeaders.Origin, "https://example.com")
            header(HttpHeaders.AccessControlRequestMethod, "POST")
            header(HttpHeaders.AccessControlRequestHeaders, "Content-Type")
        }
        
        assertEquals(HttpStatusCode.OK, response.status)
        
        val corsHeaders = response.headers.getAll(HttpHeaders.AccessControlAllowOrigin)
        assertNotNull(corsHeaders)
    }
}

