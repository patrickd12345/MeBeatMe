import Foundation
import os

/// Coordinates file import operations and delegates to appropriate parsers
@Observable
class FileImportCoordinator {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "FileImport")
    
    /// Supported file formats
    enum SupportedFormat: String, CaseIterable {
        case gpx = "gpx"
        case tcx = "tcx"
        case fit = "fit"
        
        var mimeType: String {
            switch self {
            case .gpx: return "application/gpx+xml"
            case .tcx: return "application/vnd.garmin.tcx+xml"
            case .fit: return "application/octet-stream"
            }
        }
        
        var fileExtension: String {
            return rawValue
        }
        
        var displayName: String {
            switch self {
            case .gpx: return "GPX (GPS Exchange)"
            case .tcx: return "TCX (Training Center)"
            case .fit: return "FIT (Flexible and Interoperable Data Transfer)"
            }
        }
    }
    
    /// Detects file format from URL and delegates to appropriate parser
    func importFile(from url: URL) async throws -> RunRecord {
        logger.info("Starting file import from: \(url.lastPathComponent)")
        
        let fileExtension = url.pathExtension.lowercased()
        
        guard let format = SupportedFormat(rawValue: fileExtension) else {
            throw AppError.unsupportedFormat(fileExtension)
        }
        
        let data = try Data(contentsOf: url)
        
        switch format {
        case .gpx:
            return try await GPXParser().parse(data: data, fileName: url.lastPathComponent)
        case .tcx:
            return try await TCXParser().parse(data: data, fileName: url.lastPathComponent)
        case .fit:
            // FIT parser would go here - for now, throw unsupported
            throw AppError.unsupportedFormat("FIT files not yet supported")
        }
    }
    
    /// Validates that a file can be imported
    func canImportFile(at url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return SupportedFormat(rawValue: fileExtension) != nil
    }
    
    /// Returns supported file extensions for file picker
    func supportedFileExtensions() -> [String] {
        return SupportedFormat.allCases.map { $0.fileExtension }
    }
    
    /// Returns supported MIME types for file picker
    func supportedMimeTypes() -> [String] {
        return SupportedFormat.allCases.map { $0.mimeType }
    }
}
