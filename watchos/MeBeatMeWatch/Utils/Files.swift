import Foundation
import os

/// Utility functions for file operations
struct Files {
    private static let logger = Logger(subsystem: "com.mebeatme.watch", category: "Files")
    
    /// Documents directory URL
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Temporary directory URL
    static var temporaryDirectory: URL {
        return FileManager.default.temporaryDirectory
    }
    
    /// Checks if a file exists at the given URL
    static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Gets file size in bytes
    static func fileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            logger.error("Failed to get file size: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Gets file modification date
    static func modificationDate(at url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.modificationDate] as? Date
        } catch {
            logger.error("Failed to get modification date: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Creates a directory if it doesn't exist
    static func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        logger.info("Created directory: \(url.path)")
    }
    
    /// Deletes a file or directory
    static func delete(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
        logger.info("Deleted: \(url.path)")
    }
    
    /// Copies a file to a new location
    static func copy(from sourceURL: URL, to destinationURL: URL) throws {
        // Create destination directory if needed
        let destinationDir = destinationURL.deletingLastPathComponent()
        try createDirectory(at: destinationDir)
        
        // Copy the file
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        logger.info("Copied \(sourceURL.lastPathComponent) to \(destinationURL.path)")
    }
    
    /// Moves a file to a new location
    static func move(from sourceURL: URL, to destinationURL: URL) throws {
        // Create destination directory if needed
        let destinationDir = destinationURL.deletingLastPathComponent()
        try createDirectory(at: destinationDir)
        
        // Move the file
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        logger.info("Moved \(sourceURL.lastPathComponent) to \(destinationURL.path)")
    }
    
    /// Lists files in a directory
    static func listFiles(in directory: URL, includingSubdirectories: Bool = false) throws -> [URL] {
        let options: FileManager.DirectoryEnumerationOptions = includingSubdirectories ? [] : [.skipsSubdirectoryDescendants]
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: options)
    }
    
    /// Gets available disk space in bytes
    static func availableDiskSpace() -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: documentsDirectory.path)
            return attributes[.systemFreeSize] as? Int64
        } catch {
            logger.error("Failed to get available disk space: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Formats file size in human-readable format
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Validates file extension
    static func isValidFileExtension(_ url: URL, allowedExtensions: [String]) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return allowedExtensions.contains(fileExtension)
    }
    
    /// Gets file extension
    static func fileExtension(_ url: URL) -> String {
        return url.pathExtension.lowercased()
    }
    
    /// Gets file name without extension
    static func fileNameWithoutExtension(_ url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent
    }
    
    /// Creates a unique filename to avoid conflicts
    static func uniqueFileName(for url: URL, in directory: URL) -> URL {
        let fileName = url.lastPathComponent
        let fileNameWithoutExt = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        
        var counter = 1
        var newURL = directory.appendingPathComponent(fileName)
        
        while fileExists(at: newURL) {
            let newFileName = "\(fileNameWithoutExt)_\(counter).\(fileExtension)"
            newURL = directory.appendingPathComponent(newFileName)
            counter += 1
        }
        
        return newURL
    }
    
    /// Cleans up temporary files older than specified days
    static func cleanupTemporaryFiles(olderThanDays days: Int = 7) throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let tempFiles = try listFiles(in: temporaryDirectory, includingSubdirectories: true)
        
        var deletedCount = 0
        for fileURL in tempFiles {
            if let modificationDate = modificationDate(at: fileURL),
               modificationDate < cutoffDate {
                try delete(at: fileURL)
                deletedCount += 1
            }
        }
        
        logger.info("Cleaned up \(deletedCount) temporary files")
    }
    
    /// Gets directory size in bytes
    static func directorySize(at url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        do {
            let files = try listFiles(in: url, includingSubdirectories: true)
            for fileURL in files {
                if let size = fileSize(at: fileURL) {
                    totalSize += size
                }
            }
        } catch {
            logger.error("Failed to calculate directory size: \(error.localizedDescription)")
        }
        
        return totalSize
    }
}
