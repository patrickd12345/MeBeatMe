import java.io.*;
import java.net.*;
import java.util.*;
import java.time.Instant;

public class ProductionHttpServer {
    // Store workout data in memory
    private static final List<WorkoutData> workouts = new ArrayList<>();
    private static double currentBestPPI = 131.5; // Current best PPI
    
    // Production configuration
    private static final String DOMAIN = System.getenv().getOrDefault("FULL_DOMAIN", "mebeatme.ready2race.run");
    private static final String CORS_ORIGINS = System.getenv().getOrDefault("CORS_ORIGINS", "https://mebeatme.ready2race.run,https://ready2race.run");
    private static final int SERVER_PORT = Integer.parseInt(System.getenv().getOrDefault("SERVER_PORT", "8080"));
    private static final String SERVER_HOST = System.getenv().getOrDefault("SERVER_HOST", "0.0.0.0");
    
    public static void main(String[] args) {
        try {
            ServerSocket server = new ServerSocket(SERVER_PORT, 50, InetAddress.getByName(SERVER_HOST));
            System.out.println("MeBeatMe Production Server running on http://" + SERVER_HOST + ":" + SERVER_PORT);
            System.out.println("Domain: " + DOMAIN);
            System.out.println("CORS Origins: " + CORS_ORIGINS);
            System.out.println("Health endpoint: http://" + SERVER_HOST + ":" + SERVER_PORT + "/health");
            System.out.println("Strava endpoints: /strava/token, /strava/import");
            System.out.println("Sync endpoints: /sync/bests, /sync/sessions, /sync/runs");
            
            while (true) {
                Socket client = server.accept();
                new Thread(() -> handleClient(client)).start();
            }
        } catch (IOException e) {
            System.err.println("Server error: " + e.getMessage());
        }
    }
    
    private static void handleClient(Socket client) {
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
            PrintWriter writer = new PrintWriter(client.getOutputStream(), true);
            
            String request = reader.readLine();
            if (request != null) {
                String[] parts = request.split(" ");
                if (parts.length >= 2) {
                    String method = parts[0];
                    String path = parts[1];
                    
                    // Log request for production monitoring
                    System.out.println("Request: " + method + " " + path + " from " + client.getInetAddress());
                    
                    if (method.equals("OPTIONS")) {
                        // Handle CORS preflight requests
                        handleCorsPreflight(writer);
                    } else if (path.startsWith("/health")) {
                        sendHealthResponse(writer);
                    } else if (path.startsWith("/sync/bests")) {
                        handleBestsEndpoint(writer);
                    } else if (path.startsWith("/sync/sessions")) {
                        handleSessionsEndpoint(writer);
                    } else if (path.startsWith("/sync/runs/") && method.equals("DELETE")) {
                        handleDeleteWorkout(reader, writer, path);
                    } else if (path.startsWith("/sync/runs") && method.equals("POST")) {
                        handleAddWorkout(reader, writer);
                    } else if (path.startsWith("/strava/token")) {
                        handleStravaTokenExchange(reader, writer);
                    } else if (path.startsWith("/strava/import")) {
                        handleStravaImport(reader, writer);
                    } else if (path.startsWith("/strava/test")) {
                        handleStravaTest(writer);
                    } else {
                        send404Response(writer);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Client handling error: " + e.getMessage());
        } finally {
            try {
                client.close();
            } catch (IOException e) {
                System.err.println("Error closing client: " + e.getMessage());
            }
        }
    }
    
    private static void handleCorsPreflight(PrintWriter writer) {
        writer.println("HTTP/1.1 200 OK");
        writer.println("Access-Control-Allow-Origin: *");
        writer.println("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
        writer.println("Access-Control-Allow-Headers: Content-Type, Authorization");
        writer.println("Content-Length: 0");
        writer.println();
        writer.flush();
    }
    
    private static void sendHealthResponse(PrintWriter writer) {
        String healthJson = String.format(
            "{\"status\":\"ok\",\"version\":\"1.0.0\",\"domain\":\"%s\",\"timestamp\":%d,\"workouts\":%d}",
            DOMAIN, System.currentTimeMillis(), workouts.size()
        );
        sendJsonResponse(writer, healthJson);
    }
    
    private static void handleBestsEndpoint(PrintWriter writer) {
        String bests = String.format(
            "{\"status\":\"success\",\"bests\":{\"KM_3_8\":%.1f},\"lastUpdated\":%d}",
            currentBestPPI, System.currentTimeMillis()
        );
        sendJsonResponse(writer, bests);
    }
    
    private static void handleSessionsEndpoint(PrintWriter writer) {
        StringBuilder sessionsJson = new StringBuilder();
        sessionsJson.append("{\"status\":\"success\",\"sessions\":[");
        
        // Add hardcoded run
        sessionsJson.append("{");
        sessionsJson.append("\"id\":\"hardcoded_run\",");
        sessionsJson.append("\"distance\":5940,");
        sessionsJson.append("\"duration\":2498,");
        sessionsJson.append("\"ppi\":355.0,");
        sessionsJson.append("\"bucket\":\"KM_3_8\",");
        sessionsJson.append("\"createdAt\":1757520000000");
        sessionsJson.append("}");
        
        // Add stored workouts
        for (WorkoutData workout : workouts) {
            sessionsJson.append(",");
            sessionsJson.append("{");
            sessionsJson.append("\"id\":\"").append(workout.id).append("\",");
            sessionsJson.append("\"distance\":").append((int)workout.distanceMeters).append(",");
            sessionsJson.append("\"duration\":").append(workout.elapsedSeconds).append(",");
            sessionsJson.append("\"ppi\":").append(String.format("%.1f", workout.ppi)).append(",");
            sessionsJson.append("\"bucket\":\"KM_3_8\",");
            sessionsJson.append("\"createdAt\":").append(workout.timestamp);
            sessionsJson.append("}");
        }
        
        sessionsJson.append("],\"count\":").append(workouts.size() + 1).append("}");
        sendJsonResponse(writer, sessionsJson.toString());
    }
    
    private static void handleDeleteWorkout(BufferedReader reader, PrintWriter writer, String path) {
        try {
            String workoutId = path.substring("/sync/runs/".length());
            boolean removed = workouts.removeIf(workout -> workout.id.equals(workoutId));
            
            if (removed) {
                // Recalculate best PPI
                currentBestPPI = 131.5; // Reset to original best
                for (WorkoutData workout : workouts) {
                    if (workout.ppi > currentBestPPI) {
                        currentBestPPI = workout.ppi;
                    }
                }
                sendJsonResponse(writer, "{\"status\":\"success\",\"message\":\"Workout deleted successfully\"}");
                System.out.println("Deleted workout: " + workoutId + ", New best PPI: " + String.format("%.1f", currentBestPPI));
            } else {
                sendJsonResponse(writer, "{\"status\":\"error\",\"message\":\"Workout not found\"}");
            }
        } catch (Exception e) {
            System.err.println("Error deleting workout: " + e.getMessage());
            sendJsonResponse(writer, "{\"status\":\"error\",\"message\":\"Internal server error\"}");
        }
    }
    
    private static void handleAddWorkout(BufferedReader reader, PrintWriter writer) {
        try {
            // Read the request body
            StringBuilder body = new StringBuilder();
            int contentLength = 0;
            
            // First pass: read headers to find Content-Length
            String line;
            while ((line = reader.readLine()) != null && !line.isEmpty()) {
                if (line.toLowerCase().startsWith("content-length:")) {
                    contentLength = Integer.parseInt(line.substring(15).trim());
                }
            }
            
            // Second pass: read exactly the number of bytes specified by Content-Length
            if (contentLength > 0) {
                char[] buffer = new char[contentLength];
                int bytesRead = reader.read(buffer, 0, contentLength);
                if (bytesRead > 0) {
                    body.append(buffer, 0, bytesRead);
                }
            }
            
            System.out.println("Received workout data: " + body.toString());
            
            // Parse JSON (simplified)
            String workoutJson = extractWorkoutFromArray(body.toString());
            if (workoutJson == null) {
                sendJsonResponse(writer, "{\"status\":\"error\",\"message\":\"Invalid JSON format\"}");
                return;
            }
            
            // Extract workout data
            String workoutId = extractString(workoutJson, "id");
            double distance = extractDouble(workoutJson, "distanceMeters");
            double time = extractDouble(workoutJson, "elapsedSeconds");
            long timestamp = extractLong(workoutJson, "startedAtEpochMs");
            
            // Calculate PPI
            double ppi = calculatePPI(distance, time);
            
            // Create and store workout
            WorkoutData workout = new WorkoutData(workoutId, distance, (int)time, ppi, timestamp);
            workouts.add(workout);
            
            // Update best PPI if needed
            if (ppi > currentBestPPI) {
                currentBestPPI = ppi;
            }
            
            System.out.println("Stored workout: " + String.format("%.1f", distance/1000.0) + "km in " + 
                             formatTime((int)time) + " (PPI: " + String.format("%.1f", ppi) + ")");
            
            sendJsonResponse(writer, "{\"status\":\"success\",\"message\":\"Workout added successfully\",\"ppi\":" + String.format("%.1f", ppi) + "}");
            
        } catch (Exception e) {
            System.err.println("Error adding workout: " + e.getMessage());
            sendJsonResponse(writer, "{\"status\":\"error\",\"message\":\"Internal server error\"}");
        }
    }
    
    private static void handleStravaTokenExchange(BufferedReader reader, PrintWriter writer) {
        try {
            // Read the request body
            StringBuilder body = new StringBuilder();
            int contentLength = 0;
            
            String line;
            while ((line = reader.readLine()) != null && !line.isEmpty()) {
                if (line.toLowerCase().startsWith("content-length:")) {
                    contentLength = Integer.parseInt(line.substring(15).trim());
                }
            }
            
            if (contentLength > 0) {
                char[] buffer = new char[contentLength];
                int bytesRead = reader.read(buffer, 0, contentLength);
                if (bytesRead > 0) {
                    body.append(buffer, 0, bytesRead);
                }
            }
            
            System.out.println("Strava token exchange request");
            
            String code = extractString(body.toString(), "code");
            if (code == null || code.isEmpty()) {
                sendJsonResponse(writer, "{\"success\":false,\"error\":\"No authorization code provided\"}");
                return;
            }
            
            // For production, you would exchange the code for a real token
            // For now, return a mock response
            sendJsonResponse(writer, "{\"success\":true,\"access_token\":\"mock_token\",\"refresh_token\":\"mock_refresh\"}");
            
        } catch (Exception e) {
            System.err.println("Error handling Strava token exchange: " + e.getMessage());
            sendJsonResponse(writer, "{\"success\":false,\"error\":\"Internal server error\"}");
        }
    }
    
    private static void handleStravaImport(BufferedReader reader, PrintWriter writer) {
        try {
            // Read the request body
            StringBuilder body = new StringBuilder();
            int contentLength = 0;
            
            String line;
            while ((line = reader.readLine()) != null && !line.isEmpty()) {
                if (line.toLowerCase().startsWith("content-length:")) {
                    contentLength = Integer.parseInt(line.substring(15).trim());
                }
            }
            
            if (contentLength > 0) {
                char[] buffer = new char[contentLength];
                int bytesRead = reader.read(buffer, 0, contentLength);
                if (bytesRead > 0) {
                    body.append(buffer, 0, bytesRead);
                }
            }
            
            System.out.println("Strava import request");
            
            // Mock import for demonstration
            String importResult = "{\"success\":true,\"imported\":3,\"total\":3,\"activities\":[" +
                "{\"name\":\"Morning Run\",\"distance\":\"5.0\",\"time\":\"25:30\",\"success\":true}," +
                "{\"name\":\"Evening Run\",\"distance\":\"8.5\",\"time\":\"42:15\",\"success\":true}," +
                "{\"name\":\"Weekend Long Run\",\"distance\":\"15.2\",\"time\":\"1:18:45\",\"success\":true}" +
                "]}";
            
            sendJsonResponse(writer, importResult);
            
        } catch (Exception e) {
            System.err.println("Error handling Strava import: " + e.getMessage());
            sendJsonResponse(writer, "{\"success\":false,\"error\":\"Internal server error\"}");
        }
    }
    
    private static void handleStravaTest(PrintWriter writer) {
        try {
            System.out.println("Testing Strava integration...");
            
            // Mock test response
            String testResult = "{\"success\":true,\"imported\":2,\"total\":2,\"activities\":[" +
                "{\"name\":\"Test Run 1\",\"distance\":\"5.0\",\"time\":\"20:00\",\"success\":true}," +
                "{\"name\":\"Test Run 2\",\"distance\":\"10.0\",\"time\":\"45:30\",\"success\":true}" +
                "]}";
            
            sendJsonResponse(writer, testResult);
            
        } catch (Exception e) {
            System.err.println("Error in Strava test: " + e.getMessage());
            sendJsonResponse(writer, "{\"success\":false,\"error\":\"Test failed: " + e.getMessage() + "\"}");
        }
    }
    
    private static void sendJsonResponse(PrintWriter writer, String json) {
        writer.println("HTTP/1.1 200 OK");
        writer.println("Content-Type: application/json");
        writer.println("Access-Control-Allow-Origin: *");
        writer.println("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
        writer.println("Access-Control-Allow-Headers: Content-Type, Authorization");
        writer.println("Content-Length: " + json.length());
        writer.println();
        writer.println(json);
        writer.flush();
    }
    
    private static void send404Response(PrintWriter writer) {
        writer.println("HTTP/1.1 404 Not Found");
        writer.println("Content-Type: text/plain");
        writer.println("Access-Control-Allow-Origin: *");
        writer.println("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
        writer.println("Access-Control-Allow-Headers: Content-Type, Authorization");
        writer.println();
        writer.println("404 Not Found");
        writer.flush();
    }
    
    // Helper methods
    private static String extractWorkoutFromArray(String json) {
        try {
            int start = json.indexOf('[') + 1;
            int end = json.lastIndexOf(']');
            if (start > 0 && end > start) {
                return json.substring(start, end).trim();
            }
        } catch (Exception e) {
            System.err.println("Error extracting workout from array: " + e.getMessage());
        }
        return null;
    }
    
    private static double extractDouble(String json, String key) {
        try {
            int startIndex = json.indexOf("\"" + key + "\":") + key.length() + 3;
            int endIndex = json.indexOf(",", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("]", startIndex);
            String value = json.substring(startIndex, endIndex).trim();
            return Double.parseDouble(value);
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    private static long extractLong(String json, String key) {
        try {
            int startIndex = json.indexOf("\"" + key + "\":") + key.length() + 3;
            int endIndex = json.indexOf(",", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("]", startIndex);
            String value = json.substring(startIndex, endIndex).trim();
            return Long.parseLong(value);
        } catch (Exception e) {
            return System.currentTimeMillis();
        }
    }
    
    private static String extractString(String json, String key) {
        try {
            int startIndex = json.indexOf("\"" + key + "\":\"") + key.length() + 4;
            int endIndex = json.indexOf("\"", startIndex);
            if (endIndex > startIndex) {
                return json.substring(startIndex, endIndex);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    private static double calculatePPI(double distanceMeters, double timeSeconds) {
        double baselineTime = getInterpolatedBaselineTime(distanceMeters);
        double ratio = baselineTime / timeSeconds;
        return 1000.0 * Math.pow(ratio, 3);
    }
    
    private static double getInterpolatedBaselineTime(double distanceMeters) {
        double[][] baselines = {
            {1500, 210},    // 3:30
            {5000, 755},    // 12:35 
            {10000, 1571},  // 26:11
            {21097, 3540},  // 59:00
            {42195, 7460}   // 2:04:20
        };
        
        if (distanceMeters <= baselines[0][0]) {
            return baselines[0][1];
        }
        if (distanceMeters >= baselines[baselines.length - 1][0]) {
            return baselines[baselines.length - 1][1];
        }
        
        for (int i = 0; i < baselines.length - 1; i++) {
            double currentDist = baselines[i][0];
            double nextDist = baselines[i + 1][0];
            
            if (distanceMeters >= currentDist && distanceMeters <= nextDist) {
                double logDist1 = Math.log(currentDist);
                double logDist2 = Math.log(nextDist);
                double logTime1 = Math.log(baselines[i][1]);
                double logTime2 = Math.log(baselines[i + 1][1]);
                double logDistTarget = Math.log(distanceMeters);
                
                double ratio = (logDistTarget - logDist1) / (logDist2 - logDist1);
                double logTimeTarget = logTime1 + ratio * (logTime2 - logTime1);
                
                return Math.exp(logTimeTarget);
            }
        }
        
        return baselines[baselines.length - 1][1];
    }
    
    private static String formatTime(int seconds) {
        int hours = seconds / 3600;
        int minutes = (seconds % 3600) / 60;
        int secs = seconds % 60;
        
        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, secs);
        } else {
            return String.format("%d:%02d", minutes, secs);
        }
    }
    
    // Workout data class
    static class WorkoutData {
        final String id;
        final double distanceMeters;
        final int elapsedSeconds;
        final double ppi;
        final long timestamp;
        
        WorkoutData(String id, double distanceMeters, int elapsedSeconds, double ppi, long timestamp) {
            this.id = id;
            this.distanceMeters = distanceMeters;
            this.elapsedSeconds = elapsedSeconds;
            this.ppi = ppi;
            this.timestamp = timestamp;
        }
    }
}
