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
    
    /// Calculates the required time to achieve a target PPI score for a given distance.
    static func requiredTimeFor(distanceM: Double, targetScore: Double) -> Double {
        // This would typically call the KMP PpiEngine.requiredTimeFor method
        // For now, return a placeholder calculation
        // In a real implementation, this would use the actual PPI engine
        
        // Simple placeholder: assume linear relationship
        // This is not accurate but serves as a fallback
        let baseTime = distanceM / 1000.0 * 300.0 // 5 minutes per km baseline
        let scoreMultiplier = 1000.0 / max(targetScore, 100.0)
        return baseTime * scoreMultiplier
    }
}
