import SwiftUI

/// Displays live metrics during an active run.
struct RunActiveView: View {
    @ObservedObject var viewModel: RunSessionViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text(timeString(viewModel.elapsed))
                .font(.title3)
            Text(String(format: "%.2f km", viewModel.liveDistance / 1000))
            Text(formatPace(viewModel.livePace))
                .font(.headline)
            Text("Δ " + formatPace(viewModel.paceDelta))
                .foregroundColor(viewModel.paceDelta <= 0 ? .green : .red)
            Text("\(Int(viewModel.liveHeartRate)) bpm")
            Button("Stop") { viewModel.stopRun() }
                .tint(.red)
        }
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatPace(_ secPerKm: Double) -> String {
        guard secPerKm.isFinite else { return "-" }
        let minutes = Int(secPerKm) / 60
        let seconds = Int(secPerKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
