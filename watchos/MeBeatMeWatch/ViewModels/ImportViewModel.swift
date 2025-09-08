import Foundation
import Observation
import os

/// ViewModel for the import flow
@Observable
class ImportViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "ImportViewModel")
    private let fileImportCoordinator = FileImportCoordinator()
    private let runStore = RunStore()
    
    var isImporting = false
    var errorMessage: String?
    var importedRun: RunRecord?
    
    /// Imports a file and creates a RunRecord
    func importFile(from url: URL) {
        logger.info("Starting file import from: \(url.lastPathComponent)")
        
        isImporting = true
        errorMessage = nil
        importedRun = nil
        
        Task {
            do {
                let runRecord = try await fileImportCoordinator.importFile(from: url)
                
                await MainActor.run {
                    self.importedRun = runRecord
                    self.isImporting = false
                }
                
                logger.info("Successfully imported file: \(runRecord.fileName)")
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isImporting = false
                }
                
                logger.error("Failed to import file: \(error.localizedDescription)")
            }
        }
    }
    
    /// Saves the imported run to storage
    func saveImportedRun() throws {
        guard let run = importedRun else {
            throw AppError.ioFailure("No imported run to save")
        }
        
        logger.info("Saving imported run: \(run.fileName)")
        
        try runStore.saveRun(run)
        
        logger.info("Successfully saved run: \(run.fileName)")
    }
    
    /// Checks if a file can be imported
    func canImportFile(at url: URL) -> Bool {
        return fileImportCoordinator.canImportFile(at: url)
    }
    
    /// Resets the import state
    func reset() {
        isImporting = false
        errorMessage = nil
        importedRun = nil
    }
}
