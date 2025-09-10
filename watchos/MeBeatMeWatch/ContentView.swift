import SwiftUI

struct ContentView: View {
    @State private var isWorkoutActive = false
    @State private var workoutStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var workoutDistance: Double = 0.0
    @State private var ppiScore: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("MeBeatMe")
                .font(.title2)
                .fontWeight(.bold)
            
            if isWorkoutActive {
                // Workout Active View
                VStack(spacing: 15) {
                    Text("Workout Active")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Elapsed Time:")
                        .font(.caption)
                    
                    Text(formatTime(elapsedTime))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Distance: \(String(format: "%.2f", workoutDistance)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("PPI Score: \(String(format: "%.1f", ppiScore))")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Button("Stop Workout") {
                        stopWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.red)
                }
            } else {
                // Welcome View
                VStack(spacing: 15) {
                    Text("Welcome to MeBeatMe!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Button("Start Workout") {
                        startWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("MeBeatMe app launched")
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startWorkout() {
        print("Start workout button tapped!")
        isWorkoutActive = true
        workoutStartTime = Date()
        elapsedTime = 0
        workoutDistance = 0.0
        ppiScore = 0.0
        
        // Start timer to update elapsed time and simulate distance
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = workoutStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
                // Simulate distance increase (roughly 3.5 m/s pace)
                workoutDistance = elapsedTime * 3.5 / 1000.0
                // Calculate PPI score (placeholder until KMP is fully integrated)
                ppiScore = workoutDistance * 100.0 // Simple placeholder calculation
                
                print("Timer tick: elapsed=\(elapsedTime), distance=\(workoutDistance), ppi=\(ppiScore)")
            }
        }
        
        print("Workout started at: \(workoutStartTime?.description ?? "unknown")")
    }
    
    private func stopWorkout() {
        print("Stop workout button tapped!")
        isWorkoutActive = false
        timer?.invalidate()
        timer = nil
        
        print("Workout stopped. Total time: \(formatTime(elapsedTime)), Distance: \(String(format: "%.2f", workoutDistance)) km, PPI: \(String(format: "%.1f", ppiScore))")
        
        // Reset for next workout
        workoutStartTime = nil
        elapsedTime = 0
        workoutDistance = 0.0
        ppiScore = 0.0
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}