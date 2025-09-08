import SwiftUI

/// View for displaying run analysis results
struct AnalysisView: View {
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @Environment(ImportViewModel.self) private var importViewModel
    @Environment(\.dismiss) private var dismiss
    
    let analyzedRun: AnalyzedRun
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // PPI Score
                    ppiSection
                    
                    // Run Details
                    runDetailsSection
                    
                    // Recommendation
                    recommendationSection
                    
                    // Save button
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Save Run", isPresented: $showingSaveConfirmation) {
                Button("Save") {
                    saveRun()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Save this run to your collection?")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("📊")
                .font(.system(size: 40))
            
            Text("Run Analysis Complete")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var ppiSection: some View {
        VStack(spacing: 12) {
            Text("Personal Performance Index")
                .font(.headline)
            
            Text(analysisViewModel.formatPPI(analyzedRun.ppi))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("points")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // PPI interpretation
            Text(ppiInterpretation(analyzedRun.ppi))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var runDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Run Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                detailRow(title: "Distance", value: String(format: "%.2f km", analyzedRun.runRecord.distance / 1000.0))
                detailRow(title: "Duration", value: formatDuration(analyzedRun.runRecord.duration))
                detailRow(title: "Average Pace", value: formatPace(analyzedRun.runRecord.averagePace))
                detailRow(title: "Source", value: analyzedRun.runRecord.source.uppercased())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendation")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Difficulty indicator
                HStack {
                    Text("Difficulty:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(analyzedRun.recommendation.difficulty.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(analyzedRun.recommendation.difficulty.color))
                }
                
                // Target pace
                HStack {
                    Text("Target Pace:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(formatPace(analyzedRun.recommendation.targetPace))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // Projected gain
                HStack {
                    Text("Projected Gain:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("+\(String(format: "%.0f", analyzedRun.recommendation.projectedGain)) PPI")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                // Description
                Text(analyzedRun.recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var saveButton: some View {
        Button(action: {
            showingSaveConfirmation = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Save Run")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
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
    
    private func ppiInterpretation(_ ppi: Double) -> String {
        switch ppi {
        case 0..<200:
            return "Beginner level - great start!"
        case 200..<400:
            return "Recreational runner - keep improving!"
        case 400..<600:
            return "Good fitness level - well done!"
        case 600..<800:
            return "Strong performance - impressive!"
        case 800..<1000:
            return "Excellent performance - near elite!"
        default:
            return "Elite level - outstanding!"
        }
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
    
    private func saveRun() {
        do {
            try importViewModel.saveImportedRun()
            dismiss()
        } catch {
            // Handle error
        }
    }
}

#Preview {
    let sampleRun = RunRecord(
        distance: 5940,
        duration: 2498,
        averagePace: 420,
        source: "gpx",
        fileName: "sample.gpx"
    )
    
    let sampleAnalysis = AnalyzedRun(
        runRecord: sampleRun,
        ppi: 355,
        purdyScore: 355,
        recommendation: Recommendation(
            targetPace: 400,
            projectedGain: 25,
            description: "Moderate challenge: 20s/km faster for +25 PPI",
            difficulty: .moderate
        )
    )
    
    AnalysisView(analyzedRun: sampleAnalysis)
        .environment(AnalysisViewModel())
        .environment(ImportViewModel())
}
