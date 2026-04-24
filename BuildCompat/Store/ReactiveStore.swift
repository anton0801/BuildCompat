import Foundation
import AppsFlyerLib

actor ReactiveStore {
    
    private var attribution: AttributionSlot = .vacant
    private var target: TargetSlot = .vacant
    private var consent: ConsentSlot = .vacant
    
    private var organicHandled: Bool = false
    
    private var sequenceCompleted: Bool = false
    
    private var signalContinuation: AsyncStream<StageSignal>.Continuation?
    nonisolated let signalStream: AsyncStream<StageSignal>
    
    private let vault: DataVault
    private let clearance: ClearanceGate
    private let probe: AttributionProbe
    private let beacon: EndpointBeacon
    private let arbiter: ConsentArbiter
    
    init() {
        let locator = ServiceLocator.shared
        self.vault = locator.resolve(DataVault.self)
        self.clearance = locator.resolve(ClearanceGate.self)
        self.probe = locator.resolve(AttributionProbe.self)
        self.beacon = locator.resolve(EndpointBeacon.self)
        self.arbiter = locator.resolve(ConsentArbiter.self)
        
        var cont: AsyncStream<StageSignal>.Continuation!
        self.signalStream = AsyncStream<StageSignal> { continuation in
            cont = continuation
        }
        self.signalContinuation = cont
    }
    
    func canStillRun() -> Bool {
        true // !sequenceCompleted
    }
    
    func dispatch(_ action: BuildCompatAction) async {
        switch action {
        case .bootstrap:
            await performBootstrap()
            
        case .attributionArrived(let data):
            performAttributionArrived(data)
            
        case .routesArrived(let data):
            performRoutesArrived(data)
            
        case .startSequence:
            await performStartSequence()
            
        case .consentAccepted:
            await performConsentAccepted()
            
        case .consentDeclined:
            performConsentDeclined()
        }
    }
    
    func onDeadlineReached() {
        guard !sequenceCompleted else {
            return
        }
        emit(.proceedToMain)
    }
    
    func onNetworkLost() {
        emit(.connectionLost)
    }
    
    func onNetworkRestored() {
        emit(.connectionRestored)
    }
    
    private func performBootstrap() async {
        let snapshot = vault.fetchSnapshot()
        
        attribution.payload = snapshot.payload
        attribution.routes = snapshot.routes
        
        target.address = snapshot.address
        target.phase = snapshot.phase
        target.fresh = snapshot.fresh
        
        consent.granted = snapshot.granted
        consent.denied = snapshot.denied
        consent.promptedAt = snapshot.promptedAt
    }
    
    private func performAttributionArrived(_ data: [String: Any]) {
        let stringified = data.mapValues { "\($0)" }
        attribution.payload = stringified
        vault.stash(payload: stringified)
    }
    
    private func performRoutesArrived(_ data: [String: Any]) {
        let stringified = data.mapValues { "\($0)" }
        attribution.routes = stringified
        vault.stash(routes: stringified)
    }
    
    private func performStartSequence() async {
        guard !sequenceCompleted else { return }
        
        if let tempURL = UserDefaults.standard.string(forKey: VaultKey.transientURL),
           !tempURL.isEmpty {
            finalizeTarget(url: tempURL)
            return
        }
        
        guard attribution.filled() else {
            return
        }
        
        let clearanceResult = await performClearance()
        
        switch clearanceResult {
        case .some(true):
            break  // продолжаем
        case .some(false), .none:
            emit(.proceedToMain)
            return
        }
        
        // 4. Organic flow (один раз)
        if attribution.isOrganic() && target.fresh && !organicHandled {
            organicHandled = true
            await performOrganicRefresh()
        }
        
        let (url, errorKind) = await performLocate()
        
        if let errorKind = errorKind {
            sequenceCompleted = true
            emit(.proceedToMain)
            return
        }
        
        guard let url = url else {
            sequenceCompleted = true
            emit(.proceedToMain)
            return
        }
        
        finalizeTarget(url: url)
    }
    
    private func performConsentAccepted() async {
        var localConsent = consent
        
        let result: Result<Bool, Error> = await withCheckedContinuation { continuation in
            arbiter.inquire { result in
                continuation.resume(returning: result)
            }
        }
        
        switch result {
        case .success(let granted):
            if granted {
                localConsent.granted = true
                localConsent.denied = false
                localConsent.promptedAt = Date()
                arbiter.arm()
            } else {
                localConsent.granted = false
                localConsent.denied = true
                localConsent.promptedAt = Date()
            }
        case .failure:
            localConsent.granted = false
            localConsent.denied = true
            localConsent.promptedAt = Date()
        }
        
        consent = localConsent
        vault.stash(consent: localConsent)
        
        emit(.proceedToWeb)
    }
    
    private func performConsentDeclined() {
        consent.promptedAt = Date()
        vault.stash(consent: consent)
        
        emit(.proceedToWeb)
    }
    
    private func performClearance() async -> Bool? {
        await withCheckedContinuation { continuation in
            clearance.authorize { value in
                continuation.resume(returning: value)
            }
        }
    }
    
    private func performOrganicRefresh() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        guard !target.locked else { return }
        
        let deviceID = AppsFlyerLib.shared().getAppsFlyerUID()
        
        let fetched: [String: Any]? = await withCheckedContinuation { continuation in
            probe.probe(deviceID: deviceID) { value in
                continuation.resume(returning: value)
            }
        }
        
        guard var fetched = fetched else { return }
        
        for (k, v) in attribution.routes {
            if fetched[k] == nil {
                fetched[k] = v
            }
        }
        
        let stringified = fetched.mapValues { "\($0)" }
        attribution.payload = stringified
        vault.stash(payload: stringified)
    }
    
    private func performLocate() async -> (String?, BuildCompatErrorKind?) {
        let contextDict = attribution.payload.mapValues { $0 as Any }
        
        return await withCheckedContinuation { continuation in
            beacon.locate(context: contextDict) { url, errorKind in
                continuation.resume(returning: (url, errorKind))
            }
        }
    }
    
    private func finalizeTarget(url: String) {
        let needsConsent = consent.readyToPrompt()
        
        target.address = url
        target.phase = "Active"
        target.fresh = false
        target.locked = true
        
        vault.stash(address: url, phase: "Active")
        vault.markBooted()
        
        UserDefaults.standard.removeObject(forKey: VaultKey.transientURL)
        
        sequenceCompleted = true
        
        emit(needsConsent ? .proceedToPrompt : .proceedToWeb)
    }
    
    private func emit(_ signal: StageSignal) {
        signalContinuation?.yield(signal)
    }
}
