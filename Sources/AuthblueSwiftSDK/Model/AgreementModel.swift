import Foundation


struct AgreementReceiptRepositories: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    let result: [AgreementReceiptModel]
}

struct AgreementReceiptModel: Codable, Identifiable{
    var id: String
    var created_at: String
    var client_id: String
    var client_name: String
    var content: AgreementContentModel
    var agreement_method: AgreementMethod
    var requesting_info: AgreementModel
    var type: String
}

struct AgreementContentModel: Codable{
    var agreement: String
}

struct AgreementModel: Codable {
    var name: Bool
    var birthday: Bool
    var age: Bool
    var picture: Bool
    var sex: Bool
    var address: Bool
    var phone: Bool
    var email: Bool
    
    func toString() -> String?{
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional: For pretty-printed JSON
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to encode person object:", error)
        }
        
        return nil
        
    }
    
    static func fromString(_ x: String) -> AgreementModel?{
        do {
            let jsonData = x.data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try decoder.decode(AgreementModel.self, from: jsonData)
            return obj
        } catch {
            print("Failed to decode JSON string:", error)
        }
        return nil
    }
}



struct AgreementMethod: Codable{
    var face_id: Bool
    var my_number_card: Bool
    var signature: Bool
    
    func toString() -> String?{
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional: For pretty-printed JSON
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to encode person object:", error)
        }
        
        return nil
        
    }
    
    static func fromString(_ x: String) -> AgreementMethod?{
        do {
            let jsonData = x.data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try decoder.decode(AgreementMethod.self, from: jsonData)
            return obj
        } catch {
            print("Failed to decode JSON string:", error)
        }
        return nil
    }
}


struct UserInfoModel: Encodable{
    var name: String?
    var birthday: String?
    var age: String?
    var picture: String?
    var sex: String?
    var address: String?
    var phone: String?
    var email: String?
}
