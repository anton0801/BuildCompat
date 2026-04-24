import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let dataHub = DataHub()
    private let pushRelay = PushRelay()
    
    // MARK: - Launch
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        dataHub.onAttributionReady = { [weak self] data in
            self?.broadcastAttribution(data)
        }
        
        dataHub.onRoutesReady = { [weak self] data in
            self?.broadcastRoutes(data)
        }
        
        // Все методы настройки — в extension'ах ниже
        configureFirebase()
        configureMessaging()
        configureAppsFlyer()
        
        if let remote = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pushRelay.transmit(remote)
        }
        
        observeLifecycle()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    fileprivate func broadcastAttribution(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: .init("ConversionDataReceived"),
            object: nil,
            userInfo: ["conversionData": data]
        )
    }
    
    fileprivate func broadcastRoutes(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: .init("deeplink_values"),
            object: nil,
            userInfo: ["deeplinksData": data]
        )
    }
}

// MARK: - Firebase Setup (extension)

extension AppDelegate {
    fileprivate func configureFirebase() {
        FirebaseApp.configure()
    }
}

// MARK: - Messaging Setup (extension)

extension AppDelegate: MessagingDelegate {
    fileprivate func configureMessaging() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        messaging.token { token, err in
            guard err == nil, let t = token else { return }
            
            UserDefaults.standard.set(t, forKey: VaultKey.fcmToken)
            UserDefaults.standard.set(t, forKey: VaultKey.pushToken)
            UserDefaults(suiteName: CompatParams.groupSuite)?.set(t, forKey: "shared_fcm")
        }
    }
}

// MARK: - AppsFlyer Setup (extension)

extension AppDelegate: AppsFlyerLibDelegate, DeepLinkDelegate {
    fileprivate func configureAppsFlyer() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = CompatParams.flyerKey
        sdk.appleAppID = CompatParams.appStoreID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    fileprivate func observeLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onActivation),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc fileprivate func onActivation() {
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "att_status")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        dataHub.acceptAttribution(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        let errorData: [AnyHashable: Any] = [
            "error": true,
            "error_desc": error.localizedDescription
        ]
        dataHub.acceptAttribution(errorData)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let link = result.deepLink else { return }
        
        dataHub.acceptRoutes(link.clickEvent)
    }
}

// MARK: - Notification Delegate (extension)

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        pushRelay.transmit(notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        pushRelay.transmit(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        pushRelay.transmit(userInfo)
        completionHandler(.newData)
    }
}

// MARK: - Data Hub (helper #1) — буферизация AppsFlyer данных

final class DataHub: NSObject {
    
    var onAttributionReady: (([AnyHashable: Any]) -> Void)?
    var onRoutesReady: (([AnyHashable: Any]) -> Void)?
    
    private var attributionBuffer: [AnyHashable: Any] = [:]
    private var routesBuffer: [AnyHashable: Any] = [:]
    private var mergeTimer: Timer?
    
    func acceptAttribution(_ data: [AnyHashable: Any]) {
        attributionBuffer = data
        armMerge()
        
        if !routesBuffer.isEmpty {
            merge()
        }
    }
    
    func acceptRoutes(_ data: [AnyHashable: Any]) {
        guard !UserDefaults.standard.bool(forKey: VaultKey.booted) else { return }
        
        routesBuffer = data
        onRoutesReady?(data)
        mergeTimer?.invalidate()
        
        if !attributionBuffer.isEmpty {
            merge()
        }
    }
    
    private func armMerge() {
        mergeTimer?.invalidate()
        mergeTimer = Timer.scheduledTimer(
            withTimeInterval: 2.5,
            repeats: false
        ) { [weak self] _ in
            self?.merge()
        }
    }
    
    private func merge() {
        var combined = attributionBuffer
        
        for (k, v) in routesBuffer {
            let prefixed = "deep_\(k)"
            if combined[prefixed] == nil {
                combined[prefixed] = v
            }
        }
        
        onAttributionReady?(combined)
    }
}

// MARK: - Push Relay (helper #2) — извлечение URL из push

final class PushRelay: NSObject {
    
    func transmit(_ payload: [AnyHashable: Any]) {
        guard let url = extract(payload) else { return }
        
        UserDefaults.standard.set(url, forKey: VaultKey.transientURL)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(
                name: .init("LoadTempURL"),
                object: nil,
                userInfo: ["temp_url": url]
            )
        }
    }
    
    private func extract(_ payload: [AnyHashable: Any]) -> String? {
        if let direct = payload["url"] as? String {
            return direct
        }
        
        if let nested = payload["data"] as? [String: Any],
           let url = nested["url"] as? String {
            return url
        }
        
        if let aps = payload["aps"] as? [String: Any],
           let nested = aps["data"] as? [String: Any],
           let url = nested["url"] as? String {
            return url
        }
        
        if let custom = payload["custom"] as? [String: Any],
           let url = custom["target_url"] as? String {
            return url
        }
        
        return nil
    }
}
