import SwiftUI

/// Main home view showing dashboard with runs and bests
struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Highest PPI (90 days) - prominently displayed
                    highestPPISection
                    
                    // Performance insights
                    if !viewModel.performanceInsights.isEmpty {
                        performanceInsightsSection
                    }
                    
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
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Post-Run Analysis")
                .font(.title2)
                .fontWeight(.semibold)
            
            if viewModel.hasRuns {
                Text("\(viewModel.totalRunsCount) runs • \(viewModel.formattedTotalDistance)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Import your first run to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var highestPPISection: some View {
        VStack(spacing: 16) {
            Text("Highest PPI (Last 90 Days)")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let highestPPI = viewModel.highestPPILast90Days {
                VStack(spacing: 8) {
                    Text(viewModel.formatPPI(highestPPI))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.performanceLevel.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                // Motivation message
                Text(viewModel.motivationMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No runs yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Import your first run to get a PPI score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var performanceInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Insights")
                .font(.headline)
            
            ForEach(viewModel.performanceInsights, id: \.self) { insight in
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text(insight)
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
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
        .cornerRadius(16)
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
        .cornerRadius(16)
    }
    
    private func runRow(_ run: RunRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatDistance(run.distance))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(viewModel.formatRelativeDate(run.date))
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
                Text("Import Race File")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel())
}
