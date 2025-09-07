import SwiftUI

/// Lists previous runs and starts new sessions.
struct RunDashboardView: View {
    @StateObject var viewModel = RunSessionViewModel()
    @State private var runs: [Run] = []
    private let store = RunStore()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent Runs")) {
                    ForEach(runs) { run in
                        VStack(alignment: .leading) {
                            Text(run.startedAt, style: .date)
                            Text(String(format: "%.2f km", run.distanceM / 1000))
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.carousel)
            .navigationTitle("MeBeatMe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Start") {
                        Task { await viewModel.startRun(targetDistance: 5000, windowSec: 1800) }
                    }
                }
            }
        }
        .onAppear { runs = store.list(limit: 10) }
    }
}
