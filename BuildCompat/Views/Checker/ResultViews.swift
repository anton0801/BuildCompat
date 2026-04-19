import SwiftUI

// MARK: - Result Detail View (Screens 10, 11, 12)
struct ResultDetailView: View {
    let result: CompatibilityResult
    @State private var expandedFix: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(result.status.color.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: result.status.icon)
                            .font(.system(size: 36))
                            .foregroundColor(result.status.color)
                    }
                    .bcStatusGlow(result.status.color)

                    Text(result.status.rawValue)
                        .font(BCFont.display(28))
                        .foregroundColor(result.status.color)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(result.status.color.opacity(0.06))
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // Materials
                VStack(spacing: 0) {
                    Text("Materials Checked")
                        .font(BCFont.body(12, weight: .semibold))
                        .foregroundColor(.bcTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                    HStack(spacing: 12) {
                        MaterialBadge(material: result.materialA)
                        Image(systemName: "arrow.left.and.right")
                            .foregroundColor(.bcTextMuted)
                        MaterialBadge(material: result.materialB)
                    }
                }
                .padding(16)
                .bcCard()
                .padding(.horizontal, 20)

                // Explanation
                VStack(alignment: .leading, spacing: 10) {
                    Label("Why This Result", systemImage: "info.circle.fill")
                        .font(BCFont.heading(15))
                        .foregroundColor(.bcTextPrimary)

                    Text(result.explanation)
                        .font(BCFont.body(15))
                        .foregroundColor(.bcTextPrimary)
                        .lineSpacing(4)
                }
                .padding(16)
                .bcCard()
                .padding(.horizontal, 20)

                // Suggested Fix
                if !result.suggestedFix.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What To Do", systemImage: "wrench.and.screwdriver.fill")
                            .font(BCFont.heading(15))
                            .foregroundColor(.bcTextPrimary)

                        VStack(spacing: 10) {
                            ForEach(Array(result.suggestedFix.enumerated()), id: \.offset) { i, fix in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.bcAccent)
                                            .frame(width: 24, height: 24)
                                        Text("\(i+1)")
                                            .font(BCFont.mono(12))
                                            .foregroundColor(.white)
                                    }
                                    Text(fix)
                                        .font(BCFont.body(14))
                                        .foregroundColor(.bcTextPrimary)
                                        .lineSpacing(2)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.bcBackgroundSecondary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                    .bcCard()
                    .padding(.horizontal, 20)
                }

                // Date
                Text("Checked \(result.date, style: .relative) ago")
                    .font(BCFont.body(12))
                    .foregroundColor(.bcTextMuted)
                    .padding(.bottom, 20)
            }
            .padding(.top, 8)
        }
        .background(Color.bcBackground)
        .navigationTitle("Compatibility Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MaterialBadge: View {
    let material: Material
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(material.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: material.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(material.category.color)
            }
            Text(material.name)
                .font(BCFont.body(12, weight: .medium))
                .foregroundColor(.bcTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Material Detail View (Screen 9)
struct MaterialDetailView: View {
    let material: Material
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @EnvironmentObject var materialsVM: MaterialsViewModel
    @State private var isFav: Bool = false
    @State private var showChecker: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(material.category.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: material.category.icon)
                            .font(.system(size: 36))
                            .foregroundColor(material.category.color)
                    }
                    Text(material.name)
                        .font(BCFont.display(24))
                        .foregroundColor(.bcTextPrimary)
                    Text(material.category.rawValue)
                        .font(BCFont.body(14))
                        .foregroundColor(material.category.color)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(material.category.color.opacity(0.12))
                        .cornerRadius(20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Label("About", systemImage: "doc.text.fill")
                        .font(BCFont.heading(15))
                        .foregroundColor(.bcTextPrimary)
                    Text(material.description)
                        .font(BCFont.body(14))
                        .foregroundColor(.bcTextSecondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .bcCard()
                .padding(.horizontal, 20)

                // Properties
                if !material.properties.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Properties", systemImage: "list.bullet.rectangle")
                            .font(BCFont.heading(15))
                            .foregroundColor(.bcTextPrimary)
                        ForEach(Array(material.properties.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                    .font(BCFont.body(14))
                                    .foregroundColor(.bcTextSecondary)
                                Spacer()
                                Text(value)
                                    .font(BCFont.body(14, weight: .medium))
                                    .foregroundColor(.bcTextPrimary)
                            }
                            .padding(.vertical, 6)
                            if key != material.properties.keys.sorted().last {
                                Divider().background(Color.bcBorder)
                            }
                        }
                    }
                    .padding(16)
                    .bcCard()
                    .padding(.horizontal, 20)
                }

                // Tags
                if !material.tags.isEmpty {
                    FlowTagView(tags: material.tags)
                        .padding(.horizontal, 20)
                }

                // Actions
                VStack(spacing: 10) {
                    NavigationLink(destination: MaterialCheckerView()) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Check Compatibility")
                        }
                        .font(BCFont.body(15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.bcAccent)
                        .cornerRadius(12)
                    }

                    Button {
                        isFav.toggle()
                        favoritesVM.toggle(material: material)
                    } label: {
                        HStack {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                            Text(isFav ? "Saved to Favorites" : "Add to Favorites")
                        }
                    }
                    .buttonStyle(BCSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.bcBackground)
        .navigationTitle(material.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isFav = favoritesVM.isFavorite(material) }
    }
}

struct FlowTagView: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Tags", systemImage: "tag.fill")
                .font(BCFont.heading(14))
                .foregroundColor(.bcTextSecondary)
                .padding(.bottom, 2)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(BCFont.body(12))
                        .foregroundColor(.bcAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.bcAccent.opacity(0.08))
                        .cornerRadius(8)
                }
            }
        }
    }
}
