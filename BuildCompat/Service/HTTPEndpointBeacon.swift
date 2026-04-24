import Foundation
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import WebKit

final class HTTPEndpointBeacon: EndpointBeacon {
    
    private let session: URLSession
    private let delays: [Double] = [45.0, 90.0, 180.0]
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 90
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }
    
    private var userAgent: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    // Completion с (url, error) - handler-based
    func locate(context: [String: Any], handler: @escaping (String?, BuildCompatErrorKind?) -> Void) {
        guard let endpoint = URL(string: CompatParams.serverEndpoint) else {
            handler(nil, .badPayload)
            return
        }
        
        var payload: [String: Any] = context
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        payload["store_id"] = "id\(CompatParams.appStoreID)"
        payload["push_token"] = UserDefaults.standard.string(forKey: VaultKey.pushToken)
            ?? Messaging.messaging().fcmToken
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            handler(nil, .badPayload)
            return
        }
        request.httpBody = body
        
        attempt(request: request, index: 0, handler: handler)
    }
    
    private func attempt(
        request: URLRequest,
        index: Int,
        handler: @escaping (String?, BuildCompatErrorKind?) -> Void
    ) {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let _ = error {
                self.retryOrFail(request: request, index: index, lastError: .noConnection, handler: handler)
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.retryOrFail(request: request, index: index, lastError: .noConnection, handler: handler)
                return
            }
            
            // ✅ FIX #5: 404 ПЕРВЫМ — сразу отказ без ретраев
            if http.statusCode == 404 {
                print("\(CompatParams.signature) 404 → serverDecline")
                handler(nil, .serverDecline)
                return
            }
            
            if http.statusCode == 429 {
                // Throttled → retry с увеличенным бэкоффом
                self.retryOrFail(request: request, index: index, lastError: .throttled, handler: handler)
                return
            }
            
            guard (200...299).contains(http.statusCode), let data = data else {
                self.retryOrFail(request: request, index: index, lastError: .noConnection, handler: handler)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                handler(nil, .badPayload)
                return
            }
            
            guard let ok = json["ok"] as? Bool else {
                handler(nil, .badPayload)
                return
            }
            
            // ✅ FIX #5: ok:false — отдельная проверка, не ретраим
            if !ok {
                print("\(CompatParams.signature) ok:false → serverDecline")
                handler(nil, .serverDecline)
                return
            }
            
            guard let url = json["url"] as? String else {
                handler(nil, .badPayload)
                return
            }
            
            handler(url, nil)
        }
        
        task.resume()
    }
    
    private func retryOrFail(
        request: URLRequest,
        index: Int,
        lastError: BuildCompatErrorKind,
        handler: @escaping (String?, BuildCompatErrorKind?) -> Void
    ) {
        guard index < delays.count - 1 else {
            handler(nil, lastError)
            return
        }
        
        let delay = lastError == .throttled
            ? delays[index] * Double(index + 1)
            : delays[index]
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.attempt(request: request, index: index + 1, handler: handler)
        }
    }
}
