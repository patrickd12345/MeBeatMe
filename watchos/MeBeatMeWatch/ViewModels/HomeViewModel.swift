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
                let loadedRuns = runStore.loadRuns()
                let loadedBests = runStore.loadBests()
                
                await MainActor.run {
                    self.runs = loadedRuns.sorted { $0.date > $1.date }
                    self.bests = loadedBests
                    self.isLoading = false
                }
                
                logger.info("Loaded \(loadedRuns.count) runs and bests")
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                    self.isLoading = false
                }
                
                logger.error("Failed to load data: \(error.localizedDescription)")
            }
        }
    }
    
    /// Refreshes the data
    func refresh() {
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
    
    /// Formats PPI for display
    func formatPPI(_ ppi: Double?) -> String {
        guard let ppi = ppi else { return "N/A" }
        return String(format: "%.0f", ppi)
    }
    
    /// Formats pace for display
    func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formats duration for display
    func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Formats distance for display
    func formatDistance(_ distance: Double) -> String {
        let distanceKm = distance / 1000.0
        return String(format: "%.2f km", distanceKm)
    }
    
    /// Formats date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
