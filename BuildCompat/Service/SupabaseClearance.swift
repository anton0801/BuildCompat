import Supabase
import Foundation

final class SupabaseClearance: ClearanceGate {
    
    private let client: SupabaseClient
    
    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://pzomfnxsiwirammwwckm.supabase.co")!,
            supabaseKey: "sb_publishable_oKOw3fc6H_xGHelZSbBqsg_cIJB7vSz"
        )
    }
    
    // Completion-based (не async throws, не Result)
    func authorize(completion: @escaping (Bool?) -> Void) {
        Task {
            do {
                let rows: [ClearanceRow] = try await client
                    .from("validation")
                    .select()
                    .limit(1)
                    .execute()
                    .value
                
                guard let row = rows.first else {
                    completion(false)
                    return
                }
                
                completion(row.isValid)
            } catch {
                print("\(CompatParams.signature) Clearance error: \(error)")
                completion(nil)  // nil = ошибка (не true/false)
            }
        }
    }
}

struct ClearanceRow: Codable {
    let id: Int?
    let isValid: Bool
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isValid = "is_valid"
        case createdAt = "created_at"
    }
}
