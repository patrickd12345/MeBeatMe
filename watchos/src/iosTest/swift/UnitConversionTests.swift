import XCTest
import shared

final class UnitConversionTests: XCTestCase {
    func testMetersPerSecondRoundTrip() {
        let mps = 3.5
        let secPerKm = PaceUtils().metersPerSecondToSecondsPerKm(metersPerSecond: mps)
        let roundTrip = PaceUtils().secondsPerKmToMetersPerSecond(secondsPerKm: secPerKm)
        XCTAssertEqual(mps, roundTrip, accuracy: 0.0001)
    }
}
