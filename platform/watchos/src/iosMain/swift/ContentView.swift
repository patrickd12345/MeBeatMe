import SwiftUI
import HealthKit
import WorkoutKit
import core

struct ContentView: View {
    @StateObject private var viewModel = MeBeatMeViewModel()
    
    var body: some View {
        NavigationView {
            switch viewModel.currentScreen {
            case .challengeSelection:
                ChallengeSelectionView(viewModel: viewModel)
            case .liveRun:
                LiveRunView(viewModel: viewModel)
            case .postRun:
                PostRunView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.requestHealthPermissions()
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
                
                ForEach(viewModel.challenges, id: \.label) { choice in
                    ChoiceCard(choice: choice) {
                        viewModel.startLiveRun(choice)
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

struct ChoiceCard: View {
    let choice: BeatChoice
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(choice.label)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Target: \(formatPace(choice.targetPaceSecPerKm))/km")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Duration: \(choice.windowSeconds / 60) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
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

struct LiveRunView: View {
    @ObservedObject var viewModel: MeBeatMeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if let session = viewModel.liveSession {
                Text(session.choice.label)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Progress ring
                ZStack {
                    ProgressRing(progress: session.progressPercentage())
                        .frame(width: 120, height: 120)
                    
                    VStack {
                        Text(formatPace(Int(session.currentPaceSecPerKm)))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Target: \(formatPace(session.choice.targetPaceSecPerKm))")
                            .font(.caption)
                    }
                }
                
                // Pace status
                Text(viewModel.isOnTarget ? "On Target! 🎯" : "Adjust Pace")
                    .foregroundColor(viewModel.isOnTarget ? .green : .orange)
                
                Button("Stop Run") {
                    viewModel.stopLiveRun()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress >= 1.0 ? Color.green : Color.blue,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct PostRunView: View {
    @ObservedObject var viewModel: MeBeatMeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if let score = viewModel.lastScore {
                Text("🎉 Run Complete!")
                    .font(.headline)
                    .fontWeight(.bold)
                
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
private func formatPace(_ secPerKm: Int) -> String {
    let minutes = secPerKm / 60
    let seconds = secPerKm % 60
    return String(format: "%d:%02d/km", minutes, seconds)
}

enum Screen {
    case challengeSelection
    case liveRun
    case postRun
}
