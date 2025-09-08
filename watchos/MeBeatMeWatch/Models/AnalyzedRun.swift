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

/// Performance level based on PPI score
enum PerformanceLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
    
    var description: String {
        switch self {
        case .beginner:
            return "Building base fitness"
        case .intermediate:
            return "Developing consistency"
        case .advanced:
            return "Competitive performance"
        case .elite:
            return "World-class performance"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner:
            return "figure.walk"
        case .intermediate:
            return "figure.run"
        case .advanced:
            return "figure.run.circle"
        case .elite:
            return "crown.fill"
        }
    }
}

/// Represents performance metrics for a run
struct PerformanceMetrics: Codable, Equatable {
    let efficiency: Double
    let consistency: Double
    let distanceCategory: DistanceCategory
    let paceCategory: PaceCategory
    let heartRateZone: HeartRateZone?
    
    init(
        efficiency: Double,
        consistency: Double,
        distanceCategory: DistanceCategory,
        paceCategory: PaceCategory,
        heartRateZone: HeartRateZone? = nil
    ) {
        self.efficiency = efficiency
        self.consistency = consistency
        self.distanceCategory = distanceCategory
        self.paceCategory = paceCategory
        self.heartRateZone = heartRateZone
    }
    
    enum DistanceCategory: String, Codable, CaseIterable {
        case short = "Short"
        case medium = "Medium"
        case long = "Long"
        case ultra = "Ultra"
        
        var description: String {
            switch self {
            case .short:
                return "1-3km"
            case .medium:
                return "3-8km"
            case .long:
                return "8-15km"
            case .ultra:
                return "15km+"
            }
        }
    }
    
    enum PaceCategory: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case elite = "Elite"
        
        var description: String {
            switch self {
            case .beginner:
                return "6:00+/km"
            case .intermediate:
                return "5:00-6:00/km"
            case .advanced:
                return "4:00-5:00/km"
            case .elite:
                return "<4:00/km"
            }
        }
    }
    
    enum HeartRateZone: String, Codable, CaseIterable {
        case zone1 = "Zone 1"
        case zone2 = "Zone 2"
        case zone3 = "Zone 3"
        case zone4 = "Zone 4"
        case zone5 = "Zone 5"
        
        var description: String {
            switch self {
            case .zone1:
                return "Recovery"
            case .zone2:
                return "Aerobic Base"
            case .zone3:
                return "Aerobic Threshold"
            case .zone4:
                return "Lactate Threshold"
            case .zone5:
                return "Neuromuscular Power"
            }
        }
        
        var color: String {
            switch self {
            case .zone1:
                return "blue"
            case .zone2:
                return "green"
            case .zone3:
                return "yellow"
            case .zone4:
                return "orange"
            case .zone5:
                return "red"
            }
        }
    }
}