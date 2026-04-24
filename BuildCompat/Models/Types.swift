import Foundation

struct AttributionSlot {
    var payload: [String: String]
    var routes: [String: String]
    
    static var vacant: AttributionSlot {
        AttributionSlot(payload: [:], routes: [:])
    }
    
    func filled() -> Bool {
        !payload.isEmpty
    }
    
    func isOrganic() -> Bool {
        payload["af_status"] == "Organic"
    }
}

struct TargetSlot {
    var address: String?
    var phase: String?
    var fresh: Bool
    var locked: Bool
    
    static var vacant: TargetSlot {
        TargetSlot(
            address: nil,
            phase: nil,
            fresh: true,
            locked: false
        )
    }
}

struct ConsentSlot {
    var granted: Bool
    var denied: Bool
    var promptedAt: Date?
    
    static var vacant: ConsentSlot {
        ConsentSlot(
            granted: false,
            denied: false,
            promptedAt: nil
        )
    }
    
    func readyToPrompt() -> Bool {
        guard !granted && !denied else { return false }
        
        if let date = promptedAt {
            let days = Date().timeIntervalSince(date) / 86400
            return days >= 3
        }
        return true
    }
}

struct VaultSnapshot {
    let payload: [String: String]
    let routes: [String: String]
    let address: String?
    let phase: String?
    let fresh: Bool
    let granted: Bool
    let denied: Bool
    let promptedAt: Date?
}

enum BuildCompatAction {
    case bootstrap
    case attributionArrived([String: Any])
    case routesArrived([String: Any])
    case startSequence
    case consentAccepted
    case consentDeclined
}

enum StageSignal {
    case idle
    case proceedToPrompt
    case proceedToWeb
    case proceedToMain
    case connectionLost
    case connectionRestored
}

struct CompatParams {
    static let appStoreID = "6762561193"
    static let flyerKey = "A35cgMteVLcBLQ25up7JmN"
    static let groupSuite = "group.buildcompat.workspace"
    static let cookieVault = "buildcompat_vault"
    static let serverEndpoint = "https://builldcompat.com/config.php"
    static let signature = "🔨 [BuildCompat]"
}

struct VaultKey {
    static let payload = "bc_payload"
    static let routes = "bc_routes"
    static let address = "bc_addr"
    static let phase = "bc_phase"
    static let booted = "bc_booted"
    static let consentYes = "bc_consent_yes"
    static let consentNo = "bc_consent_no"
    static let consentWhen = "bc_consent_when"
    static let transientURL = "temp_url"
    static let fcmToken = "fcm_token"
    static let pushToken = "push_token"
}
