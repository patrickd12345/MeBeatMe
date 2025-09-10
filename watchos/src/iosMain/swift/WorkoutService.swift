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
        try await builder?.beginCollection(at: start)

        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect().sink { [weak self] now in
            self?.elapsed = now.timeIntervalSince(start)
            self?.updateMetrics()
        }
    }

    /// Starts a basic timer when HealthKit is not available (simulator/fallback)
    func startBasicTimer() async throws {
        print("🔄 WorkoutService.startBasicTimer() called")
        let start = Date()
        
        // Use a simple Timer that should work reliably on watchOS
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { 
                    print("❌ WorkoutService timer callback: self is nil")
                    return 
                }
                self.elapsed = Date().timeIntervalSince(start)
                self.updateBasicMetrics()
                print("🕐 Timer tick: elapsed=\(self.elapsed), distance=\(self.distance), pace=\(self.pace), heartRate=\(self.heartRate)")
            }
        
        print("✅ Basic timer started successfully")
    }
    
    /// Updates basic metrics without HealthKit
    private func updateBasicMetrics() {
        print("📊 updateBasicMetrics() called - elapsed: \(elapsed)")
        // Simulate basic metrics for testing
        // In a real app, you might get these from GPS or other sensors
        distance = elapsed * 3.0 // Simulate 3 m/s average speed
        pace = distance > 0 ? elapsed / (distance / 1000) : 0
        heartRate = 150.0 // Simulate average heart rate
        print("📊 Updated metrics - distance: \(distance), pace: \(pace), heartRate: \(heartRate)")
    }

    /// Stops the active workout session.
    func stop() async {
        timer?.cancel()
        
        if let session = session {
            session.end()
            do {
                try await builder?.endCollection(at: Date())
                try await builder?.finishWorkout()
            } catch {
                print("Error stopping HealthKit workout: \(error)")
            }
        }
        
        print("✅ Workout stopped")
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
    func stop() async {}
}
#endif
