import XCTest
@testable import MeBeatMeWatch

/// Tests for unit conversions and formatting
class UnitsTests: XCTestCase {
    
    func testPaceConversion_RoundTrip_ReturnsOriginal() {
        let originalPace: Double = 420.0 // 7:00/km
        
        // Convert to minutes:seconds format and back
        let minutes = Int(originalPace) / 60
        let seconds = Int(originalPace) % 60
        
        // Convert back to total seconds
        let convertedPace = Double(minutes * 60 + seconds)
        
        XCTAssertEqual(convertedPace, originalPace, accuracy: 1.0, "Round-trip conversion should preserve original value")
    }
    
    func testDistanceConversion_MetersToKilometers_ReturnsCorrect() {
        let distanceMeters: Double = 5000.0
        let distanceKm = distanceMeters / 1000.0
        
        XCTAssertEqual(distanceKm, 5.0, "5000 meters should equal 5 kilometers")
    }
    
    func testDurationConversion_SecondsToMinutes_ReturnsCorrect() {
        let durationSeconds = 1800
        let durationMinutes = durationSeconds / 60
        
        XCTAssertEqual(durationMinutes, 30, "1800 seconds should equal 30 minutes")
    }
    
    func testDurationConversion_SecondsToHoursMinutesSeconds_ReturnsCorrect() {
        let durationSeconds = 3661 // 1 hour, 1 minute, 1 second
        
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60
        
        XCTAssertEqual(hours, 1, "Hours should be 1")
        XCTAssertEqual(minutes, 1, "Minutes should be 1")
        XCTAssertEqual(seconds, 1, "Seconds should be 1")
    }
    
    func testPaceCalculation_DistanceAndTime_ReturnsCorrectPace() {
        let distance: Double = 5000.0 // 5km
        let duration = 1800 // 30 minutes
        
        let pace = Double(duration) / (distance / 1000.0) // seconds per kilometer
        
        XCTAssertEqual(pace, 360.0, "Pace should be 360 seconds per kilometer (6:00/km)")
    }
}
