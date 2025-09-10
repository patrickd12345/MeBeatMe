import Foundation

/// Represents an analyzed run with PPI score and recommendations
struct AnalyzedRun: Codable, Identifiable, Equatable {
    let id: UUID
    let run: RunRecord
    let ppi: Double
    let recommendations: [Recommendation]
    let metrics: PerformanceMetrics
    let analyzedAt: Date
    
    init(
        id: UUID = UUID(),
        run: RunRecord,
        ppi: Double,
        recommendations: [Recommendation] = [],
        metrics: PerformanceMetrics,
        analyzedAt: Date = Date()
    ) {
        self.id = id
        self.run = run
        self.ppi = ppi
        self.recommendations = recommendations
        self.metrics = metrics
        self.analyzedAt = analyzedAt
    }
    
    /// Formatted PPI score
    var formattedPPI: String {
        return String(format: "%.1f", ppi)
    }
    
    /// Performance level based on PPI score
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
    
    /// Performance level color
    var performanceLevelColor: String {
        switch performanceLevel {
        case .beginner:
            return "blue"
        case .intermediate:
            return "green"
        case .advanced:
            return "orange"
        case .elite:
            return "red"
        }
    }
    
    /// High priority recommendations
    var highPriorityRecommendations: [Recommendation] {
        return recommendations.filter { $0.priority == .high }
    }
    
    /// Medium priority recommendations
    var mediumPriorityRecommendations: [Recommendation] {
        return recommendations.filter { $0.priority == .medium }
    }
    
    /// Low priority recommendations
    var lowPriorityRecommendations: [Recommendation] {
        return recommendations.filter { $0.priority == .low }
    }
}
