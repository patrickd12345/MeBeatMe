import SwiftUI

/// View for displaying detailed run information
struct RunDetailView: View {
    let run: RunRecord
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @State private var showingAnalysis = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Basic metrics
                basicMetricsSection
                
                // Splits (if available)
                if let splits = run.splits, !splits.isEmpty {
                    splitsSection(splits)
                }
                
                // Heart rate data (if available)
                if let heartRateData = run.heartRateData, !heartRateData.isEmpty {
                    heartRateSection(heartRateData)
                }
                
                // Additional data
                additionalDataSection
                
                // Analysis button
                analysisButton
            }
            .padding()
        }
        .navigationTitle("Run Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingAnalysis) {
            AnalysisView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(run.fileName)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(formatDate(run.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var basicMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Run Metrics")
                .font(.headline)
            
            VStack(spacing: 12) {
                metricRow(
                    title: "Distance",
                    value: Units.formatDistance(run.distance),
                    icon: "figure.run"
                )
                
                metricRow(
                    title: "Duration",
                    value: Units.formatTime(run.duration),
                    icon: "clock"
                )
                
                metricRow(
                    title: "Average Pace",
                    value: Units.formatPace(run.averagePace),
                    icon: "speedometer"
                )
                
                metricRow(
                    title: "Source",
                    value: run.source.uppercased(),
                    icon: "doc.text"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func splitsSection(_ splits: [Split]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Splits")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(splits) { split in
                    splitRow(split)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func splitRow(_ split: Split) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(split.formattedDistance)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let heartRate = split.averageHeartRate {
                    Text("\(heartRate) bpm avg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(split.formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(split.formattedPace)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func heartRateSection(_ heartRateData: [HeartRatePoint]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate")
                .font(.headline)
            
            let avgHeartRate = heartRateData.map { $0.heartRate }.reduce(0, +) / heartRateData.count
            let maxHeartRate = heartRateData.map { $0.heartRate }.max() ?? 0
            let minHeartRate = heartRateData.map { $0.heartRate }.min() ?? 0
            
            VStack(spacing: 12) {
                metricRow(
                    title: "Average",
                    value: "\(avgHeartRate) bpm",
                    icon: "heart.fill"
                )
                
                metricRow(
                    title: "Maximum",
                    value: "\(maxHeartRate) bpm",
                    icon: "heart.fill"
                )
                
                metricRow(
                    title: "Minimum",
                    value: "\(minHeartRate) bpm",
                    icon: "heart.fill"
                )
                
                metricRow(
                    title: "Data Points",
                    value: "\(heartRateData.count)",
                    icon: "waveform.path.ecg"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var additionalDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Data")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let elevationGain = run.elevationGain, elevationGain > 0 {
                    metricRow(
                        title: "Elevation Gain",
                        value: String(format: "%.0f m", elevationGain),
                        icon: "mountain.2"
                    )
                }
                
                if let temperature = run.temperature {
                    metricRow(
                        title: "Temperature",
                        value: String(format: "%.1f°C", temperature),
                        icon: "thermometer"
                    )
                }
                
                metricRow(
                    title: "File Size",
                    value: "N/A", // Would need to calculate from original file
                    icon: "doc"
                )
                
                metricRow(
                    title: "Import Date",
                    value: formatDate(run.date),
                    icon: "calendar"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var analysisButton: some View {
        Button(action: {
            analyzeRun()
        }) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Analyze Run")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func analyzeRun() {
        analysisViewModel.analyzeRun(run)
        showingAnalysis = true
    }
}

#Preview {
    NavigationStack {
        RunDetailView(run: RunRecord(
            distance: 5000,
            duration: 1800,
            averagePace: 360,
            source: "gpx",
            fileName: "sample_5k.gpx"
        ))
    }
    .environment(AnalysisViewModel())
}
