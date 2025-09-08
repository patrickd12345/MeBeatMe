import SwiftUI

/// View for displaying run analysis results
struct AnalysisView: View {
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let analysis = analysisViewModel.analyzedRun {
                        // PPI Score section
                        ppiScoreSection(analysis)
                        
                        // Performance metrics
                        performanceMetricsSection(analysis)
                        
                        // Recommendations
                        recommendationsSection(analysis)
                        
                        // Performance insights
                        performanceInsightsSection
                        
                        // Improvement suggestions
                        improvementSuggestionsSection
                        
                        // Target for next run
                        targetSection
                    } else if analysisViewModel.isAnalyzing {
                        // Analysis progress
                        analysisProgressSection
                    } else {
                        // No analysis state
                        noAnalysisSection
                    }
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
            .alert("Error", isPresented: .constant(analysisViewModel.errorMessage != nil)) {
                Button("OK") {
                    analysisViewModel.errorMessage = nil
                }
            } message: {
                Text(analysisViewModel.errorMessage ?? "")
            }
        }
    }
    
    private func ppiScoreSection(_ analysis: RunAnalysis) -> some View {
        VStack(spacing: 16) {
            Text("PPI Score")
                .font(.headline)
            
            Text(Units.formatPPI(analysis.ppi))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("points")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(analysis.performanceLevel.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            Text(performanceLevelDescription(analysis.performanceLevel))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func performanceMetricsSection(_ analysis: RunAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
            
            VStack(spacing: 12) {
                metricRow(
                    title: "Distance",
                    value: Units.formatDistance(analysis.run.distance),
                    icon: "figure.run"
                )
                
                metricRow(
                    title: "Duration",
                    value: Units.formatTime(analysis.run.duration),
                    icon: "clock"
                )
                
                metricRow(
                    title: "Average Pace",
                    value: Units.formatPace(analysis.run.averagePace),
                    icon: "speedometer"
                )
                
                if let elevationGain = analysis.run.elevationGain, elevationGain > 0 {
                    metricRow(
                        title: "Elevation Gain",
                        value: String(format: "%.0f m", elevationGain),
                        icon: "mountain.2"
                    )
                }
                
                if let heartRateData = analysis.run.heartRateData, !heartRateData.isEmpty {
                    let avgHeartRate = heartRateData.map { $0.heartRate }.reduce(0, +) / heartRateData.count
                    metricRow(
                        title: "Avg Heart Rate",
                        value: "\(avgHeartRate) bpm",
                        icon: "heart.fill"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func metricRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func recommendationsSection(_ analysis: RunAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations")
                .font(.headline)
            
            if analysis.recommendations.isEmpty {
                Text("No specific recommendations at this time.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    // High priority recommendations
                    if !analysisViewModel.highPriorityRecommendations.isEmpty {
                        recommendationGroup(
                            title: "High Priority",
                            recommendations: analysisViewModel.highPriorityRecommendations,
                            color: .red
                        )
                    }
                    
                    // Medium priority recommendations
                    if !analysisViewModel.mediumPriorityRecommendations.isEmpty {
                        recommendationGroup(
                            title: "Medium Priority",
                            recommendations: analysisViewModel.mediumPriorityRecommendations,
                            color: .orange
                        )
                    }
                    
                    // Low priority recommendations
                    if !analysisViewModel.lowPriorityRecommendations.isEmpty {
                        recommendationGroup(
                            title: "Low Priority",
                            recommendations: analysisViewModel.lowPriorityRecommendations,
                            color: .green
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func recommendationGroup(title: String, recommendations: [Recommendation], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            ForEach(recommendations) { recommendation in
                recommendationRow(recommendation)
            }
        }
    }
    
    private func recommendationRow(_ recommendation: Recommendation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.typeIcon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var performanceInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Insights")
                .font(.headline)
            
            ForEach(analysisViewModel.performanceInsights, id: \.self) { insight in
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
    
    private var improvementSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Improvement Suggestions")
                .font(.headline)
            
            ForEach(analysisViewModel.improvementSuggestions, id: \.self) { suggestion in
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    Text(suggestion)
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Run Target")
                .font(.headline)
            
            if let targetPPI = analysisViewModel.targetPPIForNextRun,
               let requiredPace = analysisViewModel.requiredPaceForTarget {
                VStack(spacing: 12) {
                    HStack {
                        Text("Target PPI:")
                        Spacer()
                        Text(Units.formatPPI(targetPPI))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Required Pace:")
                        Spacer()
                        Text(Units.formatPace(requiredPace))
                            .fontWeight(.medium)
                    }
                    
                    Text("Aim for this pace to improve your PPI score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Complete more runs to get personalized targets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var analysisProgressSection: some View {
        VStack(spacing: 16) {
            ProgressView(value: analysisViewModel.analysisProgress)
                .progressViewStyle(LinearProgressViewStyle())
            
            Text(analysisViewModel.analysisStatus)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var noAnalysisSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Analysis Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Import and analyze a run to see detailed performance insights")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func performanceLevelDescription(_ level: PerformanceLevel) -> String {
        switch level {
        case .beginner:
            return "Building base fitness"
        case .intermediate:
            return "Developing consistency"
        case .advanced:
            return "Competitive performance"
        case .elite:
            return "World-class performance"
        }
    }
}

#Preview {
    AnalysisView()
        .environment(AnalysisViewModel())
}
