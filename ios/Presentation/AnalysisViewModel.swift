import Foundation
import Observation
import os

/// ViewModel for run analysis
@Observable
class AnalysisViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "AnalysisViewModel")
    private let analysisService = AnalysisService()
    private let kmpBridge = KMPBridge()
    
    var analyzedRun: RunAnalysis?
    var isAnalyzing = false
    var errorMessage: String?
    var analysisProgress: Double = 0.0
    var analysisStatus: String = ""
    
    /// Analyzes a run record
    func analyzeRun(_ runRecord: RunRecord) {
        logger.info("Starting analysis for run: \(runRecord.fileName)")
        
        isAnalyzing = true
        errorMessage = nil
        analyzedRun = nil
        analysisProgress = 0.0
        analysisStatus = "Starting analysis..."
        
        Task {
            do {
                // Step 1: Calculate PPI
                await updateProgress(0.3, status: "Calculating PPI...")
                
                let ppi = kmpBridge.calculatePPI(distance: runRecord.distance, duration: runRecord.duration)
                
                // Step 2: Generate recommendations
                await updateProgress(0.6, status: "Generating recommendations...")
                
                let analysis = analysisService.analyzeRun(runRecord)
                
                await MainActor.run {
                    self.analyzedRun = analysis
                    self.analysisProgress = 1.0
                    self.analysisStatus = "Analysis complete!"
                    self.isAnalyzing = false
                }
                
                AppLogger.logUserAction("run_analyzed", parameters: [
                    "file_name": runRecord.fileName,
                    "distance": runRecord.distance,
                    "duration": runRecord.duration,
                    "ppi": analysis.ppi,
                    "recommendations_count": analysis.recommendations.count
                ])
                
                logger.info("Analysis complete for run: \(runRecord.fileName)")
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
                    self.isAnalyzing = false
                    self.analysisStatus = "Analysis failed"
                }
                
                AppLogger.logError(error, context: "Failed to analyze run")
            }
        }
    }
    
    /// Gets high priority recommendations
    var highPriorityRecommendations: [Recommendation] {
        return analyzedRun?.recommendations.filter { $0.priority == .high } ?? []
    }
    
    /// Gets medium priority recommendations
    var mediumPriorityRecommendations: [Recommendation] {
        return analyzedRun?.recommendations.filter { $0.priority == .medium } ?? []
    }
    
    /// Gets low priority recommendations
    var lowPriorityRecommendations: [Recommendation] {
        return analyzedRun?.recommendations.filter { $0.priority == .low } ?? []
    }
    
    /// Gets recommendations by type
    func recommendationsByType(_ type: Recommendation.RecommendationType) -> [Recommendation] {
        return analyzedRun?.recommendations.filter { $0.type == type } ?? []
    }
    
    /// Gets performance insights
    var performanceInsights: [String] {
        guard let analysis = analyzedRun else { return [] }
        
        var insights: [String] = []
        
        // PPI insight
        let ppi = analysis.ppi
        let level = analysis.performanceLevel
        insights.append("Your PPI of \(Units.formatPPI(ppi)) puts you in the \(level.rawValue) category")
        
        // Distance insight
        let distanceKm = analysis.run.distance / 1000.0
        let distanceCategory = analysis.metrics.distanceCategory
        insights.append("This \(String(format: "%.1f", distanceKm))km run is a \(distanceCategory.rawValue) distance")
        
        // Pace insight
        let paceCategory = analysis.metrics.paceCategory
        insights.append("Your pace of \(Units.formatPace(analysis.run.averagePace)) is \(paceCategory.rawValue) level")
        
        // Consistency insight
        if analysis.metrics.consistency > 0.8 {
            insights.append("Excellent pace consistency throughout the run")
        } else if analysis.metrics.consistency > 0.6 {
            insights.append("Good pace consistency with some variation")
        } else {
            insights.append("Consider working on pace consistency")
        }
        
        return insights
    }
    
    /// Gets improvement suggestions
    var improvementSuggestions: [String] {
        guard let analysis = analyzedRun else { return [] }
        
        var suggestions: [String] = []
        
        // Based on PPI level
        switch analysis.performanceLevel {
        case .beginner:
            suggestions.append("Focus on building aerobic base with easy runs")
            suggestions.append("Aim for consistency over speed")
        case .intermediate:
            suggestions.append("Add tempo runs to improve lactate threshold")
            suggestions.append("Include interval training for speed development")
        case .advanced:
            suggestions.append("Fine-tune training with specific pace work")
            suggestions.append("Consider race-specific preparation")
        case .elite:
            suggestions.append("Maintain current training load")
            suggestions.append("Focus on recovery and injury prevention")
        }
        
        // Based on recommendations
        for recommendation in highPriorityRecommendations {
            suggestions.append(recommendation.description)
        }
        
        return suggestions
    }
    
    /// Gets target PPI for next run
    var targetPPIForNextRun: Double? {
        guard let currentPPI = analyzedRun?.ppi else { return nil }
        return currentPPI + 10 // Aim for 10 point improvement
    }
    
    /// Gets required pace for target PPI
    var requiredPaceForTarget: Double? {
        guard let targetPPI = targetPPIForNextRun,
              let run = analyzedRun?.run else { return nil }
        
        return kmpBridge.calculateRequiredPace(for: targetPPI, distance: run.distance)
    }
    
    /// Formats PPI for display
    func formatPPI(_ ppi: Double) -> String {
        return Units.formatPPI(ppi)
    }
    
    /// Formats pace for display
    func formatPace(_ pace: Double) -> String {
        return Units.formatPace(pace)
    }
    
    /// Gets the color for a priority level
    func colorForPriority(_ priority: Recommendation.RecommendationPriority) -> String {
        return priority.priorityColor
    }
    
    /// Gets the icon for a recommendation type
    func iconForType(_ type: Recommendation.RecommendationType) -> String {
        return type.typeIcon
    }
    
    /// Resets the analysis state
    func reset() {
        analyzedRun = nil
        isAnalyzing = false
        errorMessage = nil
        analysisProgress = 0.0
        analysisStatus = ""
    }
    
    /// Updates analysis progress
    private func updateProgress(_ progress: Double, status: String) async {
        await MainActor.run {
            self.analysisProgress = progress
            self.analysisStatus = status
        }
    }
    
    /// Gets analysis summary
    var analysisSummary: String? {
        guard let analysis = analyzedRun else { return nil }
        
        let ppi = Units.formatPPI(analysis.ppi)
        let level = analysis.performanceLevel.rawValue
        let recommendationsCount = analysis.recommendations.count
        
        return "\(ppi) PPI (\(level)) • \(recommendationsCount) recommendations"
    }
    
    /// Checks if analysis is complete
    var isAnalysisComplete: Bool {
        return analyzedRun != nil && !isAnalyzing
    }
    
    /// Gets performance trend (placeholder for future implementation)
    var performanceTrend: String {
        // This would compare with previous runs
        return "Improving" // Placeholder
    }
}
