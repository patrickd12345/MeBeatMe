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
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        let typesToRead: Set<HKObjectType> = typesToShare
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }
    #else
    /// Fallback for platforms without HealthKit.
    func requestAuthorization() async throws {}
    #endif
}
