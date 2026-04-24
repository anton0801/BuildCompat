import Foundation

protocol DataVault {
    func stash(payload: [String: String])
    func stash(routes: [String: String])
    func stash(address: String, phase: String)
    func stash(consent: ConsentSlot)
    func markBooted()
    func fetchSnapshot() -> VaultSnapshot
    func invalidateCache()
}

protocol ClearanceGate {
    func authorize(completion: @escaping (Bool?) -> Void)
}

protocol AttributionProbe {
    func probe(deviceID: String, handler: @escaping ([String: Any]?) -> Void)
}

protocol EndpointBeacon {
    func locate(context: [String: Any], handler: @escaping (String?, BuildCompatErrorKind?) -> Void)
}

protocol ConsentArbiter {
    func inquire(completion: @escaping (Result<Bool, Error>) -> Void)
    func arm()
}

enum BuildCompatErrorKind {
    case noConnection
    case badPayload
    case serverDecline
    case throttled
    case unknownFailure
}

protocol ActionMiddleware: AnyObject {
    var next: ActionMiddleware? { get set }
    func handle(_ action: BuildCompatAction) async
}

class AbstractMiddleware: ActionMiddleware {
    var next: ActionMiddleware?
    
    func handle(_ action: BuildCompatAction) async {
        await forward(action)
    }
    
    func forward(_ action: BuildCompatAction) async {
        await next?.handle(action)
    }
}
