import Foundation
import Alamofire

public struct APIClient {
    
    public static func createUserWithAuth(username: String, email: String, handler: @escaping ResultHandler<createUserWithAuthResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/users_with_auth_mobile"
        print("\n\nhere!!!!!")
        print(urlString)
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let param: Parameters = [
            //"user_id": user_id,
            "username": username,
            "email": email
        ]
        print(param)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(urlString,
                   method:.post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: headers
        ).responseJSON {response in
            guard let data = response.data else{
                handler(.failure(.invalidResponse))
                return
            }
            do{
                let res = try JSONDecoder().decode(createUserWithAuthResponseAPI.self, from: data)
                handler(.success(res))
            } catch {
                handler(.failure(.unknown(error)))
            }
            
        }
    }
    
    
    static func authAgreementWithQRRequest(clientId: String, signature: String?, digitalSignature: String?, userInfoModel: UserInfoModel, uid: String, handler: @escaping ResultHandler<AuthAgreementWithQRResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/oauth/agreement_with_qr/mobile"
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let jsonEncoder = JSONEncoder()
        var tmp: Data = Data()
        do{
            
            tmp = try jsonEncoder.encode(userInfoModel)
            let tmp2 = try? JSONSerialization.jsonObject(with: tmp)
            let param: Parameters = [
                "client_id": clientId,
                "signature": signature,
                "digital_signature": digitalSignature,
                "requesting_info": tmp2,
                "uid": uid
            ]
            
            
            let userDefaults = UserDefaults.standard
            guard let token = userDefaults.string(forKey: "authblue_api_token") else {
                print("cannot find token")
                userDefaults.set(false, forKey: "log_status")
                return
            }
            
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization":"Bearer \(token)"
                
            ]
            
            AF.request(urlString,
                       method:.post,
                       parameters: param,
                       encoding: JSONEncoding.default,
                       headers: headers
            ).responseJSON {response in
                if(response.response?.statusCode == 401){
                    print("falled 401")
                    userDefaults.set(false, forKey: "log_status")
                }
                guard let data = response.data else{
                    print("falled invalid response")
                    handler(.failure(.invalidResponse))
                    return
                }
                do{
                    let res = try JSONDecoder().decode(AuthAgreementWithQRResponseAPI.self, from: data)
                    handler(.success(res))
                } catch {
                    print("falled json decoder failed")
                    handler(.failure(.unknown(error)))
                }
                
            }
        }catch{
            print("falled json encode failed")
            handler(.failure(.unknown(error)))
        }
        
    }
    
    static func postCertificateToFastAPI(certificate_pem_string: String, handler: @escaping ResultHandler<CertificateRegisterResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/register_certificate"
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let param: Parameters = [
            //"certificate": indivisualNumberCardData.certificate_pem,
            "certificate": certificate_pem_string
        ]
        
        let userDefaults = UserDefaults.standard
        guard let token = userDefaults.string(forKey: "authblue_api_token") else {
            print("cannot find token")
            userDefaults.set(false, forKey: "log_status")
            return
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization":"Bearer \(token)"

        ]
        
        AF.request(urlString,
                   method:.post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: headers
        ).responseJSON {response in
            if(response.response?.statusCode == 401){
                userDefaults.set(false, forKey: "log_status")
            }
            guard let data = response.data else{
                handler(.failure(.invalidResponse))
                return
            }
            do{
                let res = try JSONDecoder().decode(CertificateRegisterResponseAPI.self, from: data)
                handler(.success(res))
            } catch {
                handler(.failure(.unknown(error)))
            }
            
        }
        
    }
    
    static func requestCertificateExists(handler: @escaping ResultHandler<RequestCertificateExistsResponseAPI>) {
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/request_certificate_exists"
        guard let url = URL(string: urlString) else {
            handler(.failure(.invalidURL))
            return
        }

        let userDefaults = UserDefaults.standard
        guard let token = userDefaults.string(forKey: "authblue_api_token") else {
            print("cannot find token")
            userDefaults.set(false, forKey: "log_status")
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization":"Bearer \(token)"

        ]
        
        AF.request(
            urlString,
            method: .get,
            headers: headers
            
        )
        .responseJSON{ response in
            if(response.response?.statusCode == 401){
                userDefaults.set(false, forKey: "log_status")
            }
            
            guard let data = response.data else {
                handler(.failure(.invalidResponse))
                return
            }
            do {
                let res = try JSONDecoder().decode(RequestCertificateExistsResponseAPI.self, from: data)
                print("here!!!!!")
                handler(.success(res))
            } catch {
                handler(.failure(.unknown(error)))
            }
        }
    }
    
    static func requestNonceFastAPI(handler: @escaping ResultHandler<RequestNonceResponseAPI>) {
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/request_nonce"
        guard let url = URL(string: urlString) else {
            handler(.failure(.invalidURL))
            return
        }
        
        let userDefaults = UserDefaults.standard
        guard let token = userDefaults.string(forKey: "authblue_api_token") else {
            print("cannot find token")
            userDefaults.set(false, forKey: "log_status")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization":"Bearer \(token)"
            
        ]
        AF.request(
            urlString,
            method: .get,
            headers: headers
            
        )
        .responseJSON{ response in
            if(response.response?.statusCode == 401){
                userDefaults.set(false, forKey: "log_status")
            }
            
            guard let data = response.data else {
                handler(.failure(.invalidResponse))
                return
            }
            do {
                let res = try JSONDecoder().decode(RequestNonceResponseAPI.self, from: data)
                handler(.success(res))
            } catch {
                handler(.failure(.unknown(error)))
            }
        }
    }
    
    static func getTutorialClient(handler: @escaping ResultHandler<AgreementRequestResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/clients/get_tutorial_client"
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let jsonEncoder = JSONEncoder()
        var tmp: Data = Data()
        do{
            
            
            let userDefaults = UserDefaults.standard
            guard let token = userDefaults.string(forKey: "authblue_api_token") else {
                print("cannot find token")
                userDefaults.set(false, forKey: "log_status")
                return
            }
            
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization":"Bearer \(token)"
                
            ]
            
            AF.request(urlString,
                       method:.get,
                       headers: headers
            ).responseJSON {response in
                if(response.response?.statusCode == 401){
                    print("falled 401")
                    userDefaults.set(false, forKey: "log_status")
                }
                guard let data = response.data else{
                    print("falled invalid response")
                    handler(.failure(.invalidResponse))
                    return
                }
                do{
                    let res = try JSONDecoder().decode(AgreementRequestResponseAPI.self, from: data)
                    handler(.success(res))
                } catch {
                    print("falled json decoder failed")
                    handler(.failure(.unknown(error)))
                }
                
            }
        }catch{
            print("falled json encode failed")
            handler(.failure(.unknown(error)))
        }
        
    }
    
    static func getClientForAgreement(client_id: String, client_name: String, handler: @escaping ResultHandler<AgreementRequestResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/clients/get_for_agreement"
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let jsonEncoder = JSONEncoder()
        var tmp: Data = Data()
        do{
            
            let param: Parameters = [
                "client_id": client_id,
                "client_name": client_name,
            ]
            
            
            let userDefaults = UserDefaults.standard
            guard let token = userDefaults.string(forKey: "authblue_api_token") else {
                print("cannot find token")
                userDefaults.set(false, forKey: "log_status")
                return
            }
            
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization":"Bearer \(token)"
                
            ]
            
            AF.request(urlString,
                       method:.post,
                       parameters: param,
                       encoding: JSONEncoding.default,
                       headers: headers
            ).responseJSON {response in
                if(response.response?.statusCode == 401){
                    print("falled 401")
                    userDefaults.set(false, forKey: "log_status")
                }
                guard let data = response.data else{
                    print("falled invalid response")
                    handler(.failure(.invalidResponse))
                    return
                }
                do{
                    let res = try JSONDecoder().decode(AgreementRequestResponseAPI.self, from: data)
                    handler(.success(res))
                } catch {
                    print("falled json decoder failed")
                    handler(.failure(.unknown(error)))
                }
                
            }
        }catch{
            print("falled json encode failed")
            handler(.failure(.unknown(error)))
        }
        
    }
    static func getClientForAgreementById(query_id: String, client_id: String, handler: @escaping ResultHandler<AgreementRequestResponseAPI>){
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "authblue_api_host") as! String
        let urlString = "\(apiHost)/clients/get_for_agreement_by_id"
        guard let url = URL(string: urlString) else{
            handler(.failure(.invalidURL))
            return
        }
        let jsonEncoder = JSONEncoder()
        var tmp: Data = Data()
        do{
            
            let param: Parameters = [
                "query_id": query_id,
                "client_id": client_id,
            ]
            
            
            let userDefaults = UserDefaults.standard
            guard let token = userDefaults.string(forKey: "authblue_api_token") else {
                print("cannot find token")
                userDefaults.set(false, forKey: "log_status")
                return
            }
            
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization":"Bearer \(token)"
                
            ]
            
            AF.request(urlString,
                       method:.post,
                       parameters: param,
                       encoding: JSONEncoding.default,
                       headers: headers
            ).responseJSON {response in
                if(response.response?.statusCode == 401){
                    print("falled 401")
                    userDefaults.set(false, forKey: "log_status")
                }
                guard let data = response.data else{
                    print("falled invalid response")
                    handler(.failure(.invalidResponse))
                    return
                }
                do{
                    let res = try JSONDecoder().decode(AgreementRequestResponseAPI.self, from: data)
                    handler(.success(res))
                } catch {
                    print("falled json decoder failed")
                    handler(.failure(.unknown(error)))
                }
                
            }
        }catch{
            print("falled json encode failed")
            handler(.failure(.unknown(error)))
        }
        
    }
}
