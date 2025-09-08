import XCTest
@testable import MeBeatMeWatch

/// Tests for the analysis service
class AnalysisServiceTests: XCTestCase {
    private let analysisService = AnalysisService()
    
    func testAnalyzeRun_ValidRun_ReturnsAnalyzedRun() throws {
        let runRecord = RunRecord(
            distance: 5000.0,
            duration: 1800,
            averagePace: 360.0,
            source: "test",
            fileName: "test.gpx"
        )
        
        let analyzedRun = try analysisService.analyzeRun(runRecord)
        
        XCTAssertEqual(analyzedRun.runRecord.id, runRecord.id)
        XCTAssertGreaterThan(analyzedRun.ppi, 0, "PPI should be greater than 0")
        XCTAssertGreaterThan(analyzedRun.purdyScore, 0, "Purdy score should be greater than 0")
        XCTAssertFalse(analyzedRun.recommendation.description.isEmpty, "Recommendation description should not be empty")
    }
    
    func testAnalyzeRun_RecommendationsMonotonic_FasterTimesHaveBetterRecommendations() throws {
        let slowRun = RunRecord(
            distance: 5000.0,
            duration: 2400, // 40 minutes
            averagePace: 480.0,
            source: "test",
            fileName: "slow.gpx"
        )
        
        let fastRun = RunRecord(
            distance: 5000.0,
            duration: 1800, // 30 minutes
            averagePace: 360.0,
            source: "test",
            fileName: "fast.gpx"
        )
        
        let slowAnalysis = try analysisService.analyzeRun(slowRun)
        let fastAnalysis = try analysisService.analyzeRun(fastRun)
        
        XCTAssertGreaterThan(fastAnalysis.ppi, slowAnalysis.ppi, "Faster run should have higher PPI")
        XCTAssertGreaterThan(fastAnalysis.recommendation.targetPace, slowAnalysis.recommendation.targetPace, "Faster run should have higher target pace")
    }
    
    func testAnalyzeRun_DifferentDistances_ReturnsAppropriateRecommendations() throws {
        let shortRun = RunRecord(
            distance: 3000.0, // 3km
            duration: 900, // 15 minutes
            averagePace: 300.0,
            source: "test",
            fileName: "short.gpx"
        )
        
        let longRun = RunRecord(
            distance: 10000.0, // 10km
            duration: 3600, // 60 minutes
            averagePace: 360.0,
            source: "test",
            fileName: "long.gpx"
        )
        
        let shortAnalysis = try analysisService.analyzeRun(shortRun)
        let longAnalysis = try analysisService.analyzeRun(longRun)
        
        XCTAssertNotEqual(shortAnalysis.ppi, longAnalysis.ppi, "Different distances should have different PPI")
        XCTAssertNotEqual(shortAnalysis.recommendation.targetPace, longAnalysis.recommendation.targetPace, "Different distances should have different target paces")
    }
    
    func testValidateRecommendations_ReturnsTrue() {
        let isValid = analysisService.validateRecommendations()
        
        XCTAssertTrue(isValid, "Recommendation validation should pass")
    }
    
    func testAnalyzeRun_RecommendationDifficulty_MatchesPerformanceLevel() throws {
        let beginnerRun = RunRecord(
            distance: 5000.0,
            duration: 3000, // 50 minutes (slow)
            averagePace: 600.0,
            source: "test",
            fileName: "beginner.gpx"
        )
        
        let advancedRun = RunRecord(
            distance: 5000.0,
            duration: 1500, // 25 minutes (fast)
            averagePace: 300.0,
            source: "test",
            fileName: "advanced.gpx"
        )
        
        let beginnerAnalysis = try analysisService.analyzeRun(beginnerRun)
        let advancedAnalysis = try analysisService.analyzeRun(advancedRun)
        
        // Beginner should get easier recommendations, advanced should get harder
        XCTAssertLessThanOrEqual(beginnerAnalysis.recommendation.projectedGain, advancedAnalysis.recommendation.projectedGain, "Advanced runners should have higher projected gains")
    }
}
