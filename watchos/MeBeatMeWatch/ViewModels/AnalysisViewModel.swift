import Foundation
import Observation
import os

/// ViewModel for run analysis
@Observable
class AnalysisViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "AnalysisViewModel")
    private let analysisService = AnalysisService()
    
    var analyzedRun: AnalyzedRun?
    var isAnalyzing = false
    var errorMessage: String?
    
    /// Analyzes a run record
    func analyzeRun(_ runRecord: RunRecord) {
        logger.info("Starting analysis for run: \(runRecord.fileName)")
        
        isAnalyzing = true
        errorMessage = nil
        analyzedRun = nil
        
        Task {
            do {
                let analysis = try analysisService.analyzeRun(runRecord)
                
                await MainActor.run {
                    self.analyzedRun = analysis
                    self.isAnalyzing = false
                }
                
                logger.info("Analysis complete for run: \(runRecord.fileName)")
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isAnalyzing = false
                }
                
                logger.error("Failed to analyze run: \(error.localizedDescription)")
            }
        }
    }
    
    /// Formats PPI for display
    func formatPPI(_ ppi: Double) -> String {
        return String(format: "%.0f", ppi)
    }
    
    /// Formats pace for display
    func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Gets the color for a difficulty level
    func colorForDifficulty(_ difficulty: Recommendation.Difficulty) -> String {
        return difficulty.color
    }
    
    /// Resets the analysis state
    func reset() {
        analyzedRun = nil
        isAnalyzing = false
        errorMessage = nil
    }
}
