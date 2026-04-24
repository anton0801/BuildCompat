import AppsFlyerLib
import Foundation

final class AppsFlyerProbe: AttributionProbe {
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 90
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }
    
    // Completion-based
    func probe(deviceID: String, handler: @escaping ([String: Any]?) -> Void) {
        var components = URLComponents(string: "https://gcdsdk.appsflyer.com/install_data/v4.0/id\(CompatParams.appStoreID)")
        components?.queryItems = [
            URLQueryItem(name: "devkey", value: CompatParams.flyerKey),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        
        guard let requestURL = components?.url else {
            handler(nil)
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data,
                  let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                handler(nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                handler(nil)
                return
            }
            
            handler(json)
        }
        
        task.resume()
    }
}
