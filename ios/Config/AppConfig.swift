import Foundation

/// Global configuration values for the iOS app
enum AppConfig {
    /// Base URL for server communication
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
    
    /// App Group identifier for sharing data between iOS and watchOS
    /// TODO: Enable when implementing watchOS sync
    // static let appGroupIdentifier = "group.com.mebeatme.shared"
    
    /// Maximum file size for import (10MB)
    static let maxFileSizeBytes: Int64 = 10 * 1024 * 1024
    
    /// Supported file extensions
    static let supportedFileExtensions = ["gpx", "tcx"]
    
    /// Default target window for PPI calculation (8 weeks)
    static let defaultTargetWindowSeconds = 8 * 7 * 24 * 3600
    
    /// Default distance buckets for bests tracking
    static let defaultDistanceBuckets: [Double] = [5000, 10000, 21097, 42195] // 5K, 10K, Half, Full
    
    /// Sync settings
    static let enableSync = false // TODO: Enable when server sync is implemented
    static let syncIntervalSeconds = 300 // 5 minutes
    
    /// Analytics settings
    static let enableAnalytics = true
    static let enableCrashReporting = true
    
    /// Debug settings
    static let enableDebugLogging = true
    static let enablePerformanceLogging = true
    
    /// UI settings
    static let defaultUnits: DistanceUnit = .metric
    static let enableHapticFeedback = true
    static let enableAnimations = true
    
    /// Distance unit preference
    enum DistanceUnit: String, CaseIterable {
        case metric = "metric"
        case imperial = "imperial"
        
        var displayName: String {
            switch self {
            case .metric:
                return "Metric (km)"
            case .imperial:
                return "Imperial (mi)"
            }
        }
    }
    
    /// Gets the current distance unit from UserDefaults
    static var currentDistanceUnit: DistanceUnit {
        if let unitString = UserDefaults.standard.string(forKey: "distanceUnit"),
           let unit = DistanceUnit(rawValue: unitString) {
            return unit
        }
        return defaultUnits
    }
    
    /// Sets the distance unit preference
    static func setDistanceUnit(_ unit: DistanceUnit) {
        UserDefaults.standard.set(unit.rawValue, forKey: "distanceUnit")
    }
    
    /// Gets app version information
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Gets build number
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Gets app display name
    static var appDisplayName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "MeBeatMe"
    }
    
    /// Gets bundle identifier
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.mebeatme.ios"
    }
    
    /// Checks if running in debug mode
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Checks if running in simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Gets device information
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown"
    }
    
    /// Gets iOS version
    static var iOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// Gets device name
    static var deviceName: String {
        return UIDevice.current.name
    }
    
    /// Gets user agent string for network requests
    static var userAgent: String {
        return "\(appDisplayName)/\(appVersion) (\(deviceModel); iOS \(iOSVersion))"
    }
    
    /// Gets privacy policy URL
    static var privacyPolicyURL: URL {
        return URL(string: "https://\(fullDomain)/privacy")!
    }
    
    /// Gets terms of service URL
    static var termsOfServiceURL: URL {
        return URL(string: "https://\(fullDomain)/terms")!
    }
    
    /// Gets support URL
    static var supportURL: URL {
        return URL(string: "https://\(fullDomain)/support")!
    }
    
    /// Gets feedback email
    static var feedbackEmail: String {
        return "feedback@\(fullDomain)"
    }
    
    /// Gets support email
    static var supportEmail: String {
        return "support@\(fullDomain)"
    }
}

/// Secrets and sensitive configuration
/// This would typically be loaded from a secure configuration file
enum Secrets {
    /// API key for server communication (if needed)
    static let apiKey: String? = nil
    
    /// Analytics API key (if using third-party analytics)
    static let analyticsKey: String? = nil
    
    /// Crash reporting API key (if using third-party crash reporting)
    static let crashReportingKey: String? = nil
    
    /// App Store Connect API key (for automated builds)
    static let appStoreConnectKey: String? = nil
}
