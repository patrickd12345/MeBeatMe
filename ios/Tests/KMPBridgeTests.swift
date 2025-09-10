import XCTest
@testable import MeBeatMeWatch
import shared

class KMPBridgeTests: XCTestCase {
    
    func testPurdyScoreCalculation() throws {
        // Test 5K (5000m) - recreational runner time
        let score5k = try PerfIndex.purdyScore(distanceMeters: 5000.0, durationSec: 1500) // 5K in 25:00
        XCTAssertEqual(score5k, 355.0, accuracy: 1.0) // Should be around 355 points
        
        // Test 10K (10000m) - recreational runner time  
        let score10k = try PerfIndex.purdyScore(distanceMeters: 10000.0, durationSec: 3000) // 10K in 50:00
        XCTAssertEqual(score10k, 355.0, accuracy: 1.0) // Should be around 355 points
        
        // Test Half Marathon (21097.5m) - recreational runner time
        let scoreHalf = try PerfIndex.purdyScore(distanceMeters: 21097.5, durationSec: 6300) // Half in 1:45:00
        XCTAssertEqual(scoreHalf, 355.0, accuracy: 1.0) // Should be around 355 points
    }
    
    func testPurdyScoreElitePerformance() throws {
        // Elite 5K time (13:00 = 780 seconds)
        let eliteScore = try PerfIndex.purdyScore(distanceMeters: 5000.0, durationSec: 780)
        XCTAssertEqual(eliteScore, 1000.0, accuracy: 1.0) // Should be exactly 1000 points
        
        // Elite 10K time (27:00 = 1620 seconds)
        let elite10kScore = try PerfIndex.purdyScore(distanceMeters: 10000.0, durationSec: 1620)
        XCTAssertEqual(elite10kScore, 1000.0, accuracy: 1.0) // Should be exactly 1000 points
    }
    
    func testPurdyScoreInvalidInputs() {
        // Test negative distance
        XCTAssertThrowsError(try PerfIndex.purdyScore(distanceMeters: -100.0, durationSec: 300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test negative duration
        XCTAssertThrowsError(try PerfIndex.purdyScore(distanceMeters: 5000.0, durationSec: -300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test zero distance
        XCTAssertThrowsError(try PerfIndex.purdyScore(distanceMeters: 0.0, durationSec: 300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test zero duration
        XCTAssertThrowsError(try PerfIndex.purdyScore(distanceMeters: 5000.0, durationSec: 0)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
    }
    
    func testTargetPaceCalculation() throws {
        // 5K in 20 minutes = 4:00/km
        let pace5k = try PerfIndex.targetPace(distanceMeters: 5000.0, windowSec: 1200)
        XCTAssertEqual(pace5k, 240.0, accuracy: 0.1) // 4:00 = 240 seconds
        
        // 10K in 40 minutes = 4:00/km
        let pace10k = try PerfIndex.targetPace(distanceMeters: 10000.0, windowSec: 2400)
        XCTAssertEqual(pace10k, 240.0, accuracy: 0.1) // 4:00 = 240 seconds
        
        // Half Marathon in 1:30 = 4:16/km
        let paceHalf = try PerfIndex.targetPace(distanceMeters: 21097.5, windowSec: 5400)
        XCTAssertEqual(paceHalf, 256.0, accuracy: 1.0) // 4:16 = 256 seconds
    }
    
    func testTargetPaceInvalidInputs() {
        // Test negative distance
        XCTAssertThrowsError(try PerfIndex.targetPace(distanceMeters: -100.0, windowSec: 300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test negative window
        XCTAssertThrowsError(try PerfIndex.targetPace(distanceMeters: 5000.0, windowSec: -300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test zero distance
        XCTAssertThrowsError(try PerfIndex.targetPace(distanceMeters: 0.0, windowSec: 300)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
        
        // Test zero window
        XCTAssertThrowsError(try PerfIndex.targetPace(distanceMeters: 5000.0, windowSec: 0)) { error in
            XCTAssertTrue(error is PerfIndexError)
        }
    }
    
    func testHighestPpiInWindow() {
        let nowMs: Int64 = 1700000000000 // Some timestamp
        let dayMs: Int64 = 24 * 3600 * 1000
        
        let runs = [
            RunDTO(id: "1", source: "GPX", startedAtEpochMs: nowMs - 10 * dayMs, endedAtEpochMs: nowMs - 10 * dayMs + 1500, distanceMeters: 5000.0, elapsedSeconds: 1500, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: 400.0, notes: nil),
            RunDTO(id: "2", source: "GPX", startedAtEpochMs: nowMs - 50 * dayMs, endedAtEpochMs: nowMs - 50 * dayMs + 1200, distanceMeters: 5000.0, elapsedSeconds: 1200, avgPaceSecPerKm: 240.0, avgHr: nil, ppi: 600.0, notes: nil),
            RunDTO(id: "3", source: "GPX", startedAtEpochMs: nowMs - 100 * dayMs, endedAtEpochMs: nowMs - 100 * dayMs + 1800, distanceMeters: 5000.0, elapsedSeconds: 1800, avgPaceSecPerKm: 360.0, avgHr: nil, ppi: 300.0, notes: nil), // Outside 90 days
            RunDTO(id: "4", source: "GPX", startedAtEpochMs: nowMs - 5 * dayMs, endedAtEpochMs: nowMs - 5 * dayMs + 1400, distanceMeters: 5000.0, elapsedSeconds: 1400, avgPaceSecPerKm: 280.0, avgHr: nil, ppi: 500.0, notes: nil)
        ]
        
        let highest = PerfIndex.highestPpiInWindow(runs: runs, nowMs: nowMs, days: 90)
        XCTAssertEqual(highest, 600.0) // Should find the 600 PPI run
    }
    
    func testHighestPpiInWindowNoRuns() {
        let nowMs: Int64 = 1700000000000
        let runs = [
            RunDTO(id: "1", source: "GPX", startedAtEpochMs: nowMs - 100 * 24 * 3600 * 1000, endedAtEpochMs: nowMs - 100 * 24 * 3600 * 1000 + 1500, distanceMeters: 5000.0, elapsedSeconds: 1500, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: 400.0, notes: nil)
        ]
        
        let highest = PerfIndex.highestPpiInWindow(runs: runs, nowMs: nowMs, days: 90)
        XCTAssertNil(highest) // Should return nil
    }
    
    func testHighestPpiInWindowIgnoresNullPpi() {
        let nowMs: Int64 = 1700000000000
        let dayMs: Int64 = 24 * 3600 * 1000
        
        let runs = [
            RunDTO(id: "1", source: "GPX", startedAtEpochMs: nowMs - 10 * dayMs, endedAtEpochMs: nowMs - 10 * dayMs + 1500, distanceMeters: 5000.0, elapsedSeconds: 1500, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil),
            RunDTO(id: "2", source: "GPX", startedAtEpochMs: nowMs - 20 * dayMs, endedAtEpochMs: nowMs - 20 * dayMs + 1200, distanceMeters: 5000.0, elapsedSeconds: 1200, avgPaceSecPerKm: 240.0, avgHr: nil, ppi: 600.0, notes: nil)
        ]
        
        let highest = PerfIndex.highestPpiInWindow(runs: runs, nowMs: nowMs, days: 90)
        XCTAssertEqual(highest, 600.0) // Should find the 600 PPI run, ignore null
    }
    
    func testCalculateBests() {
        let runs = [
            RunDTO(id: "1", source: "GPX", startedAtEpochMs: 1000, endedAtEpochMs: 2000, distanceMeters: 5000.0, elapsedSeconds: 1500, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil), // 5K in 25:00
            RunDTO(id: "2", source: "GPX", startedAtEpochMs: 2000, endedAtEpochMs: 3000, distanceMeters: 5000.0, elapsedSeconds: 1200, avgPaceSecPerKm: 240.0, avgHr: nil, ppi: nil, notes: nil), // 5K in 20:00 (better)
            RunDTO(id: "3", source: "GPX", startedAtEpochMs: 3000, endedAtEpochMs: 4000, distanceMeters: 10000.0, elapsedSeconds: 3000, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil), // 10K in 50:00
            RunDTO(id: "4", source: "GPX", startedAtEpochMs: 4000, endedAtEpochMs: 5000, distanceMeters: 10000.0, elapsedSeconds: 2400, avgPaceSecPerKm: 240.0, avgHr: nil, ppi: nil, notes: nil), // 10K in 40:00 (better)
            RunDTO(id: "5", source: "GPX", startedAtEpochMs: 5000, endedAtEpochMs: 6000, distanceMeters: 21097.5, elapsedSeconds: 6300, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil), // Half in 1:45:00
            RunDTO(id: "6", source: "GPX", startedAtEpochMs: 6000, endedAtEpochMs: 7000, distanceMeters: 21097.5, elapsedSeconds: 5400, avgPaceSecPerKm: 256.0, avgHr: nil, ppi: nil, notes: nil), // Half in 1:30:00 (better)
            RunDTO(id: "7", source: "GPX", startedAtEpochMs: 7000, endedAtEpochMs: 8000, distanceMeters: 42195.0, elapsedSeconds: 12600, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil), // Full in 3:30:00
            RunDTO(id: "8", source: "GPX", startedAtEpochMs: 8000, endedAtEpochMs: 9000, distanceMeters: 42195.0, elapsedSeconds: 10800, avgPaceSecPerKm: 256.0, avgHr: nil, ppi: nil, notes: nil) // Full in 3:00:00 (better)
        ]
        
        let bests = PerfIndex.calculateBests(runs: runs)
        
        XCTAssertEqual(bests.best5kSec, 1200) // 20:00
        XCTAssertEqual(bests.best10kSec, 2400) // 40:00
        XCTAssertEqual(bests.bestHalfSec, 5400) // 1:30:00
        XCTAssertEqual(bests.bestFullSec, 10800) // 3:00:00
    }
    
    func testCalculateBestsEmptyList() {
        let bests = PerfIndex.calculateBests(runs: [])
        
        XCTAssertNil(bests.best5kSec)
        XCTAssertNil(bests.best10kSec)
        XCTAssertNil(bests.bestHalfSec)
        XCTAssertNil(bests.bestFullSec)
        XCTAssertNil(bests.highestPPILast90Days)
    }
    
    func testCalculateBestsWithSinceFilter() {
        let baseTime: Int64 = 1700000000000
        let runs = [
            RunDTO(id: "1", source: "GPX", startedAtEpochMs: baseTime - 1000, endedAtEpochMs: baseTime - 1000 + 1500, distanceMeters: 5000.0, elapsedSeconds: 1500, avgPaceSecPerKm: 300.0, avgHr: nil, ppi: nil, notes: nil), // Old run
            RunDTO(id: "2", source: "GPX", startedAtEpochMs: baseTime + 1000, endedAtEpochMs: baseTime + 1000 + 1200, distanceMeters: 5000.0, elapsedSeconds: 1200, avgPaceSecPerKm: 240.0, avgHr: nil, ppi: nil, notes: nil) // Recent run
        ]
        
        let bests = PerfIndex.calculateBests(runs: runs, sinceMs: baseTime)
        
        XCTAssertEqual(bests.best5kSec, 1200) // Should only find the recent run
    }
}

