import Foundation

final class LoggingMiddleware: AbstractMiddleware {
    override func handle(_ action: BuildCompatAction) async {
        let label = describe(action)
        
        await forward(action)
    }
    
    private func describe(_ action: BuildCompatAction) -> String {
        switch action {
        case .bootstrap: return "bootstrap"
        case .attributionArrived: return "attributionArrived"
        case .routesArrived: return "routesArrived"
        case .startSequence: return "startSequence"
        case .consentAccepted: return "consentAccepted"
        case .consentDeclined: return "consentDeclined"
        }
    }
}

final class GatekeeperMiddleware: AbstractMiddleware {
    
    private let store: ReactiveStore
    
    init(store: ReactiveStore) {
        self.store = store
        super.init()
    }
    
    override func handle(_ action: BuildCompatAction) async {
        switch action {
        case .startSequence, .consentAccepted, .consentDeclined:
            let allowed = await store.canStillRun()
            guard allowed else {
                // print("\(CompatParams.signature) Gatekeeper blocked: sequence completed")
                return
            }
        default:
            break
        }
        
        await forward(action)
    }
}

final class DispatcherMiddleware: AbstractMiddleware {
    
    private let store: ReactiveStore
    
    init(store: ReactiveStore) {
        self.store = store
        super.init()
    }
    
    override func handle(_ action: BuildCompatAction) async {
        await store.dispatch(action)
    }
}

final class MiddlewareChain {
    
    private let head: ActionMiddleware
    
    init(store: ReactiveStore) {
        let logger = LoggingMiddleware()
        let gatekeeper = GatekeeperMiddleware(store: store)
        let dispatcher = DispatcherMiddleware(store: store)
        
        // Связываем: logger → gatekeeper → dispatcher
        logger.next = gatekeeper
        gatekeeper.next = dispatcher
        
        self.head = logger
    }
    
    func process(_ action: BuildCompatAction) async {
        await head.handle(action)
    }
}
