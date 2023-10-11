import Foundation

enum AuthMethod: String{
    case faceid = "faceid"
    case mnc = "creditcard"
    case signature = "signature"
}

enum AuthMethodState: String{
    case yet = "-1"
    case current = "85e0f9"
    case done = "63e369"
}

func authMethodListToAgreementMethods(authModelList: [AuthMethod]) -> AgreementMethod{
    var res: AgreementMethod = AgreementMethod(face_id: false, my_number_card: false, signature: false)
    
    authModelList.forEach{el in
        if(el == .faceid){
            res.face_id = true
        }else if(el == .mnc){
            res.my_number_card = true
        }else if(el == .signature){
            res.signature = true
        }
    }
    
    return res
}

func agreementMethodsToAuthMethodList(agreement_method: AgreementMethod) -> [AuthMethod]{
    var res: [AuthMethod] = []
    if(agreement_method.face_id){
        res.append(AuthMethod.faceid)
    }
    if(agreement_method.my_number_card){
        res.append(AuthMethod.mnc)
    }
    if(agreement_method.signature){
        res.append(AuthMethod.signature)
    }
    return res
    
}

