import XCTest
@testable import MeBeatMeWatch
import Shared

final class SharedLinkSmokeTests: XCTestCase {
    func testSharedSymbolLoads() {
        // Test that we can call a basic function from Shared
        let testRun = RunDTO(
            id: "test",
            source: "Manual",
            startedAtEpochMs: 1234567890000,
            endedAtEpochMs: 1234567890000,
            distanceMeters: 5000.0,
            elapsedSeconds: 1500,
            avgPaceSecPerKm: 300.0,
            ppi: nil
        )
        
        // Test PPI calculation
        let runWithPpi = testRun.calculatePpi()
        XCTAssertNotNil(runWithPpi.ppi)
        XCTAssertGreaterThan(runWithPpi.ppi!, 0)
        
        // Test that Shared module is properly linked
        XCTAssertTrue(true, "Shared module loaded successfully")
    }
    
    func testPurdyScoreCalculation() {
        // Test the core PPI calculation
        let score = purdyScore(5000.0, 1500) // 5K in 25 minutes
        XCTAssertGreaterThan(score, 0)
        XCTAssertLessThan(score, 1000)
    }
}
