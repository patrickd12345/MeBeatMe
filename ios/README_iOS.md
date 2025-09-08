# MeBeatMe iOS App

A SwiftUI iOS companion app for post-run analysis using the Purdy Points PPI system.

## Overview

MeBeatMe iOS is designed to work alongside the watchOS app, providing a comprehensive platform for importing, analyzing, and managing running performance data. The app focuses on post-run analysis with the Personal Performance Index (PPI) calculation using the Purdy Points model.

## Features

### Core Functionality
- **File Import**: Import GPX and TCX files via Files app or Share Sheet
- **PPI Calculation**: Calculate Personal Performance Index using KMP bridge
- **90-Day Tracking**: Track highest PPI over the last 90 days
- **Run Analysis**: Detailed analysis with performance insights and recommendations
- **Local Storage**: JSON-based persistence with atomic writes
- **Settings Management**: Configurable units, preferences, and app settings

### Import Methods
1. **Files App**: Use the built-in document picker to select files
2. **Share Sheet**: Import files shared from other apps (Safari, Files, etc.)

### Supported File Formats
- **GPX**: GPS Exchange Format (fully supported)
- **TCX**: Training Center XML (stub implementation)
- **FIT**: Flexible and Interoperable Data Transfer (future)

## Architecture

### Project Structure
```
ios/
├── Models/                 # Data models (RunRecord, Bests, Split)
├── Data/
│   ├── Import/            # File import coordination and parsers
│   └── Persistence/       # JSON storage management
├── Domain/                # Business logic (KMPBridge, AnalysisService)
├── Presentation/          # ViewModels with Observation pattern
├── UI/                    # SwiftUI views
├── Utils/                 # Utilities (Units, Files, Logging, ErrorHandling)
├── Config/                # App configuration
├── ShareSheet/            # Share Sheet integration
├── Extensions/            # Extension points (WatchConnectivity, App Groups)
├── Tests/                 # Unit tests
└── MeBeatMeApp.swift      # Main app entry point
```

### Key Components

#### Models
- `RunRecord`: Complete run data with GPS, heart rate, and metadata
- `Bests`: Personal best times and 90-day highest PPI
- `Split`: Individual segment data within a run

#### Data Layer
- `FileImportCoordinator`: Handles file format detection and parsing
- `GPXParser`: Parses GPX files into RunRecord objects
- `RunStore`: Manages JSON persistence with atomic writes

#### Domain Layer
- `KMPBridge`: Interface to Kotlin Multiplatform shared logic
- `AnalysisService`: Generates performance insights and recommendations

#### Presentation Layer
- `HomeViewModel`: Manages home screen data and statistics
- `ImportViewModel`: Handles file import workflow
- `AnalysisViewModel`: Manages run analysis results
- `SettingsViewModel`: Manages app settings and preferences

## Setup Instructions

### Prerequisites
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `MeBeatMe.xcodeproj` in Xcode
3. Select the iOS target
4. Build and run on simulator or device

### Configuration
1. **Server Configuration**: Update `AppConfig.swift` with your server URL
2. **App Groups**: Configure App Group identifier for watchOS sync (optional)
3. **Share Sheet**: Register supported file types in Info.plist

## Usage

### Importing Files

#### Via Files App
1. Tap the "Import" tab
2. Tap "Choose from Files"
3. Select a GPX or TCX file
4. Review the imported data
5. Tap "Save" to add to your collection

#### Via Share Sheet
1. Open a GPX/TCX file in Safari or Files app
2. Tap the Share button
3. Select "MeBeatMe" from the share sheet
4. The file will be automatically imported

### Viewing Analysis
1. Import a run file
2. Tap "Analyze" to see detailed performance insights
3. View PPI score, recommendations, and improvement suggestions
4. Save the run to your collection

### Managing Settings
1. Tap the "Settings" tab
2. Configure units (Metric/Imperial)
3. Adjust preferences (notifications, haptic feedback)
4. View app information and statistics

## 90-Day PPI Logic

The app calculates the highest PPI score from runs within the last 90 days:

1. **Filter Runs**: Only runs from the last 90 days are considered
2. **Calculate PPI**: Each run's PPI is calculated using the Purdy Points model
3. **Find Maximum**: The highest PPI score is identified
4. **Update Bests**: The `highestPPILast90Days` field is updated

### Example Test Case
```swift
// Runs: 2 inside 90 days (PPI 48.2, 51.9), 1 at 91 days (PPI 49.7)
// Result: highestPPILast90Days = 51.9
```

## KMP Integration

The app uses a Kotlin Multiplatform bridge for PPI calculations:

### Current Implementation
- Local Purdy Points formula implementation
- PPI calculation: `P = 1000 × (T₀/T)³`
- Standard times for different distances

### Future KMP Integration
```swift
// TODO: Replace with actual KMP framework call
// return SharedKMP.PerfIndex.purdyScore(distanceMeters: distance, durationSec: duration)
```

## Extension Points

### WatchConnectivity (Future)
- Send runs from iPhone to Apple Watch
- Sync bests and settings
- Real-time communication

### App Groups (Future)
- Shared storage between iOS and watchOS
- Automatic data synchronization
- Unified data model

### Server Sync (Future)
- Cloud backup of runs and bests
- Cross-device synchronization
- Performance analytics

## Testing

### Unit Tests
- `GPXParserTests`: File parsing functionality
- `RunStoreTests`: Persistence and 90-day logic
- `KMPBridgeTests`: PPI calculation accuracy
- `UnitsTests`: Unit conversion utilities

### Test Assets
- `sample_5k.gpx`: 5K test run
- `sample_10k.gpx`: 10K test run

### Running Tests
```bash
# Run all tests
xcodebuild test -scheme MeBeatMe-iOS -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme MeBeatMe-iOS -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MeBeatMeTests/GPXParserTests
```

## DTOs and Serialization

The app uses consistent data models for future sync:

### RunRecord
```swift
struct RunRecord: Codable {
    let id: UUID
    let date: Date
    let distance: Double // meters
    let duration: Int // seconds
    let averagePace: Double // seconds per kilometer
    let splits: [Split]?
    let source: String
    let fileName: String
    let heartRateData: [HeartRatePoint]?
    let elevationGain: Double?
    let temperature: Double?
}
```

### Bests
```swift
struct Bests: Codable {
    var best5kSec: Int?
    var best10kSec: Int?
    var bestHalfSec: Int?
    var bestFullSec: Int?
    var highestPPILast90Days: Double?
    var lastUpdated: Date
}
```

## Future Enhancements

### Phase 1: Core Features
- [ ] Complete TCX parser implementation
- [ ] FIT file support
- [ ] Enhanced heart rate analysis
- [ ] Pace zone recommendations

### Phase 2: Sync & Integration
- [ ] WatchConnectivity implementation
- [ ] App Groups shared storage
- [ ] Server sync functionality
- [ ] Cross-device data synchronization

### Phase 3: Advanced Features
- [ ] Live tracking integration
- [ ] Advanced analytics
- [ ] Social features
- [ ] Training plans

## Troubleshooting

### Common Issues

#### Import Failures
- **File too large**: Maximum file size is 10MB
- **Unsupported format**: Only GPX and TCX are supported
- **Invalid file**: Ensure the file contains valid GPS data

#### PPI Calculation Issues
- **Invalid PPI**: Check that distance and duration are reasonable
- **Bridge errors**: Restart the app if KMP bridge fails

#### Storage Issues
- **Low storage**: Check available disk space
- **Corrupted data**: Use "Clear All Data" in settings

### Debug Information
Enable debug logging in `AppConfig.swift`:
```swift
static let enableDebugLogging = true
static let enablePerformanceLogging = true
```

## Contributing

1. Follow Swift coding conventions
2. Add unit tests for new functionality
3. Update documentation for API changes
4. Ensure all tests pass before submitting

## License

This project is part of the MeBeatMe ecosystem. See the main repository for license information.
