import SwiftUI

/// View for importing race files
struct ImportView: View {
    @Environment(ImportViewModel.self) private var importViewModel
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingAnalysis = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Import Race File")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a GPX or TCX file to analyze your run")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // File picker button
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Choose File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(importViewModel.isImporting)
                
                // Import status
                if importViewModel.isImporting {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Importing...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Error message
                if let errorMessage = importViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Imported run preview
                if let importedRun = importViewModel.importedRun {
                    VStack(spacing: 12) {
                        Text("File Imported Successfully!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        runPreview(importedRun)
                        
                        Button(action: {
                            analyzeRun(importedRun)
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("Analyze Run")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.xml, .data],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .navigationDestination(isPresented: $showingAnalysis) {
                if let analyzedRun = analysisViewModel.analyzedRun {
                    AnalysisView(analyzedRun: analyzedRun)
                }
            }
        }
    }
    
    private func runPreview(_ run: RunRecord) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Distance:")
                Spacer()
                Text(String(format: "%.2f km", run.distance / 1000.0))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Duration:")
                Spacer()
                Text(formatDuration(run.duration))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Pace:")
                Spacer()
                Text(formatPace(run.averagePace))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Source:")
                Spacer()
                Text(run.source.uppercased())
                    .fontWeight(.medium)
            }
        }
        .font(.subheadline)
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                importViewModel.importFile(from: url)
            }
        case .failure(let error):
            importViewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func analyzeRun(_ run: RunRecord) {
        analysisViewModel.analyzeRun(run)
        showingAnalysis = true
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
    ImportView()
        .environment(ImportViewModel())
        .environment(AnalysisViewModel())
}
