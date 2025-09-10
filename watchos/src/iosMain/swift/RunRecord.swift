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
    let heartRateData: [HeartRatePoint]?
    let elevationGain: Double? // meters
    let temperature: Double? // celsius
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        distance: Double,
        duration: Int,
        averagePace: Double,
        splits: [Split]? = nil,
        source: String,
        fileName: String,
        heartRateData: [HeartRatePoint]? = nil,
        elevationGain: Double? = nil,
        temperature: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.splits = splits
        self.source = source
        self.fileName = fileName
        self.heartRateData = heartRateData
        self.elevationGain = elevationGain
        self.temperature = temperature
    }
}

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
}

/// Represents heart rate data at a specific point in time
struct HeartRatePoint: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let heartRate: Int // bpm
    
    init(
        id: UUID = UUID(),
        timestamp: Date,
        heartRate: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
    }
}