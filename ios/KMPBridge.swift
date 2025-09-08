import Foundation
import shared

/// Bridge between Swift and Kotlin Multiplatform Shared module
/// Provides access to core PPI calculations and shared functions
enum PerfIndex {
    
    /// Calculate Purdy score using the cubic relationship: P = 1000 × (T₀/T)³
    /// - Parameters:
    ///   - distanceMeters: Distance in meters
    ///   - durationSec: Duration in seconds
    /// - Returns: Purdy score (1-1000+ points)
    /// - Throws: IllegalArgumentException if inputs are invalid
    static func purdyScore(distanceMeters: Double, durationSec: Int32) throws -> Double {
        do {
            return try SharedFunctionsKt.purdyScore(distanceMeters: distanceMeters, durationSec: durationSec)
        } catch {
            throw PerfIndexError.invalidInput(error.localizedDescription)
        }
    }
    
    /// Calculate target pace in seconds per kilometer
    /// - Parameters:
    ///   - distanceMeters: Distance in meters
    ///   - windowSec: Time window in seconds
    /// - Returns: Target pace in seconds per kilometer
    /// - Throws: IllegalArgumentException if inputs are invalid
    static func targetPace(distanceMeters: Double, windowSec: Int32) throws -> Double {
        do {
            return try SharedFunctionsKt.targetPace(distanceMeters: distanceMeters, windowSec: windowSec)
        } catch {
            throw PerfIndexError.invalidInput(error.localizedDescription)
        }
    }
    
    /// Calculate the highest PPI in the last N days from a list of runs
    /// - Parameters:
    ///   - runs: List of runs to analyze
    ///   - nowMs: Current timestamp in milliseconds
    ///   - days: Number of days to look back (default 90)
    /// - Returns: Highest PPI in the window, or nil if no runs found
    static func highestPpiInWindow(runs: [RunDTO], nowMs: Int64, days: Int32 = 90) -> Double? {
        return SharedFunctionsKt.highestPpiInWindow(runs: runs, nowMs: nowMs, days: days)
    }
    
    /// Calculate best times for standard distances
    /// - Parameters:
    ///   - runs: List of runs to analyze
    ///   - sinceMs: Only consider runs after this timestamp (default 0 = all time)
    /// - Returns: BestsDTO with best times for 5K, 10K, Half, Full
    static func calculateBests(runs: [RunDTO], sinceMs: Int64 = 0) -> BestsDTO {
        return SharedFunctionsKt.calculateBests(runs: runs, sinceMs: sinceMs)
    }
}

/// Errors that can be thrown by PerfIndex functions
enum PerfIndexError: Error, LocalizedError {
    case invalidInput(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        }
    }
}

/// Extension to convert between Swift and Kotlin types
extension RunDTO {
    /// Convert Swift RunDTO to Kotlin RunDTO
    static func fromKotlin(_ kotlinRun: shared.RunDTO) -> RunDTO {
        return RunDTO(
            id: kotlinRun.id,
            source: kotlinRun.source,
            startedAtEpochMs: kotlinRun.startedAtEpochMs,
            endedAtEpochMs: kotlinRun.endedAtEpochMs,
            distanceMeters: kotlinRun.distanceMeters,
            elapsedSeconds: kotlinRun.elapsedSeconds,
            avgPaceSecPerKm: kotlinRun.avgPaceSecPerKm,
            avgHr: kotlinRun.avgHr?.int32Value,
            ppi: kotlinRun.ppi,
            notes: kotlinRun.notes
        )
    }
    
    /// Convert Kotlin RunDTO to Swift RunDTO
    func toKotlin() -> shared.RunDTO {
        return shared.RunDTO(
            id: self.id,
            source: self.source,
            startedAtEpochMs: self.startedAtEpochMs,
            endedAtEpochMs: self.endedAtEpochMs,
            distanceMeters: self.distanceMeters,
            elapsedSeconds: self.elapsedSeconds,
            avgPaceSecPerKm: self.avgPaceSecPerKm,
            avgHr: self.avgHr.map { KotlinInt(value: $0) },
            ppi: self.ppi,
            notes: self.notes
        )
    }
}

extension BestsDTO {
    /// Convert Swift BestsDTO to Kotlin BestsDTO
    static func fromKotlin(_ kotlinBests: shared.BestsDTO) -> BestsDTO {
        return BestsDTO(
            best5kSec: kotlinBests.best5kSec?.int32Value,
            best10kSec: kotlinBests.best10kSec?.int32Value,
            bestHalfSec: kotlinBests.bestHalfSec?.int32Value,
            bestFullSec: kotlinBests.bestFullSec?.int32Value,
            highestPPILast90Days: kotlinBests.highestPPILast90Days
        )
    }
    
    /// Convert Kotlin BestsDTO to Swift BestsDTO
    func toKotlin() -> shared.BestsDTO {
        return shared.BestsDTO(
            best5kSec: self.best5kSec.map { KotlinInt(value: $0) },
            best10kSec: self.best10kSec.map { KotlinInt(value: $0) },
            bestHalfSec: self.bestHalfSec.map { KotlinInt(value: $0) },
            bestFullSec: self.bestFullSec.map { KotlinInt(value: $0) },
            highestPPILast90Days: self.highestPPILast90Days
        )
    }
}

