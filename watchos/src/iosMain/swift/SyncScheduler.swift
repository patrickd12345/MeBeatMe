import Foundation
import Combine

/// Schedules background synchronization attempts.
final class SyncScheduler {
    private let store: RunStore
    private let client: SyncClient
    private var cancellables = Set<AnyCancellable>()

    init(store: RunStore, client: SyncClient = SyncClient()) {
        self.store = store
        self.client = client
    }

    /// Attempts to sync immediately.
    func syncNow() async {
        do {
            try await client.upload(runs: store.list())
        } catch {
            print("Sync failed: \(error)")
        }
    }
}
