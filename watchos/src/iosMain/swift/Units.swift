import Foundation

/// Utility functions for unit conversions and formatting
struct Units {
    
    // MARK: - Distance Conversions
    
    /// Converts meters to kilometers
    static func metersToKilometers(_ meters: Double) -> Double {
        return meters / 1000.0
    }
    
    /// Converts kilometers to meters
    static func kilometersToMeters(_ kilometers: Double) -> Double {
        return kilometers * 1000.0
    }
    
    /// Converts meters to miles
    static func metersToMiles(_ meters: Double) -> Double {
        return meters * 0.000621371
    }
    
    /// Converts miles to meters
    static func milesToMeters(_ miles: Double) -> Double {
        return miles / 0.000621371
    }
    
    // MARK: - Time Formatting
    
    /// Formats time in seconds as MM:SS
    static func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    /// Formats time in seconds as HH:MM:SS
    static func formatTimeLong(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    
    // MARK: - Pace Formatting
    
    /// Formats pace in seconds per kilometer as MM:SS/km
    static func formatPace(_ paceSecondsPerKm: Double) -> String {
        let minutes = Int(paceSecondsPerKm) / 60
        let seconds = Int(paceSecondsPerKm) % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
    
    /// Formats pace in seconds per mile as MM:SS/mi
    static func formatPacePerMile(_ paceSecondsPerKm: Double) -> String {
        let paceSecondsPerMile = paceSecondsPerKm * 1.60934
        let minutes = Int(paceSecondsPerMile) / 60
        let seconds = Int(paceSecondsPerMile) % 60
        return String(format: "%d:%02d/mi", minutes, seconds)
    }
    
    // MARK: - Distance Formatting
    
    /// Formats distance in meters as X.X km
    static func formatDistance(_ meters: Double) -> String {
        let kilometers = metersToKilometers(meters)
        return String(format: "%.1f km", kilometers)
    }
    
    /// Formats distance in meters as X.XX mi
    static func formatDistanceMiles(_ meters: Double) -> String {
        let miles = metersToMiles(meters)
        return String(format: "%.2f mi", miles)
    }
    
    // MARK: - Speed Conversions
    
    /// Converts pace (seconds per km) to speed (km/h)
    static func paceToSpeed(_ paceSecondsPerKm: Double) -> Double {
        guard paceSecondsPerKm > 0 else { return 0 }
        return 3600.0 / paceSecondsPerKm
    }
    
    /// Converts speed (km/h) to pace (seconds per km)
    static func speedToPace(_ speedKmh: Double) -> Double {
        guard speedKmh > 0 else { return 0 }
        return 3600.0 / speedKmh
    }
    
    // MARK: - Temperature Conversions
    
    /// Converts Celsius to Fahrenheit
    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9.0/5.0 + 32.0
    }
    
    /// Converts Fahrenheit to Celsius
    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32.0) * 5.0/9.0
    }
    
    // MARK: - Heart Rate Calculations
    
    /// Calculates maximum heart rate based on age
    static func maxHeartRate(age: Int) -> Int {
        return 220 - age
    }
    
    /// Calculates heart rate zones based on age
    static func heartRateZones(age: Int) -> HeartRateZones {
        let maxHR = maxHeartRate(age: age)
        
        return HeartRateZones(
            zone1: Int(Double(maxHR) * 0.5)...Int(Double(maxHR) * 0.6),   // Recovery
            zone2: Int(Double(maxHR) * 0.6)...Int(Double(maxHR) * 0.7),   // Aerobic Base
            zone3: Int(Double(maxHR) * 0.7)...Int(Double(maxHR) * 0.8),   // Aerobic Threshold
            zone4: Int(Double(maxHR) * 0.8)...Int(Double(maxHR) * 0.9),   // Lactate Threshold
            zone5: Int(Double(maxHR) * 0.9)...maxHR                        // Neuromuscular Power
        )
    }
    
    // MARK: - PPI Formatting
    
    /// Formats PPI score with appropriate precision
    static func formatPPI(_ ppi: Double) -> String {
        return String(format: "%.1f", ppi)
    }
    
    /// Gets performance level description for PPI score
    static func performanceLevelDescription(_ ppi: Double) -> String {
        switch ppi {
        case 0..<200:
            return "Beginner"
        case 200..<350:
            return "Intermediate"
        case 350..<500:
            return "Advanced"
        default:
            return "Elite"
        }
    }
}

/// Represents heart rate training zones
struct HeartRateZones {
    let zone1: ClosedRange<Int>  // Recovery
    let zone2: ClosedRange<Int>  // Aerobic Base
    let zone3: ClosedRange<Int>  // Aerobic Threshold
    let zone4: ClosedRange<Int>  // Lactate Threshold
    let zone5: ClosedRange<Int>  // Neuromuscular Power
    
    /// Gets the zone for a given heart rate
    func zone(for heartRate: Int) -> Int? {
        if zone1.contains(heartRate) { return 1 }
        if zone2.contains(heartRate) { return 2 }
        if zone3.contains(heartRate) { return 3 }
        if zone4.contains(heartRate) { return 4 }
        if zone5.contains(heartRate) { return 5 }
        return nil
    }
    
    /// Gets zone description
    func description(for zone: Int) -> String {
        switch zone {
        case 1: return "Recovery"
        case 2: return "Aerobic Base"
        case 3: return "Aerobic Threshold"
        case 4: return "Lactate Threshold"
        case 5: return "Neuromuscular Power"
        default: return "Unknown Zone"
        }
    }
}
