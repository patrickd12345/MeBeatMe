import Foundation
import os

/// Centralized logging system for MeBeatMe iOS
struct AppLogger {
    private static let subsystem = "com.mebeatme.ios"
    
    // Category-specific loggers
    static let fileImport = Logger(subsystem: subsystem, category: "FileImport")
    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let analysis = Logger(subsystem: subsystem, category: "Analysis")
    static let kmpBridge = Logger(subsystem: subsystem, category: "KMPBridge")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let sync = Logger(subsystem: subsystem, category: "Sync")
    static let shareSheet = Logger(subsystem: subsystem, category: "ShareSheet")
    
    /// General purpose logger
    static let general = Logger(subsystem: subsystem, category: "General")
    
    /// Log levels for different environments
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
            }
        }
    }
    
    /// Logs a message with the specified level
    static func log(_ message: String, level: LogLevel = .info, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(category)] \(fileName):\(line) \(function) - \(message)"
        
        let logger = Logger(subsystem: subsystem, category: category)
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        case .critical:
            logger.critical("\(logMessage)")
        }
    }
    
    /// Logs an error with context
    static func logError(_ error: Error, context: String = "", category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(category)] \(fileName):\(line) \(function) - \(context): \(error.localizedDescription)"
        
        let logger = Logger(subsystem: subsystem, category: category)
        logger.error("\(logMessage)")
        
        // Log additional error details if available
        if let appError = error as? AppError {
            logger.error("Recovery: \(appError.recoverySuggestion ?? "No recovery suggestion")")
            logger.error("Reason: \(appError.failureReason ?? "No failure reason")")
        }
    }
    
    /// Logs performance metrics
    static func logPerformance(_ operation: String, duration: TimeInterval, category: String = "Performance") {
        let message = "\(operation) took \(String(format: "%.3f", duration))s"
        log(message, level: .info, category: category)
    }
    
    /// Logs user actions for analytics
    static func logUserAction(_ action: String, parameters: [String: Any] = [:], category: String = "UserAction") {
        let paramsString = parameters.isEmpty ? "" : " - \(parameters)"
        let message = "User action: \(action)\(paramsString)"
        log(message, level: .info, category: category)
    }
    
    /// Logs network requests
    static func logNetworkRequest(_ url: String, method: String = "GET", statusCode: Int? = nil, duration: TimeInterval? = nil) {
        var message = "\(method) \(url)"
        
        if let statusCode = statusCode {
            message += " - Status: \(statusCode)"
        }
        
        if let duration = duration {
            message += " - Duration: \(String(format: "%.3f", duration))s"
        }
        
        log(message, level: .info, category: "Network")
    }
    
    /// Logs file operations
    static func logFileOperation(_ operation: String, filePath: String, success: Bool, error: Error? = nil) {
        let status = success ? "SUCCESS" : "FAILED"
        var message = "File \(operation): \(filePath) - \(status)"
        
        if let error = error {
            message += " - Error: \(error.localizedDescription)"
        }
        
        log(message, level: success ? .info : .error, category: "FileOperation")
    }
    
    /// Logs PPI calculations
    static func logPPICalculation(distance: Double, duration: Int, ppi: Double, model: String = "Purdy") {
        let distanceKm = distance / 1000.0
        let message = "PPI Calculation (\(model)): \(String(format: "%.2f", distanceKm))km in \(Units.formatTime(duration)) = \(String(format: "%.1f", ppi)) PPI"
        log(message, level: .info, category: "PPI")
    }
    
    /// Logs sync operations
    static func logSyncOperation(_ operation: String, success: Bool, itemsCount: Int? = nil, error: Error? = nil) {
        var message = "Sync \(operation): \(success ? "SUCCESS" : "FAILED")"
        
        if let itemsCount = itemsCount {
            message += " - Items: \(itemsCount)"
        }
        
        if let error = error {
            message += " - Error: \(error.localizedDescription)"
        }
        
        log(message, level: success ? .info : .error, category: "Sync")
    }
    
    /// Logs share sheet operations
    static func logShareSheetOperation(_ operation: String, fileType: String, success: Bool, error: Error? = nil) {
        var message = "Share Sheet \(operation): \(fileType) - \(success ? "SUCCESS" : "FAILED")"
        
        if let error = error {
            message += " - Error: \(error.localizedDescription)"
        }
        
        log(message, level: success ? .info : .error, category: "ShareSheet")
    }
}

/// Performance measurement utility
struct PerformanceTimer {
    private let startTime: CFAbsoluteTime
    private let operation: String
    private let category: String
    
    init(_ operation: String, category: String = "Performance") {
        self.operation = operation
        self.category = category
        self.startTime = CFAbsoluteTimeGetCurrent()
        
        AppLogger.log("Starting \(operation)", level: .debug, category: category)
    }
    
    deinit {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        AppLogger.logPerformance(operation, duration: duration, category: category)
    }
    
    /// Manually stop the timer and return duration
    func stop() -> TimeInterval {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        AppLogger.logPerformance(operation, duration: duration, category: category)
        return duration
    }
}

/// Convenience macro for performance timing
func measurePerformance<T>(_ operation: String, category: String = "Performance", block: () throws -> T) rethrows -> T {
    let timer = PerformanceTimer(operation, category: category)
    defer { _ = timer.stop() }
    return try block()
}
