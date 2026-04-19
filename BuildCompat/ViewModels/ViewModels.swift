import SwiftUI
import Combine
import UserNotifications

// MARK: - Auth ViewModel
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: AppUser? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @AppStorage("savedUserData") private var savedUserData: Data = Data()

    init() {
        loadUser()
    }

    func loginWithDemo() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let demo = AppUser(id: "demo-001", name: "Demo User", email: "demo@buildcompat.app", isDemo: true)
            self.currentUser = demo
            self.isLoggedIn = true
            self.isLoading = false
            self.saveUser()
        }
    }

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = AppUser(name: email.components(separatedBy: "@").first?.capitalized ?? "User", email: email)
            self.currentUser = user
            self.isLoggedIn = true
            self.isLoading = false
            self.saveUser()
        }
    }

    func register(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = AppUser(name: name, email: email)
            self.currentUser = user
            self.isLoggedIn = true
            self.isLoading = false
            self.saveUser()
        }
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        savedUserData = Data()
    }

    func deleteAccount() {
        logout()
    }

    func updateName(_ name: String) {
        currentUser?.name = name
        saveUser()
    }

    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            savedUserData = encoded
        }
    }

    private func loadUser() {
        if let user = try? JSONDecoder().decode(AppUser.self, from: savedUserData) {
            currentUser = user
            isLoggedIn = true
        }
    }
}

// MARK: - Materials ViewModel
class MaterialsViewModel: ObservableObject {
    @Published var materials: [Material] = SampleData.materials
    @Published var searchText: String = ""
    @Published var selectedCategory: MaterialCategory? = nil

    var filteredMaterials: [Material] {
        var result = materials
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result
    }

    func materials(for category: MaterialCategory) -> [Material] {
        materials.filter { $0.category == category }
    }
}

// MARK: - Checker ViewModel
class CheckerViewModel: ObservableObject {
    @Published var materialA: Material? = nil
    @Published var materialB: Material? = nil
    @Published var result: CompatibilityResult? = nil
    @Published var isChecking: Bool = false
    @Published var showResult: Bool = false

    func checkCompatibility(historyVM: HistoryViewModel) {
        guard let a = materialA, let b = materialB else { return }
        isChecking = true
        result = nil
        showResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let res = SampleData.getCompatibility(materialA: a, materialB: b)
            self.result = res
            self.isChecking = false
            self.showResult = true
            historyVM.add(result: res)
        }
    }

    func reset() {
        materialA = nil
        materialB = nil
        result = nil
        showResult = false
    }
}

// MARK: - History ViewModel
class HistoryViewModel: ObservableObject {
    @Published var history: [CompatibilityResult] = []
    @AppStorage("historyData") private var historyData: Data = Data()

    init() { load() }

    func add(result: CompatibilityResult) {
        history.insert(result, at: 0)
        if history.count > 50 { history = Array(history.prefix(50)) }
        save()
    }

    func remove(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        save()
    }

    func clearAll() {
        history.removeAll()
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(history) { historyData = encoded }
    }
    private func load() {
        if let decoded = try? JSONDecoder().decode([CompatibilityResult].self, from: historyData) {
            history = decoded
        }
    }
}

// MARK: - Favorites ViewModel
class FavoritesViewModel: ObservableObject {
    @Published var favoriteMaterials: [Material] = []
    @AppStorage("favMaterialsData") private var favData: Data = Data()

    init() { load() }

    func toggle(material: Material) {
        if isFavorite(material) {
            favoriteMaterials.removeAll { $0.id == material.id }
        } else {
            favoriteMaterials.append(material)
        }
        save()
    }

    func isFavorite(_ material: Material) -> Bool {
        favoriteMaterials.contains { $0.id == material.id }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(favoriteMaterials) { favData = encoded }
    }
    private func load() {
        if let decoded = try? JSONDecoder().decode([Material].self, from: favData) {
            favoriteMaterials = decoded
        }
    }
}

// MARK: - Projects ViewModel
class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @AppStorage("projectsData") private var projectsData: Data = Data()

    init() { load() }

    func addProject(name: String, description: String) {
        let p = Project(name: name, description: description)
        projects.append(p)
        save()
    }

    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        save()
    }

    func addMaterial(_ material: Material, to projectID: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == projectID }) else { return }
        if !projects[idx].materials.contains(where: { $0.id == material.id }) {
            projects[idx].materials.append(material)
            save()
        }
    }

    func saveCombination(_ result: CompatibilityResult, to projectID: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[idx].savedCombinations.append(result)
        save()
    }

    func removeMaterial(_ material: Material, from projectID: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[idx].materials.removeAll { $0.id == material.id }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(projects) { projectsData = encoded }
    }
    private func load() {
        if let decoded = try? JSONDecoder().decode([Project].self, from: projectsData) {
            projects = decoded
        }
    }
}

// MARK: - Notifications ViewModel
class NotificationsViewModel: ObservableObject {
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("reminderTime") var reminderHour: Int = 9
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    init() { checkStatus() }

    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                self.checkStatus()
                completion(granted)
            }
        }
    }

    func scheduleReminder(hour: Int, minute: Int = 0) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard notificationsEnabled else { return }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Build Compat Reminder"
        content.body = "Don't forget to check material compatibility before starting your next project!"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        reminderHour = hour
    }

    func disableNotifications() {
        notificationsEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
