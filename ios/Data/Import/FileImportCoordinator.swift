import Foundation
import os
import UniformTypeIdentifiers

/// Coordinates file import operations and delegates to appropriate parsers
@Observable
class FileImportCoordinator {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "FileImport")
    
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
        
        var utType: UTType {
            switch self {
            case .gpx: return UTType(filenameExtension: "gpx") ?? UTType.xml
            case .tcx: return UTType(filenameExtension: "tcx") ?? UTType.xml
            case .fit: return UTType(filenameExtension: "fit") ?? UTType.data
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
    
    /// Returns supported UTTypes for document picker
    func supportedUTTypes() -> [UTType] {
        return SupportedFormat.allCases.map { $0.utType }
    }
    
    /// Validates file before import
    func validateFile(at url: URL) -> (isValid: Bool, errorMessage: String?) {
        // Check if file exists
        guard Files.fileExists(at: url) else {
            return (false, "File not found")
        }
        
        // Check file extension
        guard canImportFile(at: url) else {
            return (false, "Unsupported file format. Please use GPX or TCX files.")
        }
        
        // Check file size (max 10MB)
        if let size = Files.fileSize(at: url), size > 10 * 1024 * 1024 {
            return (false, "File too large. Maximum size is 10MB.")
        }
        
        return (true, nil)
    }
    
    /// Gets file information for display
    func getFileInfo(for url: URL) -> (size: String, date: String, name: String) {
        let size = Files.fileSize(at: url).map { Files.formatFileSize($0) } ?? "Unknown size"
        let date = Files.modificationDate(at: url).map { 
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: $0)
        } ?? "Unknown date"
        let name = url.lastPathComponent
        
        return (size, date, name)
    }
}
