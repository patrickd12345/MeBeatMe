# watchOS Integration

This module will consume the MeBeatMe core as an iOS framework.

## Building the Framework

To produce an `.xcframework` from the core module:

```bash
./gradlew :core:assembleXCFramework
```

The framework will be available at: `core/build/XCFrameworks/debug/core.xcframework`

## Integration Steps

1. **Add to Xcode Project**: Drag the `.xcframework` into your watchOS app target
2. **Import in Swift**: `import core`
3. **Use Core Classes**: 
   ```swift
   let history = HistoryStore()
   let planner = BeatPlanner(history: history.all())
   let choices = planner.choicesFor(bucket: .km_3_8)
   ```

## SwiftUI Implementation

The watchOS app will use SwiftUI to create:
- Multiple-choice challenge selection screen
- Live running session with progress ring
- Post-run feedback and celebration

## Next Steps

- Create SwiftUI views that mirror the Wear OS Compose implementation
- Integrate with HealthKit for workout data
- Add WorkoutKit for real-time metrics
- Implement Apple Watch haptic feedback
