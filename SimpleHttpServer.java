import java.io.*;
import java.net.*;
import java.util.*;

public class SimpleHttpServer {
    // Store workout data in memory
    private static final List<WorkoutData> workouts = new ArrayList<>();
    private static double currentBestPPI = 131.5; // Current best PPI
    public static void main(String[] args) {
        try {
            ServerSocket server = new ServerSocket(8080);
            System.out.println("MeBeatMe Server running on http://localhost:8080");
            System.out.println("Health endpoint: http://localhost:8080/health");
            System.out.println("Upload endpoint: http://localhost:8080/sync/upload");
            System.out.println("Bests endpoint: http://localhost:8080/sync/bests");
            
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
                    
                    if (path.startsWith("/health")) {
                        sendJsonResponse(writer, "{\"status\":\"ok\",\"version\":\"0.2.0\"}");
                    } else if (path.startsWith("/sync/bests")) {
                        // Return the current best PPI (updated when new workouts are added)
                        String bests = "{\"status\":\"success\",\"bests\":{\"KM_3_8\":" + String.format("%.1f", currentBestPPI) + "},\"lastUpdated\":" + System.currentTimeMillis() + "}";
                        sendJsonResponse(writer, bests);
                    } else if (path.startsWith("/sync/upload")) {
                        sendJsonResponse(writer, "{\"status\":\"success\",\"message\":\"Session uploaded successfully\"}");
                    } else if (path.startsWith("/sync/runs")) {
                        // Handle manual workout submissions
                        if (method.equals("POST")) {
                            // Read the request body
                            StringBuilder body = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null && !line.isEmpty()) {
                                body.append(line);
                            }
                            
                            // Parse and store the workout data
                            try {
                                // Simple JSON parsing for workout data
                                String jsonBody = body.toString();
                                if (jsonBody.contains("distanceMeters") && jsonBody.contains("elapsedSeconds")) {
                                    // Extract values from JSON (simple parsing)
                                    double distance = extractDouble(jsonBody, "distanceMeters");
                                    double time = extractDouble(jsonBody, "elapsedSeconds");
                                    
                                    // Calculate PPI
                                    double baselineTime = getInterpolatedBaselineTime(distance);
                                    double ppi = 1000.0 * Math.pow(time / baselineTime, -2.0);
                                    ppi = Math.max(100, Math.min(2000, ppi)); // Clamp to reasonable range
                                    
                                    // Store workout
                                    WorkoutData workout = new WorkoutData(
                                        "manual_" + System.currentTimeMillis(),
                                        distance,
                                        (int)time,
                                        ppi,
                                        System.currentTimeMillis()
                                    );
                                    workouts.add(workout);
                                    
                                    // Update best PPI if this is better
                                    if (ppi > currentBestPPI) {
                                        currentBestPPI = ppi;
                                    }
                                    
                                    System.out.println("Stored workout: " + distance + "m in " + time + "s, PPI: " + String.format("%.1f", ppi));
                                }
                                
                                sendJsonResponse(writer, "{\"status\":\"success\",\"message\":\"Run added successfully\"}");
                            } catch (Exception e) {
                                System.err.println("Error parsing workout data: " + e.getMessage());
                                sendJsonResponse(writer, "{\"status\":\"error\",\"message\":\"Failed to parse workout data\"}");
                            }
                        } else {
                            // Return stored workouts
                            StringBuilder runsJson = new StringBuilder("{\"status\":\"success\",\"runs\":[");
                            for (int i = 0; i < workouts.size(); i++) {
                                WorkoutData workout = workouts.get(i);
                                runsJson.append("{");
                                runsJson.append("\"id\":\"").append(workout.id).append("\",");
                                runsJson.append("\"distanceMeters\":").append(workout.distanceMeters).append(",");
                                runsJson.append("\"elapsedSeconds\":").append(workout.elapsedSeconds).append(",");
                                runsJson.append("\"ppi\":").append(String.format("%.1f", workout.ppi)).append(",");
                                runsJson.append("\"timestamp\":").append(workout.timestamp);
                                runsJson.append("}");
                                if (i < workouts.size() - 1) runsJson.append(",");
                            }
                            runsJson.append("]}");
                            sendJsonResponse(writer, runsJson.toString());
                        }
                    } else if (path.startsWith("/sync/sessions")) {
                        // Your actual 5.94km run: 41:38 = 2498 seconds
                        double distanceMeters = 5940.0;
                        double timeSeconds = 2498.0;
                        
                        // CORRECTED Purdy formula: PPI = 1000 * (actual_time / baseline_time)^(-2.0)
                        double baselineTime = getInterpolatedBaselineTime(distanceMeters);
                        double actualPpi = 1000.0 * Math.pow(timeSeconds / baselineTime, -2.0);
                        
                        String sessions = "{\"status\":\"success\",\"sessions\":[{\"id\":\"your_5_9k_run\",\"filename\":\"your_run_5.9km.fit\",\"distance\":" + distanceMeters + ",\"duration\":" + timeSeconds + ",\"ppi\":" + String.format("%.1f", actualPpi) + ",\"bucket\":\"KM_3_8\",\"createdAt\":" + System.currentTimeMillis() + "}],\"count\":1}";
                        sendJsonResponse(writer, sessions);
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
    
    private static void sendJsonResponse(PrintWriter writer, String json) {
        writer.println("HTTP/1.1 200 OK");
        writer.println("Content-Type: application/json");
        writer.println("Access-Control-Allow-Origin: *");
        writer.println("Access-Control-Allow-Methods: GET, POST, OPTIONS");
        writer.println("Access-Control-Allow-Headers: Content-Type");
        writer.println("Content-Length: " + json.length());
        writer.println();
        writer.println(json);
        writer.flush();
    }
    
    private static void send404Response(PrintWriter writer) {
        writer.println("HTTP/1.1 404 Not Found");
        writer.println("Content-Type: text/plain");
        writer.println();
        writer.println("Not Found");
        writer.flush();
    }
    
    private static double getInterpolatedBaselineTime(double distanceMeters) {
        // Elite baseline times (in seconds) - realistic values
        double[][] baselines = {
            {1500, 210},    // 3:30
            {5000, 755},    // 12:35 
            {10000, 1571},  // 26:11
            {21097, 3540},  // 59:00
            {42195, 7460}   // 2:04:20
        };
        
        // Handle edge cases
        if (distanceMeters <= baselines[0][0]) {
            return baselines[0][1];
        }
        if (distanceMeters >= baselines[baselines.length - 1][0]) {
            return baselines[baselines.length - 1][1];
        }
        
        // Find surrounding anchors and interpolate
        for (int i = 0; i < baselines.length - 1; i++) {
            double currentDist = baselines[i][0];
            double nextDist = baselines[i + 1][0];
            
            if (distanceMeters >= currentDist && distanceMeters <= nextDist) {
                // Linear interpolation in log-log space
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
    
    // Helper method to extract double values from JSON
    private static double extractDouble(String json, String key) {
        try {
            int startIndex = json.indexOf("\"" + key + "\":") + key.length() + 3;
            int endIndex = json.indexOf(",", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("]", startIndex);
            String value = json.substring(startIndex, endIndex).trim();
            return Double.parseDouble(value);
        } catch (Exception e) {
            System.err.println("Error extracting " + key + " from JSON: " + e.getMessage());
            return 0.0;
        }
    }
    
    // Simple data class for workout storage
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
