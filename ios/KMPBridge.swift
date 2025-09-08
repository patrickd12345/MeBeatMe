// KMPBridge.swift
// iOS/watchOS bridge to KMP shared module
// Following the HYBRID PROMPT specifications
//
// This file should be added to your iOS/watchOS projects
// and the Shared.xcframework should be embedded

import Foundation
import Shared

enum PerfIndex {
    
    /// Calculate Purdy score using shared KMP implementation
    /// @param distanceMeters Distance in meters
    /// @param durationSec Duration in seconds
    /// @return Purdy score (100-2000 range)
    /// @throws PerfIndexError if inputs are invalid
    static func purdyScore(distanceMeters: Double, durationSec: Int32) throws -> Double {
        do {
            return try Shared.purdyScore(distanceMeters: distanceMeters, durationSec: durationSec)
        } catch {
            throw PerfIndexError.calculationFailed(error.localizedDescription)
        }
    }
    
    /// Calculate target pace using shared KMP implementation
    /// @param distanceMeters Distance in meters
    /// @param windowSec Duration window in seconds
    /// @return Required pace in seconds per kilometer
    /// @throws PerfIndexError if inputs are invalid
    static func targetPace(distanceMeters: Double, windowSec: Int32) throws -> Double {
        do {
            return try Shared.targetPace(distanceMeters: distanceMeters, windowSec: windowSec)
        } catch {
            throw PerfIndexError.calculationFailed(error.localizedDescription)
        }
    }
    
    /// Calculate highest PPI in 90-day window
    /// @param runs List of runs to analyze
    /// @param nowMs Current time in milliseconds
    /// @param days Number of days to look back (default 90)
    /// @return Highest PPI in the window, or nil if no runs
    static func highestPpiInWindow(runs: [RunDto], nowMs: Int64, days: Int32 = 90) -> Double? {
        return Shared.highestPpiInWindow(runs: runs, nowMs: nowMs, days: days)
    }
}

enum PerfIndexError: Error {
    case calculationFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .calculationFailed(let message):
            return "Calculation failed: \(message)"
        }
    }
}