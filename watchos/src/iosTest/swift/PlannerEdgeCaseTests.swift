import XCTest

final class PlannerEdgeCaseTests: XCTestCase {
    func testVeryShortWindow() {
        let pace = KMPBridge.targetPace(for: 1000, windowSec: 60)
        XCTAssertGreaterThan(pace, 10)
    }

    func testLongWindow() {
        let pace = KMPBridge.targetPace(for: 10000, windowSec: 7200)
        XCTAssertLessThan(pace, 2)
    }
}
