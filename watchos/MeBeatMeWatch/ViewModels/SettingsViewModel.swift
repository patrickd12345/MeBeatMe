import Foundation
import Observation
import os

/// ViewModel for settings
@Observable
class SettingsViewModel {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "SettingsViewModel")
    
    var units: DistanceUnit = .metric
    var targetWindow: TargetWindow = .medium
    var defaultBucket: DistanceBucket = .shortRun
    
    enum DistanceUnit: String, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    enum TargetWindow: String, CaseIterable {
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
    }
    
    enum DistanceBucket: String, CaseIterable {
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
    }
    
    init() {
        loadSettings()
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
        
        logger.info("Loaded settings - Units: \(units.rawValue), Window: \(targetWindow.rawValue), Bucket: \(defaultBucket.rawValue)")
    }
    
    /// Saves settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(units.rawValue, forKey: "units")
        UserDefaults.standard.set(targetWindow.rawValue, forKey: "targetWindow")
        UserDefaults.standard.set(defaultBucket.rawValue, forKey: "defaultBucket")
        
        logger.info("Saved settings - Units: \(units.rawValue), Window: \(targetWindow.rawValue), Bucket: \(defaultBucket.rawValue)")
    }
    
    /// Formats distance based on current units
    func formatDistance(_ distance: Double) -> String {
        switch units {
        case .metric:
            let distanceKm = distance / 1000.0
            return String(format: "%.2f km", distanceKm)
        case .imperial:
            let distanceMiles = distance / 1609.34
            return String(format: "%.2f mi", distanceMiles)
        }
    }
    
    /// Formats pace based on current units
    func formatPace(_ pace: Double) -> String {
        switch units {
        case .metric:
            let minutes = Int(pace) / 60
            let seconds = Int(pace) % 60
            return String(format: "%d:%02d/km", minutes, seconds)
        case .imperial:
            let pacePerMile = pace * 1.60934
            let minutes = Int(pacePerMile) / 60
            let seconds = Int(pacePerMile) % 60
            return String(format: "%d:%02d/mi", minutes, seconds)
        }
    }
}
