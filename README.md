# MeBeatMe

A cross-platform watch app that helps runners beat their own performance index each day, rather than racing others. Built with Kotlin Multiplatform for shared core logic and native UI for watchOS and Wear OS.

## 🎯 Mission

MeBeatMe presents runners with multiple-choice challenges on their wrist, asking "what would it take today to beat your best comparable performance?" The app uses the Purdy Points model to create normalized performance comparisons across different distances.

## ✨ Features

### v0.1 Core Features
- **Multiple-Choice Challenges**: Four challenge types (Short & Fierce, Tempo Boost, Ease Into It, Surprise Me)
- **Real-Time Pacing**: Live pace feedback with haptic coaching
- **Performance Index (PPI)**: Purdy Points-based scoring system
- **Historical Tracking**: Automatic tracking of best performance per distance bucket
- **Cross-Platform**: Native UI for both watchOS and Wear OS

### Challenge Types
1. **Short & Fierce** — Hold target pace for short duration to beat sprint equivalent
2. **Tempo Boost** — Sustain tempo pace to beat short-run index  
3. **Ease Into It** — Cruise at comfortable pace to beat long-run PPI
4. **Surprise Me** — AI-generated playful but beatable challenge

## 🏗️ Architecture

### Kotlin Multiplatform Monorepo
```
MeBeatMe/
├── shared/           # KMP core (PPI math, data models, business logic)
├── watchos/          # iOS/watchOS SwiftUI interface
├── wearos/           # Android/Wear OS Compose interface
└── build.gradle.kts  # Root build configuration
```

### Core Components
- **PurdyPointsCalculator**: Implements the Purdy Points model for PPI calculation
- **PerformanceBucketManager**: Manages distance buckets and historical bests
- **ChallengeGenerator**: Creates multiple-choice targets that beat historical performance
- **MeBeatMeService**: Main orchestrator for app functionality

### Data Models
- **RunSession**: Distance, duration, pace, samples
- **Score**: PPI, bucket, target metrics, achievement status
- **ChallengeOption**: Generated challenge with target pace/duration
- **DistanceBucket**: Comparable performance bins (Sprint, Short Run, Medium Run, etc.)

## 🧮 Performance Index (PPI) System

Based on the Purdy Points model from elite athlete tables (1974), MeBeatMe calculates a Performance Index that allows comparison across different distances:

- **Formula**: PPI = 1000 × (pace_ratio)^(-1.07)
- **Reference Points**: Elite performance benchmarks for 100m to marathon
- **Normalization**: Enables fair comparison between 1km sprint and 10km tempo run

### Distance Buckets
- **Sprint** (1-3km): Short, intense efforts
- **Short Run** (3-8km): Tempo and 5K efforts  
- **Medium Run** (8-15km): 10K and half-marathon pace
- **Long Run** (15-25km): Marathon training runs
- **Ultra Run** (25km+): Ultra-marathon distances

## 🚀 Getting Started

### Prerequisites
- Android Studio Arctic Fox or later
- Xcode 14+ (for watchOS)
- Kotlin 1.9.20+
- Gradle 8.0+

### Building the Project

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/MeBeatMe.git
   cd MeBeatMe
   ```

2. **Build shared KMP module**
   ```bash
   ./gradlew :shared:build
   ```

3. **Build Wear OS app**
   ```bash
   ./gradlew :wearos:assembleDebug
   ```

4. **Build watchOS framework**
   ```bash
   ./gradlew :watchos:linkDebugFrameworkIosArm64
   ```

### Running Tests
```bash
./gradlew test
```

## 📱 Platform-Specific Features

### Wear OS (Android)
- Jetpack Compose UI optimized for round screens
- Material 3 design system
- Android haptic feedback integration
- Health Connect integration for workout data

### watchOS (iOS)
- SwiftUI native interface
- HealthKit integration for workout tracking
- WorkoutKit for real-time metrics
- Apple Watch haptic feedback

## 🔧 Development

### Adding New Challenge Types
1. Extend `ChallengeGenerator` with new challenge logic
2. Add challenge type to `ChallengeOption` model
3. Update UI components to handle new challenge type
4. Add tests for new challenge generation

### Customizing PPI Calculation
The Purdy Points model can be adjusted in `PurdyPointsCalculator.kt`:
- Modify reference performance times
- Adjust power factor for pace scaling
- Add new distance reference points

### Platform Integration
- **Health Data**: Integrate with HealthKit (iOS) and Health Connect (Android)
- **Location**: GPS tracking for accurate distance measurement
- **Sensors**: Heart rate, cadence, and other metrics

## 🧪 Testing

The project includes comprehensive unit tests for:
- PPI calculation accuracy
- Challenge generation logic
- Bucket management
- Pace/time conversions

Run tests with:
```bash
./gradlew test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- **Smashrun**: Inspiration for the SPI (Smashrun Performance Index) concept
- **Purdy Points Model**: Performance comparison methodology
- **Kotlin Multiplatform**: Enabling shared business logic across platforms
- **SwiftUI & Jetpack Compose**: Modern declarative UI frameworks

---

*"The only person you should try to be better than is the person you were yesterday."* - MeBeatMe Philosophy 
