import SwiftUI
import Combine

class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("themeMode") var themeMode: String = "system" {
        didSet { updateColorScheme() }
    }
    @AppStorage("selectedLanguage") var selectedLanguage: String = "English"
    @AppStorage("selectedUnits") var selectedUnits: String = "Metric"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false

    @Published var showSplash: Bool = true
    @Published var colorScheme: ColorScheme? = nil

    init() {
        updateColorScheme()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation { self.showSplash = false }
        }
    }

    func updateColorScheme() {
        switch themeMode {
        case "light": colorScheme = .light
        case "dark": colorScheme = .dark
        default: colorScheme = nil
        }
    }
}
