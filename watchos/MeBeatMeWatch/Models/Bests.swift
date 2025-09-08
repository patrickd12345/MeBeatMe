import Foundation

/// Represents the best performances across different distances
struct Bests: Codable, Equatable {
    var best5kSec: Int?
    var best10kSec: Int?
    var bestHalfSec: Int?
    var bestFullSec: Int?
    var highestPPILast90Days: Double?
    var lastUpdated: Date
    
    init(
        best5kSec: Int? = nil,
        best10kSec: Int? = nil,
        bestHalfSec: Int? = nil,
        bestFullSec: Int? = nil,
        highestPPILast90Days: Double? = nil,
        lastUpdated: Date = Date()
    ) {
        self.best5kSec = best5kSec
        self.best10kSec = best10kSec
        self.bestHalfSec = bestHalfSec
        self.bestFullSec = bestFullSec
        self.highestPPILast90Days = highestPPILast90Days
        self.lastUpdated = lastUpdated
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
        
        lastUpdated = Date()
    }
    
    /// Returns a formatted string for the best time at a given distance
    func formattedBestTime(for distance: Double) -> String? {
        guard let time = bestTime(for: distance) else { return nil }
        return Units.formatTime(time)
    }
}
