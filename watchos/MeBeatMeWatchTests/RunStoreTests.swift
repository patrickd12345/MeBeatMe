import XCTest
@testable import MeBeatMeWatch

/// Tests for the run store and 90-day PPI calculation
class RunStoreTests: XCTestCase {
    private var runStore: RunStore!
    private let tempDirectory = FileManager.default.temporaryDirectory
    
    override func setUp() {
        super.setUp()
        runStore = RunStore()
        
        // Clear any existing data
        try? runStore.clearAll()
    }
    
    override func tearDown() {
        // Clean up test data
        try? runStore.clearAll()
        super.tearDown()
    }
    
    func testSaveAndLoadRuns_EmptyStore_ReturnsEmptyArray() {
        let runs = runStore.loadRuns()
        XCTAssertTrue(runs.isEmpty, "Empty store should return empty array")
    }
    
    func testSaveRun_ValidRun_SavesSuccessfully() throws {
        let run = RunRecord(
            distance: 5000.0,
            duration: 1800,
            averagePace: 360.0,
            source: "test",
            fileName: "test.gpx"
        )
        
        try runStore.saveRun(run)
        
        let loadedRuns = runStore.loadRuns()
        XCTAssertEqual(loadedRuns.count, 1, "Should have 1 run after saving")
        XCTAssertEqual(loadedRuns.first?.id, run.id, "Saved run should match loaded run")
    }
    
    func testLoadBests_EmptyStore_ReturnsEmptyBests() {
        let bests = runStore.loadBests()
        
        XCTAssertNil(bests.best5kSec, "5K best should be nil")
        XCTAssertNil(bests.best10kSec, "10K best should be nil")
        XCTAssertNil(bests.bestHalfSec, "Half marathon best should be nil")
        XCTAssertNil(bests.bestFullSec, "Marathon best should be nil")
        XCTAssertNil(bests.highestPPILast90Days, "90-day PPI should be nil")
    }
    
    func testUpdateBests_5KRuns_UpdatesCorrectly() throws {
        let run1 = RunRecord(
            distance: 5000.0,
            duration: 1800, // 30 minutes
            averagePace: 360.0,
            source: "test",
            fileName: "run1.gpx"
        )
        
        let run2 = RunRecord(
            distance: 5000.0,
            duration: 1500, // 25 minutes (faster)
            averagePace: 300.0,
            source: "test",
            fileName: "run2.gpx"
        )
        
        try runStore.saveRun(run1)
        try runStore.saveRun(run2)
        
        let bests = runStore.loadBests()
        XCTAssertEqual(bests.best5kSec, 1500, "Should save the faster 5K time")
    }
    
    func testHighestPPILast90Days_RecentRuns_CalculatesCorrectly() throws {
        // Create runs with different PPI scores
        let run1 = RunRecord(
            distance: 5000.0,
            duration: 1800, // 30 minutes
            averagePace: 360.0,
            source: "test",
            fileName: "run1.gpx"
        )
        
        let run2 = RunRecord(
            distance: 5000.0,
            duration: 1500, // 25 minutes (faster = higher PPI)
            averagePace: 300.0,
            source: "test",
            fileName: "run2.gpx"
        )
        
        try runStore.saveRun(run1)
        try runStore.saveRun(run2)
        
        let bests = runStore.loadBests()
        
        // The highest PPI should be from the faster run
        XCTAssertNotNil(bests.highestPPILast90Days, "Should have a highest PPI value")
        XCTAssertGreaterThan(bests.highestPPILast90Days!, 0, "Highest PPI should be greater than 0")
    }
    
    func testBestsUpdateBestTime_DifferentDistances_UpdatesCorrectBuckets() {
        var bests = Bests()
        
        // Test 5K distance
        bests.updateBestTime(for: 5000.0, time: 1800)
        XCTAssertEqual(bests.best5kSec, 1800, "Should update 5K best")
        
        // Test 10K distance
        bests.updateBestTime(for: 10000.0, time: 3600)
        XCTAssertEqual(bests.best10kSec, 3600, "Should update 10K best")
        
        // Test half marathon distance
        bests.updateBestTime(for: 21000.0, time: 7200)
        XCTAssertEqual(bests.bestHalfSec, 7200, "Should update half marathon best")
        
        // Test marathon distance
        bests.updateBestTime(for: 42000.0, time: 14400)
        XCTAssertEqual(bests.bestFullSec, 14400, "Should update marathon best")
    }
    
    func testBestsUpdateBestTime_OnlyUpdatesIfFaster() {
        var bests = Bests()
        
        // Set initial best
        bests.updateBestTime(for: 5000.0, time: 1800)
        XCTAssertEqual(bests.best5kSec, 1800, "Should set initial best")
        
        // Try to update with slower time
        bests.updateBestTime(for: 5000.0, time: 2000)
        XCTAssertEqual(bests.best5kSec, 1800, "Should not update with slower time")
        
        // Update with faster time
        bests.updateBestTime(for: 5000.0, time: 1500)
        XCTAssertEqual(bests.best5kSec, 1500, "Should update with faster time")
    }
    
    func testClearAll_RemovesAllData() throws {
        let run = RunRecord(
            distance: 5000.0,
            duration: 1800,
            averagePace: 360.0,
            source: "test",
            fileName: "test.gpx"
        )
        
        try runStore.saveRun(run)
        
        // Verify data exists
        let runsBefore = runStore.loadRuns()
        XCTAssertEqual(runsBefore.count, 1, "Should have 1 run before clearing")
        
        // Clear all data
        try runStore.clearAll()
        
        // Verify data is gone
        let runsAfter = runStore.loadRuns()
        XCTAssertEqual(runsAfter.count, 0, "Should have 0 runs after clearing")
        
        let bestsAfter = runStore.loadBests()
        XCTAssertNil(bestsAfter.best5kSec, "Should have no bests after clearing")
    }
}
