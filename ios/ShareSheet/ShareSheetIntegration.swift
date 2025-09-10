import SwiftUI
import UniformTypeIdentifiers

/// Share Sheet extension for importing GPX/TCX files
struct ShareSheetView: UIViewControllerRepresentable {
    let completion: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .postToTwitter,
            .postToFacebook,
            .openInIBooks
        ]
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

/// Document importer for handling shared files
class DocumentImporter: ObservableObject {
    private let fileImportCoordinator = FileImportCoordinator()
    private let runStore = RunStore()
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var importedRun: RunRecord?
    
    /// Processes a shared file URL
    func processSharedFile(_ url: URL) {
        AppLogger.logShareSheetOperation("process_shared_file", fileType: url.pathExtension, success: false)
        
        isProcessing = true
        errorMessage = nil
        importedRun = nil
        
        Task {
            do {
                // Validate file
                let validation = fileImportCoordinator.validateFile(at: url)
                guard validation.isValid else {
                    throw AppError.invalidFileFormat(validation.errorMessage ?? "Invalid file")
                }
                
                // Import file
                let runRecord = try await fileImportCoordinator.importFile(from: url)
                
                await MainActor.run {
                    self.importedRun = runRecord
                    self.isProcessing = false
                }
                
                AppLogger.logShareSheetOperation("process_shared_file", fileType: url.pathExtension, success: true)
                
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.userFriendlyMessage(for: error)
                    self.isProcessing = false
                }
                
                AppLogger.logShareSheetOperation("process_shared_file", fileType: url.pathExtension, success: false, error: error)
            }
        }
    }
    
    /// Saves the imported run
    func saveImportedRun() throws {
        guard let run = importedRun else {
            throw AppError.storageError("No imported run to save")
        }
        
        try runStore.saveRun(run)
        AppLogger.logUserAction("run_saved_from_share_sheet")
    }
}

/// Share extension coordinator
class ShareExtensionCoordinator: ObservableObject {
    @Published var sharedURL: URL?
    @Published var isActive = false
    
    func handleSharedURL(_ url: URL) {
        sharedURL = url
        isActive = true
        AppLogger.logUserAction("share_extension_activated", parameters: ["file_type": url.pathExtension])
    }
    
    func dismiss() {
        sharedURL = nil
        isActive = false
    }
}

/// UTType extensions for supported file formats
extension UTType {
    static var gpx: UTType {
        UTType(filenameExtension: "gpx") ?? UTType.xml
    }
    
    static var tcx: UTType {
        UTType(filenameExtension: "tcx") ?? UTType.xml
    }
    
    static var fit: UTType {
        UTType(filenameExtension: "fit") ?? UTType.data
    }
}

/// Share sheet modifier for SwiftUI views
struct ShareSheetModifier: ViewModifier {
    @State private var showingShareSheet = false
    let items: [Any]
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingShareSheet) {
                ShareSheetView { result in
                    switch result {
                    case .success(let url):
                        // Handle successful share
                        AppLogger.logUserAction("share_sheet_success")
                    case .failure(let error):
                        AppLogger.logError(error, context: "Share sheet failed")
                    }
                }
            }
            .onTapGesture {
                showingShareSheet = true
            }
    }
}

extension View {
    func shareSheet(items: [Any]) -> some View {
        modifier(ShareSheetModifier(items: items))
    }
}

/// File sharing utilities
struct FileSharing {
    /// Checks if a file can be shared
    static func canShare(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return AppConfig.supportedFileExtensions.contains(fileExtension)
    }
    
    /// Gets file type description
    static func fileTypeDescription(_ url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "gpx":
            return "GPX (GPS Exchange Format)"
        case "tcx":
            return "TCX (Training Center XML)"
        case "fit":
            return "FIT (Flexible and Interoperable Data Transfer)"
        default:
            return "Unknown file type"
        }
    }
    
    /// Validates file for sharing
    static func validateFile(_ url: URL) -> (isValid: Bool, errorMessage: String?) {
        // Check file extension
        guard canShare(url) else {
            return (false, "Unsupported file format")
        }
        
        // Check file size
        if let size = Files.fileSize(at: url), size > AppConfig.maxFileSizeBytes {
            return (false, "File too large")
        }
        
        // Check if file exists
        guard Files.fileExists(at: url) else {
            return (false, "File not found")
        }
        
        return (true, nil)
    }
}

/// Share sheet handler for the main app
class ShareSheetHandler: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var importedRun: RunRecord?
    
    private let documentImporter = DocumentImporter()
    
    func handleSharedFile(_ url: URL) {
        documentImporter.processSharedFile(url)
        
        // Observe the document importer's state
        documentImporter.$isProcessing
            .assign(to: &$isProcessing)
        
        documentImporter.$errorMessage
            .assign(to: &$errorMessage)
        
        documentImporter.$importedRun
            .assign(to: &$importedRun)
    }
    
    func saveImportedRun() throws {
        try documentImporter.saveImportedRun()
    }
}
