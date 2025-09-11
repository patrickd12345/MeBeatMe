import SwiftUI

/// Main home view showing dashboard with runs and bests
struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var isRunning = false
    @State private var runSessionViewModel: RunSessionViewModel?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("MeBeatMe")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Three key numbers
                threeNumbersSection
                
                // Start Run button
                NavigationLink(destination: runActiveView, isActive: $isRunning) {
                    startRunButton
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                viewModel.refresh()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var threeNumbersSection: some View {
        VStack(spacing: 16) {
            // PPI to beat
            VStack(spacing: 4) {
                Text("PPI to Beat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let highestPPI = viewModel.highestPPILast90Days {
                    Text("\(Int(highestPPI))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Current PPI (if running)
            VStack(spacing: 4) {
                Text("Current PPI")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isRunning, let currentPPI = runSessionViewModel?.currentPPI {
                    Text("\(Int(currentPPI))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Time to reach PPI to beat
            VStack(spacing: 4) {
                Text("Time to Beat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isRunning, let timeToBeat = runSessionViewModel?.timeToBeatTargetPPI {
                    Text(timeToBeat)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    
    private var startRunButton: some View {
        Button(action: {
            startRun()
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                Text("Start Run")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var runActiveView: some View {
        if let runSessionViewModel = runSessionViewModel {
            RunActiveView(viewModel: runSessionViewModel)
                .navigationTitle("Running")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("Starting run...")
                .navigationTitle("Running")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func startRun() {
        print("🏃 HomeView.startRun() called")
        runSessionViewModel = RunSessionViewModel()
        
        // Pass the target PPI to the run session
        if let targetPPI = viewModel.highestPPILast90Days {
            runSessionViewModel?.setTargetPPI(targetPPI)
        }
        
        Task {
            print("🏃 Starting run task...")
            // Start with a 5K target (5000m) and 30-minute window
            await runSessionViewModel?.startRun(targetDistance: 5000, windowSec: 1800)
            print("🏃 Run started successfully, setting isRunning = true")
            await MainActor.run {
                isRunning = true
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel())
}
