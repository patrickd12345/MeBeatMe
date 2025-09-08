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

## Usage Examples

### Basic Scoring

```kotlin
// Default Purdy model
val score = PpiEngine.score(5000.0, 1200.0) // 5K in 20:00

// Switch to Transparent model
PpiEngine.model = PpiModel.TransparentV0
val transparentScore = PpiEngine.score(5000.0, 1200.0)
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
├── PpiEngine.kt              # Unified facade
├── PpiCurvePurdy.kt          # Purdy-based scoring
├── PpiCurveTransparent.kt    # Refactored v0
└── PurdyTable.kt             # Baseline anchor management

core/src/commonMain/resources/
└── purdy_baseline.csv        # Elite anchor points

core/src/commonTest/kotlin/com/mebeatme/core/ppi/
└── PpiPurdyTest.kt           # Comprehensive test suite
```
