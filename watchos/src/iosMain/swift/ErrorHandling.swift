import Foundation

/// Application-specific errors
enum AppError: LocalizedError, Equatable {
    case fileNotFound(String)
    case invalidFileFormat(String)
    case unsupportedFormat(String)
    case noTrackData(String)
    case parsingError(String)
    case networkError(String)
    case storageError(String)
    case analysisError(String)
    case kmpBridgeError(String)
    case configurationError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "File not found: \(filename)"
        case .invalidFileFormat(let format):
            return "Invalid file format: \(format)"
        case .unsupportedFormat(let format):
            return "Unsupported file format: \(format)"
        case .noTrackData(let reason):
            return "No track data found: \(reason)"
        case .parsingError(let reason):
            return "Parsing error: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .storageError(let reason):
            return "Storage error: \(reason)"
        case .analysisError(let reason):
            return "Analysis error: \(reason)"
        case .kmpBridgeError(let reason):
            return "KMP Bridge error: \(reason)"
        case .configurationError(let reason):
            return "Configuration error: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Please check that the file exists and try again."
        case .invalidFileFormat:
            return "Please ensure the file is a valid GPX or TCX format."
        case .unsupportedFormat:
            return "Please convert the file to GPX or TCX format."
        case .noTrackData:
            return "Please ensure the file contains GPS track data."
        case .parsingError:
            return "Please try with a different file or check the file format."
        case .networkError:
            return "Please check your internet connection and try again."
        case .storageError:
            return "Please check available storage space and try again."
        case .analysisError:
            return "Please try analyzing the run again."
        case .kmpBridgeError:
            return "Please restart the app and try again."
        case .configurationError:
            return "Please check your app configuration."
        }
    }
    
    var failureReason: String? {
        switch self {
        case .fileNotFound:
            return "The specified file could not be located."
        case .invalidFileFormat:
            return "The file format is not recognized or corrupted."
        case .unsupportedFormat:
            return "The file format is not supported by this app."
        case .noTrackData:
            return "The file does not contain valid GPS track data."
        case .parsingError:
            return "An error occurred while parsing the file data."
        case .networkError:
            return "A network connection error occurred."
        case .storageError:
            return "A local storage error occurred."
        case .analysisError:
            return "An error occurred during run analysis."
        case .kmpBridgeError:
            return "An error occurred in the KMP bridge."
        case .configurationError:
            return "An error occurred in app configuration."
        }
    }
}

/// Error handling utilities
struct ErrorHandler {
    /// Logs an error with appropriate context
    static func logError(_ error: Error, context: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("❌ Error in \(fileName):\(line) \(function) - \(context): \(error.localizedDescription)")
        
        // In production, this would use proper logging framework
        #if DEBUG
        if let appError = error as? AppError {
            print("   Recovery: \(appError.recoverySuggestion ?? "No recovery suggestion")")
            print("   Reason: \(appError.failureReason ?? "No failure reason")")
        }
        #endif
    }
    
    /// Creates a user-friendly error message
    static func userFriendlyMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.errorDescription ?? "An unknown error occurred"
        }
        
        // Handle common system errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection available"
            case .timedOut:
                return "Request timed out"
            case .cannotFindHost:
                return "Cannot connect to server"
            default:
                return "Network error occurred"
            }
        }
        
        return error.localizedDescription
    }
    
    /// Creates a recovery suggestion for an error
    static func recoverySuggestion(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.recoverySuggestion ?? "Please try again"
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "Please check your internet connection"
            case .timedOut:
                return "Please try again in a moment"
            case .cannotFindHost:
                return "Please check your network settings"
            default:
                return "Please try again"
            }
        }
        
        return "Please try again"
    }
}
