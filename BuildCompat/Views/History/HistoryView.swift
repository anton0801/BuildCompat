import SwiftUI

// MARK: - History View (Screen 19, 25)
struct HistoryView: View {
    @EnvironmentObject var historyVM: HistoryViewModel
    @State private var showClearConfirm: Bool = false
    @State private var filterStatus: CompatibilityStatus? = nil

    var filtered: [CompatibilityResult] {
        guard let f = filterStatus else { return historyVM.history }
        return historyVM.history.filter { $0.status == f }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(label: "All", isSelected: filterStatus == nil) {
                            withAnimation(.bcQuick) { filterStatus = nil }
                        }
                        CategoryChip(label: "✅ Compatible", color: .bcCompatible,
                                     isSelected: filterStatus == .compatible) {
                            withAnimation(.bcQuick) {
                                filterStatus = filterStatus == .compatible ? nil : .compatible
                            }
                        }
                        CategoryChip(label: "⚠️ Warning", color: .bcWarning,
                                     isSelected: filterStatus == .warning) {
                            withAnimation(.bcQuick) {
                                filterStatus = filterStatus == .warning ? nil : .warning
                            }
                        }
                        CategoryChip(label: "❌ Incompatible", color: .bcIncompatible,
                                     isSelected: filterStatus == .incompatible) {
                            withAnimation(.bcQuick) {
                                filterStatus = filterStatus == .incompatible ? nil : .incompatible
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if historyVM.history.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.bcTextMuted)
                        Text("No history yet")
                            .font(BCFont.heading(18))
                            .foregroundColor(.bcTextPrimary)
                        Text("Your compatibility checks will appear here")
                            .font(BCFont.body(14))
                            .foregroundColor(.bcTextSecondary)
                    }
                    Spacer()
                } else if filtered.isEmpty {
                    Spacer()
                    Text("No results for this filter")
                        .font(BCFont.body(14))
                        .foregroundColor(.bcTextMuted)
                    Spacer()
                } else {
                    List {
                        ForEach(filtered) { result in
                            NavigationLink(destination: ResultDetailView(result: result)) {
                                HistoryRow(result: result)
                            }
                            .listRowBackground(Color.bcCard)
                            .listRowSeparatorTint(Color.bcBorder)
                        }
                        .onDelete { offsets in
                            // Map filtered indices back to original
                            let ids = offsets.map { filtered[$0].id }
                            historyVM.history.removeAll { ids.contains($0.id) }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.bcBackground)
                }
            }
            .background(Color.bcBackground)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !historyVM.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showClearConfirm = true
                        } label: {
                            Text("Clear All")
                                .font(BCFont.body(14))
                                .foregroundColor(.bcIncompatible)
                        }
                    }
                }
            }
            .confirmationDialog("Clear all history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Clear All", role: .destructive) {
                    historyVM.clearAll()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct HistoryRow: View {
    let result: CompatibilityResult
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(result.status.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: result.status.icon)
                    .font(.system(size: 16))
                    .foregroundColor(result.status.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(result.materialA.name) + \(result.materialB.name)")
                    .font(BCFont.body(14, weight: .medium))
                    .foregroundColor(.bcTextPrimary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(result.status.rawValue)
                        .font(BCFont.body(12))
                        .foregroundColor(result.status.color)
                    Text("•")
                        .foregroundColor(.bcTextMuted)
                    Text(result.date, style: .relative)
                        .font(BCFont.body(12))
                        .foregroundColor(.bcTextMuted)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
