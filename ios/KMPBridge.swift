// KMPBridge.swift
// This file should be added to your iOS/watchOS projects
// and the Shared.xcframework should be embedded

import Foundation
import Shared

enum PerfIndex {
    
    /// Calculate Purdy score using shared KMP implementation
    static func purdyScore(distanceMeters: Double, durationSec: Int32) throws -> Double {
        do {
            return try Shared.PurdyCalculator().purdyScore(distanceMeters: distanceMeters, durationSec: durationSec)
        } catch {
            throw PerfIndexError.calculationFailed(error.localizedDescription)
        }
    }
    
    /// Calculate target pace using shared KMP implementation
    static func targetPace(distanceMeters: Double, windowSec: Int32) throws -> Double {
        do {
            return try Shared.PurdyCalculator().targetPace(distanceMeters: distanceMeters, windowSec: windowSec)
        } catch {
            throw PerfIndexError.calculationFailed(error.localizedDescription)
        }
    }
    
    /// Calculate highest PPI in 90-day window
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
