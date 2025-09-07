import SwiftUI

/// Displays summary after a run completes.
struct RunSummaryView: View {
    let run: Run

    var body: some View {
        VStack(spacing: 8) {
            Text("Run Summary")
                .font(.headline)
            Text(String(format: "%.2f km", run.distanceM / 1000))
            Text(formatPace(run.avgPaceSecPerKm))
            Text("Purdy: \(Int(run.purdyScore))")
        }
    }

    private func formatPace(_ secPerKm: Double) -> String {
        let minutes = Int(secPerKm) / 60
        let seconds = Int(secPerKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
