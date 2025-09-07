import XCTest
@testable import watchos

final class KMPBridgeTests: XCTestCase {
    func testTargetPace() {
        let pace = KMPBridge.targetPace(for: 5000, windowSec: 1500)
        XCTAssertEqual(pace, 5000/1500, accuracy: 0.0001)
    }

    func testPurdyScoreNonZero() {
        let score = KMPBridge.purdyScore(distanceMeters: 5000, durationSec: 1500)
        XCTAssertGreaterThan(score, 0)
    }
}
