import Foundation

/// Global configuration values.
enum AppConfig {
    /// Base URL for server communication.
    static let baseURL = URL(string: "http://localhost:8080")!
}

/// Access token loaded from Secrets.plist. Not committed to source control.
enum Secrets {
    static var token: String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }
        return dict["token"] as? String
    }
}
