import SwiftUI

@main
struct BuildCompatApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var materialsVM = MaterialsViewModel()
    @StateObject private var projectsVM = ProjectsViewModel()
    @StateObject private var historyVM = HistoryViewModel()
    @StateObject private var favoritesVM = FavoritesViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(authVM)
                .environmentObject(materialsVM)
                .environmentObject(projectsVM)
                .environmentObject(historyVM)
                .environmentObject(favoritesVM)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if appState.showSplash {
                SplashView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if !authVM.isLoggedIn {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.showSplash)
        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: authVM.isLoggedIn)
    }
}
