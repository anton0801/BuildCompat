import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var materialsVM: MaterialsViewModel
    @State private var checkerShowing: Bool = false
    @State private var selectedMaterial: Material? = nil

    let tips: [(String, String, Color)] = [
        ("Always prime porous surfaces", "circle.hexagonpath.fill", Color.bcAccent),
        ("Use C2 adhesive for large tiles", "square.grid.2x2.fill", Color.bcTile),
        ("Check moisture before tiling", "drop.fill", Color.bcCompatible),
        ("Leave expansion gaps for wood floors", "tree.fill", Color.bcWood)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello, \(authVM.currentUser?.name.components(separatedBy: " ").first ?? "there")! 👋")
                                .font(BCFont.display(24))
                                .foregroundColor(.bcTextPrimary)
                            Text("Check material compatibility")
                                .font(BCFont.body(14))
                                .foregroundColor(.bcTextSecondary)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Circle()
                                .fill(Color.bcAccent.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(authVM.currentUser?.name.prefix(1) ?? "U"))
                                        .font(BCFont.heading(18))
                                        .foregroundColor(.bcAccent)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Quick Check card
                    NavigationLink(destination: MaterialCheckerView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.bcAccent.opacity(0.15))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.bcAccent)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Material Checker")
                                    .font(BCFont.heading(16))
                                    .foregroundColor(.bcTextPrimary)
                                Text("Check if 2 materials are compatible")
                                    .font(BCFont.body(13))
                                    .foregroundColor(.bcTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.bcAccent)
                        }
                        .padding(16)
                        .bcCard()
                    }
                    .padding(.horizontal, 20)

                    // Stats row
                    HStack(spacing: 12) {
                        DashboardStatCard(
                            value: "\(historyVM.history.count)",
                            label: "Checks Done",
                            icon: "checkmark.circle.fill",
                            color: .bcCompatible
                        )
                        DashboardStatCard(
                            value: "\(historyVM.history.filter { $0.status == .incompatible }.count)",
                            label: "Conflicts Found",
                            icon: "xmark.circle.fill",
                            color: .bcIncompatible
                        )
                        DashboardStatCard(
                            value: "\(historyVM.history.filter { $0.status == .warning }.count)",
                            label: "Warnings",
                            icon: "exclamationmark.triangle.fill",
                            color: .bcWarning
                        )
                    }
                    .padding(.horizontal, 20)

                    // Recent checks
                    if !historyVM.history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Recent Checks", icon: "clock.fill")
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(historyVM.history.prefix(5)) { result in
                                        NavigationLink(destination: ResultDetailView(result: result)) {
                                            RecentCheckCard(result: result)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Popular materials
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Popular Materials", icon: "star.fill")
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(materialsVM.materials.prefix(6)) { material in
                                    NavigationLink(destination: MaterialDetailView(material: material)) {
                                        MaterialChipView(material: material)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Quick Tips", icon: "lightbulb.fill")
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            ForEach(tips, id: \.0) { tip in
                                TipRow(text: tip.0, icon: tip.1, color: tip.2)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(Color.bcBackground)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OfflineView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("p")
                    .resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                    .blur(radius: 21)
                    .opacity(0.5)
                
                Image("pp")
                    .resizable()
                    .frame(width: 250, height: 220)
            }
        }
        .ignoresSafeArea()
    }
}

struct DashboardStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(BCFont.display(22))
                .foregroundColor(.bcTextPrimary)
            Text(label)
                .font(BCFont.body(11))
                .foregroundColor(.bcTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .bcCard()
    }
}

struct RecentCheckCard: View {
    let result: CompatibilityResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.status.icon)
                    .foregroundColor(result.status.color)
                    .font(.system(size: 16))
                Spacer()
                Text(result.date, style: .time)
                    .font(BCFont.body(11))
                    .foregroundColor(.bcTextMuted)
            }
            Text(result.materialA.name)
                .font(BCFont.body(13, weight: .medium))
                .foregroundColor(.bcTextPrimary)
                .lineLimit(1)
            Text("+ \(result.materialB.name)")
                .font(BCFont.body(12))
                .foregroundColor(.bcTextSecondary)
                .lineLimit(1)
        }
        .frame(width: 160)
        .padding(14)
        .bcCard()
    }
}

struct MaterialChipView: View {
    let material: Material

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(material.category.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: material.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(material.category.color)
            }
            Text(material.name)
                .font(BCFont.body(12, weight: .medium))
                .foregroundColor(.bcTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
        .padding(12)
        .bcCard()
    }
}

struct TipRow: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(Circle())
            Text(text)
                .font(BCFont.body(14))
                .foregroundColor(.bcTextPrimary)
            Spacer()
        }
        .padding(12)
        .bcCard()
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.bcAccent)
            Text(title)
                .font(BCFont.heading(16))
                .foregroundColor(.bcTextPrimary)
        }
    }
}
