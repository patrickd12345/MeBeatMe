import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingImportView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Import Tab
            ImportTabView()
                .tabItem {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import")
                }
                .tag(1)
            
            // History Tab
            HistoryTabView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
            
            // Settings Tab
            SettingsTabView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .onAppear {
            print("MeBeatMe app launched")
        }
    }
}

// MARK: - Home Tab View
struct HomeTabView: View {
    @State private var isWorkoutActive = false
    @State private var workoutStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var workoutDistance: Double = 0.0
    @State private var ppiScore: Double = 0.0
    @State private var showingImportView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                if isWorkoutActive {
                    // Workout Active View
                    workoutActiveSection
                } else {
                    // Welcome View
                    welcomeSection
                }
                
                Spacer()
                
                // Quick Actions
                quickActionsSection
            }
            .padding()
            .navigationTitle("MeBeatMe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImportView = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showingImportView) {
                ImportView()
                    .environment(ImportViewModel())
                    .environment(AnalysisViewModel())
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🏃‍♂️")
                .font(.system(size: 40))
            
            Text("MeBeatMe")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Personal Performance Index")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var workoutActiveSection: some View {
        VStack(spacing: 15) {
            Text("Workout Active")
                .font(.headline)
                .foregroundColor(.green)
            
            // Main metrics
            HStack(spacing: 20) {
                VStack {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(elapsedTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f km", workoutDistance))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack {
                    Text("PPI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", ppiScore))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            Button("Stop Workout") {
                stopWorkout()
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            Text("Welcome to MeBeatMe!")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Track your runs and improve your Personal Performance Index")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Workout") {
                startWorkout()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: {
                    showingImportView = true
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                        Text("Import")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                NavigationLink(destination: RunHistoryView().environment(RunStore())) {
                    VStack {
                        Image(systemName: "clock")
                            .font(.title2)
                        Text("History")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                }
            }
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

// MARK: - Import Tab View
struct ImportTabView: View {
    var body: some View {
        NavigationStack {
            ImportView()
                .environment(ImportViewModel())
                .environment(AnalysisViewModel())
        }
    }
}

// MARK: - History Tab View
struct HistoryTabView: View {
    var body: some View {
        NavigationStack {
            RunHistoryView()
                .environment(RunStore())
        }
    }
}

// MARK: - Settings Tab View
struct SettingsTabView: View {
    @State private var notificationsEnabled = true
    @State private var metricUnits = true
    @State private var autoSync = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Toggle("Metric Units", isOn: $metricUnits)
                    Toggle("Auto Sync", isOn: $autoSync)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data") {
                    Button("Clear All Data") {
                        // TODO: Implement clear data
                    }
                    .foregroundColor(.red)
                    
                    Button("Export Data") {
                        // TODO: Implement data export
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}