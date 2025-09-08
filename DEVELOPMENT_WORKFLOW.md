# MeBeatMe watchOS Development Workflow

## Quick Start Guide

### Windows Development (Daily)
```powershell
# Run from repo root
.\scripts\dev-win.ps1
```

This script will:
- Build and test shared KMP code
- Test server endpoints  
- Build web application
- Provide next steps for CI

### macOS CI Integration

1. **Push changes to trigger CI**:
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

2. **Download artifacts on Mac**:
   ```bash
   ./scripts/pull-artifacts-mac.sh
   ```

3. **Open in Xcode**:
   ```bash
   xed watchos/MeBeatMe.xcodeproj
   ```

## Project Structure

```
MeBeatMe/
├── shared/                 # KMP core (Purdy/PPI, planner)
├── server/                 # Ktor app (sync, /bests)
├── web/                    # Web dashboard
├── watchos/                # Xcode project & SwiftUI
│   ├── MeBeatMeWatch/      # Main app source
│   ├── MeBeatMeWatchTests/ # Test suite
│   ├── TestAssets/         # Sample files
│   └── Frameworks/         # KMP framework (CI artifact)
├── .github/workflows/      # CI configuration
└── scripts/                # Development scripts
```

## Key Features

### Post-Run Analysis
- Import GPX/TCX files
- Calculate PPI using Purdy Points model
- Generate performance recommendations
- Track 90-day best PPI

### Production Architecture
- SwiftUI with Observation
- MVVM pattern
- Comprehensive testing
- Clean separation of concerns

### KMP Integration
- Shared logic for PPI calculations
- Single source of truth
- Cross-platform compatibility

## Testing

### Windows Tests
```powershell
.\gradlew :shared:test
.\gradlew :server:test
.\gradlew :web:test
```

### watchOS Tests
Run in Xcode: `Cmd+U`

### Test Coverage
- KMP Bridge: PPI calculation accuracy
- File Parsing: GPX/TCX import validation
- Analysis Service: Recommendation generation
- Run Store: 90-day PPI calculation
- Unit Conversions: Round-trip accuracy

## CI/CD Pipeline

### GitHub Actions Workflow
- **KMP iOS Framework**: Builds `Shared.xcframework`
- **watchOS App**: Compiles and tests watchOS app
- **Multi-platform Tests**: Runs on Ubuntu, Windows, macOS
- **Artifacts**: Downloadable builds and frameworks

### Artifacts
- `Shared.xcframework`: KMP framework for iOS/watchOS
- `MeBeatMe-watchOS-build`: Compiled watchOS app

## Development Tips

### Windows Development
- Use IntelliJ IDEA for KMP development
- Test core logic locally
- Don't attempt iOS/watchOS builds on Windows
- Use CI for Apple platform builds

### macOS Development
- Download CI artifacts before development
- Use Xcode for watchOS development
- Test with sample files in TestAssets/
- Simulator testing is sufficient for most development

### File Import Testing
- Use `TestAssets/sample_5k.gpx` for 5K testing
- Use `TestAssets/sample_10k.gpx` for 10K testing
- Test with real GPX files from your running apps

## Troubleshooting

### Common Issues
1. **Build Failures**: Ensure CI artifacts are downloaded
2. **Import Errors**: Check file format and GPS data quality
3. **PPI Calculation**: Verify KMP bridge integration
4. **Storage Issues**: Check device storage and permissions

### Debug Information
- All operations logged with `os.Logger`
- User-friendly error messages
- Detailed test diagnostics

## Future Enhancements

### Planned Features
- Live tracking with WorkoutKit
- HealthKit integration
- Complications for watch face
- iOS companion app
- Cloud sync

### Extensibility
- New file formats (FIT, JSON)
- Pluggable analysis algorithms
- Multiple storage backends
- Customizable UI themes

## Support

For issues and questions:
1. Check troubleshooting section
2. Review test cases for examples
3. Examine sample files for formats
4. Create issue with reproduction steps
