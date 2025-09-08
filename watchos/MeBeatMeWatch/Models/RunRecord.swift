import Foundation

/// Represents a completed run with all necessary data for analysis
struct RunRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let distance: Double // meters
    let duration: Int // seconds
    let averagePace: Double // seconds per kilometer
    let splits: [Split]?
    let source: String // "gpx", "tcx", "fit", etc.
    let fileName: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        distance: Double,
        duration: Int,
        averagePace: Double,
        splits: [Split]? = nil,
        source: String,
        fileName: String
    ) {
        self.id = id
        self.date = date
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.splits = splits
        self.source = source
        self.fileName = fileName
    }
}

/// Represents a split/segment within a run
struct Split: Codable, Identifiable, Equatable {
    let id: UUID
    let distance: Double // meters
    let duration: Int // seconds
    let pace: Double // seconds per kilometer
    
    init(
        id: UUID = UUID(),
        distance: Double,
        duration: Int,
        pace: Double
    ) {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }
}

/// Represents the best performances across different distances
struct Bests: Codable, Equatable {
    var best5kSec: Int?
    var best10kSec: Int?
    var bestHalfSec: Int?
    var bestFullSec: Int?
    var highestPPILast90Days: Double?
    
    init(
        best5kSec: Int? = nil,
        best10kSec: Int? = nil,
        bestHalfSec: Int? = nil,
        bestFullSec: Int? = nil,
        highestPPILast90Days: Double? = nil
    ) {
        self.best5kSec = best5kSec
        self.best10kSec = best10kSec
        self.bestHalfSec = bestHalfSec
        self.bestFullSec = bestFullSec
        self.highestPPILast90Days = highestPPILast90Days
    }
    
    /// Returns the best time for a given distance bucket
    func bestTime(for distance: Double) -> Int? {
        let distanceKm = distance / 1000.0
        
        switch distanceKm {
        case 0..<7.5:
            return best5kSec
        case 7.5..<12.5:
            return best10kSec
        case 12.5..<25:
            return bestHalfSec
        default:
            return bestFullSec
        }
    }
    
    /// Updates the best time for a given distance if the new time is better
    mutating func updateBestTime(for distance: Double, time: Int) {
        let distanceKm = distance / 1000.0
        
        switch distanceKm {
        case 0..<7.5:
            if best5kSec == nil || time < best5kSec! {
                best5kSec = time
            }
        case 7.5..<12.5:
            if best10kSec == nil || time < best10kSec! {
                best10kSec = time
            }
        case 12.5..<25:
            if bestHalfSec == nil || time < bestHalfSec! {
                bestHalfSec = time
            }
        default:
            if bestFullSec == nil || time < bestFullSec! {
                bestFullSec = time
            }
        }
    }
}
