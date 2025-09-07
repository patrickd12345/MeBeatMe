import Foundation
import HealthKit
import WorkoutKit
import Combine
import core

class MeBeatMeViewModel: ObservableObject {
    @Published var currentScreen: Screen = .challengeSelection
    @Published var challenges: [BeatChoice] = []
    @Published var liveSession: LiveSession?
    @Published var isOnTarget: Bool = false
    @Published var lastScore: Score?
    
    private let healthStore = HKHealthStore()
    private let workoutManager = WorkoutManager()
    private let historyStore = HistoryStore()
    private var cancellables = Set<AnyCancellable>()
    
    func requestHealthPermissions() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Health authorization error: \(error)")
            }
        }
    }
    
    func generateChallenges() {
        let bucket = Bucket.km_3_8
        let planner = BeatPlanner(history: historyStore.all())
        challenges = planner.choicesFor(bucket: bucket)
    }
    
    func startLiveRun(_ choice: BeatChoice) {
        let session = LiveSession(
            choice: choice,
            startTimeMs: Int64(Date().timeIntervalSince1970 * 1000)
        )
        liveSession = session
        currentScreen = .liveRun
        
        // Start workout tracking
        workoutManager.startWorkout { [weak self] workoutData in
            DispatchQueue.main.async {
                self?.updateLiveSession(workoutData)
            }
        }
    }
    
    private func updateLiveSession(_ workoutData: WorkoutData) {
        guard var session = liveSession else { return }
        
        session = session.copy(
            currentDistanceM: workoutData.distanceMeters,
            currentElapsedSec: workoutData.elapsedSeconds,
            currentPaceSecPerKm: workoutData.currentPaceSecPerKm
        )
        
        liveSession = session
        
        // Check if on target pace
        isOnTarget = session.isOnTargetPace()
        
        // Trigger haptic feedback
        if isOnTarget {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    func stopLiveRun() {
        guard let session = liveSession else { return }
        
        workoutManager.stopWorkout()
        
        // Complete the session
        let runSession = session.complete()
        let ppi = PpiCurve.score(distanceM: runSession.distanceMeters, elapsedSec: runSession.elapsedSeconds)
        let bucket = bucketFor(distanceM: runSession.distanceMeters)
        
        let score = Score(
            sessionId: runSession.id,
            ppi: ppi,
            bucket: bucket
        )
        
        // Save to history
        historyStore.add(score: score)
        
        lastScore = score
        liveSession = nil
        currentScreen = .postRun
        
        // Celebration haptic
        WKInterfaceDevice.current().play(.success)
    }
    
    func startNewSession() {
        currentScreen = .challengeSelection
        lastScore = nil
        isOnTarget = false
        generateChallenges()
    }
}

// WorkoutManager for HealthKit integration
class WorkoutManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    func startWorkout(completion: @escaping (WorkoutData) -> Void) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(at: Date()) { success, error in
                if let error = error {
                    print("Workout builder error: \(error)")
                }
            }
            
            // Monitor workout data
            workoutBuilder?.dataSource?.enableCollection(for: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, predicate: nil)
            workoutBuilder?.dataSource?.enableCollection(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, predicate: nil)
            
            // Start monitoring
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.updateWorkoutData(completion: completion)
            }
            
        } catch {
            print("Workout session error: \(error)")
        }
    }
    
    private func updateWorkoutData(completion: @escaping (WorkoutData) -> Void) {
        guard let builder = workoutBuilder else { return }
        
        let distance = builder.statistics(for: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!)?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0.0
        let duration = builder.elapsedTime
        let pace = duration > 0 ? (duration / (distance / 1000.0)) : 0.0
        
        let workoutData = WorkoutData(
            distanceMeters: distance,
            elapsedSeconds: duration,
            currentPaceSecPerKm: pace
        )
        
        completion(workoutData)
    }
    
    func stopWorkout() {
        workoutSession?.end()
        workoutBuilder?.endCollection(at: Date()) { success, error in
            if let error = error {
                print("End collection error: \(error)")
            }
        }
    }
}

struct WorkoutData {
    let distanceMeters: Double
    let elapsedSeconds: Double
    let currentPaceSecPerKm: Double
}
