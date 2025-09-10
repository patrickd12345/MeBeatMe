import Foundation

/// Persists runs to a JSON file under Application Support.
final class RunStore {
    private let fileManager: FileManager
    private let fileURL: URL
    private var cache: [Run] = []

    init(fileManager: FileManager = .default, directory: URL? = nil) {
        self.fileManager = fileManager
        let dir = directory ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent("runs.json")
        load()
        
        // Add sample data if no runs exist
        if cache.isEmpty {
            addSampleData()
        }
    }

    /// Saves a run to disk.
    func save(_ run: Run) {
        cache.append(run)
        persist()
    }

    /// Lists saved runs, optionally limiting count.
    func list(limit: Int? = nil) -> [Run] {
        if let limit = limit { return Array(cache.suffix(limit)) }
        return cache
    }

    /// Computes personal bests from stored runs.
    func bests() -> Bests {
        var best = Bests()
        if let fiveK = cache.filter({ $0.distanceM >= 5000 }).min(by: { $0.elapsedSec < $1.elapsedSec }) {
            best.fastest5k = Double(fiveK.elapsedSec)
        }
        if let tenK = cache.filter({ $0.distanceM >= 10000 }).min(by: { $0.elapsedSec < $1.elapsedSec }) {
            best.fastest10k = Double(tenK.elapsedSec)
        }
        best.bestPurdy = cache.map { $0.purdyScore }.max()
        return best
    }

    private func load() {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            cache = try JSONDecoder().decode([Run].self, from: data)
        } catch {
            cache = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(cache)
            let tmpURL = fileURL.appendingPathExtension("tmp")
            try data.write(to: tmpURL, options: .atomic)
            _ = try fileManager.replaceItem(at: fileURL, withItemAt: tmpURL, backupItemName: nil, options: [], resultingItemURL: nil)
        } catch {
            print("RunStore persist failed: \(error)")
        }
    }
    
    private func addSampleData() {
        let now = Date()
        // Use your actual run data instead of sample data
        let actualRun = Run(
            id: UUID(uuidString: "1e324f19-0d3d-4279-8b62-afd0ab6c6536") ?? UUID(),
            startedAt: Date(timeIntervalSince1970: 1757280743787 / 1000.0), // Your actual run date
            endedAt: Date(timeIntervalSince1970: (1757280743787 + 2498000) / 1000.0), // Start + duration
            distanceM: 5940.0, // Your actual distance
            elapsedSec: 2498, // Your actual duration
            avgPaceSecPerKm: 355.0, // Your actual pace (seconds per km)
            avgHr: 150.0, // Estimated heart rate
            purdyScore: 355.0, // Your actual PPI score
            notes: "Your actual 5.94km run",
            source: "fit"
        )
        
        cache = [actualRun]
        persist()
    }
}
