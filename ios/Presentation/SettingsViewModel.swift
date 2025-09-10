import Foundation
import Observation
import os

/// ViewModel for settings
@Observable
class SettingsViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "SettingsViewModel")
    private let runStore = RunStore()
    
    var units: AppConfig.DistanceUnit = .metric
    var enableNotifications: Bool = true
    var enableHapticFeedback: Bool = true
    var enableAnalytics: Bool = true
    var enableSync: Bool = false
    var enableAutoImport: Bool = false
    
    // App info
    var appVersion: String = "1.0.0"
    var buildNumber: String = "1"
    var lastSyncDate: Date?
    var totalRunsCount: Int = 0
    var totalDistanceKm: Double = 0.0
    
    init() {
        loadSettings()
        loadAppInfo()
    }
    
    /// Loads settings from UserDefaults
    private func loadSettings() {
        if let unitsString = UserDefaults.standard.string(forKey: "units"),
           let units = AppConfig.DistanceUnit(rawValue: unitsString) {
            self.units = units
        }
        
        enableNotifications = UserDefaults.standard.object(forKey: "enableNotifications") as? Bool ?? true
        enableHapticFeedback = UserDefaults.standard.object(forKey: "enableHapticFeedback") as? Bool ?? true
        enableAnalytics = UserDefaults.standard.object(forKey: "enableAnalytics") as? Bool ?? true
        enableSync = UserDefaults.standard.object(forKey: "enableSync") as? Bool ?? false
        enableAutoImport = UserDefaults.standard.object(forKey: "enableAutoImport") as? Bool ?? false
        
        if let lastSync = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date {
            self.lastSyncDate = lastSync
        }
        
        AppLogger.logUserAction("settings_loaded", parameters: [
            "units": units.rawValue,
            "notifications": enableNotifications,
            "haptic": enableHapticFeedback,
            "analytics": enableAnalytics,
            "sync": enableSync
        ])
        
        logger.info("Loaded settings - Units: \(units.rawValue)")
    }
    
    /// Loads app information
    private func loadAppInfo() {
        appVersion = AppConfig.appVersion
        buildNumber = AppConfig.buildNumber
        
        // Load run statistics
        let runs = runStore.loadRuns()
        totalRunsCount = runs.count
        totalDistanceKm = runs.reduce(0) { $0 + $1.distance } / 1000.0
    }
    
    /// Saves settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(units.rawValue, forKey: "units")
        UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        UserDefaults.standard.set(enableHapticFeedback, forKey: "enableHapticFeedback")
        UserDefaults.standard.set(enableAnalytics, forKey: "enableAnalytics")
        UserDefaults.standard.set(enableSync, forKey: "enableSync")
        UserDefaults.standard.set(enableAutoImport, forKey: "enableAutoImport")
        
        if let lastSync = lastSyncDate {
            UserDefaults.standard.set(lastSync, forKey: "lastSyncDate")
        }
        
        AppLogger.logUserAction("settings_saved", parameters: [
            "units": units.rawValue,
            "notifications": enableNotifications,
            "haptic": enableHapticFeedback,
            "analytics": enableAnalytics,
            "sync": enableSync
        ])
        
        logger.info("Saved settings - Units: \(units.rawValue)")
    }
    
    /// Resets all settings to defaults
    func resetToDefaults() {
        units = .metric
        enableNotifications = true
        enableHapticFeedback = true
        enableAnalytics = true
        enableSync = false
        enableAutoImport = false
        
        saveSettings()
        
        AppLogger.logUserAction("settings_reset")
        logger.info("Reset settings to defaults")
    }
    
    /// Clears all app data
    func clearAllData() throws {
        try runStore.deleteAll()
        
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
        return enableSync && AppConfig.enableSync
    }
    
    /// Gets app information for display
    var appInfo: String {
        return "\(AppConfig.appDisplayName) v\(appVersion) (\(buildNumber))"
    }
    
    /// Gets domain information
    var domainInfo: String {
        return AppConfig.fullDomain
    }
    
    /// Gets supported file formats
    var supportedFileFormats: [String] {
        return AppConfig.supportedFileExtensions.map { $0.uppercased() }
    }
    
    /// Gets maximum file size
    var maxFileSize: String {
        return Files.formatFileSize(AppConfig.maxFileSizeBytes)
    }
    
    /// Gets privacy policy URL
    var privacyPolicyURL: String {
        return AppConfig.privacyPolicyURL.absoluteString
    }
    
    /// Gets terms of service URL
    var termsOfServiceURL: String {
        return AppConfig.termsOfServiceURL.absoluteString
    }
    
    /// Gets support URL
    var supportURL: String {
        return AppConfig.supportURL.absoluteString
    }
    
    /// Gets feedback email
    var feedbackEmail: String {
        return AppConfig.feedbackEmail
    }
    
    /// Gets support email
    var supportEmail: String {
        return AppConfig.supportEmail
    }
    
    /// Gets device information
    var deviceInfo: String {
        return "\(AppConfig.deviceModel) • iOS \(AppConfig.iOSVersion)"
    }
    
    /// Gets debug information
    var debugInfo: String {
        var info = "Debug Mode: \(AppConfig.isDebugMode ? "Yes" : "No")\n"
        info += "Simulator: \(AppConfig.isSimulator ? "Yes" : "No")\n"
        info += "Bundle ID: \(AppConfig.bundleIdentifier)\n"
        info += "User Agent: \(AppConfig.userAgent)"
        return info
    }
    
    /// Exports app data for debugging
    func exportAppData() -> String {
        let runs = runStore.loadRuns()
        let bests = runStore.loadBests()
        
        var export = "MeBeatMe Data Export\n"
        export += "===================\n\n"
        export += "Export Date: \(Date())\n"
        export += "App Version: \(appVersion) (\(buildNumber))\n"
        export += "Device: \(deviceInfo)\n\n"
        
        export += "Runs (\(runs.count)):\n"
        for run in runs {
            export += "- \(run.fileName): \(Units.formatDistance(run.distance)) in \(Units.formatTime(run.duration))\n"
        }
        
        export += "\nBests:\n"
        export += "- 5K: \(bests.formattedBestTime(for: 5000) ?? "N/A")\n"
        export += "- 10K: \(bests.formattedBestTime(for: 10000) ?? "N/A")\n"
        export += "- Half: \(bests.formattedBestTime(for: 21097) ?? "N/A")\n"
        export += "- Full: \(bests.formattedBestTime(for: 42195) ?? "N/A")\n"
        export += "- Highest PPI (90d): \(Units.formatPPI(bests.highestPPILast90Days))\n"
        
        return export
    }
}
