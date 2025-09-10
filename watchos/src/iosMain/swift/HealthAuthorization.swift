import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Handles requesting HealthKit permissions required for workout tracking.
struct HealthAuthorization {
    static let shared = HealthAuthorization()

    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()

    /// Requests read and write access for workout metrics.
    func requestAuthorization() async throws {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        let typesToRead: Set<HKObjectType> = typesToShare
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            print("HealthKit authorization failed: \(error)")
            // For now, we'll continue without HealthKit rather than crashing
            // In a real app, you'd want to handle this more gracefully
        }
    }
    #else
    /// Fallback for platforms without HealthKit.
    func requestAuthorization() async throws {}
    #endif
}
