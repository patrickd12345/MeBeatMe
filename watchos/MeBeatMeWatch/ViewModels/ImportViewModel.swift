import Foundation
import Observation
import os

/// ViewModel for the import flow
@Observable
class ImportViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "ImportViewModel")
    private let fileImportCoordinator = FileImportCoordinator()
    private let runStore = RunStore()
    private let analysisService = AnalysisService()
    
    var isImporting = false
    var errorMessage: String?
    var importedRun: RunRecord?
    var analysisResult: RunAnalysis?
    var importProgress: Double = 0.0
    var importStatus: String = ""
    
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
        // Check if file exists
        guard Files.fileExists(at: url) else {
            return (false, "File not found")
        }
        
        // Check file extension
        guard canImportFile(at: url) else {
            return (false, "Unsupported file format. Please use GPX or TCX files.")
        }
        
        // Check file size (max 10MB)
        if let size = Files.fileSize(at: url), size > 10 * 1024 * 1024 {
            return (false, "File too large. Maximum size is 10MB.")
        }
        
        return (true, nil)
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
}
