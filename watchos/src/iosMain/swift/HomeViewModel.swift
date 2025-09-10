import Foundation
import Observation
import os

/// ViewModel for the home screen
@Observable
class HomeViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "HomeViewModel")
    private let runStore = RunStore()
    private let analysisService = AnalysisService()
    
    var runs: [RunRecord] = []
    var bests: Bests = Bests()
    var isLoading = false
    var errorMessage: String?
    var lastRefreshDate: Date?
    
    init() {
        loadData()
    }
    
    /// Loads runs and bests from storage
    func loadData() {
        logger.info("Loading home data")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedRuns = runStore.list()
                let loadedBests = runStore.bests()
                
                // Convert Run to RunRecord
                let convertedRuns = loadedRuns.map { run in
                    RunRecord(
                        id: run.id,
                        date: run.startedAt,
                        distance: run.distanceM,
                        duration: run.elapsedSec,
                        averagePace: run.avgPaceSecPerKm,
                        splits: nil,
                        source: run.source,
                        fileName: "\(run.id).\(run.source)",
                        heartRateData: nil,
                        elevationGain: nil,
                        temperature: nil
                    )
                }
                
                await MainActor.run {
                    self.runs = convertedRuns.sorted { $0.date > $1.date }
                    self.bests = loadedBests
                    self.isLoading = false
                    self.lastRefreshDate = Date()
                }
                
                AppLogger.logUserAction("home_data_loaded", parameters: [
                    "runs_count": convertedRuns.count,
                    "highest_ppi": loadedBests.highestPPILast90Days ?? 0
                ])
                
                logger.info("Loaded \(convertedRuns.count) runs and bests")
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
                    self.isLoading = false
                }
                
                AppLogger.logError(error, context: "Failed to load home data")
            }
        }
    }
    
    /// Refreshes the data
    func refresh() {
        AppLogger.logUserAction("home_refresh")
        loadData()
    }
    
    /// Gets recent runs (last 5)
    var recentRuns: [RunRecord] {
        return Array(runs.prefix(5))
    }
    
    /// Gets the highest PPI from the last 90 days
    var highestPPILast90Days: Double? {
        return bests.highestPPILast90Days
    }
    
    /// Gets performance level for highest PPI
    var performanceLevel: PerformanceLevel {
        guard let ppi = highestPPILast90Days else { return .beginner }
        
        switch ppi {
        case 0..<200:
            return .beginner
        case 200..<350:
            return .intermediate
        case 350..<500:
            return .advanced
        default:
            return .elite
        }
    }
    
    /// Gets total runs count
    var totalRunsCount: Int {
        return runs.count
    }
    
    /// Gets total distance in kilometers
    var totalDistanceKm: Double {
        return runs.reduce(0) { $0 + $1.distance } / 1000.0
    }
    
    /// Gets average pace across all runs
    var averagePace: Double? {
        guard !runs.isEmpty else { return nil }
        let totalPace = runs.reduce(0) { $0 + $1.averagePace }
        return totalPace / Double(runs.count)
    }
    
    /// Gets runs from last 7 days
    var runsLast7Days: [RunRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return runs.filter { $0.date >= sevenDaysAgo }
    }
    
    /// Gets runs from last 30 days
    var runsLast30Days: [RunRecord] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return runs.filter { $0.date >= thirtyDaysAgo }
    }
    
    /// Checks if user has any runs
    var hasRuns: Bool {
        return !runs.isEmpty
    }
    
    /// Gets the most recent run
    var mostRecentRun: RunRecord? {
        return runs.first
    }
    
    /// Gets the best run by PPI
    var bestRunByPPI: RunRecord? {
        return runs.max { run1, run2 in
            let ppi1 = analysisService.analyzeRun(run1).ppi
            let ppi2 = analysisService.analyzeRun(run2).ppi
            return ppi1 < ppi2
        }
    }
    
    /// Formats PPI for display
    func formatPPI(_ ppi: Double?) -> String {
        guard let ppi = ppi else { return "N/A" }
        return Units.formatPPI(ppi)
    }
    
    /// Formats pace for display
    func formatPace(_ pace: Double) -> String {
        return Units.formatPace(pace)
    }
    
    /// Formats duration for display
    func formatDuration(_ duration: Int) -> String {
        return Units.formatTime(duration)
    }
    
    /// Formats distance for display
    func formatDistance(_ distance: Double) -> String {
        return Units.formatDistance(distance)
    }
    
    /// Formats date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Formats relative date (e.g., "2 days ago")
    func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// Gets motivation message based on performance
    var motivationMessage: String {
        switch performanceLevel {
        case .beginner:
            return "Keep building your base fitness! Every run counts."
        case .intermediate:
            return "Great consistency! You're developing strong habits."
        case .advanced:
            return "Excellent performance! You're reaching competitive levels."
        case .elite:
            return "Outstanding! You're performing at world-class levels."
        }
    }
    
    /// Gets next goal suggestion
    var nextGoalSuggestion: String {
        guard let highestPPI = highestPPILast90Days else {
            return "Complete your first run to get a PPI score!"
        }
        
        let nextTarget = highestPPI + 10
        return "Try to reach \(Int(nextTarget)) PPI on your next run!"
    }
}
