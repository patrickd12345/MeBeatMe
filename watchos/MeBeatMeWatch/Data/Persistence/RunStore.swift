import Foundation
import os

/// Manages persistence of run records and bests using JSON files
class RunStore {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "RunStore")
    private let fileManager = FileManager.default
    private let kmpBridge = KMPBridge()
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var runsFileURL: URL {
        documentsDirectory.appendingPathComponent("runs.json")
    }
    
    private var bestsFileURL: URL {
        documentsDirectory.appendingPathComponent("bests.json")
    }
    
    /// Loads all run records from storage
    func loadRuns() -> [RunRecord] {
        logger.info("Loading runs from storage")
        
        guard fileManager.fileExists(atPath: runsFileURL.path) else {
            logger.info("No runs file found, returning empty array")
            return []
        }
        
        do {
            let data = try Data(contentsOf: runsFileURL)
            let runs = try JSONDecoder().decode([RunRecord].self, from: data)
            logger.info("Loaded \(runs.count) runs from storage")
            return runs
        } catch {
            logger.error("Failed to load runs: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Saves a run record to storage (append-only)
    func saveRun(_ run: RunRecord) throws {
        logger.info("Saving run: \(run.fileName)")
        
        var runs = loadRuns()
        runs.append(run)
        
        try saveRuns(runs)
        
        // Update bests after saving run
        try updateBests(with: run)
    }
    
    /// Saves all run records to storage
    private func saveRuns(_ runs: [RunRecord]) throws {
        let data = try JSONEncoder().encode(runs)
        try data.write(to: runsFileURL)
        logger.info("Saved \(runs.count) runs to storage")
    }
    
    /// Loads bests from storage
    func loadBests() -> Bests {
        logger.info("Loading bests from storage")
        
        guard fileManager.fileExists(atPath: bestsFileURL.path) else {
            logger.info("No bests file found, returning empty bests")
            return Bests()
        }
        
        do {
            let data = try Data(contentsOf: bestsFileURL)
            let bests = try JSONDecoder().decode(Bests.self, from: data)
            logger.info("Loaded bests from storage")
            return bests
        } catch {
            logger.error("Failed to load bests: \(error.localizedDescription)")
            return Bests()
        }
    }
    
    /// Updates bests with a new run and calculates 90-day highest PPI
    private func updateBests(with run: RunRecord) throws {
        logger.info("Updating bests with run: \(run.fileName)")
        
        var bests = loadBests()
        
        // Update distance-based bests
        bests.updateBestTime(for: run.distance, time: run.duration)
        
        // Calculate 90-day highest PPI using KMP bridge
        let runs90Days = runsInLast90Days()
        let highestPPI = calculateHighestPPI(in: runs90Days)
        bests.highestPPILast90Days = highestPPI
        
        // Save updated bests
        let data = try JSONEncoder().encode(bests)
        try data.write(to: bestsFileURL)
        
        logger.info("Updated bests - highest PPI last 90 days: \(highestPPI ?? 0)")
    }
    
    /// Returns runs from the last 90 days
    private func runsInLast90Days() -> [RunRecord] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        
        return loadRuns().filter { run in
            run.date >= cutoffDate
        }
    }
    
    /// Calculates the highest PPI from the given runs using KMP bridge
    private func calculateHighestPPI(in runs: [RunRecord]) -> Double? {
        guard !runs.isEmpty else { return nil }
        
        var highestPPI: Double = 0
        
        for run in runs {
            // Use KMP bridge to calculate PPI
            let ppi = kmpBridge.calculatePPI(distance: run.distance, duration: run.duration)
            highestPPI = max(highestPPI, ppi)
        }
        
        return highestPPI
    }
    
    /// Gets the highest PPI from the last 90 days
    func getHighestPPILast90Days() -> Double? {
        let runs90Days = runsInLast90Days()
        return calculateHighestPPI(in: runs90Days)
    }
    
    /// Gets recent runs (last 10)
    func getRecentRuns(limit: Int = 10) -> [RunRecord] {
        let allRuns = loadRuns()
        return Array(allRuns.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    /// Gets runs for a specific date range
    func getRuns(from startDate: Date, to endDate: Date) -> [RunRecord] {
        let allRuns = loadRuns()
        return allRuns.filter { run in
            run.date >= startDate && run.date <= endDate
        }
    }
    
    /// Clears all stored data (for testing)
    func clearAll() throws {
        logger.info("Clearing all stored data")
        
        if fileManager.fileExists(atPath: runsFileURL.path) {
            try fileManager.removeItem(at: runsFileURL)
        }
        
        if fileManager.fileExists(atPath: bestsFileURL.path) {
            try fileManager.removeItem(at: bestsFileURL)
        }
        
        logger.info("Cleared all stored data")
    }
}
