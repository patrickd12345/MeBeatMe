import Foundation
import Combine
import shared

class MeBeatMeViewModel: ObservableObject {
    private let meBeatMeService = MeBeatMeService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentScreen: Screen = .challengeSelection
    @Published var challenges: [ChallengeOption] = []
    @Published var selectedChallenge: ChallengeOption?
    @Published var realTimeFeedback: RealTimeFeedback?
    @Published var lastScore: Score?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe challenges
        meBeatMeService.currentChallenges.asPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] challenges in
                self?.challenges = challenges
            }
            .store(in: &cancellables)
        
        // Observe selected challenge
        meBeatMeService.selectedChallenge.asPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] challenge in
                self?.selectedChallenge = challenge
                if challenge != nil {
                    self?.currentScreen = .runningSession
                }
            }
            .store(in: &cancellables)
    }
    
    func generateChallenges() {
        meBeatMeService.generateChallenges()
    }
    
    func selectChallenge(_ challenge: ChallengeOption) {
        meBeatMeService.selectChallenge(challenge: challenge)
    }
    
    func updateSession(distance: Double, duration: Int64, currentPace: Double) {
        meBeatMeService.updateSession(distance: distance, duration: duration, currentPace: currentPace)
        
        // Update real-time feedback
        if let feedback = meBeatMeService.getRealTimeFeedback() {
            DispatchQueue.main.async {
                self.realTimeFeedback = feedback
                self.triggerHapticFeedback(for: feedback.paceZone)
            }
        }
    }
    
    func completeSession() {
        if let score = meBeatMeService.completeSession() {
            DispatchQueue.main.async {
                self.lastScore = score
                self.currentScreen = .postRunFeedback
                
                if score.achieved {
                    self.triggerHapticFeedback(for: .celebration)
                }
            }
        }
    }
    
    func startNewSession() {
        DispatchQueue.main.async {
            self.currentScreen = .challengeSelection
            self.lastScore = nil
            self.realTimeFeedback = nil
            self.generateChallenges()
        }
    }
    
    private func triggerHapticFeedback(for paceZone: PaceZone) {
        switch paceZone {
        case .onTarget:
            WKInterfaceDevice.current().play(.success)
        case .tooFast:
            WKInterfaceDevice.current().play(.notification)
        case .tooSlow:
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    private func triggerHapticFeedback(for type: HapticType) {
        switch type {
        case .success:
            WKInterfaceDevice.current().play(.success)
        case .warning:
            WKInterfaceDevice.current().play(.notification)
        case .encouragement:
            WKInterfaceDevice.current().play(.click)
        case .celebration:
            WKInterfaceDevice.current().play(.success)
        }
    }
}

enum Screen {
    case challengeSelection
    case runningSession
    case postRunFeedback
}

enum HapticType {
    case success
    case warning
    case encouragement
    case celebration
}

// Extension to convert Kotlin Flow to Combine Publisher
extension Kotlinx_coroutines_coreFlow {
    func asPublisher<T>() -> AnyPublisher<T, Never> {
        return Future<T, Never> { promise in
            // This is a simplified implementation
            // In a real app, you'd need proper Flow to Publisher conversion
        }
        .eraseToAnyPublisher()
    }
}
