import Foundation
import Observation
import os

/// ViewModel for settings
@Observable
class SettingsViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "SettingsViewModel")
    private let runStore = RunStore()
    
    var units: DistanceUnit = .metric
    var targetWindow: TargetWindow = .medium
    var defaultBucket: DistanceBucket = .shortRun
    var enableNotifications: Bool = true
    var enableHapticFeedback: Bool = true
    var enableAnalytics: Bool = true
    var syncEnabled: Bool = true
    var autoImport: Bool = false
    
    // App info
    var appVersion: String = "1.0.0"
    var buildNumber: String = "1"
    var lastSyncDate: Date?
    var totalRunsCount: Int = 0
    var totalDistanceKm: Double = 0.0
    
    enum DistanceUnit: String, CaseIterable, Codable {
        case metric = "Metric"
        case imperial = "Imperial"
        
        var description: String {
            switch self {
            case .metric:
                return "Kilometers and meters"
            case .imperial:
                return "Miles and feet"
            }
        }
    }
    
    enum TargetWindow: String, CaseIterable, Codable {
        case short = "Short (5 min)"
        case medium = "Medium (10 min)"
        case long = "Long (20 min)"
        
        var durationMinutes: Int {
            switch self {
            case .short: return 5
            case .medium: return 10
            case .long: return 20
            }
        }
        
        var description: String {
            switch self {
            case .short:
                return "Quick challenges for busy schedules"
            case .medium:
                return "Balanced challenges for regular training"
            case .long:
                return "Extended challenges for dedicated sessions"
            }
        }
    }
    
    enum DistanceBucket: String, CaseIterable, Codable {
        case sprint = "Sprint (1-3km)"
        case shortRun = "Short Run (3-8km)"
        case mediumRun = "Medium Run (8-15km)"
        case longRun = "Long Run (15-25km)"
        case ultraRun = "Ultra Run (25km+)"
        
        var minDistance: Double {
            switch self {
            case .sprint: return 1000
            case .shortRun: return 3000
            case .mediumRun: return 8000
            case .longRun: return 15000
            case .ultraRun: return 25000
            }
        }
        
        var maxDistance: Double {
            switch self {
            case .sprint: return 3000
            case .shortRun: return 8000
            case .mediumRun: return 15000
            case .longRun: return 25000
            case .ultraRun: return Double.infinity
            }
        }
        
        var description: String {
            switch self {
            case .sprint:
                return "Short, fast efforts"
            case .shortRun:
                return "Quick training runs"
            case .mediumRun:
                return "Standard training distance"
            case .longRun:
                return "Endurance building runs"
            case .ultraRun:
                return "Ultra-distance challenges"
            }
        }
    }
    
    init() {
        loadSettings()
        loadAppInfo()
    }
    
    /// Loads settings from UserDefaults
    private func loadSettings() {
        if let unitsString = UserDefaults.standard.string(forKey: "units"),
           let units = DistanceUnit(rawValue: unitsString) {
            self.units = units
        }
        
        if let windowString = UserDefaults.standard.string(forKey: "targetWindow"),
           let window = TargetWindow(rawValue: windowString) {
            self.targetWindow = window
        }
        
        if let bucketString = UserDefaults.standard.string(forKey: "defaultBucket"),
           let bucket = DistanceBucket(rawValue: bucketString) {
            self.defaultBucket = bucket
        }
        
        enableNotifications = UserDefaults.standard.object(forKey: "enableNotifications") as? Bool ?? true
        enableHapticFeedback = UserDefaults.standard.object(forKey: "enableHapticFeedback") as? Bool ?? true
        enableAnalytics = UserDefaults.standard.object(forKey: "enableAnalytics") as? Bool ?? true
        syncEnabled = UserDefaults.standard.object(forKey: "syncEnabled") as? Bool ?? true
        autoImport = UserDefaults.standard.object(forKey: "autoImport") as? Bool ?? false
        
        if let lastSync = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date {
            self.lastSyncDate = lastSync
        }
        
        AppLogger.logUserAction("settings_loaded", parameters: [
            "units": units.rawValue,
            "target_window": targetWindow.rawValue,
            "default_bucket": defaultBucket.rawValue,
            "notifications": enableNotifications,
            "haptic": enableHapticFeedback,
            "analytics": enableAnalytics,
            "sync": syncEnabled
        ])
        
        logger.info("Loaded settings - Units: \(units.rawValue), Window: \(targetWindow.rawValue), Bucket: \(defaultBucket.rawValue)")
    }
    
    /// Loads app information
    private func loadAppInfo() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        // Load run statistics
        let runs = runStore.loadRuns()
        totalRunsCount = runs.count
        totalDistanceKm = runs.reduce(0) { $0 + $1.distance } / 1000.0
    }
    
    /// Saves settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(units.rawValue, forKey: "units")
        UserDefaults.standard.set(targetWindow.rawValue, forKey: "targetWindow")
        UserDefaults.standard.set(defaultBucket.rawValue, forKey: "defaultBucket")
        UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        UserDefaults.standard.set(enableHapticFeedback, forKey: "enableHapticFeedback")
        UserDefaults.standard.set(enableAnalytics, forKey: "enableAnalytics")
        UserDefaults.standard.set(syncEnabled, forKey: "syncEnabled")
        UserDefaults.standard.set(autoImport, forKey: "autoImport")
        
        if let lastSync = lastSyncDate {
            UserDefaults.standard.set(lastSync, forKey: "lastSyncDate")
        }
        
        AppLogger.logUserAction("settings_saved", parameters: [
            "units": units.rawValue,
            "target_window": targetWindow.rawValue,
            "default_bucket": defaultBucket.rawValue,
            "notifications": enableNotifications,
            "haptic": enableHapticFeedback,
            "analytics": enableAnalytics,
            "sync": syncEnabled
        ])
        
        logger.info("Saved settings - Units: \(units.rawValue), Window: \(targetWindow.rawValue), Bucket: \(defaultBucket.rawValue)")
    }
    
    /// Resets all settings to defaults
    func resetToDefaults() {
        units = .metric
        targetWindow = .medium
        defaultBucket = .shortRun
        enableNotifications = true
        enableHapticFeedback = true
        enableAnalytics = true
        syncEnabled = true
        autoImport = false
        
        saveSettings()
        
        AppLogger.logUserAction("settings_reset")
        logger.info("Reset settings to defaults")
    }
    
    /// Clears all app data
    func clearAllData() throws {
        try runStore.clearAll()
        
        // Reset settings
        resetToDefaults()
        
        // Clear UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        AppLogger.logUserAction("data_cleared")
        logger.info("Cleared all app data")
    }
    
    /// Formats distance based on current units
    func formatDistance(_ distance: Double) -> String {
        switch units {
        case .metric:
            return Units.formatDistance(distance)
        case .imperial:
            return Units.formatDistanceMiles(distance)
        }
    }
    
    /// Formats pace based on current units
    func formatPace(_ pace: Double) -> String {
        switch units {
        case .metric:
            return Units.formatPace(pace)
        case .imperial:
            return Units.formatPacePerMile(pace)
        }
    }
    
    /// Formats total distance for display
    var formattedTotalDistance: String {
        return formatDistance(totalDistanceKm * 1000)
    }
    
    /// Formats last sync date
    var formattedLastSyncDate: String {
        guard let lastSync = lastSyncDate else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastSync, relativeTo: Date())
    }
    
    /// Gets storage usage information
    var storageInfo: (used: String, available: String) {
        let used = Files.formatFileSize(Int64(totalDistanceKm * 1000)) // Rough estimate
        let available = Files.formatFileSize(Files.availableDiskSpace() ?? 0)
        return (used, available)
    }
    
    /// Checks if sync is available
    var isSyncAvailable: Bool {
        return syncEnabled && AppConfig.baseURL.scheme == "https"
    }
    
    /// Gets app information for display
    var appInfo: String {
        return "MeBeatMe v\(appVersion) (\(buildNumber))"
    }
    
    /// Gets domain information
    var domainInfo: String {
        return AppConfig.fullDomain
    }
    
    /// Gets supported file formats
    var supportedFileFormats: [String] {
        return ["GPX", "TCX"] // FIT not yet supported
    }
    
    /// Gets maximum file size
    var maxFileSize: String {
        return "10 MB"
    }
    
    /// Gets privacy policy URL
    var privacyPolicyURL: String {
        return "https://\(AppConfig.fullDomain)/privacy"
    }
    
    /// Gets terms of service URL
    var termsOfServiceURL: String {
        return "https://\(AppConfig.fullDomain)/terms"
    }
    
    /// Gets support URL
    var supportURL: String {
        return "https://\(AppConfig.fullDomain)/support"
    }
}
