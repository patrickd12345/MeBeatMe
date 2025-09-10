import Foundation

/// Data transfer object representing a completed run.
struct Run: Codable, Identifiable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let distanceM: Double
    let elapsedSec: Int
    let avgPaceSecPerKm: Double
    let avgHr: Double?
    let purdyScore: Double
    let notes: String?
    let source: String

    init(id: UUID = UUID(),
         startedAt: Date,
         endedAt: Date,
         distanceM: Double,
         elapsedSec: Int,
         avgPaceSecPerKm: Double,
         avgHr: Double?,
         purdyScore: Double,
         notes: String? = nil,
         source: String = "watchOS") {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.distanceM = distanceM
        self.elapsedSec = elapsedSec
        self.avgPaceSecPerKm = avgPaceSecPerKm
        self.avgHr = avgHr
        self.purdyScore = purdyScore
        self.notes = notes
        self.source = source
    }
}

/// Container for personal bests.
struct Bests: Codable {
    var fastest5k: Double?
    var fastest10k: Double?
    var bestPurdy: Double?
    var highestPPILast90Days: Double?
}
