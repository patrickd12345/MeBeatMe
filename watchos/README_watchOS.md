# MeBeatMe watchOS App

A production-grade watchOS app focused on post-run analysis using the Purdy-based Personal Performance Index (PPI) system.

## Overview

The MeBeatMe watchOS app provides runners with detailed analysis of their training runs, including PPI scoring, performance recommendations, and progress tracking. The app is designed for post-run analysis first, with extensibility for live tracking in future versions.

## Features

### Core Functionality
- **File Import**: Import GPX and TCX files from your running apps
- **PPI Analysis**: Calculate Personal Performance Index using the Purdy Points model
- **Performance Recommendations**: Get targeted training suggestions
- **Progress Tracking**: Track your best times and highest PPI over 90 days
- **Clean UI**: SwiftUI-based interface optimized for Apple Watch

### Technical Features
- **Kotlin Multiplatform Integration**: Uses shared KMP logic for PPI calculations
- **Local Storage**: JSON-based persistence with atomic writes
- **Comprehensive Testing**: Unit tests for all core functionality
- **Production Architecture**: Clean separation of concerns with MVVM pattern

## Architecture

### Layers
- **Data**: File import/parsing, persistence, optional sync client
- **Domain**: PPI & planner calls via KMP bridge, analysis/recommendation engine
- **Presentation**: SwiftUI views + ViewModels (Observable, testable)

### Key Components
- `FileImportCoordinator`: Handles file import and format detection
- `KMPBridge`: Interface to shared Kotlin Multiplatform logic
- `AnalysisService`: Generates performance recommendations
- `RunStore`: Manages local persistence and 90-day PPI calculation
- `HomeViewModel`: Main dashboard state management

## Development Workflow

### Windows-First Development
This project is designed for Windows-first development with macOS CI:

1. **Daily Development on Windows**:
   ```powershell
   .\scripts\dev-win.ps1
   ```

2. **Push to Trigger macOS CI**:
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

3. **Download CI Artifacts** (on Mac):
   ```bash
   ./scripts/pull-artifacts-mac.sh
   ```

### CI/CD Pipeline
- **GitHub Actions**: Automated builds on macOS runners
- **KMP Framework**: Builds `Shared.xcframework` for iOS/watchOS
- **watchOS App**: Compiles and tests the watchOS application
- **Artifacts**: Downloadable builds and frameworks

## Installation & Setup

### Prerequisites
- **Windows**: IntelliJ IDEA, Android Studio, JDK 17
- **macOS**: Xcode 15+, watchOS 10+ SDK
- **GitHub**: Repository with Actions enabled

### Quick Start
1. Clone the repository
2. Run Windows development script: `.\scripts\dev-win.ps1`
3. Push changes to trigger CI
4. Download artifacts on Mac: `./scripts/pull-artifacts-mac.sh`
5. Open `watchos/MeBeatMe.xcodeproj` in Xcode

## Usage

### Importing Runs
1. Open the MeBeatMe app on your Apple Watch
2. Tap "Import Race" on the home screen
3. Select a GPX or TCX file from your device
4. Review the imported run details
5. Tap "Analyze Run" to get PPI and recommendations
6. Save the run to your collection

### Understanding PPI
The Personal Performance Index (PPI) uses the Purdy Points model:
- **Scale**: 1-1000 points
- **1 point**: Moderate 5km walk
- **1000 points**: World record performance
- **355 points**: Example recreational runner performance

### 90-Day Tracking
The app automatically tracks your highest PPI from the last 90 days:
- Displayed prominently on the home screen
- Updated automatically when you save new runs
- Helps track long-term fitness progress

## Testing

### Running Tests
```bash
# On Windows
.\gradlew :shared:test

# On macOS (in Xcode)
Cmd+U
```

### Test Coverage
- **KMP Bridge**: PPI calculation accuracy and monotonicity
- **File Parsing**: GPX/TCX import validation
- **Analysis Service**: Recommendation generation
- **Run Store**: 90-day PPI calculation
- **Unit Conversions**: Round-trip accuracy

### Sample Test Files
- `TestAssets/sample_5k.gpx`: 5K test run
- `TestAssets/sample_10k.gpx`: 10K test run

## Configuration

### Settings
- **Units**: Metric or Imperial
- **Target Window**: Short (5 min), Medium (10 min), Long (20 min)
- **Default Bucket**: Sprint, Short Run, Medium Run, Long Run, Ultra Run

### Entitlements (Future)
Prepared for future live tracking features:
- `com.apple.developer.healthkit`
- `com.apple.developer.healthkit.access`
- Background delivery placeholders

## File Formats

### Supported Formats
- **GPX**: GPS Exchange Format (primary)
- **TCX**: Training Center XML (secondary)
- **FIT**: Future support planned

### File Structure
```
watchos/
├── MeBeatMeWatch/           # Main app source
├── MeBeatMeWatchTests/      # Test suite
├── TestAssets/              # Sample files
├── Frameworks/              # KMP framework (CI artifact)
└── MeBeatMe.xcodeproj       # Xcode project
```

## Troubleshooting

### Common Issues
1. **Build Failures**: Ensure CI artifacts are downloaded
2. **Import Errors**: Check file format and GPS data quality
3. **PPI Calculation**: Verify KMP bridge is properly integrated
4. **Storage Issues**: Check device storage and permissions

### Debug Information
- All operations are logged using `os.Logger`
- Error messages are user-friendly and actionable
- Test failures include detailed diagnostic information

## Future Enhancements

### Planned Features
- **Live Tracking**: Real-time workout monitoring
- **HealthKit Integration**: Automatic workout import
- **Complications**: Quick PPI display on watch face
- **iOS Companion**: Easier file import and management
- **Sync**: Cloud backup and multi-device sync

### Extensibility Points
- **New File Formats**: Easy to add FIT, JSON, etc.
- **Analysis Algorithms**: Pluggable recommendation engines
- **Storage Backends**: Database, cloud, etc.
- **UI Themes**: Customizable appearance

## Contributing

### Development Guidelines
1. Follow SwiftUI best practices
2. Write comprehensive tests
3. Use Observable for state management
4. Maintain clean architecture
5. Document public APIs

### Code Style
- Swift 5.9+ features
- SwiftUI with Observation
- Async/await for concurrency
- Error handling with `AppError`

## License

This project is part of the MeBeatMe running analysis suite. See main repository for license information.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review test cases for usage examples
3. Examine sample files for format requirements
4. Create an issue with detailed reproduction steps
