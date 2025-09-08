import Foundation
import os

/// Manages persistence of run records and bests using JSON files
class RunStore {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "RunStore")
    private let fileManager = FileManager.default
    private let kmpBridge = KMPBridge()
    
    // MARK: - File URLs
    
    private var applicationSupportDirectory: URL {
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    
    private var runsFileURL: URL {
        applicationSupportDirectory.appendingPathComponent("runs.json")
    }
    
    private var bestsFileURL: URL {
        applicationSupportDirectory.appendingPathComponent("bests.json")
    }
    
    // MARK: - Initialization
    
    init() {
        // Ensure Application Support directory exists
        try? fileManager.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Run Management
    
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
    
    /// Saves a run record to storage (append-only with atomic write)
    func saveRun(_ run: RunRecord) throws {
        logger.info("Saving run: \(run.fileName)")
        
        var runs = loadRuns()
        runs.append(run)
        
        try saveRuns(runs)
        
        // Update bests after saving run
        try updateBests(with: run)
        
        AppLogger.logUserAction("run_saved", parameters: [
            "file_name": run.fileName,
            "distance": run.distance,
            "duration": run.duration
        ])
    }
    
    /// Saves all run records to storage with atomic write
    private func saveRuns(_ runs: [RunRecord]) throws {
        let data = try JSONEncoder().encode(runs)
        
        // Atomic write: write to temporary file first, then move
        let tempURL = runsFileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL)
        try fileManager.moveItem(at: tempURL, to: runsFileURL)
        
        logger.info("Saved \(runs.count) runs to storage")
    }
    
    /// Gets runs with optional limit
    func listRuns(limit: Int? = nil) -> [RunRecord] {
        let runs = loadRuns().sorted { $0.date > $1.date }
        
        if let limit = limit {
            return Array(runs.prefix(limit))
        }
        
        return runs
    }
    
    /// Deletes all runs (for testing)
    func deleteAll() throws {
        logger.info("Deleting all runs")
        
        if fileManager.fileExists(atPath: runsFileURL.path) {
            try fileManager.removeItem(at: runsFileURL)
        }
        
        if fileManager.fileExists(atPath: bestsFileURL.path) {
            try fileManager.removeItem(at: bestsFileURL)
        }
        
        logger.info("Deleted all runs")
    }
    
    // MARK: - Bests Management
    
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
    
    /// Gets current bests with 90-day PPI calculation
    func bests(now: Date = Date()) -> Bests {
        logger.info("Calculating bests for date: \(now)")
        
        var bests = loadBests()
        
        // Calculate 90-day highest PPI
        let runs90Days = runsInLast90Days(now: now)
        let highestPPI = calculateHighestPPI(in: runs90Days)
        bests.highestPPILast90Days = highestPPI
        
        // Update distance-based bests
        let allRuns = loadRuns()
        for run in allRuns {
            bests.updateBestTime(for: run.distance, time: run.duration)
        }
        
        // Save updated bests
        try? saveBests(bests)
        
        logger.info("Calculated bests - highest PPI last 90 days: \(highestPPI ?? 0)")
        
        return bests
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
        try saveBests(bests)
        
        logger.info("Updated bests - highest PPI last 90 days: \(highestPPI ?? 0)")
    }
    
    /// Saves bests to storage with atomic write
    private func saveBests(_ bests: Bests) throws {
        let data = try JSONEncoder().encode(bests)
        
        // Atomic write: write to temporary file first, then move
        let tempURL = bestsFileURL.appendingPathExtension("tmp")
        try data.write(to: tempURL)
        try fileManager.moveItem(at: tempURL, to: bestsFileURL)
    }
    
    // MARK: - 90-Day PPI Calculation
    
    /// Returns runs from the last 90 days
    private func runsInLast90Days(now: Date = Date()) -> [RunRecord] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: now) ?? now
        
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
    
    // MARK: - Statistics
    
    /// Gets total runs count
    func getTotalRunsCount() -> Int {
        return loadRuns().count
    }
    
    /// Gets total distance in kilometers
    func getTotalDistanceKm() -> Double {
        return loadRuns().reduce(0) { $0 + $1.distance } / 1000.0
    }
    
    /// Gets average pace across all runs
    func getAveragePace() -> Double? {
        let runs = loadRuns()
        guard !runs.isEmpty else { return nil }
        let totalPace = runs.reduce(0) { $0 + $1.averagePace }
        return totalPace / Double(runs.count)
    }
}
