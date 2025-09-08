import Foundation
import os

/// Service for analyzing runs and generating recommendations
class AnalysisService {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "AnalysisService")
    private let kmpBridge = KMPBridge()
    
    /// Analyzes a run and generates recommendations
    /// - Parameter runRecord: The run to analyze
    /// - Returns: AnalyzedRun with PPI, Purdy score, and recommendations
    func analyzeRun(_ runRecord: RunRecord) throws -> AnalyzedRun {
        logger.info("Analyzing run: \(runRecord.fileName)")
        
        // Calculate PPI using KMP bridge
        let ppi = kmpBridge.calculatePPI(distance: runRecord.distance, duration: runRecord.duration)
        
        // For now, Purdy score is the same as PPI
        // In a full implementation, this might be different
        let purdyScore = ppi
        
        // Generate recommendation
        let recommendation = try generateRecommendation(for: runRecord, currentPPI: ppi)
        
        let analyzedRun = AnalyzedRun(
            runRecord: runRecord,
            ppi: ppi,
            purdyScore: purdyScore,
            recommendation: recommendation
        )
        
        logger.info("Analysis complete - PPI: \(String(format: "%.1f", ppi)), Recommendation: \(recommendation.description)")
        
        return analyzedRun
    }
    
    /// Generates a training recommendation based on the run
    private func generateRecommendation(for run: RunRecord, currentPPI: Double) throws -> Recommendation {
        let distanceKm = run.distance / 1000.0
        
        // Determine target PPI improvement
        let targetPPI = calculateTargetPPI(currentPPI: currentPPI)
        let projectedGain = targetPPI - currentPPI
        
        // Calculate required pace
        let requiredPace = kmpBridge.calculateRequiredPace(for: targetPPI, distance: run.distance)
        
        // Determine difficulty based on improvement needed
        let difficulty = determineDifficulty(currentPPI: currentPPI, targetPPI: targetPPI)
        
        // Generate description
        let description = generateDescription(
            currentPace: run.averagePace,
            targetPace: requiredPace,
            projectedGain: projectedGain,
            difficulty: difficulty
        )
        
        return Recommendation(
            targetPace: requiredPace,
            projectedGain: projectedGain,
            description: description,
            difficulty: difficulty
        )
    }
    
    /// Calculates target PPI based on current performance
    private func calculateTargetPPI(currentPPI: Double) -> Double {
        // Progressive improvement based on current level
        switch currentPPI {
        case 0..<200:
            return currentPPI + 50  // Large improvement for beginners
        case 200..<400:
            return currentPPI + 30  // Moderate improvement
        case 400..<600:
            return currentPPI + 20  // Smaller improvement
        case 600..<800:
            return currentPPI + 15  // Even smaller improvement
        default:
            return currentPPI + 10  // Minimal improvement for elite
        }
    }
    
    /// Determines difficulty level based on improvement needed
    private func determineDifficulty(currentPPI: Double, targetPPI: Double) -> Recommendation.Difficulty {
        let improvement = targetPPI - currentPPI
        
        switch improvement {
        case 0..<10:
            return .easy
        case 10..<25:
            return .moderate
        case 25..<50:
            return .hard
        default:
            return .extreme
        }
    }
    
    /// Generates a human-readable description of the recommendation
    private func generateDescription(
        currentPace: Double,
        targetPace: Double,
        projectedGain: Double,
        difficulty: Recommendation.Difficulty
    ) -> String {
        let paceImprovement = currentPace - targetPace
        let paceImprovementFormatted = String(format: "%.1f", paceImprovement)
        
        switch difficulty {
        case .easy:
            return "Easy improvement: \(paceImprovementFormatted)s/km faster for +\(String(format: "%.0f", projectedGain)) PPI"
        case .moderate:
            return "Moderate challenge: \(paceImprovementFormatted)s/km faster for +\(String(format: "%.0f", projectedGain)) PPI"
        case .hard:
            return "Hard challenge: \(paceImprovementFormatted)s/km faster for +\(String(format: "%.0f", projectedGain)) PPI"
        case .extreme:
            return "Extreme challenge: \(paceImprovementFormatted)s/km faster for +\(String(format: "%.0f", projectedGain)) PPI"
        }
    }
    
    /// Validates that recommendations are monotonic (better performance = better PPI)
    func validateRecommendations() -> Bool {
        logger.info("Validating recommendation monotonicity")
        
        // Test with different performance levels
        let testCases: [(distance: Double, duration: Int)] = [
            (5000, 1800),  // Slow 5K
            (5000, 1500),  // Moderate 5K
            (5000, 1200),  // Fast 5K
        ]
        
        var previousPPI: Double = 0
        
        for testCase in testCases {
            let run = RunRecord(
                distance: testCase.distance,
                duration: testCase.duration,
                averagePace: Double(testCase.duration) / (testCase.distance / 1000.0),
                source: "test",
                fileName: "test"
            )
            
            do {
                let analyzedRun = try analyzeRun(run)
                
                // Check monotonicity: faster times should have higher PPI
                if analyzedRun.ppi <= previousPPI {
                    logger.error("Monotonicity violation: PPI \(analyzedRun.ppi) <= previous \(previousPPI)")
                    return false
                }
                
                previousPPI = analyzedRun.ppi
            } catch {
                logger.error("Failed to analyze test case: \(error)")
                return false
            }
        }
        
        logger.info("Recommendation monotonicity validation passed")
        return true
    }
}
