import Foundation
import Observation
import os
import UniformTypeIdentifiers

/// ViewModel for the import flow
@Observable
class ImportViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "ImportViewModel")
    private let fileImportCoordinator = FileImportCoordinator()
    private let runStore = RunStore()
    private let analysisService = AnalysisService()
    
    var isImporting = false
    var errorMessage: String?
    var importedRun: RunRecord?
    var analysisResult: RunAnalysis?
    var importProgress: Double = 0.0
    var importStatus: String = ""
    var showingDocumentPicker = false
    var showingShareSheet = false
    
    /// Imports a file and creates a RunRecord
    func importFile(from url: URL) {
        logger.info("Starting file import from: \(url.lastPathComponent)")
        
        isImporting = true
        errorMessage = nil
        importedRun = nil
        analysisResult = nil
        importProgress = 0.0
        importStatus = "Starting import..."
        
        Task {
            do {
                // Step 1: Validate file
                await updateProgress(0.2, status: "Validating file...")
                
                guard fileImportCoordinator.canImportFile(at: url) else {
                    throw AppError.unsupportedFormat(url.pathExtension)
                }
                
                // Step 2: Parse file
                await updateProgress(0.4, status: "Parsing file...")
                
                let runRecord = try await fileImportCoordinator.importFile(from: url)
                
                await MainActor.run {
                    self.importedRun = runRecord
                }
                
                // Step 3: Analyze run
                await updateProgress(0.7, status: "Analyzing run...")
                
                let analysis = analysisService.analyzeRun(runRecord)
                
                await MainActor.run {
                    self.analysisResult = analysis
                    self.importProgress = 1.0
                    self.importStatus = "Import complete!"
                    self.isImporting = false
                }
                
                AppLogger.logUserAction("file_imported", parameters: [
                    "file_name": runRecord.fileName,
                    "file_type": runRecord.source,
                    "distance": runRecord.distance,
                    "duration": runRecord.duration,
                    "ppi": analysis.ppi
                ])
                
                logger.info("Successfully imported file: \(runRecord.fileName)")
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
                    self.isImporting = false
                    self.importStatus = "Import failed"
                }
                
                AppLogger.logError(error, context: "Failed to import file")
            }
        }
    }
    
    /// Saves the imported run to storage
    func saveImportedRun() throws {
        guard let run = importedRun else {
            throw AppError.storageError("No imported run to save")
        }
        
        logger.info("Saving imported run: \(run.fileName)")
        
        try runStore.saveRun(run)
        
        AppLogger.logUserAction("run_saved", parameters: [
            "file_name": run.fileName,
            "distance": run.distance,
            "duration": run.duration
        ])
        
        logger.info("Successfully saved run: \(run.fileName)")
    }
    
    /// Checks if a file can be imported
    func canImportFile(at url: URL) -> Bool {
        return fileImportCoordinator.canImportFile(at: url)
    }
    
    /// Gets supported file formats
    func supportedFileFormats() -> [FileImportCoordinator.SupportedFormat] {
        return FileImportCoordinator.SupportedFormat.allCases
    }
    
    /// Gets supported UTTypes for document picker
    func supportedUTTypes() -> [UTType] {
        return fileImportCoordinator.supportedUTTypes()
    }
    
    /// Gets file size for display
    func getFileSize(for url: URL) -> String {
        guard let size = Files.fileSize(at: url) else {
            return "Unknown size"
        }
        return Files.formatFileSize(size)
    }
    
    /// Gets file modification date
    func getFileDate(for url: URL) -> String {
        guard let date = Files.modificationDate(at: url) else {
            return "Unknown date"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Validates file before import
    func validateFile(at url: URL) -> (isValid: Bool, errorMessage: String?) {
        return fileImportCoordinator.validateFile(at: url)
    }
    
    /// Resets the import state
    func reset() {
        isImporting = false
        errorMessage = nil
        importedRun = nil
        analysisResult = nil
        importProgress = 0.0
        importStatus = ""
    }
    
    /// Updates import progress
    private func updateProgress(_ progress: Double, status: String) async {
        await MainActor.run {
            self.importProgress = progress
            self.importStatus = status
        }
    }
    
    /// Gets import summary for display
    var importSummary: String? {
        guard let run = importedRun else { return nil }
        
        let distance = Units.formatDistance(run.distance)
        let duration = Units.formatTime(run.duration)
        let pace = Units.formatPace(run.averagePace)
        
        return "\(distance) in \(duration) (\(pace))"
    }
    
    /// Gets analysis summary for display
    var analysisSummary: String? {
        guard let analysis = analysisResult else { return nil }
        
        let ppi = Units.formatPPI(analysis.ppi)
        let level = analysis.performanceLevel.rawValue
        
        return "\(ppi) PPI (\(level))"
    }
    
    /// Gets recommendation count by priority
    var recommendationCounts: (high: Int, medium: Int, low: Int) {
        guard let analysis = analysisResult else { return (0, 0, 0) }
        
        let high = analysis.recommendations.filter { $0.priority == .high }.count
        let medium = analysis.recommendations.filter { $0.priority == .medium }.count
        let low = analysis.recommendations.filter { $0.priority == .low }.count
        
        return (high, medium, low)
    }
    
    /// Shows document picker
    func showDocumentPicker() {
        showingDocumentPicker = true
        AppLogger.logUserAction("document_picker_opened")
    }
    
    /// Shows share sheet
    func showShareSheet() {
        showingShareSheet = true
        AppLogger.logUserAction("share_sheet_opened")
    }
    
    /// Handles document picker result
    func handleDocumentPickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                importFile(from: url)
            }
        case .failure(let error):
            errorMessage = ErrorHandler.userFriendlyMessage(for: error)
            AppLogger.logError(error, context: "Document picker failed")
        }
    }
    
    /// Handles share sheet result
    func handleShareSheetResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            importFile(from: url)
        case .failure(let error):
            errorMessage = ErrorHandler.userFriendlyMessage(for: error)
            AppLogger.logError(error, context: "Share sheet failed")
        }
    }
    
    /// Gets maximum file size for display
    var maxFileSize: String {
        return Files.formatFileSize(AppConfig.maxFileSizeBytes)
    }
    
    /// Gets supported file extensions for display
    var supportedFileExtensions: [String] {
        return AppConfig.supportedFileExtensions.map { $0.uppercased() }
    }
}
