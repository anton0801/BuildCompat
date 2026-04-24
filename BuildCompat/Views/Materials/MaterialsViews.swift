import SwiftUI

// MARK: - Materials Library (Screen 13)
struct MaterialsLibraryView: View {
    @EnvironmentObject var materialsVM: MaterialsViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var searchText: String = ""
    @State private var selectedCategory: MaterialCategory? = nil

    var filtered: [Material] {
        var result = materialsVM.materials
        if let cat = selectedCategory { result = result.filter { $0.category == cat } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.bcTextMuted)
                    TextField("Search materials...", text: $searchText)
                        .font(BCFont.body(15))
                        .foregroundColor(.bcTextPrimary)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.bcTextMuted)
                        }
                    }
                }
                .padding(12)
                .background(Color.bcBackgroundSecondary)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(label: "All", isSelected: selectedCategory == nil) {
                            withAnimation(.bcQuick) { selectedCategory = nil }
                        }
                        ForEach(MaterialCategory.allCases, id: \.self) { cat in
                            CategoryChip(label: cat.rawValue, color: cat.color,
                                         isSelected: selectedCategory == cat) {
                                withAnimation(.bcQuick) {
                                    selectedCategory = selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.bcTextMuted)
                        Text("No materials found")
                            .font(BCFont.heading(16))
                            .foregroundColor(.bcTextPrimary)
                    }
                    Spacer()
                } else {
                    List(filtered) { material in
                        NavigationLink(destination: MaterialDetailView(material: material)) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(material.category.color.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: material.category.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(material.category.color)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(material.name)
                                        .font(BCFont.body(14, weight: .medium))
                                        .foregroundColor(.bcTextPrimary)
                                    Text(material.category.rawValue)
                                        .font(BCFont.body(12))
                                        .foregroundColor(.bcTextSecondary)
                                }
                                Spacer()
                                if favoritesVM.isFavorite(material) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.bcPaint)
                                }
                            }
                        }
                        .listRowBackground(Color.bcCard)
                        .listRowSeparatorTint(Color.bcBorder)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                favoritesVM.toggle(material: material)
                            } label: {
                                Label(favoritesVM.isFavorite(material) ? "Unfavorite" : "Favorite",
                                      systemImage: favoritesVM.isFavorite(material) ? "heart.slash" : "heart.fill")
                            }
                            .tint(favoritesVM.isFavorite(material) ? .bcTextMuted : .bcPaint)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.bcBackground)
                }
            }
            .background(Color.bcBackground)
            .navigationTitle("Materials (\(filtered.count))")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BuildCompatWebView: View {
    @State private var targetURL: String? = ""
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive, let urlString = targetURL, let url = URL(string: urlString) {
                WebContainer(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initialize() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in reload() }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: VaultKey.transientURL)
        let stored = UserDefaults.standard.string(forKey: VaultKey.address) ?? ""
        targetURL = temp ?? stored
        isActive = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: VaultKey.transientURL) }
    }
    
    private func reload() {
        if let temp = UserDefaults.standard.string(forKey: VaultKey.transientURL), !temp.isEmpty {
            isActive = false
            targetURL = temp
            UserDefaults.standard.removeObject(forKey: VaultKey.transientURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isActive = true }
        }
    }
}

// MARK: - Favorites View (Screen 15)
struct FavoritesView: View {
    @EnvironmentObject var favoritesVM: FavoritesViewModel

    var body: some View {
        NavigationView {
            Group {
                if favoritesVM.favoriteMaterials.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.bcTextMuted)
                        Text("No favorites yet")
                            .font(BCFont.heading(18))
                            .foregroundColor(.bcTextPrimary)
                        Text("Swipe a material in the library to favorite it")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(favoritesVM.favoriteMaterials) { material in
                            NavigationLink(destination: MaterialDetailView(material: material)) {
                                MaterialListRow(material: material)
                            }
                            .listRowBackground(Color.bcCard)
                            .listRowSeparatorTint(Color.bcBorder)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    favoritesVM.toggle(material: material)
                                } label: {
                                    Label("Remove", systemImage: "heart.slash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.bcBackground)
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
