import Foundation

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
    
    /// Returns a color for the priority level
    var priorityColor: String {
        switch priority {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
    
    /// Returns an icon for the recommendation type
    var typeIcon: String {
        switch type {
        case .distance:
            return "figure.run"
        case .pace:
            return "speedometer"
        case .performance:
            return "chart.line.uptrend.xyaxis"
        case .heartRate:
            return "heart.fill"
        case .recovery:
            return "bed.double.fill"
        }
    }
}
