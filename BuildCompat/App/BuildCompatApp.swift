import SwiftUI

@main
struct BuildCompatApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

struct RootView: View {

    @StateObject private var appState = AppState()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var materialsVM = MaterialsViewModel()
    @StateObject private var projectsVM = ProjectsViewModel()
    @StateObject private var historyVM = HistoryViewModel()
    @StateObject private var favoritesVM = FavoritesViewModel()

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if !authVM.isLoggedIn {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: authVM.isLoggedIn)
        .environmentObject(appState)
        .environmentObject(authVM)
        .environmentObject(materialsVM)
        .environmentObject(projectsVM)
        .environmentObject(historyVM)
        .environmentObject(favoritesVM)
        .preferredColorScheme(appState.colorScheme)
    }
}
