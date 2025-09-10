import SwiftUI

@main
struct MeBeatMeWatchApp: App {
    var body: some Scene {		
        WindowGroup {
            HomeView()
                .environment(HomeViewModel())
        }
    }
}
