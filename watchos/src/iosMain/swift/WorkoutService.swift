import Foundation
#if canImport(HealthKit)
import HealthKit
import Combine
#endif

/// Streams live workout metrics using HealthKit.
#if canImport(HealthKit)
final class WorkoutService: NSObject, ObservableObject {
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var distance: Double = 0
    @Published private(set) var pace: Double = 0    // seconds per km
    @Published private(set) var heartRate: Double = 0

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var timer: AnyCancellable?

    /// Starts a running workout session and begins publishing metrics.
    func start() async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
        builder = session?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
        session?.delegate = self
        builder?.delegate = self

        let start = Date()
        session?.startActivity(with: start)
        builder?.beginCollection(withStart: start) { _, _ in }

        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { [weak self] now in
            self?.elapsed = now.timeIntervalSince(start)
            self?.updateMetrics()
        }
    }

    /// Stops the active workout session.
    func stop() {
        timer?.cancel()
        session?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in
            self.builder?.finishWorkout { _, _ in }
        }
    }

    private func updateMetrics() {
        guard let builder = builder else { return }
        if let distanceStat = builder.statistics(for: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!) {
            distance = distanceStat.sumQuantity()?.doubleValue(for: .meter()) ?? 0
        }
        if elapsed > 0 && distance > 0 {
            pace = (elapsed / distance) * 1000
        }
        if let hrStat = builder.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!) {
            heartRate = hrStat.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
        }
    }
}

extension WorkoutService: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        updateMetrics()
    }
}
#else
/// Placeholder implementation for platforms without HealthKit.
final class WorkoutService: ObservableObject {
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var distance: Double = 0
    @Published private(set) var pace: Double = 0
    @Published private(set) var heartRate: Double = 0

    func start() async throws {}
    func stop() {}
}
#endif
