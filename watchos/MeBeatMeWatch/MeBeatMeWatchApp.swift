import SwiftUI
import Observation

@main
struct MeBeatMeWatchApp: App {
    @State private var homeViewModel = HomeViewModel()
    @State private var importViewModel = ImportViewModel()
    @State private var analysisViewModel = AnalysisViewModel()
    @State private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
                .environment(importViewModel)
                .environment(analysisViewModel)
                .environment(settingsViewModel)
        }
    }
}
