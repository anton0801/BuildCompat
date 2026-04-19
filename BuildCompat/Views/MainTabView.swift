import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            MaterialCheckerView()
                .tabItem {
                    Label("Checker", systemImage: "checkmark.seal.fill")
                }
                .tag(1)

            MaterialsLibraryView()
                .tabItem {
                    Label("Materials", systemImage: "square.3.layers.3d.down.right.fill")
                }
                .tag(2)

            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
                .tag(3)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(.bcAccent)
    }
}
