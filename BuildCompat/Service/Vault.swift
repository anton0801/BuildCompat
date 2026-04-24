import Foundation

final class CachedVault: DataVault {
    
    private let sharedStore: UserDefaults
    private let localStore: UserDefaults
    
    private var snapshotCache: VaultSnapshot?
    private let cacheLock = NSLock()
    
    init() {
        self.sharedStore = UserDefaults(suiteName: CompatParams.groupSuite)!
        self.localStore = UserDefaults.standard
    }
    
    func stash(payload: [String: String]) {
        guard let encoded = encode(payload) else { return }
        sharedStore.set(encoded, forKey: VaultKey.payload)
        invalidateCache()
    }
    
    func stash(routes: [String: String]) {
        guard let encoded = encode(routes) else { return }
        let obfuscated = obfuscate(encoded)
        sharedStore.set(obfuscated, forKey: VaultKey.routes)
        invalidateCache()
    }
    
    func stash(address: String, phase: String) {
        sharedStore.set(address, forKey: VaultKey.address)
        localStore.set(address, forKey: VaultKey.address)
        sharedStore.set(phase, forKey: VaultKey.phase)
        invalidateCache()
    }
    
    func stash(consent: ConsentSlot) {
        sharedStore.set(consent.granted, forKey: VaultKey.consentYes)
        sharedStore.set(consent.denied, forKey: VaultKey.consentNo)
        
        if let when = consent.promptedAt {
            let ms = when.timeIntervalSince1970 * 1000
            sharedStore.set(ms, forKey: VaultKey.consentWhen)
        }
        invalidateCache()
    }
    
    func markBooted() {
        sharedStore.set(true, forKey: VaultKey.booted)
        invalidateCache()
    }
    
    // MARK: - Fetch with Cache
    
    func fetchSnapshot() -> VaultSnapshot {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        
        if let cached = snapshotCache {
            return cached
        }
        
        let snapshot = buildSnapshot()
        snapshotCache = snapshot
        return snapshot
    }
    
    func invalidateCache() {
        cacheLock.lock()
        snapshotCache = nil
        cacheLock.unlock()
    }
    
    // MARK: - Build Snapshot
    
    private func buildSnapshot() -> VaultSnapshot {
        let payloadEncoded = sharedStore.string(forKey: VaultKey.payload) ?? ""
        let payload = decode(payloadEncoded) ?? [:]
        
        let routesObfuscated = sharedStore.string(forKey: VaultKey.routes) ?? ""
        let routesEncoded = deobfuscate(routesObfuscated) ?? ""
        let routes = decode(routesEncoded) ?? [:]
        
        let address = sharedStore.string(forKey: VaultKey.address)
        let phase = sharedStore.string(forKey: VaultKey.phase)
        let booted = sharedStore.bool(forKey: VaultKey.booted)
        
        let granted = sharedStore.bool(forKey: VaultKey.consentYes)
        let denied = sharedStore.bool(forKey: VaultKey.consentNo)
        let whenMs = sharedStore.double(forKey: VaultKey.consentWhen)
        let when = whenMs > 0 ? Date(timeIntervalSince1970: whenMs / 1000) : nil
        
        return VaultSnapshot(
            payload: payload,
            routes: routes,
            address: address,
            phase: phase,
            fresh: !booted,
            granted: granted,
            denied: denied,
            promptedAt: when
        )
    }
    
    // MARK: - Encoding
    
    private func encode(_ dict: [String: String]) -> String? {
        let anyDict = dict.mapValues { $0 as Any }
        guard let data = try? JSONSerialization.data(withJSONObject: anyDict),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        return text
    }
    
    private func decode(_ text: String) -> [String: String]? {
        guard let data = text.data(using: .utf8),
              let anyDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return anyDict.mapValues { "\($0)" }
    }
    
    // MARK: - Obfuscation
    
    private func obfuscate(_ input: String) -> String {
        let b64 = Data(input.utf8).base64EncodedString()
        return b64
            .replacingOccurrences(of: "=", with: "*")
            .replacingOccurrences(of: "+", with: "-")
    }
    
    private func deobfuscate(_ input: String) -> String? {
        let b64 = input
            .replacingOccurrences(of: "*", with: "=")
            .replacingOccurrences(of: "-", with: "+")
        
        guard let data = Data(base64Encoded: b64),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        return text
    }
}
