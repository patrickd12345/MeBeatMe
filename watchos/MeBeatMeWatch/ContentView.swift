import SwiftUI

struct ContentView: View {
    @State private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            HomeView()
                .environment(homeViewModel)
        }
    }
}

#Preview {
    ContentView()
}
