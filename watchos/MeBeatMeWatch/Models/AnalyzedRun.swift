import Foundation

/// Represents the result of analyzing a run
struct AnalyzedRun: Identifiable, Equatable {
    let id: UUID
    let runRecord: RunRecord
    let ppi: Double
    let purdyScore: Double
    let recommendation: Recommendation
    
    init(
        id: UUID = UUID(),
        runRecord: RunRecord,
        ppi: Double,
        purdyScore: Double,
        recommendation: Recommendation
    ) {
        self.id = id
        self.runRecord = runRecord
        self.ppi = ppi
        self.purdyScore = purdyScore
        self.recommendation = recommendation
    }
}

/// Represents a training recommendation based on the run analysis
struct Recommendation: Equatable {
    let targetPace: Double // seconds per kilometer
    let projectedGain: Double // expected PPI improvement
    let description: String
    let difficulty: Difficulty
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case moderate = "Moderate"
        case hard = "Hard"
        case extreme = "Extreme"
        
        var color: String {
            switch self {
            case .easy: return "green"
            case .moderate: return "blue"
            case .hard: return "orange"
            case .extreme: return "red"
            }
        }
    }
}

/// Central error handling for the app
enum AppError: LocalizedError, Equatable {
    case unsupportedFormat(String)
    case parseFailed(String)
    case ioFailure(String)
    case kmpBridgeFailure(String)
    case analysisFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let format):
            return "Unsupported file format: \(format)"
        case .parseFailed(let reason):
            return "Failed to parse file: \(reason)"
        case .ioFailure(let reason):
            return "I/O error: \(reason)"
        case .kmpBridgeFailure(let reason):
            return "KMP bridge error: \(reason)"
        case .analysisFailure(let reason):
            return "Analysis error: \(reason)"
        }
    }
}
