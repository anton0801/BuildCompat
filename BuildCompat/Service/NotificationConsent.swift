import UIKit
import UserNotifications

// MARK: - Consent Arbiter

final class NotificationConsent: ConsentArbiter {
    
    // Result-based (а не continuation и не direct async)
    func inquire(completion: @escaping (Result<Bool, Error>) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(granted))
                }
            }
        }
    }
    
    func arm() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
