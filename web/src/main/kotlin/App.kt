import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.await
import kotlinx.serialization.json.Json
import com.mebeatme.core.ppi.PpiEngine

fun main() {
    val scope = MainScope()
    val store = HistoryStore()
    
    scope.launch {
        try {
            // Fetch data from server - use subdomain in production
            val baseUrl = if (window.location.hostname.contains("ready2race.me")) {
                "https://mebeatme.ready2race.me"
            } else {
                "http://localhost:8080"
            }
            
            val bestsResponse = window.fetch("$baseUrl/api/v1/sync/bests").await()
            val bestsData = bestsResponse.json().await()
            
            val sessionsResponse = window.fetch("$baseUrl/api/v1/sync/sessions").await()
            val sessionsData = sessionsResponse.json().await()
            
            // Display dashboard
            displayDashboard(store, bestsData, sessionsData)
        } catch (e: Exception) {
            // Fallback to local data
            displayDashboard(store, null, null)
        }
    }
}

fun displayDashboard(store: HistoryStore, bestsData: dynamic?, sessionsData: dynamic?) {
    val bucket = Bucket.KM_3_8
    val planner = BeatPlanner(store.all())
    val choices = planner.choicesFor(bucket)
    
    val appElement = document.getElementById("app")!!
    
    appElement.innerHTML = """
        <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
            <h1>🏃‍♂️ MeBeatMe HQ</h1>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">
                <div style="background: #f5f5f5; padding: 20px; border-radius: 8px;">
                    <h2>📊 Best PPI by Bucket</h2>
                    <div id="bests"></div>
                </div>
                
                <div style="background: #f5f5f5; padding: 20px; border-radius: 8px;">
                    <h2>🎯 Challenge Planner</h2>
                    <div id="planner"></div>
                </div>
            </div>
            
            <div style="background: #f5f5f5; padding: 20px; border-radius: 8px;">
                <h2>📈 Recent Sessions</h2>
                <div id="sessions"></div>
            </div>
            
            <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin-top: 20px;">
                <h2>🔍 PPI Transparency</h2>
                <div id="transparency"></div>
            </div>
        </div>
    """
    
    // Display bests
    val bestsElement = document.getElementById("bests")!!
    if (bestsData != null) {
        val bests = bestsData.bests as Map<String, Double>
        bestsElement.innerHTML = bests.entries.joinToString("<br>") { (bucket, ppi) ->
            "<strong>$bucket:</strong> ${ppi.toInt()} PPI"
        }
    } else {
        val localBests = store.bestByBucket()
        bestsElement.innerHTML = localBests.entries.joinToString("<br>") { (bucket, ppi) ->
            "<strong>${bucket.name}:</strong> ${ppi.toInt()} PPI"
        }
    }
    
    // Display planner
    val plannerElement = document.getElementById("planner")!!
    plannerElement.innerHTML = choices.joinToString("<br>") { choice ->
        "<div style='margin: 8px 0; padding: 8px; background: white; border-radius: 4px;'>" +
        "<strong>${choice.label}</strong><br>" +
        "Target: ${formatPace(choice.targetPaceSecPerKm)}/km for ${choice.windowSeconds/60}min<br>" +
        "Expected PPI: ${choice.willExceedScore.toInt()}" +
        "</div>"
    }
    
    // Display sessions
    val sessionsElement = document.getElementById("sessions")!!
    if (sessionsData != null) {
        val sessions = sessionsData.sessions as Array<dynamic>
        sessionsElement.innerHTML = sessions.joinToString("<br>") { session ->
            val distance = session.distanceMeters as Double
            val duration = session.elapsedSeconds as Double
            val ppi = PpiEngine.score(distance, duration)
            val bucket = bucketFor(distance)
            
            "<div style='margin: 8px 0; padding: 8px; background: white; border-radius: 4px;'>" +
            "<strong>${(distance/1000).toFixed(1)}km</strong> in ${formatDuration(duration.toInt())}<br>" +
            "PPI: ${ppi.toInt()} | Bucket: ${bucket.name}" +
            "</div>"
        }
    } else {
        sessionsElement.innerHTML = "<p>No recent sessions available</p>"
    }
    
    // Display transparency
    val transparencyElement = document.getElementById("transparency")!!
    transparencyElement.innerHTML = """
        <div style='background: white; padding: 16px; border-radius: 4px;'>
            <h3>Current PPI Model: Purdy v1 (Default)</h3>
            <p><strong>Model:</strong> ${PpiEngine.getCurrentModelVersion()}</p>
            
            <h3>Purdy Formula</h3>
            <code>PPI = 1000.0 × (baseline_time / actual_time)^(-2.0)</code>
            
            <h3>Elite Baseline Anchors</h3>
            <ul>
                <li><strong>1500m:</strong> 3:50 → 1000 points</li>
                <li><strong>5000m:</strong> 13:00 → 1000 points</li>
                <li><strong>10000m:</strong> 27:00 → 1000 points</li>
                <li><strong>Half Marathon:</strong> 59:00 → 1000 points</li>
                <li><strong>Marathon:</strong> 2:04:20 → 1000 points</li>
            </ul>
            
            <h3>Score Ranges</h3>
            <ul>
                <li><strong>Elite Performance:</strong> 1000 points (meets baseline)</li>
                <li><strong>Competitive Performance:</strong> 694 points (slower than elite)</li>
                <li><strong>Recreational Performance:</strong> 300-500 points</li>
                <li><strong>Moderate Performance:</strong> 100 points (minimum score)</li>
            </ul>
            
            <h3>Distance Buckets</h3>
            <ul>
                <li><strong>KM_1_3:</strong> 1-3km (Sprint)</li>
                <li><strong>KM_3_8:</strong> 3-8km (Short Run)</li>
                <li><strong>KM_8_15:</strong> 8-15km (Medium Run)</li>
                <li><strong>KM_15_25:</strong> 15-25km (Long Run)</li>
                <li><strong>KM_25P:</strong> 25km+ (Ultra)</li>
            </ul>
            
            <h3>How It Works</h3>
            <p>The Purdy PPI system compares your performance to elite baseline times, 
            providing SPI-like scoring that rewards consistency across distances. 
            Your score reflects how you compare to world-class performance standards.</p>
        </div>
    """
}

fun formatPace(secPerKm: Int): String {
    val m = secPerKm / 60
    val s = secPerKm % 60
    return "%d:%02d/km".format(m, s)
}

fun formatDuration(seconds: Int): String {
    val m = seconds / 60
    val s = seconds % 60
    return "%d:%02d".format(m, s)
}
