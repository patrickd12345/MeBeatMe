# MeBeatMe

A watch-first running app with distance-agnostic Personal Performance Index (PPI) and on-wrist "Beat-Your-Best" multiple-choice planner.

## 🏗️ Architecture

Clean Kotlin Multiplatform monorepo:

```
MeBeatMe/
├── core/                    # KMP shared business logic
│   ├── model.kt            # RunSession, Score, Bucket enums
│   ├── ppi.kt              # PPI curve calculation
│   ├── planner.kt          # Beat-your-best choice generator
│   └── history.kt          # In-memory history store
├── platform/wearos/        # Wear OS Jetpack Compose app
├── platform/watchos/       # watchOS placeholder + xcframework task
├── web/                    # Kotlin/JS web app
└── server/                 # Ktor server with health endpoint
```

## 🚀 Quick Start

### Sync Gradle
```bash
./gradlew build
```

### Run Wear OS App
```bash
# Open Android Studio, select :platform:wearos module
# Run on Wear OS emulator → view multiple-choice list
```

### Run Web App
```bash
./gradlew :web:browserDevelopmentRun
# Open shown URL; see choices text
```

### Run Server
```bash
./gradlew :server:run
# GET http://localhost:8080/health
```

### Build iOS Framework
```bash
./gradlew :core:assembleXCFramework
# Framework available in core/build/XCFrameworks/debug/
```

## 🧮 Core Features

### PPI (Personal Performance Index)
- **v0 transparent baseline**: `score(distance,time)` with light distance scaling
- **Formula**: `350.0 * velocity^0.95 * distance^0.05`
- **Range**: 0-1200 points
- **Monotonic**: Faster times = higher scores

### Beat-Your-Best Planner
- **Distance Buckets**: KM_1_3, KM_3_8, KM_8_15, KM_15_25, KM_25P
- **Challenge Types**: Short & Fierce, Tempo Boost, Ease Into It, Surprise Me
- **Target Generation**: Beats historical best by +1 PPI point
- **Time Windows**: 5min, 10min, 20min options

### History Store
- **In-memory**: Replace with platform-specific persistence later
- **Best Tracking**: Per-bucket historical maximums
- **Corrections**: Elevation and temperature adjustments

## 📱 Platform Status

- ✅ **Core KMP**: Models, PPI curve, planner, tests
- ✅ **Wear OS**: Jetpack Compose multiple-choice UI
- ✅ **Web**: Kotlin/JS text output
- ✅ **Server**: Ktor health endpoint
- 🚧 **watchOS**: xcframework ready, SwiftUI pending

## 🔧 Development Notes

- **PPI Curve**: v0 placeholder; swap for Purdy-style fit later
- **Planner**: Beats best by +1 point; tune windows and labels
- **History**: In-memory; replace per-platform with persistence
- **Tests**: Core functions covered; keep small and documented

## 📋 Next Steps

1. **Wear OS**: Wire real sensor data + live progress ring
2. **watchOS**: Export iOS framework + build SwiftUI app
3. **Core**: Replace v0 PPI with Purdy Points model
4. **Persistence**: Platform-specific data storage
5. **Sync**: Server endpoints for cross-device history 
