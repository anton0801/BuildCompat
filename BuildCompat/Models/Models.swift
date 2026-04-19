import SwiftUI
import Foundation

// MARK: - Material Category
enum MaterialCategory: String, CaseIterable, Codable {
    case paint = "Paint"
    case tiles = "Tiles"
    case wood = "Wood"
    case concrete = "Concrete"
    case adhesives = "Adhesives"
    case metal = "Metal"
    case primer = "Primer"

    var icon: String {
        switch self {
        case .paint: return "paintbrush.fill"
        case .tiles: return "square.grid.2x2.fill"
        case .wood: return "tree.fill"
        case .concrete: return "square.3.layers.3d.down.right.fill"
        case .adhesives: return "drop.fill"
        case .metal: return "wrench.and.screwdriver.fill"
        case .primer: return "circle.hexagonpath.fill"
        }
    }

    var color: Color {
        switch self {
        case .paint: return .bcPaint
        case .tiles: return .bcTile
        case .wood: return .bcWood
        case .concrete: return .bcConcrete
        case .adhesives: return Color(hex: "#A78BFA")
        case .metal: return .bcMetal
        case .primer: return Color(hex: "#34D399")
        }
    }
}

// MARK: - Material
struct Material: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var category: MaterialCategory
    var description: String
    var properties: [String: String]
    var tags: [String]

    init(id: UUID = UUID(), name: String, category: MaterialCategory,
         description: String, properties: [String: String] = [:], tags: [String] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.properties = properties
        self.tags = tags
    }
}

// MARK: - Compatibility Result
enum CompatibilityStatus: String, Codable {
    case compatible = "Compatible"
    case warning = "Warning"
    case incompatible = "Incompatible"

    var color: Color {
        switch self {
        case .compatible: return .bcCompatible
        case .warning: return .bcWarning
        case .incompatible: return .bcIncompatible
        }
    }

    var icon: String {
        switch self {
        case .compatible: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .incompatible: return "xmark.circle.fill"
        }
    }

    var emoji: String {
        switch self {
        case .compatible: return "✅"
        case .warning: return "⚠️"
        case .incompatible: return "❌"
        }
    }
}

struct CompatibilityResult: Identifiable, Codable {
    let id: UUID
    let materialA: Material
    let materialB: Material
    let status: CompatibilityStatus
    let explanation: String
    let suggestedFix: [String]
    let date: Date

    init(id: UUID = UUID(), materialA: Material, materialB: Material,
         status: CompatibilityStatus, explanation: String,
         suggestedFix: [String] = [], date: Date = Date()) {
        self.id = id
        self.materialA = materialA
        self.materialB = materialB
        self.status = status
        self.explanation = explanation
        self.suggestedFix = suggestedFix
        self.date = date
    }
}

// MARK: - Project
struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var materials: [Material]
    var savedCombinations: [CompatibilityResult]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, description: String = "",
         materials: [Material] = [], savedCombinations: [CompatibilityResult] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.materials = materials
        self.savedCombinations = savedCombinations
        self.createdAt = createdAt
    }
}

// MARK: - Guide
struct Guide: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let icon: String
    let steps: [GuideStep]
    let warnings: [String]
    let tips: [String]

    init(id: UUID = UUID(), title: String, category: String, icon: String,
         steps: [GuideStep], warnings: [String] = [], tips: [String] = []) {
        self.id = id
        self.title = title
        self.category = category
        self.icon = icon
        self.steps = steps
        self.warnings = warnings
        self.tips = tips
    }
}

struct GuideStep: Identifiable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let description: String
    let duration: String
    let icon: String

    init(id: UUID = UUID(), stepNumber: Int, title: String,
         description: String, duration: String, icon: String) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.duration = duration
        self.icon = icon
    }
}

// MARK: - User
struct AppUser: Codable {
    var id: String
    var name: String
    var email: String
    var isDemo: Bool

    init(id: String = UUID().uuidString, name: String, email: String, isDemo: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.isDemo = isDemo
    }
}
