import Foundation
import os

/// Service for analyzing runs and generating performance recommendations
class AnalysisService {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "AnalysisService")
    private let kmpBridge = KMPBridge()
    
    /// Analyzes a run and generates recommendations
    /// - Parameter run: The run to analyze
    /// - Returns: Analysis result with PPI and recommendations
    func analyzeRun(_ run: RunRecord) -> RunAnalysis {
        logger.info("Analyzing run: \(run.fileName)")
        
        // Calculate PPI using KMP bridge
        let ppi = kmpBridge.calculatePPI(distance: run.distance, duration: run.duration)
        
        // Generate recommendations based on performance
        let recommendations = generateRecommendations(for: run, ppi: ppi)
        
        // Calculate performance metrics
        let metrics = calculatePerformanceMetrics(for: run)
        
        let analysis = RunAnalysis(
            run: run,
            ppi: ppi,
            recommendations: recommendations,
            metrics: metrics
        )
        
        logger.info("Analysis complete - PPI: \(String(format: "%.1f", ppi))")
        
        return analysis
    }
    
    /// Generates performance recommendations based on run data
    private func generateRecommendations(for run: RunRecord, ppi: Double) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Distance-based recommendations
        let distanceKm = run.distance / 1000.0
        
        if distanceKm < 5.0 {
            recommendations.append(Recommendation(
                type: .distance,
                title: "Build Endurance",
                description: "Consider increasing distance gradually to improve aerobic capacity",
                priority: .medium
            ))
        } else if distanceKm > 15.0 {
            recommendations.append(Recommendation(
                type: .distance,
                title: "Focus on Speed",
                description: "Add shorter, faster runs to improve pace and PPI",
                priority: .high
            ))
        }
        
        // Pace-based recommendations
        let paceMinutes = run.averagePace / 60.0
        
        if paceMinutes > 6.0 {
            recommendations.append(Recommendation(
                type: .pace,
                title: "Improve Pace",
                description: "Work on speed with interval training and tempo runs",
                priority: .high
            ))
        } else if paceMinutes < 4.0 {
            recommendations.append(Recommendation(
                type: .pace,
                title: "Maintain Consistency",
                description: "Excellent pace! Focus on maintaining this level",
                priority: .low
            ))
        }
        
        // PPI-based recommendations
        if ppi < 200 {
            recommendations.append(Recommendation(
                type: .performance,
                title: "Build Base Fitness",
                description: "Focus on consistent training to improve overall fitness",
                priority: .high
            ))
        } else if ppi > 500 {
            recommendations.append(Recommendation(
                type: .performance,
                title: "Elite Performance",
                description: "Outstanding performance! Consider advanced training techniques",
                priority: .low
            ))
        }
        
        // Heart rate recommendations (if available)
        if let heartRateData = run.heartRateData, !heartRateData.isEmpty {
            let avgHeartRate = heartRateData.map { $0.heartRate }.reduce(0, +) / heartRateData.count
            
            if avgHeartRate > 180 {
                recommendations.append(Recommendation(
                    type: .heartRate,
                    title: "Monitor Intensity",
                    description: "High heart rate suggests very high intensity - ensure adequate recovery",
                    priority: .medium
                ))
            }
        }
        
        return recommendations
    }
    
    /// Calculates performance metrics for a run
    private func calculatePerformanceMetrics(for run: RunRecord) -> PerformanceMetrics {
        let distanceKm = run.distance / 1000.0
        let paceMinutes = run.averagePace / 60.0
        
        // Calculate efficiency (pace per km relative to distance)
        let efficiency = paceMinutes / distanceKm
        
        // Calculate consistency (if splits available)
        var consistency: Double = 1.0
        if let splits = run.splits, splits.count > 1 {
            let paces = splits.map { $0.pace / 60.0 }
            let avgPace = paces.reduce(0, +) / Double(paces.count)
            let variance = paces.map { pow($0 - avgPace, 2) }.reduce(0, +) / Double(paces.count)
            consistency = max(0.1, 1.0 - (variance / avgPace))
        }
        
        return PerformanceMetrics(
            efficiency: efficiency,
            consistency: consistency,
            distanceCategory: getDistanceCategory(distanceKm),
            paceCategory: getPaceCategory(paceMinutes)
        )
    }
    
    /// Gets distance category for a given distance
    private func getDistanceCategory(_ distanceKm: Double) -> DistanceCategory {
        switch distanceKm {
        case 0..<3:
            return .short
        case 3..<8:
            return .medium
        case 8..<15:
            return .long
        default:
            return .ultra
        }
    }
    
    /// Gets pace category for a given pace
    private func getPaceCategory(_ paceMinutes: Double) -> PaceCategory {
        switch paceMinutes {
        case 0..<4:
            return .elite
        case 4..<5:
            return .advanced
        case 5..<6:
            return .intermediate
        default:
            return .beginner
        }
    }
}

/// Represents the result of analyzing a run
struct RunAnalysis {
    let run: RunRecord
    let ppi: Double
    let recommendations: [Recommendation]
    let metrics: PerformanceMetrics
    
    /// Formatted PPI score
    var formattedPPI: String {
        return String(format: "%.1f", ppi)
    }
    
    /// Performance level based on PPI
    var performanceLevel: PerformanceLevel {
        switch ppi {
        case 0..<200:
            return .beginner
        case 200..<350:
            return .intermediate
        case 350..<500:
            return .advanced
        default:
            return .elite
        }
    }
}

/// Represents a performance recommendation
struct Recommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
    let priority: RecommendationPriority
    
    enum RecommendationType {
        case distance
        case pace
        case performance
        case heartRate
        case recovery
    }
    
    enum RecommendationPriority {
        case low
        case medium
        case high
    }
}

/// Represents performance metrics for a run
struct PerformanceMetrics {
    let efficiency: Double
    let consistency: Double
    let distanceCategory: DistanceCategory
    let paceCategory: PaceCategory
    
    enum DistanceCategory {
        case short
        case medium
        case long
        case ultra
    }
    
    enum PaceCategory {
        case beginner
        case intermediate
        case advanced
        case elite
    }
}

/// Performance level based on PPI score
enum PerformanceLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
}