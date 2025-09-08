import XCTest
@testable import MeBeatMeWatch

/// Tests for the KMP bridge functionality
class KMPBridgeTests: XCTestCase {
    private let kmpBridge = KMPBridge()
    
    func testCalculatePPI_5KRun_ReturnsExpectedValue() {
        // Test with known 5K run data
        let distance: Double = 5000.0 // 5km
        let duration = 1800 // 30 minutes
        
        let ppi = kmpBridge.calculatePPI(distance: distance, duration: duration)
        
        // Should be a reasonable PPI score for a 30-minute 5K
        XCTAssertGreaterThan(ppi, 100.0, "PPI should be greater than 100")
        XCTAssertLessThan(ppi, 1000.0, "PPI should be less than 1000")
    }
    
    func testCalculatePPI_SmashrunCalibration_Returns355() {
        // Test with the specific run that should score 355 PPI
        let distance: Double = 5940.0 // 5.94km
        let duration = 2498 // 41:38
        
        let ppi = kmpBridge.calculatePPI(distance: distance, duration: duration)
        
        // Should be very close to 355 (allow for small floating point differences)
        XCTAssertEqual(ppi, 355.0, accuracy: 1.0, "PPI should be 355 for this specific run")
    }
    
    func testCalculateRequiredPace_TargetPPI_ReturnsCorrectPace() {
        let distance: Double = 5000.0 // 5km
        let targetPPI: Double = 400.0
        
        let requiredPace = kmpBridge.calculateRequiredPace(for: targetPPI, distance: distance)
        
        // Should be a reasonable pace (seconds per kilometer)
        XCTAssertGreaterThan(requiredPace, 200.0, "Required pace should be reasonable")
        XCTAssertLessThan(requiredPace, 600.0, "Required pace should not be too slow")
    }
    
    func testCalculateRequiredTime_TargetPPI_ReturnsCorrectTime() {
        let distance: Double = 5000.0 // 5km
        let targetPPI: Double = 400.0
        
        let requiredTime = kmpBridge.calculateRequiredTime(for: targetPPI, distance: distance)
        
        // Should be a reasonable time in seconds
        XCTAssertGreaterThan(requiredTime, 1000, "Required time should be reasonable")
        XCTAssertLessThan(requiredTime, 3000, "Required time should not be too slow")
    }
    
    func testValidateBridge_ReturnsTrue() {
        let isValid = kmpBridge.validateBridge()
        
        XCTAssertTrue(isValid, "Bridge validation should pass")
    }
    
    func testPPICalculation_Monotonicity_FasterTimesHaveHigherPPI() {
        let distance: Double = 5000.0 // 5km
        
        let slowTime = 2400 // 40 minutes
        let fastTime = 1800 // 30 minutes
        
        let slowPPI = kmpBridge.calculatePPI(distance: distance, duration: slowTime)
        let fastPPI = kmpBridge.calculatePPI(distance: distance, duration: fastTime)
        
        XCTAssertGreaterThan(fastPPI, slowPPI, "Faster times should have higher PPI")
    }
}
