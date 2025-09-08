import SwiftUI

/// Main home view showing dashboard with runs and bests
struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection
                    
                    // Highest PPI (90 days) - prominently displayed
                    highestPPISection
                    
                    // Bests section
                    bestsSection
                    
                    // Recent runs section
                    recentRunsSection
                    
                    // Import button
                    importButton
                }
                .padding()
            }
            .navigationTitle("MeBeatMe")
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
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🏃‍♂️")
                .font(.system(size: 40))
            
            Text("Post-Run Analysis")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var highestPPISection: some View {
        VStack(spacing: 12) {
            Text("Highest PPI (Last 90 Days)")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let highestPPI = viewModel.highestPPILast90Days {
                Text(viewModel.formatPPI(highestPPI))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No runs yet")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var bestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Bests")
                .font(.headline)
            
            VStack(spacing: 8) {
                bestRow(title: "5K", time: viewModel.bests.best5kSec)
                bestRow(title: "10K", time: viewModel.bests.best10kSec)
                bestRow(title: "Half Marathon", time: viewModel.bests.bestHalfSec)
                bestRow(title: "Marathon", time: viewModel.bests.bestFullSec)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func bestRow(title: String, time: Int?) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if let time = time {
                Text(viewModel.formatDuration(time))
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text("--:--")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var recentRunsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Runs")
                .font(.headline)
            
            if viewModel.recentRuns.isEmpty {
                Text("No runs yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.recentRuns) { run in
                    NavigationLink(destination: RunDetailView(run: run)) {
                        runRow(run)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func runRow(_ run: RunRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatDistance(run.distance))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(viewModel.formatDate(run.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.formatDuration(run.duration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(viewModel.formatPace(run.averagePace))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var importButton: some View {
        NavigationLink(destination: ImportView()) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Import Race")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel())
}
