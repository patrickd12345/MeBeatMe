import SwiftUI

/// View for displaying run details
struct RunDetailView: View {
    let run: RunRecord
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @State private var analyzedRun: AnalyzedRun?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Run details
                    runDetailsSection
                    
                    // Splits (if available)
                    if let splits = run.splits, !splits.isEmpty {
                        splitsSection(splits)
                    }
                    
                    // Analysis button
                    analysisButton
                    
                    // Analysis results
                    if let analyzedRun = analyzedRun {
                        analysisResultsSection(analyzedRun)
                    }
                }
                .padding()
            }
            .navigationTitle("Run Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            analyzeRun()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🏃‍♂️")
                .font(.system(size: 40))
            
            Text(run.fileName)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(formatDate(run.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var runDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Run Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                detailRow(title: "Distance", value: String(format: "%.2f km", run.distance / 1000.0))
                detailRow(title: "Duration", value: formatDuration(run.duration))
                detailRow(title: "Average Pace", value: formatPace(run.averagePace))
                detailRow(title: "Source", value: run.source.uppercased())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func splitsSection(_ splits: [Split]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Splits")
                .font(.headline)
            
            ForEach(splits) { split in
                HStack {
                    Text(String(format: "%.1f km", split.distance / 1000.0))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(formatDuration(split.duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(formatPace(split.pace))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var analysisButton: some View {
        Button(action: {
            analyzeRun()
        }) {
            HStack {
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
                Text(isAnalyzing ? "Analyzing..." : "Analyze Run")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isAnalyzing)
    }
    
    private func analysisResultsSection(_ analyzedRun: AnalyzedRun) -> some View {
        VStack(spacing: 16) {
            // PPI Score
            VStack(spacing: 8) {
                Text("Personal Performance Index")
                    .font(.headline)
                
                Text(String(format: "%.0f", analyzedRun.ppi))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Recommendation
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommendation")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Difficulty:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(analyzedRun.recommendation.difficulty.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(analyzedRun.recommendation.difficulty.color))
                    }
                    
                    HStack {
                        Text("Target Pace:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(formatPace(analyzedRun.recommendation.targetPace))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Projected Gain:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("+\(String(format: "%.0f", analyzedRun.recommendation.projectedGain)) PPI")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func analyzeRun() {
        isAnalyzing = true
        
        Task {
            do {
                let analysis = try analysisService.analyzeRun(run)
                
                await MainActor.run {
                    self.analyzedRun = analysis
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.isAnalyzing = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
}

#Preview {
    let sampleRun = RunRecord(
        distance: 5940,
        duration: 2498,
        averagePace: 420,
        splits: [
            Split(distance: 1000, duration: 420, pace: 420),
            Split(distance: 1000, duration: 415, pace: 415),
            Split(distance: 1000, duration: 425, pace: 425)
        ],
        source: "gpx",
        fileName: "sample_run.gpx"
    )
    
    RunDetailView(run: sampleRun)
        .environment(AnalysisViewModel())
}
