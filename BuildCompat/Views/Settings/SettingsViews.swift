import SwiftUI

// MARK: - More View (Hub for extra tabs)
struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    MoreRow(title: "Favorites", icon: "heart.fill", color: .bcPaint, destination: AnyView(FavoritesView()))
                    MoreRow(title: "History", icon: "clock.fill", color: .bcAccent, destination: AnyView(HistoryView()))
                    MoreRow(title: "Guides", icon: "book.fill", color: .bcCompatible, destination: AnyView(GuidesView()))
                }
                .listRowBackground(Color.bcCard)
                .listRowSeparatorTint(Color.bcBorder)

                Section {
                    MoreRow(title: "Profile", icon: "person.fill", color: .bcAccentSoft, destination: AnyView(ProfileView()))
                    MoreRow(title: "Notifications", icon: "bell.fill", color: .bcWarning, destination: AnyView(NotificationsView()))
                    MoreRow(title: "Settings", icon: "gearshape.fill", color: .bcTextSecondary, destination: AnyView(SettingsView()))
                }
                .listRowBackground(Color.bcCard)
                .listRowSeparatorTint(Color.bcBorder)
            }
            .listStyle(.insetGrouped)
            .background(Color.bcBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MoreRow: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(BCFont.body(15))
                    .foregroundColor(.bcTextPrimary)
            }
        }
    }
}

// MARK: - Profile View (Screen 26)
struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isEditing: Bool = false
    @State private var editName: String = ""
    @State private var showSavedMessage: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.bcAccent, Color.bcAccentSoft], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        Text(String(authVM.currentUser?.name.prefix(1) ?? "U").uppercased())
                            .font(BCFont.display(32))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.bcAccent.opacity(0.3), radius: 12, y: 4)

                    if let user = authVM.currentUser {
                        if isEditing {
                            HStack {
                                TextField("Name", text: $editName)
                                    .font(BCFont.display(20))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.bcTextPrimary)
                            }
                            .padding(.horizontal, 60)
                        } else {
                            Text(user.name)
                                .font(BCFont.display(20))
                                .foregroundColor(.bcTextPrimary)
                        }
                        Text(user.email)
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                        if user.isDemo {
                            Text("Demo Account")
                                .font(BCFont.body(12, weight: .medium))
                                .foregroundColor(.bcAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.bcAccent.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }

                    if showSavedMessage {
                        Text("✓ Name updated")
                            .font(BCFont.body(13))
                            .foregroundColor(.bcCompatible)
                            .transition(.opacity)
                    }

                    HStack(spacing: 10) {
                        if isEditing {
                            Button {
                                isEditing = false
                            } label: { Text("Cancel") }
                            .buttonStyle(BCSecondaryButtonStyle())
                            .frame(width: 100)

                            Button {
                                authVM.updateName(editName)
                                isEditing = false
                                showSavedMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { showSavedMessage = false }
                                }
                            } label: { Text("Save") }
                            .buttonStyle(BCPrimaryButtonStyle())
                            .frame(width: 100)
                        } else {
                            Button {
                                editName = authVM.currentUser?.name ?? ""
                                isEditing = true
                            } label: {
                                Label("Edit Name", systemImage: "pencil")
                                    .font(BCFont.body(14))
                                    .foregroundColor(.bcAccent)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.bcAccent.opacity(0.08))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.top, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color.bcBackground)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BuildCompatConsentView: View {
    let viewModel: BuildCompatViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("b")
                    .resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea().opacity(0.9)
                
                if geometry.size.width < geometry.size.height {
                    VStack(spacing: 12) {
                        Spacer()
                        titleText
                            .multilineTextAlignment(.center)
                        subtitleText
                            .multilineTextAlignment(.center)
                        actionButtons
                    }
                    .padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) {
                            Spacer()
                            titleText
                            subtitleText
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            actionButtons
                        }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    private var titleText: some View {
        Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
    }
    
    private var subtitleText: some View {
        Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 12)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.acceptConsent()
            } label: {
                Image("bb")
                    .resizable()
                    .frame(width: 300, height: 55)
            }
            
            Button {
                viewModel.declineConsent()
            } label: {
                Image("bbb")
                    .resizable()
                    .frame(width: 275, height: 38)
            }
        }
        .padding(.horizontal, 12)
    }
}


// MARK: - Settings View (Screen 27)
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @State private var showDeleteConfirm: Bool = false
    @State private var showLogoutConfirm: Bool = false
    @State private var showClearDataConfirm: Bool = false
    @State private var showSavedBanner: Bool = false

    var body: some View {
        List {
            // Appearance
            Section(header: Text("Appearance").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme")
                        .font(BCFont.body(14))
                        .foregroundColor(.bcTextPrimary)
                    Picker("Theme", selection: $appState.themeMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.bcCard)

            // Units & Language
            Section(header: Text("Preferences").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                HStack {
                    Label("Units", systemImage: "ruler")
                        .foregroundColor(.bcTextPrimary)
                    Spacer()
                    Picker("Units", selection: $appState.selectedUnits) {
                        Text("Metric").tag("Metric")
                        Text("Imperial").tag("Imperial")
                    }
                    .pickerStyle(.menu)
                    .tint(.bcAccent)
                }

                HStack {
                    Label("Language", systemImage: "globe")
                        .foregroundColor(.bcTextPrimary)
                    Spacer()
                    Picker("Language", selection: $appState.selectedLanguage) {
                        Text("English").tag("English")
                        Text("Español").tag("Español")
                        Text("Deutsch").tag("Deutsch")
                        Text("Français").tag("Français")
                    }
                    .pickerStyle(.menu)
                    .tint(.bcAccent)
                }
            }
            .listRowBackground(Color.bcCard)
            .listRowSeparatorTint(Color.bcBorder)

            // Notifications
            Section(header: Text("Notifications").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                NavigationLink(destination: NotificationsView()) {
                    Label("Notification Settings", systemImage: "bell.fill")
                        .foregroundColor(.bcTextPrimary)
                }
            }
            .listRowBackground(Color.bcCard)

            // Data
            Section(header: Text("Data").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                Button {
                    showClearDataConfirm = true
                } label: {
                    Label("Clear All History", systemImage: "trash")
                        .foregroundColor(.bcIncompatible)
                }
            }
            .listRowBackground(Color.bcCard)

            // About
            Section(header: Text("About").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                HStack {
                    Label("Version", systemImage: "info.circle")
                        .foregroundColor(.bcTextPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(BCFont.body(14))
                        .foregroundColor(.bcTextMuted)
                }
            }
            .listRowBackground(Color.bcCard)

            // Account
            Section {
                Button {
                    showLogoutConfirm = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.bcWarning)
                        Spacer()
                    }
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                            .foregroundColor(.bcIncompatible)
                        Spacer()
                    }
                }
            }
            .listRowBackground(Color.bcCard)
        }
        .listStyle(.insetGrouped)
        .background(Color.bcBackground)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .overlay(
            Group {
                if showSavedBanner {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.bcCompatible)
                            Text("Settings saved").font(BCFont.body(14)).foregroundColor(.bcTextPrimary)
                        }
                        .padding(12)
                        .background(Color.bcCard)
                        .cornerRadius(12)
                        .bcCardShadow()
                        .padding(.top, 8)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        )
        .confirmationDialog("Log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) { authVM.logout() }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete account? This action cannot be undone.",
                            isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) { authVM.deleteAccount() }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Clear all history?", isPresented: $showClearDataConfirm, titleVisibility: .visible) {
            Button("Clear History", role: .destructive) {
                historyVM.clearAll()
                withAnimation { showSavedBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showSavedBanner = false }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: appState.themeMode) { _ in
            withAnimation { showSavedBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showSavedBanner = false }
            }
        }
    }
}

// MARK: - Notifications View (Screen 24)
struct NotificationsView: View {
    @StateObject private var notifVM = NotificationsViewModel()
    @State private var reminderHour: Double = 9
    @State private var showPermissionAlert: Bool = false

    var body: some View {
        List {
            Section(header: Text("Push Notifications").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                Toggle(isOn: Binding(
                    get: { notifVM.notificationsEnabled },
                    set: { enabled in
                        if enabled {
                            notifVM.requestPermission { granted in
                                if !granted { showPermissionAlert = true }
                            }
                        } else {
                            notifVM.disableNotifications()
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Notifications")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextPrimary)
                        Text("Get daily reminders to check materials")
                            .font(BCFont.body(12))
                            .foregroundColor(.bcTextSecondary)
                    }
                }
                .tint(.bcAccent)
            }
            .listRowBackground(Color.bcCard)

            if notifVM.notificationsEnabled {
                Section(header: Text("Daily Reminder Time").font(BCFont.body(12, weight: .semibold)).foregroundColor(.bcTextMuted)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Remind me at \(Int(reminderHour)):00")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextPrimary)
                        Slider(value: $reminderHour, in: 6...22, step: 1)
                            .tint(.bcAccent)
                            .onChange(of: reminderHour) { val in
                                notifVM.scheduleReminder(hour: Int(val))
                            }
                        HStack {
                            Text("6:00 AM")
                            Spacer()
                            Text("10:00 PM")
                        }
                        .font(BCFont.body(11))
                        .foregroundColor(.bcTextMuted)
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.bcCard)
            }

            Section {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(notifVM.notificationsEnabled ? Color.bcCompatible.opacity(0.1) : Color.bcBorder)
                            .frame(width: 36, height: 36)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 15))
                            .foregroundColor(notifVM.notificationsEnabled ? .bcCompatible : .bcTextMuted)
                    }
                    Text(notifVM.notificationsEnabled ? "Notifications are active" : "Notifications are off")
                        .font(BCFont.body(14))
                        .foregroundColor(notifVM.notificationsEnabled ? .bcCompatible : .bcTextMuted)
                }
            }
            .listRowBackground(Color.bcCard)
        }
        .listStyle(.insetGrouped)
        .background(Color.bcBackground)
        .scrollContentBackground(.hidden)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            reminderHour = Double(notifVM.reminderHour)
            notifVM.checkStatus()
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }
}
