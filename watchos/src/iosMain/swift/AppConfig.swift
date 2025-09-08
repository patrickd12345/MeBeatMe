import Foundation

/// Global configuration values.
enum AppConfig {
    /// Base URL for server communication.
    /// Uses subdomain in production, localhost in development
    static let baseURL: URL = {
        #if DEBUG
        return URL(string: "http://localhost:8080")!
        #else
        return URL(string: "https://mebeatme.ready2race.me")!
        #endif
    }()
    
    /// API version for server communication
    static let apiVersion = "v1"
    
    /// Full API base URL with version
    static var apiBaseURL: URL {
        return baseURL.appendingPathComponent("api").appendingPathComponent(apiVersion)
    }
    
    /// Domain configuration
    static let domain = "ready2race.me"
    static let subdomain = "mebeatme"
    static let fullDomain = "\(subdomain).\(domain)"
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
