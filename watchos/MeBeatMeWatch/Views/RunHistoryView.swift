import SwiftUI

/// View for displaying run history and statistics
struct RunHistoryView: View {
    @Environment(RunStore.self) private var runStore
    @State private var runs: [RunRecord] = []
    @State private var isLoading = false
    @State private var selectedRun: RunRecord?
    @State private var showingRunDetail = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading runs...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if runs.isEmpty {
                    emptyStateView
                } else {
                    runHistoryList
                }
            }
            .navigationTitle("Run History")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadRuns()
            }
            .onAppear {
                Task {
                    await loadRuns()
                }
            }
            .sheet(isPresented: $showingRunDetail) {
                if let selectedRun = selectedRun {
                    RunDetailView(run: selectedRun)
                        .environment(AnalysisViewModel())
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Text("📊")
                .font(.system(size: 60))
            
            Text("No Runs Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Import your first run to see your Personal Performance Index and track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Import Run") {
                // TODO: Navigate to import view
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var runHistoryList: some View {
        List {
            // Statistics summary
            statisticsSection
            
            // Recent runs
            Section("Recent Runs") {
                ForEach(runs) { run in
                    RunHistoryRow(run: run) {
                        selectedRun = run
                        showingRunDetail = true
                    }
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        Section("Statistics") {
            VStack(spacing: 12) {
                HStack {
                    StatisticCard(
                        title: "Total Runs",
                        value: "\(runs.count)",
                        icon: "figure.run",
                        color: .blue
                    )
                    
                    StatisticCard(
                        title: "Total Distance",
                        value: formatTotalDistance(),
                        icon: "location",
                        color: .green
                    )
                }
                
                HStack {
                    StatisticCard(
                        title: "Best PPI",
                        value: formatBestPPI(),
                        icon: "star.fill",
                        color: .orange
                    )
                    
                    StatisticCard(
                        title: "Avg Pace",
                        value: formatAveragePace(),
                        icon: "speedometer",
                        color: .purple
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func loadRuns() async {
        isLoading = true
        
        do {
            let loadedRuns = try await runStore.getAllRuns()
            await MainActor.run {
                self.runs = loadedRuns.sorted { $0.date > $1.date }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func formatTotalDistance() -> String {
        let totalKm = runs.reduce(0) { $0 + $1.distance } / 1000.0
        return String(format: "%.1f km", totalKm)
    }
    
    private func formatBestPPI() -> String {
        guard let bestRun = runs.max(by: { $0.ppi ?? 0 < $1.ppi ?? 0 }),
              let ppi = bestRun.ppi else {
            return "--"
        }
        return String(format: "%.0f", ppi)
    }
    
    private func formatAveragePace() -> String {
        guard !runs.isEmpty else { return "--" }
        
        let totalPace = runs.reduce(0) { $0 + $1.averagePace }
        let averagePace = totalPace / Double(runs.count)
        
        let minutes = Int(averagePace) / 60
        let seconds = Int(averagePace) % 60
        
        return String(format: "%d:%02d/km", minutes, seconds)
    }
}

/// Row view for displaying a single run in history
struct RunHistoryRow: View {
    let run: RunRecord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.fileName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formatDate(run.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let ppi = run.ppi {
                        Text(String(format: "%.0f PPI", ppi))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Text(String(format: "%.2f km", run.distance / 1000.0))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Card view for displaying statistics
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    RunHistoryView()
        .environment(RunStore())
}
