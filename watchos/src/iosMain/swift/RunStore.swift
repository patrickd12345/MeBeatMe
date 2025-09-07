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
            _ = try fileManager.replaceItem(at: fileURL, withItemAt: tmpURL)
        } catch {
            print("RunStore persist failed: \(error)")
        }
    }
}
