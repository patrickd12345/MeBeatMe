import XCTest
@testable import MeBeatMeWatch

/// Tests for GPX file parsing
class GPXParserTests: XCTestCase {
    private let parser = GPXParser()
    
    func testParseGPX_ValidFile_ReturnsRunRecord() async throws {
        // Create a simple GPX content for testing
        let gpxContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Test">
            <trk>
                <trkseg>
                    <trkpt lat="37.7749" lon="-122.4194">
                        <time>2024-01-01T12:00:00Z</time>
                    </trkpt>
                    <trkpt lat="37.7849" lon="-122.4294">
                        <time>2024-01-01T12:30:00Z</time>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """
        
        let data = gpxContent.data(using: .utf8)!
        
        let runRecord = try await parser.parse(data: data, fileName: "test.gpx")
        
        XCTAssertEqual(runRecord.fileName, "test.gpx")
        XCTAssertEqual(runRecord.source, "gpx")
        XCTAssertGreaterThan(runRecord.distance, 0, "Distance should be greater than 0")
        XCTAssertGreaterThan(runRecord.duration, 0, "Duration should be greater than 0")
    }
    
    func testParseGPX_InvalidFile_ThrowsError() async {
        let invalidData = "invalid gpx content".data(using: .utf8)!
        
        do {
            _ = try await parser.parse(data: invalidData, fileName: "invalid.gpx")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError, "Should throw AppError")
        }
    }
    
    func testParseGPX_EmptyFile_ThrowsError() async {
        let emptyData = Data()
        
        do {
            _ = try await parser.parse(data: emptyData, fileName: "empty.gpx")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError, "Should throw AppError")
        }
    }
    
    func testParseGPX_NoTrackPoints_ThrowsError() async {
        let gpxContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Test">
            <trk>
                <trkseg>
                </trkseg>
            </trk>
        </gpx>
        """
        
        let data = gpxContent.data(using: .utf8)!
        
        do {
            _ = try await parser.parse(data: data, fileName: "empty.gpx")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AppError, "Should throw AppError")
        }
    }
}
