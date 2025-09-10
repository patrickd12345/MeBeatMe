import Foundation
// import Shared  // Temporarily disabled - KMP module not available for watchOS simulator

/// Thin Swift helpers around Kotlin shared logic.
enum KMPBridge {
    /// Calculates the average pace (m/s) required to cover `distanceMeters` within `windowSec` seconds.
    static func targetPace(for distanceMeters: Double, windowSec: Int) -> Double {
        guard windowSec > 0 else { return 0 }
        return distanceMeters / Double(windowSec)
    }

    /// Computes the Purdy performance score for a completed run.
    static func purdyScore(distanceMeters: Double, durationSec: Int) -> Double {
        // PurdyPointsCalculator().calculatePPI(distance: distanceMeters, time: Int64(durationSec))
        // Temporarily return a placeholder value
        return 100.0
    }
}
