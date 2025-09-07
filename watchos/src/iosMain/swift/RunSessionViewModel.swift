import Foundation
import Combine

/// View model driving a live running session.
final class RunSessionViewModel: ObservableObject {
    @Published var liveDistance: Double = 0
    @Published var livePace: Double = 0   // seconds per km
    @Published var liveHeartRate: Double = 0
    @Published var elapsed: TimeInterval = 0
    @Published var paceDelta: Double = 0
    @Published var purdyScore: Double = 0

    private let workoutService: WorkoutService
    private var cancellables = Set<AnyCancellable>()

    private var targetPace: Double = 0

    init(workoutService: WorkoutService = WorkoutService()) {
        self.workoutService = workoutService
        bindStreams()
    }

    private func bindStreams() {
        workoutService.$elapsed
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$elapsed)
        workoutService.$distance
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$liveDistance)
        workoutService.$pace
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$livePace)
        workoutService.$heartRate
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$liveHeartRate)

        workoutService.$pace
            .combineLatest(Just(targetPace))
            .map { current, target in current - target }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$paceDelta)

        workoutService.$distance
            .combineLatest(workoutService.$elapsed.map { Int($0) })
            .map { dist, time in KMPBridge.purdyScore(distanceMeters: dist, durationSec: time) }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$purdyScore)
    }

    /// Begins a new running session.
    func startRun(targetDistance: Double, windowSec: Int) async {
        targetPace = KMPBridge.targetPace(for: targetDistance, windowSec: windowSec)
        do {
            try await HealthAuthorization.shared.requestAuthorization()
            try await workoutService.start()
        } catch {
            print("Start run failed: \(error)")
        }
    }

    /// Stops the active run.
    func stopRun() {
        workoutService.stop()
    }
}
