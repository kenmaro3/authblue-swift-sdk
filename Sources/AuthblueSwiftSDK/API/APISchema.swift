import Foundation

public struct CertificateRegisterResponse: Codable{
    let user_id: String
}

public struct CertificateRegisterResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: CertificateRegisterResponse?
}

public struct createUserWithAuthResponse: Codable{
    let user_id: String
    let username: String
    public let access_token: String
}

public struct createUserWithAuthResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: createUserWithAuthResponse?
}

struct AuthAgreementWithQRRequest: Codable{
    let client_id: String
    let signature: String?
    let digital_signature: String?
}

struct DeleteUserResponse: Codable{
    let status: String
}

struct DeleteUserResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    let result: DeleteUserResponse?
}

public struct AuthAgreementWithQRResponse: Codable{
    let ref_code: String
}

public struct AuthAgreementWithQRResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: AuthAgreementWithQRResponse?
}

public struct AgreementRequestModel: Codable{
    let id: String
    let client_id: String
    let client_name: String
    let content: AgreementContentModel
    let requesting_info: AgreementModel
    let agreement_method: AgreementMethod
}

public struct AgreementRequestResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: AgreementRequestModel?
}


public struct NonceResult: Codable {
    let nonce: String
}

public struct RequestNonceResponseAPI: Codable{
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: NonceResult?
}

public struct RequestCertificateExistsResponse: Codable {
    let exists: Bool
}

public struct RequestCertificateExistsResponseAPI: Codable {
    let has_error: Bool
    let error_message: String?
    let req_id: String
    public let result: RequestCertificateExistsResponse?
}

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case unknown(Error)
}

extension APIError {

    var title: String {
        switch self {
            case .invalidResponse: return "無効なレスポンスです。"
            case .invalidURL: return "無効なURLです。"
            case .unknown(let error): return "予期せぬエラーが発生しました。\(error)"
        }
    }

}

public typealias ResultHandler<T> = (Result<T, APIError>) -> Void
