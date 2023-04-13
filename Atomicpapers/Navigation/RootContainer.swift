import SwiftUI

struct RootContainer: View {
    @StateObject private var navState = NavState()
    @StateObject private var userSettings = UserSettings()
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            RootView()
                .withNavDestinations()
                .navigationTitle("Atomicpapers")
        }
        .environmentObject(navState)
        .environmentObject(userSettings)
    }
}
