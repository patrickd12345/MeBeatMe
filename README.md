# MeBeatMe

A production-grade watchOS app with Purdy-based Personal Performance Index (PPI) system, designed for Windows-first development with macOS CI.

![KMP Artifacts](https://github.com/patrickd12345/MeBeatMe/actions/workflows/kmp-artifacts.yml/badge.svg)
![Build and Deploy](https://github.com/patrickd12345/MeBeatMe/actions/workflows/build-and-deploy.yml/badge.svg)

> **📋 State of the Union**: See [STATE_OF_THE_UNION.md](STATE_OF_THE_UNION.md) for current project status and next steps.
> **🚀 Automatic Deployment**: Every successful compile automatically builds and deploys to production!

## 🏗️ Architecture

Clean Kotlin Multiplatform monorepo with Windows-first development workflow:

```
MeBeatMe/
├── core/                    # KMP shared business logic (Purdy PPI)
│   ├── model.kt            # RunSession, Score, Bucket enums
│   ├── ppi/                # Purdy Points PPI system
│   │   ├── PpiEngine.kt    # Unified facade with model switching
│   │   ├── PpiCurvePurdy.kt # Purdy Points implementation
│   │   └── PpiCurveTransparent.kt # Legacy v0 system
│   ├── planner.kt          # Beat-your-best choice generator
│   └── TransparencyInfo.kt # PPI transparency system
├── shared/                  # KMP shared module
│   └── src/commonMain/kotlin/ # Shared business logic
├── watchos/                 # Production watchOS SwiftUI app
│   ├── MeBeatMeWatch/       # Main app source
│   ├── MeBeatMeWatchTests/  # Comprehensive test suite
│   ├── TestAssets/         # Sample GPX files
│   └── MeBeatMe.xcodeproj   # Xcode project
├── platform/wearos/        # Wear OS Jetpack Compose app
├── web/                    # Kotlin/JS web dashboard
├── server/                 # Ktor server with sync endpoints
├── .github/workflows/      # CI/CD pipeline
└── scripts/                # Development scripts
```

## 🚀 Quick Start

### 🎯 Automatic Build & Deploy

**Every successful compile automatically:**
- ✅ Runs all tests
- 🏗️ Builds web assets and XCFramework  
- 🚀 Deploys to production (main branch)
- 📱 Creates preview deployments (PRs)

**Setup once, deploy forever:**
```bash
# Windows
.\scripts\setup-automatic-deployment.ps1

# macOS/Linux  
./scripts/setup-automatic-deployment.sh
```

**Live App:** https://mebeatme.ready2race.run

### Windows-First Development Workflow

#### Daily Development (Windows)
```powershell
# Run from repo root
.\scripts\dev-win.ps1
```

This script will:
- Build and test shared KMP code
- Test server endpoints  
- Build web application
- Provide next steps for CI

#### macOS CI Integration
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

### Prerequisites
- **Windows**: IntelliJ IDEA, Android Studio, JDK 17
- **macOS**: Xcode 15+, watchOS 10+ SDK
- **GitHub**: Repository with Actions enabled

### Run MeBeatMe Server
```bash
# Compile and run SimpleHttpServer (recommended)
javac SimpleHttpServer.java
java SimpleHttpServer

# Alternative: Run FitFileServerWithStorage
javac FitFileServerWithStorage.java
java FitFileServerWithStorage
```

**Server Features:**
- ✅ **RESTful API**: Complete CRUD operations for workouts
- ✅ **CORS Support**: Cross-origin requests for web dashboard
- ✅ **In-memory Storage**: Workout persistence with PPI tracking
- ✅ **Real-time Updates**: Dynamic best PPI calculation
- ✅ **Error Handling**: Comprehensive error responses with proper HTTP codes
- ✅ **Strava Integration**: OAuth authentication and activity import API

### Test Server Endpoints
```bash
# Health check
curl http://localhost:8080/health

# Best PPI by bucket
curl http://localhost:8080/sync/bests

# List all workouts
curl http://localhost:8080/sync/sessions

# Add manual workout
curl -X POST http://localhost:8080/sync/runs \
  -H "Content-Type: application/json" \
  -d '[{"id":"test_workout","distanceMeters":5000,"elapsedSeconds":1200,"startedAtEpochMs":1757520000000}]'

# Delete workout
curl -X DELETE http://localhost:8080/sync/runs/test_workout

# Strava Integration (requires setup)
curl -X POST http://localhost:8080/strava/token \
  -H "Content-Type: application/json" \
  -d '{"code":"your_strava_auth_code"}'

curl -X POST http://localhost:8080/strava/import \
  -H "Content-Type: application/json" \
  -d '{"access_token":"your_token","count":10,"type":"Run","days":30}'
```

### Open Web Dashboard
```bash
# Start Python HTTP server for dashboard
python -m http.server 8082

# Start Java API server
javac SimpleHttpServer.java
java SimpleHttpServer

# Open dashboard in browser
start http://localhost:8082/dashboard.html
```

**Dashboard Features:**
- ✅ **Manual Workout Entry**: Add workouts with date, distance (km), and time (hh:mm:ss)
- ✅ **Real-time PPI Calculation**: Purdy Points formula with elite baseline times
- ✅ **Workout Management**: View, add, and delete workouts
- ✅ **Dynamic Best Tracking**: Automatically updates "PPI to beat"
- ✅ **Modern UI**: Responsive design with animations and notifications
- ✅ **Strava Integration**: Import activities directly from Strava with OAuth authentication

### Run Wear OS App (Android Studio)
1. Open Android Studio
2. Open MeBeatMe folder
3. Select `:platform:wearos` module
4. Run on Wear OS emulator/device
5. Features: Live run tracking, haptic feedback, progress ring

### Build watchOS App (Production)
1. **Windows**: Push changes to trigger CI
2. **macOS**: Download CI artifacts
3. **Xcode**: Open `watchos/MeBeatMe.xcodeproj`
4. Features: SwiftUI interface, file import, PPI analysis

## 🧮 Core Features

### PPI (Personal Performance Index) - Purdy Points Model
- **Purdy v1 (Default)**: `P = 1000 × (T₀/T)³` - cubic relationship
- **Scale**: 1-1000 points (matches Smashrun SPI)
- **Calibrated**: 355 points for 5.94km in 41:38 (recreational runner)
- **Model Switching**: Runtime switching between Purdy v1 and Transparent v0
- **Monotonic**: Faster times = higher scores

### watchOS App Features
- **File Import**: GPX/TCX parsing with comprehensive error handling
- **PPI Analysis**: Purdy Points calculation with performance recommendations
- **90-Day Tracking**: Automatic highest PPI calculation and display
- **Local Storage**: JSON-based persistence with atomic writes
- **SwiftUI Interface**: Modern reactive UI with Observation

### Beat-Your-Best Planner
- **Distance Buckets**: KM_1_3, KM_3_8, KM_8_15, KM_15_25, KM_25P
- **Challenge Types**: Short & Fierce, Tempo Boost, Ease Into It, Surprise Me
- **Target Generation**: Beats historical best by +1 PPI point
- **Time Windows**: 5min, 10min, 20min options

### History Store
- **90-Day PPI**: Automatic calculation of highest PPI in last 90 days
- **Best Tracking**: Per-bucket historical maximums
- **Corrections**: Elevation and temperature adjustments

## 📱 Platform Status

- ✅ **Core KMP**: Purdy Points PPI system with model switching
- ✅ **watchOS App**: Production-grade SwiftUI app with file import
- ✅ **Wear OS**: Complete live run experience with haptic feedback
- ✅ **Web Dashboard**: Complete workout management with manual entry and CRUD operations
- ✅ **API Server**: Java server with full REST API and CORS support
- ✅ **CI/CD**: GitHub Actions with Windows-first workflow

## 🎯 Production watchOS App Complete

### ✅ **Post-Run Analysis Focus**
- **File Import**: GPX/TCX parsing with error handling
- **PPI Analysis**: Purdy Points calculation (matches Smashrun SPI)
- **Performance Recommendations**: Targeted training suggestions
- **90-Day Tracking**: Automatic highest PPI calculation
- **Local Storage**: JSON-based persistence with atomic writes

### ✅ **Production Architecture**
- **SwiftUI + Observation**: Modern reactive UI with `@Observable` ViewModels
- **MVVM Pattern**: Clean separation of concerns
- **KMP Integration**: Single source of truth for PPI calculations
- **Comprehensive Testing**: Unit tests for all core functionality
- **Extensible Design**: Prepared for future live tracking

### ✅ **Windows-First Development**
- **Daily Development**: PowerShell scripts for Windows development
- **CI/CD Pipeline**: GitHub Actions builds watchOS on macOS runners
- **Artifact Management**: Automatic XCFramework and app builds
- **Mac Integration**: Scripts for downloading CI artifacts

### ✅ **Purdy Points Implementation**
- **Cubic Formula**: `P = 1000 × (T₀/T)³` - matches Smashrun SPI
- **Calibrated**: 355 points for 5.94km in 41:38 (recreational runner)
- **Model Switching**: Runtime switching between Purdy v1 and Transparent v0
- **Transparency**: Clear explanation of PPI calculation

## 🔧 Current Implementation

- **PPI System**: Purdy Points model with cubic relationship
- **watchOS App**: Complete SwiftUI app with file import and analysis
- **Web Dashboard**: Full-featured workout management with manual entry, CRUD operations, and real-time PPI calculation
- **API Server**: Java-based REST API with CORS support, in-memory storage, and dynamic PPI tracking
- **CI/CD**: Automated builds with Windows-first workflow
- **Testing**: Comprehensive test suite including 90-day PPI calculation
- **Documentation**: Complete README and development workflow guides

## 📋 Next Steps

1. **Live Tracking**: Extend watchOS app with WorkoutKit integration
2. **HealthKit Integration**: Automatic workout import
3. **Complications**: Quick PPI display on watch face
4. **iOS Companion**: Easier file import and management
5. **Cloud Sync**: Multi-device synchronization 
