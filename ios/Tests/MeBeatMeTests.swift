import XCTest
@testable import MeBeatMe

/// Tests for GPX parser functionality
class GPXParserTests: XCTestCase {
    private var parser: GPXParser!
    
    override func setUp() {
        super.setUp()
        parser = GPXParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    /// Tests parsing a valid GPX file
    func testParseValidGPX() async throws {
        // Load test GPX file
        guard let gpxURL = Bundle(for: type(of: self)).url(forResource: "sample_5k", withExtension: "gpx") else {
            XCTFail("Could not find sample_5k.gpx test file")
            return
        }
        
        let data = try Data(contentsOf: gpxURL)
        let runRecord = try await parser.parse(data: data, fileName: "sample_5k.gpx")
        
        // Verify basic properties
        XCTAssertEqual(runRecord.source, "gpx")
        XCTAssertEqual(runRecord.fileName, "sample_5k.gpx")
        XCTAssertGreaterThan(runRecord.distance, 0)
        XCTAssertGreaterThan(runRecord.duration, 0)
        XCTAssertGreaterThan(runRecord.averagePace, 0)
        
        // Verify distance is approximately 5km (within 10% tolerance)
        let expectedDistance: Double = 5000
        let tolerance: Double = 500
        XCTAssertEqual(runRecord.distance, expectedDistance, accuracy: tolerance)
    }
    
    /// Tests parsing an invalid GPX file
    func testParseInvalidGPX() async {
        let invalidData = "invalid gpx content".data(using: .utf8)!
        
        do {
            _ = try await parser.parse(data: invalidData, fileName: "invalid.gpx")
            XCTFail("Should have thrown an error for invalid GPX")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    /// Tests parsing an empty GPX file
    func testParseEmptyGPX() async {
        let emptyData = Data()
        
        do {
            _ = try await parser.parse(data: emptyData, fileName: "empty.gpx")
            XCTFail("Should have thrown an error for empty GPX")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    /// Tests parsing a GPX file with no track points
    func testParseGPXWithNoTrackPoints() async {
        let gpxWithoutTrackPoints = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Test">
            <trk>
                <name>Test Track</name>
            </trk>
        </gpx>
        """.data(using: .utf8)!
        
        do {
            _ = try await parser.parse(data: gpxWithoutTrackPoints, fileName: "no_trackpoints.gpx")
            XCTFail("Should have thrown an error for GPX with no track points")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}

/// Tests for RunStore persistence functionality
class RunStoreTests: XCTestCase {
    private var runStore: RunStore!
    private var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        
        // Create temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        runStore = RunStore()
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        runStore = nil
        super.tearDown()
    }
    
    /// Tests saving and loading runs
    func testSaveAndLoadRuns() throws {
        let run1 = RunRecord(
            distance: 5000,
            duration: 1800,
            averagePace: 360,
            source: "gpx",
            fileName: "test1.gpx"
        )
        
        let run2 = RunRecord(
            distance: 10000,
            duration: 3600,
            averagePace: 360,
            source: "gpx",
            fileName: "test2.gpx"
        )
        
        // Save runs
        try runStore.saveRun(run1)
        try runStore.saveRun(run2)
        
        // Load runs
        let loadedRuns = runStore.loadRuns()
        
        XCTAssertEqual(loadedRuns.count, 2)
        XCTAssertTrue(loadedRuns.contains { $0.fileName == "test1.gpx" })
        XCTAssertTrue(loadedRuns.contains { $0.fileName == "test2.gpx" })
    }
    
    /// Tests 90-day PPI calculation
    func test90DayPPICalculation() throws {
        let now = Date()
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: now)!
        let ninetyOneDaysAgo = Calendar.current.date(byAdding: .day, value: -91, to: now)!
        
        // Create runs: 2 inside 90 days with PPI 48.2/51.9, 1 at 91 days with PPI 49.7
        let run1 = RunRecord(
            date: ninetyDaysAgo,
            distance: 5000,
            duration: 1800, // 30:00 for 5K = ~48.2 PPI
            averagePace: 360,
            source: "gpx",
            fileName: "run1.gpx"
        )
        
        let run2 = RunRecord(
            date: Calendar.current.date(byAdding: .day, value: -1, to: now)!,
            distance: 5000,
            duration: 1700, // 28:20 for 5K = ~51.9 PPI
            averagePace: 340,
            source: "gpx",
            fileName: "run2.gpx"
        )
        
        let run3 = RunRecord(
            date: ninetyOneDaysAgo,
            distance: 5000,
            duration: 1750, // 29:10 for 5K = ~49.7 PPI
            averagePace: 350,
            source: "gpx",
            fileName: "run3.gpx"
        )
        
        // Save runs
        try runStore.saveRun(run1)
        try runStore.saveRun(run2)
        try runStore.saveRun(run3)
        
        // Get bests
        let bests = runStore.bests(now: now)
        
        // Should be 51.9 (highest PPI in last 90 days)
        XCTAssertEqual(bests.highestPPILast90Days, 51.9, accuracy: 1.0)
    }
    
    /// Tests bests calculation
    func testBestsCalculation() throws {
        let run1 = RunRecord(
            distance: 5000,
            duration: 1800, // 30:00
            averagePace: 360,
            source: "gpx",
            fileName: "run1.gpx"
        )
        
        let run2 = RunRecord(
            distance: 5000,
            duration: 1700, // 28:20 (better time)
            averagePace: 340,
            source: "gpx",
            fileName: "run2.gpx"
        )
        
        // Save runs
        try runStore.saveRun(run1)
        try runStore.saveRun(run2)
        
        // Get bests
        let bests = runStore.loadBests()
        
        // Should have best 5K time of 1700 seconds
        XCTAssertEqual(bests.best5kSec, 1700)
    }
    
    /// Tests deleting all runs
    func testDeleteAllRuns() throws {
        let run = RunRecord(
            distance: 5000,
            duration: 1800,
            averagePace: 360,
            source: "gpx",
            fileName: "test.gpx"
        )
        
        // Save run
        try runStore.saveRun(run)
        XCTAssertEqual(runStore.loadRuns().count, 1)
        
        // Delete all
        try runStore.deleteAll()
        XCTAssertEqual(runStore.loadRuns().count, 0)
    }
}

/// Tests for KMP bridge functionality
class KMPBridgeTests: XCTestCase {
    private var kmpBridge: KMPBridge!
    
    override func setUp() {
        super.setUp()
        kmpBridge = KMPBridge()
    }
    
    override func tearDown() {
        kmpBridge = nil
        super.tearDown()
    }
    
    /// Tests PPI calculation with known values
    func testPPICalculation() {
        // Test with known values: 5.94km in 41:38 should give ~355 PPI
        let distance: Double = 5940.0
        let duration = 2498 // 41:38 in seconds
        let expectedPPI: Double = 355.0
        
        let calculatedPPI = kmpBridge.calculatePPI(distance: distance, duration: duration)
        
        // Allow for small floating point differences
        XCTAssertEqual(calculatedPPI, expectedPPI, accuracy: 1.0)
    }
    
    /// Tests required pace calculation
    func testRequiredPaceCalculation() {
        let targetPPI: Double = 400.0
        let distance: Double = 5000.0
        
        let requiredPace = kmpBridge.calculateRequiredPace(for: targetPPI, distance: distance)
        
        // Should return a positive pace value
        XCTAssertGreaterThan(requiredPace, 0)
        
        // Verify that using this pace gives the target PPI
        let requiredTime = Int(requiredPace * (distance / 1000.0))
        let actualPPI = kmpBridge.calculatePPI(distance: distance, duration: requiredTime)
        
        XCTAssertEqual(actualPPI, targetPPI, accuracy: 1.0)
    }
    
    /// Tests bridge validation
    func testBridgeValidation() {
        let isValid = kmpBridge.validateBridge()
        XCTAssertTrue(isValid)
    }
    
    /// Tests PPI calculation edge cases
    func testPPICalculationEdgeCases() {
        // Very short distance
        let shortDistancePPI = kmpBridge.calculatePPI(distance: 100, duration: 30)
        XCTAssertGreaterThan(shortDistancePPI, 0)
        
        // Very long distance
        let longDistancePPI = kmpBridge.calculatePPI(distance: 50000, duration: 18000)
        XCTAssertGreaterThan(longDistancePPI, 0)
        
        // Very fast pace
        let fastPacePPI = kmpBridge.calculatePPI(distance: 5000, duration: 900)
        XCTAssertGreaterThan(fastPacePPI, 0)
        
        // Very slow pace
        let slowPacePPI = kmpBridge.calculatePPI(distance: 5000, duration: 3600)
        XCTAssertGreaterThan(slowPacePPI, 0)
    }
}

/// Tests for unit conversion utilities
class UnitsTests: XCTestCase {
    
    /// Tests distance conversions
    func testDistanceConversions() {
        let meters: Double = 1000
        
        // Meters to kilometers
        let kilometers = Units.metersToKilometers(meters)
        XCTAssertEqual(kilometers, 1.0)
        
        // Kilometers back to meters
        let backToMeters = Units.kilometersToMeters(kilometers)
        XCTAssertEqual(backToMeters, meters)
        
        // Meters to miles
        let miles = Units.metersToMiles(meters)
        XCTAssertEqual(miles, 0.621371, accuracy: 0.001)
        
        // Miles back to meters
        let backToMetersFromMiles = Units.milesToMeters(miles)
        XCTAssertEqual(backToMetersFromMiles, meters, accuracy: 1.0)
    }
    
    /// Tests time formatting
    func testTimeFormatting() {
        // Test MM:SS format
        let time1 = Units.formatTime(125) // 2:05
        XCTAssertEqual(time1, "2:05")
        
        // Test HH:MM:SS format
        let time2 = Units.formatTimeLong(3665) // 1:01:05
        XCTAssertEqual(time2, "1:01:05")
        
        // Test HH:MM:SS format with hours
        let time3 = Units.formatTimeLong(7200) // 2:00:00
        XCTAssertEqual(time3, "2:00:00")
    }
    
    /// Tests pace formatting
    func testPaceFormatting() {
        let paceSecondsPerKm: Double = 300 // 5:00/km
        
        let formattedPace = Units.formatPace(paceSecondsPerKm)
        XCTAssertEqual(formattedPace, "5:00/km")
        
        let formattedPacePerMile = Units.formatPacePerMile(paceSecondsPerKm)
        XCTAssertEqual(formattedPacePerMile, "8:03/mi")
    }
    
    /// Tests distance formatting
    func testDistanceFormatting() {
        let meters: Double = 5000
        
        let formattedDistance = Units.formatDistance(meters)
        XCTAssertEqual(formattedDistance, "5.0 km")
        
        let formattedDistanceMiles = Units.formatDistanceMiles(meters)
        XCTAssertEqual(formattedDistanceMiles, "3.11 mi")
    }
    
    /// Tests speed conversions
    func testSpeedConversions() {
        let paceSecondsPerKm: Double = 300 // 5:00/km
        
        // Pace to speed
        let speedKmh = Units.paceToSpeed(paceSecondsPerKm)
        XCTAssertEqual(speedKmh, 12.0) // 12 km/h
        
        // Speed back to pace
        let backToPace = Units.speedToPace(speedKmh)
        XCTAssertEqual(backToPace, paceSecondsPerKm, accuracy: 0.1)
    }
    
    /// Tests temperature conversions
    func testTemperatureConversions() {
        let celsius: Double = 20.0
        
        // Celsius to Fahrenheit
        let fahrenheit = Units.celsiusToFahrenheit(celsius)
        XCTAssertEqual(fahrenheit, 68.0)
        
        // Fahrenheit back to Celsius
        let backToCelsius = Units.fahrenheitToCelsius(fahrenheit)
        XCTAssertEqual(backToCelsius, celsius, accuracy: 0.1)
    }
    
    /// Tests heart rate calculations
    func testHeartRateCalculations() {
        let age = 30
        
        // Maximum heart rate
        let maxHR = Units.maxHeartRate(age: age)
        XCTAssertEqual(maxHR, 190)
        
        // Heart rate zones
        let zones = Units.heartRateZones(age: age)
        
        // Test zone 1 (50-60% of max HR)
        XCTAssertTrue(zones.zone1.contains(95)) // 50% of 190
        XCTAssertTrue(zones.zone1.contains(114)) // 60% of 190
        
        // Test zone 5 (90-100% of max HR)
        XCTAssertTrue(zones.zone5.contains(171)) // 90% of 190
        XCTAssertTrue(zones.zone5.contains(190)) // 100% of 190
    }
    
    /// Tests PPI formatting
    func testPPIFormatting() {
        let ppi: Double = 355.7
        
        let formattedPPI = Units.formatPPI(ppi)
        XCTAssertEqual(formattedPPI, "355.7")
        
        let performanceLevel = Units.performanceLevelDescription(ppi)
        XCTAssertEqual(performanceLevel, "Advanced")
    }
}
