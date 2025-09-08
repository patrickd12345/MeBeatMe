import SwiftUI

struct ContentView: View {
    @Environment(HomeViewModel.self) private var homeViewModel
    @Environment(ImportViewModel.self) private var importViewModel
    @Environment(AnalysisViewModel.self) private var analysisViewModel
    @Environment(SettingsViewModel.self) private var settingsViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ImportView()
                .tabItem {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import")
                }
            
            AnalysisView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analysis")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear {
            // Initialize app on first launch
            AppLogger.logUserAction("app_launched")
        }
    }
}

#Preview {
    ContentView()
        .environment(HomeViewModel())
        .environment(ImportViewModel())
        .environment(AnalysisViewModel())
        .environment(SettingsViewModel())
}
