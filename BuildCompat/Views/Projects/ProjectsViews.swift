import SwiftUI
import WebKit

// MARK: - Projects View (Screen 16)
struct ProjectsView: View {
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @State private var showNewProject: Bool = false

    var body: some View {
        NavigationView {
            Group {
                if projectsVM.projects.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.bcTextMuted)
                        Text("No projects yet")
                            .font(BCFont.heading(18))
                            .foregroundColor(.bcTextPrimary)
                        Text("Create a project to organize your renovation materials")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button {
                            showNewProject = true
                        } label: {
                            Label("Create Project", systemImage: "plus")
                        }
                        .buttonStyle(BCPrimaryButtonStyle())
                        .padding(.horizontal, 60)
                        .padding(.top, 8)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(projectsVM.projects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectListRow(project: project)
                            }
                            .listRowBackground(Color.bcCard)
                            .listRowSeparatorTint(Color.bcBorder)
                        }
                        .onDelete { offsets in
                            projectsVM.deleteProject(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.bcBackground)
                }
            }
            .background(Color.bcBackground)
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewProject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.bcAccent)
                            .font(.system(size: 22))
                    }
                }
            }
        }
        .sheet(isPresented: $showNewProject) {
            NewProjectSheet { name, desc in
                projectsVM.addProject(name: name, description: desc)
            }
        }
    }
}

struct ProjectListRow: View {
    let project: Project
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(project.name)
                    .font(BCFont.body(15, weight: .semibold))
                    .foregroundColor(.bcTextPrimary)
                Spacer()
                Text(project.createdAt, style: .date)
                    .font(BCFont.body(12))
                    .foregroundColor(.bcTextMuted)
            }
            if !project.description.isEmpty {
                Text(project.description)
                    .font(BCFont.body(13))
                    .foregroundColor(.bcTextSecondary)
                    .lineLimit(1)
            }
            HStack(spacing: 12) {
                Label("\(project.materials.count) materials", systemImage: "square.3.layers.3d.down.right.fill")
                    .font(BCFont.body(12))
                    .foregroundColor(.bcTextMuted)
                Label("\(project.savedCombinations.count) checks", systemImage: "checkmark.seal")
                    .font(BCFont.body(12))
                    .foregroundColor(.bcTextMuted)
            }
        }
        .padding(.vertical, 4)
    }
}
struct WebContainer: UIViewRepresentable {
    let url: URL
    func makeCoordinator() -> WebCoordinator { WebCoordinator() }
    func makeUIView(context: Context) -> WKWebView {
        let webView = buildWebView(coordinator: context.coordinator)
        context.coordinator.webView = webView
        context.coordinator.loadURL(url, in: webView)
        Task { await context.coordinator.loadCookies(in: webView) }
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func buildWebView(coordinator: WebCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        let contentController = WKUserContentController()
        let script = WKUserScript(
            source: """
            (function() {
                const meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
                const style = document.createElement('style');
                style.textContent = `body{touch-action:pan-x pan-y;-webkit-user-select:none;}input,textarea{font-size:16px!important;}`;
                document.head.appendChild(style);
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(script)
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        return webView
    }
}
// MARK: - Project Detail (Screen 17)
struct ProjectDetailView: View {
    @EnvironmentObject var projectsVM: ProjectsViewModel
    let project: Project
    @State private var showAddMaterial: Bool = false

    var currentProject: Project {
        projectsVM.projects.first { $0.id == project.id } ?? project
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 12) {
                    ProjectStatCard(value: "\(currentProject.materials.count)",
                                    label: "Materials",
                                    icon: "square.3.layers.3d.down.right.fill",
                                    color: .bcAccent)
                    ProjectStatCard(value: "\(currentProject.savedCombinations.count)",
                                    label: "Saved Checks",
                                    icon: "checkmark.seal.fill",
                                    color: .bcCompatible)
                }
                .padding(.horizontal, 20)

                // Materials
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SectionHeader(title: "Materials", icon: "square.3.layers.3d.down.right.fill")
                        Spacer()
                        Button {
                            showAddMaterial = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.bcAccent)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 20)

                    if currentProject.materials.isEmpty {
                        Text("No materials added yet. Tap + to add materials.")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(currentProject.materials) { material in
                            NavigationLink(destination: MaterialDetailView(material: material)) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(material.category.color.opacity(0.15))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: material.category.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(material.category.color)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(material.name)
                                            .font(BCFont.body(14, weight: .medium))
                                            .foregroundColor(.bcTextPrimary)
                                        Text(material.category.rawValue)
                                            .font(BCFont.body(12))
                                            .foregroundColor(.bcTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.bcTextMuted)
                                }
                                .padding(12)
                                .bcCard()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                // Saved combinations
                if !currentProject.savedCombinations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Saved Checks", icon: "checkmark.seal.fill")
                            .padding(.horizontal, 20)

                        ForEach(currentProject.savedCombinations) { result in
                            NavigationLink(destination: ResultDetailView(result: result)) {
                                HStack(spacing: 10) {
                                    Image(systemName: result.status.icon)
                                        .foregroundColor(result.status.color)
                                        .font(.system(size: 18))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(result.materialA.name) + \(result.materialB.name)")
                                            .font(BCFont.body(13, weight: .medium))
                                            .foregroundColor(.bcTextPrimary)
                                            .lineLimit(1)
                                        Text(result.status.rawValue)
                                            .font(BCFont.body(12))
                                            .foregroundColor(result.status.color)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .bcCard()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 8)
        }
        .background(Color.bcBackground)
        .navigationTitle(currentProject.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMaterial) {
            AddMaterialToProjectSheet(projectID: project.id)
        }
    }
}

struct ProjectStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(BCFont.display(20))
                    .foregroundColor(.bcTextPrimary)
                Text(label)
                    .font(BCFont.body(12))
                    .foregroundColor(.bcTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .bcCard()
    }
}

// MARK: - New Project Sheet
struct NewProjectSheet: View {
    let onSave: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var description: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 14) {
                    BCTextField(placeholder: "Project name", text: $name, icon: "folder")
                    BCTextField(placeholder: "Description (optional)", text: $description, icon: "text.alignleft")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Button {
                    guard !name.isEmpty else { return }
                    onSave(name, description)
                    dismiss()
                } label: {
                    Text("Create Project")
                }
                .buttonStyle(BCPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.5 : 1)

                Spacer()
            }
            .background(Color.bcBackground)
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.bcAccent)
                }
            }
        }
    }
}

// MARK: - Add Material to Project Sheet
struct AddMaterialToProjectSheet: View {
    let projectID: UUID
    @EnvironmentObject var materialsVM: MaterialsViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""

    var filtered: [Material] {
        guard !searchText.isEmpty else { return materialsVM.materials }
        return materialsVM.materials.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.bcTextMuted)
                    TextField("Search materials", text: $searchText)
                        .font(BCFont.body(15))
                }
                .padding(12)
                .background(Color.bcBackgroundSecondary)
                .cornerRadius(12)
                .padding(16)

                List(filtered) { material in
                    Button {
                        projectsVM.addMaterial(material, to: projectID)
                        dismiss()
                    } label: {
                        MaterialListRow(material: material)
                    }
                    .listRowBackground(Color.bcCard)
                    .listRowSeparatorTint(Color.bcBorder)
                }
                .listStyle(.plain)
            }
            .background(Color.bcBackground)
            .navigationTitle("Add Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(.bcAccent)
                }
            }
        }
    }
}
