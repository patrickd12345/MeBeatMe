import XCTest
@testable import watchos

final class RunStoreTests: XCTestCase {
    func testSaveLoad() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let store = RunStore(fileManager: fm, directory: dir)
        let run = Run(startedAt: Date(),
                      endedAt: Date(),
                      distanceM: 1000,
                      elapsedSec: 400,
                      avgPaceSecPerKm: 400,
                      avgHr: nil,
                      purdyScore: 50)
        store.save(run)
        let list = store.list()
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.first?.id, run.id)
    }
}
