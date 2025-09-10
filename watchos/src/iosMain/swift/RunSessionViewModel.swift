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
        print("🏃 RunSessionViewModel.init() called")
        self.workoutService = workoutService
        bindStreams()
        print("🏃 RunSessionViewModel.init() completed")
    }

    private func bindStreams() {
        print("🔗 RunSessionViewModel.bindStreams() called")
        
        workoutService.$elapsed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] elapsed in
                print("📡 Received elapsed update: \(elapsed)")
                self?.elapsed = elapsed
            }
            .store(in: &cancellables)
            
        workoutService.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                print("📡 Received distance update: \(distance)")
                self?.liveDistance = distance
            }
            .store(in: &cancellables)
            
        workoutService.$pace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pace in
                print("📡 Received pace update: \(pace)")
                self?.livePace = pace
            }
            .store(in: &cancellables)
            
        workoutService.$heartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heartRate in
                print("📡 Received heartRate update: \(heartRate)")
                self?.liveHeartRate = heartRate
            }
            .store(in: &cancellables)

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
        print("🚀 Starting run with target distance: \(targetDistance)m, window: \(windowSec)s")
        targetPace = KMPBridge.targetPace(for: targetDistance, windowSec: windowSec)
        
        // Try to start HealthKit workout, but don't fail if it doesn't work
        do {
            print("📱 Attempting HealthKit authorization...")
            try await HealthAuthorization.shared.requestAuthorization()
            print("📱 Attempting HealthKit workout start...")
            try await workoutService.start()
            print("✅ HealthKit workout started successfully")
        } catch {
            print("⚠️ HealthKit workout failed to start: \(error)")
            // Start a basic timer even if HealthKit fails
            print("🔄 Falling back to basic timer...")
            await startBasicTimer()
        }
    }
    
    /// Starts a basic timer when HealthKit is not available
    private func startBasicTimer() async {
        print("⏰ Starting basic timer...")
        // This will be implemented in WorkoutService as a fallback
        do {
            try await workoutService.startBasicTimer()
            print("✅ Basic timer started successfully")
        } catch {
            print("❌ Failed to start basic timer: \(error)")
        }
    }

    /// Stops the active run.
    func stopRun() async {
        await workoutService.stop()
    }
}
