import Foundation

/// Represents a split/segment within a run
struct Split: Codable, Identifiable, Equatable {
    let id: UUID
    let distance: Double // meters
    let duration: Int // seconds
    let pace: Double // seconds per kilometer
    let averageHeartRate: Int? // bpm
    
    init(
        id: UUID = UUID(),
        distance: Double,
        duration: Int,
        pace: Double,
        averageHeartRate: Int? = nil
    ) {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.averageHeartRate = averageHeartRate
    }
    
    /// Returns formatted pace as MM:SS per km
    var formattedPace: String {
        return Units.formatPace(pace)
    }
    
    /// Returns formatted duration as MM:SS
    var formattedDuration: String {
        return Units.formatTime(duration)
    }
    
    /// Returns formatted distance as X.X km
    var formattedDistance: String {
        return Units.formatDistance(distance)
    }
}
