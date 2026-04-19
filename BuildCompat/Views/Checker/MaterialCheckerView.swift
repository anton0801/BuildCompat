import SwiftUI

struct MaterialCheckerView: View {
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @StateObject private var checkerVM = CheckerViewModel()
    @State private var selectingSlot: Int = 0 // 1 = A, 2 = B
    @State private var showMaterialPicker: Bool = false
    @State private var showSaveToProject: Bool = false
    @State private var showResultDetail: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Material slots
                    VStack(spacing: 16) {
                        // Material A
                        MaterialSlotView(
                            label: "Material A",
                            material: checkerVM.materialA,
                            slot: 1
                        ) {
                            selectingSlot = 1
                            showMaterialPicker = true
                        }

                        // VS divider
                        HStack {
                            Rectangle().fill(Color.bcBorder).frame(height: 1)
                            ZStack {
                                Circle()
                                    .fill(Color.bcAccent.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Text("VS")
                                    .font(BCFont.mono(12))
                                    .foregroundColor(.bcAccent)
                            }
                            Rectangle().fill(Color.bcBorder).frame(height: 1)
                        }

                        // Material B
                        MaterialSlotView(
                            label: "Material B",
                            material: checkerVM.materialB,
                            slot: 2
                        ) {
                            selectingSlot = 2
                            showMaterialPicker = true
                        }
                    }
                    .padding(20)
                    .bcCard()
                    .padding(.horizontal, 20)

                    // Check button
                    Button {
                        checkerVM.checkCompatibility(historyVM: historyVM)
                    } label: {
                        HStack(spacing: 10) {
                            if checkerVM.isChecking {
                                ProgressView().tint(.white).scaleEffect(0.85)
                                Text("Checking...")
                            } else {
                                Image(systemName: "bolt.fill")
                                Text("Check Compatibility")
                            }
                        }
                    }
                    .buttonStyle(BCPrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .disabled(checkerVM.materialA == nil || checkerVM.materialB == nil || checkerVM.isChecking)
                    .opacity(checkerVM.materialA == nil || checkerVM.materialB == nil ? 0.5 : 1.0)

                    // Result
                    if checkerVM.showResult, let result = checkerVM.result {
                        CompatibilityResultCard(result: result)
                            .padding(.horizontal, 20)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                            .animation(.bcSpring, value: checkerVM.showResult)

                        // Action buttons
                        VStack(spacing: 10) {
                            NavigationLink(destination: ResultDetailView(result: result)) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                    Text("Full Explanation")
                                }
                                .font(BCFont.body(15, weight: .medium))
                                .foregroundColor(.bcAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.bcAccent.opacity(0.08))
                                .cornerRadius(12)
                            }

                            Button {
                                showSaveToProject = true
                            } label: {
                                HStack {
                                    Image(systemName: "folder.badge.plus")
                                    Text("Save to Project")
                                }
                            }
                            .buttonStyle(BCSecondaryButtonStyle())

                            Button {
                                checkerVM.reset()
                            } label: {
                                Text("Check Another")
                            }
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
            }
            .background(Color.bcBackground)
            .navigationTitle("Material Checker")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showMaterialPicker) {
            MaterialPickerSheet(slot: selectingSlot, checkerVM: checkerVM)
        }
        .sheet(isPresented: $showSaveToProject) {
            if let result = checkerVM.result {
                SaveToProjectSheet(result: result)
            }
        }
    }
}

// MARK: - Material Slot
struct MaterialSlotView: View {
    let label: String
    let material: Material?
    let slot: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(material != nil ? material!.category.color.opacity(0.15) : Color.bcBackgroundSecondary)
                        .frame(width: 50, height: 50)
                    if let mat = material {
                        Image(systemName: mat.category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(mat.category.color)
                    } else {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.bcTextMuted)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(BCFont.body(12))
                        .foregroundColor(.bcTextMuted)
                    if let mat = material {
                        Text(mat.name)
                            .font(BCFont.heading(15))
                            .foregroundColor(.bcTextPrimary)
                        Text(mat.category.rawValue)
                            .font(BCFont.body(12))
                            .foregroundColor(.bcTextSecondary)
                    } else {
                        Text("Tap to select material")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.bcTextMuted)
            }
            .padding(14)
            .background(Color.bcBackgroundSecondary)
            .cornerRadius(12)
        }
    }
}

// MARK: - Compatibility Result Card
struct CompatibilityResultCard: View {
    let result: CompatibilityResult
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // Status badge
            HStack(spacing: 10) {
                Image(systemName: result.status.icon)
                    .font(.system(size: 24))
                    .foregroundColor(result.status.color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.status.rawValue)
                        .font(BCFont.display(20))
                        .foregroundColor(result.status.color)
                    Text("\(result.materialA.name) + \(result.materialB.name)")
                        .font(BCFont.body(13))
                        .foregroundColor(.bcTextSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(result.status.emoji)
                    .font(.system(size: 32))
            }

            Divider().background(Color.bcBorder)

            // Summary
            Text(result.explanation)
                .font(BCFont.body(14))
                .foregroundColor(.bcTextPrimary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Fix suggestions if any
            if !result.suggestedFix.isEmpty && result.status != .compatible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended Actions:")
                        .font(BCFont.body(12, weight: .semibold))
                        .foregroundColor(.bcTextSecondary)
                    ForEach(result.suggestedFix.prefix(2), id: \.self) { fix in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.bcAccent)
                                .padding(.top, 2)
                            Text(fix)
                                .font(BCFont.body(13))
                                .foregroundColor(.bcTextPrimary)
                        }
                    }
                }
                .padding(12)
                .background(Color.bcAccent.opacity(0.06))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(result.status.color.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(result.status.color.opacity(0.3), lineWidth: 1.5)
        )
        .bcStatusGlow(result.status.color)
        .scaleEffect(appeared ? 1 : 0.95)
        .onAppear {
            withAnimation(.bcSpring) { appeared = true }
        }
    }
}

// MARK: - Material Picker Sheet
struct MaterialPickerSheet: View {
    let slot: Int
    @ObservedObject var checkerVM: CheckerViewModel
    @EnvironmentObject var materialsVM: MaterialsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var selectedCategory: MaterialCategory? = nil

    var filtered: [Material] {
        var result = materialsVM.materials
        if let cat = selectedCategory { result = result.filter { $0.category == cat } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.bcTextMuted)
                    TextField("Search materials", text: $searchText)
                        .font(BCFont.body(15))
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
                            selectedCategory = nil
                        }
                        ForEach(MaterialCategory.allCases, id: \.self) { cat in
                            CategoryChip(label: cat.rawValue, color: cat.color,
                                         isSelected: selectedCategory == cat) {
                                selectedCategory = selectedCategory == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                // List
                List(filtered) { material in
                    Button {
                        if slot == 1 { checkerVM.materialA = material }
                        else { checkerVM.materialB = material }
                        dismiss()
                    } label: {
                        MaterialListRow(material: material)
                    }
                    .listRowBackground(Color.bcCard)
                    .listRowSeparatorTint(Color.bcBorder)
                }
                .listStyle(.plain)
                .background(Color.bcBackground)
            }
            .background(Color.bcBackground)
            .navigationTitle("Select Material \(slot == 1 ? "A" : "B")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.bcAccent)
                }
            }
        }
    }
}

struct CategoryChip: View {
    let label: String
    var color: Color = .bcAccent
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(BCFont.body(13, weight: .medium))
                .foregroundColor(isSelected ? .white : .bcTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? color : Color.bcButtonSecondary)
                .cornerRadius(20)
        }
        .animation(.bcQuick, value: isSelected)
    }
}

struct MaterialListRow: View {
    let material: Material
    var body: some View {
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
        }
    }
}

// MARK: - Save to Project Sheet
struct SaveToProjectSheet: View {
    let result: CompatibilityResult
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showNewProject: Bool = false
    @State private var newProjectName: String = ""
    @State private var savedToProjectID: UUID? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if projectsVM.projects.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(.bcTextMuted)
                        Text("No projects yet")
                            .font(BCFont.heading(18))
                            .foregroundColor(.bcTextPrimary)
                        Text("Create a project to save this combination")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(24)
                } else {
                    List(projectsVM.projects) { project in
                        Button {
                            projectsVM.saveCombination(result, to: project.id)
                            savedToProjectID = project.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.bcAccent)
                                Text(project.name)
                                    .font(BCFont.body(15))
                                    .foregroundColor(.bcTextPrimary)
                                Spacer()
                                if savedToProjectID == project.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.bcCompatible)
                                }
                            }
                        }
                        .listRowBackground(Color.bcCard)
                    }
                    .listStyle(.plain)
                }

                Button {
                    showNewProject = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Project")
                    }
                }
                .buttonStyle(BCPrimaryButtonStyle())
                .padding(16)
            }
            .background(Color.bcBackground)
            .navigationTitle("Save to Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(.bcAccent)
                }
            }
            .sheet(isPresented: $showNewProject) {
                NewProjectSheet { name, desc in
                    projectsVM.addProject(name: name, description: desc)
                    if let p = projectsVM.projects.last {
                        projectsVM.saveCombination(result, to: p.id)
                    }
                    dismiss()
                }
            }
        }
    }
}
