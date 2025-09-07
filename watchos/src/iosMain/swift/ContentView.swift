import SwiftUI
import shared

struct ContentView: View {
    @StateObject private var viewModel = MeBeatMeViewModel()
    
    var body: some View {
        NavigationView {
            switch viewModel.currentScreen {
            case .challengeSelection:
                ChallengeSelectionView(viewModel: viewModel)
            case .runningSession:
                RunningSessionView(viewModel: viewModel)
            case .postRunFeedback:
                PostRunFeedbackView(viewModel: viewModel)
            }
        }
    }
}

struct ChallengeSelectionView: View {
    @ObservedObject var viewModel: MeBeatMeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Beat Your Best")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                ForEach(viewModel.challenges, id: \.id) { challenge in
                    ChallengeCard(challenge: challenge) {
                        viewModel.selectChallenge(challenge)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.generateChallenges()
        }
    }
}

struct ChallengeCard: View {
    let challenge: ChallengeOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(challenge.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("Target: \(formatPace(challenge.targetPace))/km")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RunningSessionView: View {
    @ObservedObject var viewModel: MeBeatMeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if let challenge = viewModel.selectedChallenge {
                Text(challenge.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Target: \(formatPace(challenge.targetPace))/km")
                    .font(.subheadline)
            }
            
            if let feedback = viewModel.realTimeFeedback {
                VStack(spacing: 12) {
                    Text("Current Pace")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatPace(feedback.currentPace))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(paceZoneColor(feedback.paceZone))
                    
                    PaceZoneIndicator(paceZone: feedback.paceZone)
                    
                    VStack(spacing: 4) {
                        Text("Progress: \(Int(feedback.progressPercentage * 100))%")
                            .font(.caption)
                        
                        ProgressView(value: feedback.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                }
            }
            
            Button("Complete Run") {
                viewModel.completeSession()
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

struct PaceZoneIndicator: View {
    let paceZone: PaceZone
    
    var body: some View {
        let (text, color) = paceZoneInfo(paceZone)
        
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct PostRunFeedbackView: View {
    @ObservedObject var viewModel: MeBeatMeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if let score = viewModel.lastScore {
                if score.achieved {
                    Text("🎉 Congratulations!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("Keep Going!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Text("Your PPI: \(Int(score.ppi))")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Bucket: \(score.bucket.name)")
                    .font(.subheadline)
                
                Button("New Challenge") {
                    viewModel.startNewSession()
                }
            }
        }
        .padding()
    }
}

// Helper functions
private func formatPace(_ secondsPerKm: Double) -> String {
    let minutes = Int(secondsPerKm / 60)
    let seconds = Int(secondsPerKm.truncatingRemainder(dividingBy: 60))
    return String(format: "%d:%02d", minutes, seconds)
}

private func paceZoneColor(_ paceZone: PaceZone) -> Color {
    switch paceZone {
    case .tooFast:
        return .red
    case .onTarget:
        return .green
    case .tooSlow:
        return .orange
    }
}

private func paceZoneInfo(_ paceZone: PaceZone) -> (String, Color) {
    switch paceZone {
    case .tooFast:
        return ("Too Fast", .red)
    case .onTarget:
        return ("On Target", .green)
    case .tooSlow:
        return ("Too Slow", .orange)
    }
}

#Preview {
    ContentView()
}
