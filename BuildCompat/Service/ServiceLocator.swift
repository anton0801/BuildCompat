import Foundation

final class ServiceLocator {
    
    static let shared = ServiceLocator()
    
    private var registry: [String: Any] = [:]
    private let lock = NSLock()
    
    private init() {
        registerDefaults()
    }
    
    // MARK: - Registration
    
    func register<T>(_ service: T, for type: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        registry[key] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        lock.lock()
        defer { lock.unlock() }
        
        let key = String(describing: type)
        guard let service = registry[key] as? T else {
            fatalError("\(CompatParams.signature) Service \(key) not registered")
        }
        return service
    }
    
    // MARK: - Default Registrations
    
    private func registerDefaults() {
        registry[String(describing: DataVault.self)] = CachedVault()
        registry[String(describing: ClearanceGate.self)] = SupabaseClearance()
        registry[String(describing: AttributionProbe.self)] = AppsFlyerProbe()
        registry[String(describing: EndpointBeacon.self)] = HTTPEndpointBeacon()
        registry[String(describing: ConsentArbiter.self)] = NotificationConsent()
    }
}
