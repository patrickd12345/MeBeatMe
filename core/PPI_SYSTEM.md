# MeBeatMe PPI System Documentation

## Overview

The MeBeatMe PPI (Personal Performance Index) system now supports two scoring models:

1. **Purdy v1** (Default) - SPI-like scoring based on elite baseline anchors
2. **Transparent v0** - Original velocity-based formula

## Architecture

### Core Components

- **`PpiEngine`** - Unified facade that switches between models at runtime
- **`PpiCurvePurdy`** - New Purdy-based scoring system
- **`PpiCurveTransparent`** - Refactored original v0 system
- **`PurdyTable`** - Loads and manages elite baseline anchor points

### Model Switching

```kotlin
// Switch to Purdy model (default)
PpiEngine.model = PpiModel.PurdyV1

// Switch to Transparent model
PpiEngine.model = PpiModel.TransparentV0

// Calculate score using active model
val score = PpiEngine.score(distanceM, elapsedSec, corrections)
```

## Purdy Model Details

### Baseline Anchors

The Purdy model uses elite performance anchors:

| Distance | Elite Time | Points |
|----------|------------|--------|
| 1500m    | 3:50       | 1000   |
| 5000m    | 13:00      | 1000   |
| 10000m   | 27:00      | 1000   |
| 21097m   | 59:00      | 1000   |
| 42195m   | 2:04:20    | 1000   |

### Scoring Formula

```
PPI = 1000.0 × (baseline_time / actual_time)^(-2.0)
```

- **Performance Ratio**: `baseline_time / actual_time`
- **Exponential Scaling**: `ratio^(-2.0)` for smooth curve
- **Score Range**: 100-2000 points
- **Elite Baseline**: 1000 points for meeting anchor times

### Score Ranges

- **Elite Performance**: 1000 points (meets baseline)
- **Competitive Performance**: 694 points (slower than elite)
- **Recreational Performance**: 300-500 points (typical range)
- **Moderate Performance**: 100 points (minimum score)

## Transparency Panel

The transparency panel now shows:

- **Model Version**: Which PPI model was used
- **Model Type**: Human-readable model name
- **Formula**: The actual formula used
- **Performance Ratio**: How you compare to elite baseline (Purdy only)
- **Baseline Time**: Elite time for your distance (Purdy only)

## Testing

Comprehensive test suite covers:

- **PurdyTable**: Anchor loading and interpolation
- **PpiCurvePurdy**: Scoring, inversion, and edge cases
- **PpiEngine**: Model switching and facade functionality
- **Calibration**: Recreational vs elite scoring ranges

## Heart Rate-Based Scoring

The system now supports heart rate-based PPI calculations that segment runs based on effort variations:

### Heart Rate Segmentation

- **Automatic Segmentation**: Creates segments when heart rate changes significantly (>10 BPM)
- **Effort-Based Corrections**: Applies time adjustments based on relative heart rate intensity
- **Zone-Aware Analysis**: Considers heart rate zones for more accurate scoring

### Effort Adjustment Formula

```kotlin
// Heart rate effort adjustment based on relative intensity
val relativeIntensity = (segmentHR - baselineHR) / (maxHR - baselineHR)

val adjustment = when {
    relativeIntensity > 0.8 -> 0.15  // High intensity: +15% time penalty
    relativeIntensity > 0.6 -> 0.08  // Moderate-high: +8% time penalty
    relativeIntensity > 0.4 -> 0.03  // Moderate: +3% time penalty
    relativeIntensity < 0.2 -> -0.05 // Low intensity: -5% time bonus
    else -> 0.0  // Normal intensity: no adjustment
}
```

## Usage Examples

### Basic Scoring

```kotlin
// Default Purdy model
val score = PpiEngine.score(5000.0, 1200.0) // 5K in 20:00

// Switch to Transparent model
PpiEngine.model = PpiModel.TransparentV0
val transparentScore = PpiEngine.score(5000.0, 1200.0)
```

### Heart Rate-Based Scoring

```kotlin
// Heart rate-based PPI calculation
val heartRateData = listOf(
    HeartRatePoint(timestampEpochMs = 1000, heartRateBpm = 150),
    HeartRatePoint(timestampEpochMs = 2000, heartRateBpm = 160),
    HeartRatePoint(timestampEpochMs = 3000, heartRateBpm = 170)
)

val hrBasedScore = PpiEngine.scoreWithHeartRate(
    distanceM = 5000.0,
    elapsedSec = 1200.0,
    heartRateData = heartRateData,
    userMaxHR = 200,
    baselineHR = 120
)
```

### Performance Analysis

```kotlin
// Get performance ratio (Purdy only)
val ratio = PpiEngine.getPerformanceRatio(5000.0, 1200.0)
// ratio = 0.65 (65% of elite pace)

// Get baseline time (Purdy only)
val baseline = PpiEngine.getBaselineTime(5000.0)
// baseline = 780.0 seconds (13:00)
```

### Required Pace Calculation

```kotlin
// Find pace needed to achieve target score
val targetScore = 1000.0
val requiredPace = PpiEngine.requiredPaceSecPerKm(targetScore, 0, 5000.0)
// Returns seconds per kilometer
```

## Migration Notes

- **Backward Compatibility**: Existing code using `PpiCurve` now uses `PpiEngine`
- **Default Model**: Purdy v1 is the default, but v0 remains selectable
- **Transparency**: Enhanced transparency panel shows model details
- **Testing**: All existing tests updated to use new facade

## File Structure

```
core/src/commonMain/kotlin/com/mebeatme/core/ppi/
├── PpiEngine.kt              # Unified facade with heart rate support
├── PpiCurvePurdy.kt          # Purdy-based scoring
├── PpiCurveTransparent.kt    # Refactored v0
├── PurdyTable.kt             # Baseline anchor management
└── HeartRatePpiCalculator.kt # Heart rate-based segmentation and scoring

core/src/commonMain/resources/
└── purdy_baseline.csv        # Elite anchor points

core/src/commonTest/kotlin/com/mebeatme/core/ppi/
├── PpiPurdyTest.kt           # Comprehensive test suite
└── HeartRatePpiCalculatorTest.kt # Heart rate calculation tests
```
