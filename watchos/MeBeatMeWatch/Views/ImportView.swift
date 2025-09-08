import SwiftUI

/// View for importing race files
struct ImportView: View {
    @Environment(ImportViewModel.self) private var importViewModel
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingAnalysis = false
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // File picker section
                    filePickerSection
                    
                    // Import progress
                    if importViewModel.isImporting {
                        importProgressSection
                    }
                    
                    // Error message
                    if let errorMessage = importViewModel.errorMessage {
                        errorSection(errorMessage)
                    }
                    
                    // Imported run preview
                    if let importedRun = importViewModel.importedRun {
                        importedRunSection(importedRun)
                    }
                    
                    // Analysis results
                    if let analysisResult = importViewModel.analysisResult {
                        analysisResultsSection(analysisResult)
                    }
                    
                    // Supported formats info
                    supportedFormatsSection
                }
                .padding()
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if importViewModel.importedRun != nil {
                        Button("Reset") {
                            importViewModel.reset()
                        }
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
            .alert("Save Run", isPresented: $showingSaveConfirmation) {
                Button("Save") {
                    saveImportedRun()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Save this run to your collection?")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Import Race File")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select a GPX or TCX file to analyze your run performance")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var filePickerSection: some View {
        VStack(spacing: 12) {
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
            
            Text("Maximum file size: \(importViewModel.maxFileSize)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var importProgressSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: importViewModel.importProgress)
                .progressViewStyle(LinearProgressViewStyle())
            
            Text(importViewModel.importStatus)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func errorSection(_ errorMessage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func importedRunSection(_ run: RunRecord) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("File Imported Successfully!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            runPreview(run)
            
            if let analysisResult = importViewModel.analysisResult {
                analysisPreview(analysisResult)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    analyzeRun(run)
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Analyze")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showingSaveConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func analysisResultsSection(_ analysis: RunAnalysis) -> some View {
        VStack(spacing: 12) {
            Text("Analysis Complete")
                .font(.headline)
                .foregroundColor(.green)
            
            HStack {
                VStack {
                    Text("PPI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(Units.formatPPI(analysis.ppi))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(analysis.performanceLevel.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack {
                    Text("Recommendations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(analysis.recommendations.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var supportedFormatsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Supported Formats")
                .font(.headline)
            
            ForEach(importViewModel.supportedFileFormats(), id: \.self) { format in
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text(format.displayName)
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func runPreview(_ run: RunRecord) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Distance:")
                Spacer()
                Text(Units.formatDistance(run.distance))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Duration:")
                Spacer()
                Text(Units.formatTime(run.duration))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Pace:")
                Spacer()
                Text(Units.formatPace(run.averagePace))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Source:")
                Spacer()
                Text(run.source.uppercased())
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("File:")
                Spacer()
                Text(run.fileName)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
        .font(.subheadline)
    }
    
    private func analysisPreview(_ analysis: RunAnalysis) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("PPI Score:")
                Spacer()
                Text(Units.formatPPI(analysis.ppi))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Performance Level:")
                Spacer()
                Text(analysis.performanceLevel.rawValue)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Recommendations:")
                Spacer()
                Text("\(analysis.recommendations.count)")
                    .fontWeight(.medium)
            }
        }
        .font(.subheadline)
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                // Validate file before importing
                let validation = importViewModel.validateFile(at: url)
                if validation.isValid {
                    importViewModel.importFile(from: url)
                } else {
                    importViewModel.errorMessage = validation.errorMessage
                }
            }
        case .failure(let error):
            importViewModel.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
        }
    }
    
    private func analyzeRun(_ run: RunRecord) {
        analysisViewModel.analyzeRun(run)
        showingAnalysis = true
    }
    
    private func saveImportedRun() {
        do {
            try importViewModel.saveImportedRun()
            AppLogger.logUserAction("run_saved_from_import")
            dismiss()
        } catch {
            importViewModel.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
        }
    }
}

#Preview {
    ImportView()
        .environment(ImportViewModel())
        .environment(AnalysisViewModel())
}
