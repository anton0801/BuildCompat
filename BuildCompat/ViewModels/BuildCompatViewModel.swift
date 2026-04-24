import Foundation
import Combine

@MainActor
final class BuildCompatViewModel: ObservableObject {
    
    @Published var showPermissionPrompt = false
    @Published var showOfflineView = false
    @Published var navigateToMain = false {
        didSet {
            if navigateToMain {
                deadlineTask?.cancel()
                uiLocked = true
            }
        }
    }
    @Published var navigateToWeb = false {
        didSet {
            if navigateToWeb {
                deadlineTask?.cancel()
                uiLocked = true
            }
        }
    }
    
    private let store: ReactiveStore
    private let chain: MiddlewareChain
    
    private var deadlineTask: Task<Void, Never>?
    private var signalTask: Task<Void, Never>?
    
    private var uiLocked: Bool = false
    
    init() {
        self.store = ReactiveStore()
        self.chain = MiddlewareChain(store: store)
    }
    
    // MARK: - Public API
    
    func launch() {
        Task {
            await chain.process(.bootstrap)
            armDeadline()
            beginSignalConsumption()
        }
    }
    
    func ingestAttribution(_ data: [String: Any]) {
        Task {
            await chain.process(.attributionArrived(data))
            await chain.process(.startSequence)
        }
    }
    
    func ingestRoutes(_ data: [String: Any]) {
        Task {
            await chain.process(.routesArrived(data))
        }
    }
    
    func acceptConsent() {
        Task {
            await chain.process(.consentAccepted)
        }
    }
    
    func declineConsent() {
        Task {
            await chain.process(.consentDeclined)
        }
    }
    
    func connectivityChanged(_ connected: Bool) {
        guard !connected else {
            showOfflineView = !connected
            return
        }
        
        showOfflineView = !connected
        
        Task {
            if connected {
                await store.onNetworkRestored()
            } else {
                await store.onNetworkLost()
            }
        }
    }
    
    // MARK: - Signal Consumption
    
    private func beginSignalConsumption() {
        signalTask = Task { [weak self] in
            guard let self = self else { return }
            
            for await signal in await self.store.signalStream {
                await self.apply(signal)
            }
        }
    }
    
    private func apply(_ signal: StageSignal) async {
        switch signal {
        case .connectionLost:
            showOfflineView = true
            return
        case .connectionRestored:
            showOfflineView = false
            return
        case .idle:
            return
        default:
            break
        }
        
        guard !uiLocked else {
            // print("\(CompatParams.signature) UI locked — ignoring signal: \(signal)")
            return
        }
        
        switch signal {
        case .proceedToMain:
            navigateToMain = true
        case .proceedToPrompt:
            showPermissionPrompt = true
        case .proceedToWeb:
            showPermissionPrompt = false
            navigateToWeb = true
        default:
            break
        }
    }
    
    private func armDeadline() {
        deadlineTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard let self = self else { return }
       
            await self.store.onDeadlineReached()
        }
    }
    
    deinit {
        deadlineTask?.cancel()
        signalTask?.cancel()
    }
}
