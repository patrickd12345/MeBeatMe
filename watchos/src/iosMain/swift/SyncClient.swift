import Foundation

/// Handles network synchronization with the Ktor server.
final class SyncClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: () -> String?

    init(baseURL: URL = AppConfig.baseURL,
         session: URLSession = .shared,
         tokenProvider: @escaping () -> String? = { Secrets.token }) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    /// Uploads an array of runs to the server.
    func upload(runs: [Run]) async throws {
        let url = baseURL.appendingPathComponent("sync/runs")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(runs)
        _ = try await session.data(for: request)
    }

    /// Fetches latest bests from the server.
    func fetchBests() async throws -> Bests {
        let url = baseURL.appendingPathComponent("sync/bests")
        var request = URLRequest(url: url)
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Bests.self, from: data)
    }
}
