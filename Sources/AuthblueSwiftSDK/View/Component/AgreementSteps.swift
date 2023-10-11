
import SwiftUI
import LocalAuthentication
import SwiftUIDigitalSignature
import SwiftASN1
import ASN1Decoder
import TRETJapanNFCReader_MIFARE_IndividualNumber

public struct AgreementSteps: View, IndividualNumberReaderSessionDelegate {
//struct AgreementSteps: View{
    public func individualNumberReaderSession(didRead individualNumberCardData: TRETJapanNFCReader_MIFARE_IndividualNumber.IndividualNumberCardData) {
        print("individualNumberReaderSession")
        print(individualNumberCardData)
        guard let signature = individualNumberCardData.signature?.base64EncodedString() else{
            print("fell to signature guard let")
            return
        }
        
        digitalSignatureString = signature
        methodsStates[index] = .done
        incrementIndexThenCheckIfDone()
        print("mncGroup: notified end: \(index)")
        isBlock = false

        

    }

    public func japanNFCReaderSession(didInvalidateWithError error: Error) {
        print("japanNFCReaderSession")
        print(error)
    }
    
    // MARK: AppStorage
    @AppStorage("authblue_personal_name") var personalName: String = ""
    @AppStorage("authblue_personal_birthday") var personalBirthday: String = ""
    @AppStorage("authblue_personal_age") var personalAge: String = ""
    @AppStorage("authblue_personal_sex") var personalSex: String = ""
    @AppStorage("authblue_personal_address") var personalAddress: String = ""
    @AppStorage("authblue_personal_phone") var personalPhone: String = ""
    @AppStorage("authblue_personal_email") var personalEmail: String = ""
    
    @AppStorage("authblue_dynamic_link_status") var dynamicLinkStatus: Bool = false
    @AppStorage("authblue_dynamic_link_query_id") var dynamicLinkQueryId: String = ""
    @AppStorage("authblue_dynamic_link_client_id") var dynamicLinkClientId: String = ""
    @AppStorage("authblue_dynamic_link_client_name") var dynamicLinkClientName: String = ""
    @AppStorage("authblue_dynamic_link_uid") var dynamicLinkUid: String = ""
    
    
    
    @State var reader: IndividualNumberReader!
    
    var clientId: String
    var methods: [AuthMethod]
    var agreementModel: AgreementModel
    @State var methodsStates: [AuthMethodState] = []
    @State var index: Int = 0
    @State var isShowSignature: Bool = false
    @State var isShowPinField: Bool = false
    @State private var signatureImage: UIImage? = nil
    @State var digitalSignatureString: String? = nil
    
    @State private var nonce_string_sha1: String = ""
    @State private var nonce_string: String = ""
    @State private var pin: String = ""
    
    
    @State var isAuthenticationCompleted: Bool = false
    
    @State var isShowAlert: Bool = false
    @State var alertType: String = ""
    
    @State private var isBlock: Bool = false
    
    @State private var isOverlayVisible = false
    @Binding private var goToAgreementSent: Bool
    @Binding private var goToAgreementSteps: Bool
    @State private var willMoveToHomeScreen = false
    
    
    let faceIdGroup = DispatchGroup()
    let mncGroup = DispatchGroup()
    let signatureGroup = DispatchGroup()
    let mncPinGroup = DispatchGroup()
    
    let submissionGroup = DispatchGroup()
    
    func deleteAppStorageForDynamicLink(){
        dynamicLinkStatus = false
        dynamicLinkQueryId = ""
        dynamicLinkClientId = ""
        dynamicLinkClientName = ""
    }
    
    
    init(clientId: String, methods: [AuthMethod], agreementModel: AgreementModel, goToAgreementSteps: Binding<Bool>, goToAgreementSent: Binding<Bool>){
        self.clientId = clientId
        self.methods = methods
        self.agreementModel = agreementModel
        self._goToAgreementSent = goToAgreementSent
        self._goToAgreementSteps = goToAgreementSteps
        var tmp: [AuthMethodState] = []
        methods.enumerated().forEach{index, el in
            if(index==0){
                tmp.append(.current)
            }else{
                tmp.append(.yet)
            }
        }
        _methodsStates = State(initialValue: tmp ?? [])
        print(methodsStates)
    }
    
    func checkIfUserHasCertificate(callback: @escaping () -> Void){
        APIClient.requestCertificateExists{result in
            switch result{
            case .success(let data):
                print("fell success")
                guard let exists = data.result?.exists else{
                    print("falled to guard else")
                    return
                }
                print(exists)
                callback()
            case .failure(let error):
                print("fell failure")
                print(error)
                
            }
        }
        
    }
    
    func getNonceAndComputeSignature(){
        
        APIClient.requestNonceFastAPI(){result in
            switch result{
            case .success(let data):
                guard let nonce = data.result?.nonce else{
                    return
                }
                let tmp = Data(base64Encoded: nonce)
                let tmp2 = String(data: tmp ?? Data(), encoding: .utf8)!
                self.nonce_string = tmp2.sha1
                self.reader.signature(nonce_string_sha1: self.nonce_string, signaturePIN: pin)
            case .failure(let error):
                print(error)
                
            }
        }
   
    }
    
    func getUserInfoModelBasedOnAgreementModel() -> UserInfoModel{
        var res = UserInfoModel()
        if(agreementModel.name){
            res.name = personalName
        }
        if(agreementModel.birthday){
            res.birthday = personalBirthday
        }
        if(agreementModel.age){
            res.age = personalAge
        }
        if(agreementModel.sex){
            res.sex = personalSex
        }
        if(agreementModel.address){
            res.address = personalAddress
        }
        if(agreementModel.phone){
            res.phone = personalPhone
        }
        if(agreementModel.email){
            res.email = personalEmail
        }
        
        return res
    }
    
    
    func handleSubmission(){
        isOverlayVisible = true
        var signatureToSend: String? = nil
        
        let userInfoModel = getUserInfoModelBasedOnAgreementModel()
        
        if let signatureImage = signatureImage{
            if let base64String = imageToBase64(image: signatureImage){
                signatureToSend = base64String
            }else{
                print("Failed to convert image to base64")
                isOverlayVisible = false
                return
            }
        }
        
        APIClient.authAgreementWithQRRequest(clientId: clientId, signature: signatureToSend, digitalSignature: digitalSignatureString, userInfoModel: userInfoModel, uid: dynamicLinkUid, handler: {res in
            print("handle submission2")
            print(res)
            isOverlayVisible = false
            switch(res){
            case .success(let result):
                if(!result.has_error){
                    print("here goToAgreementSent true!!!!")
                    self.goToAgreementSteps = false
                    self.goToAgreementSent = true
                    print(self.goToAgreementSent)
                    
                }else{
                    isShowAlert = true
                    alertType = "agreement_send_failed"
                }
            case .failure(let error):
                print("failed")
                
            }
            isOverlayVisible = false
        })
        
    }
    
    func checkIfMncIncluded() -> Bool{
        var res = false
        methods.forEach{el in
            if el == .mnc{
                res = true
            }
        }
        return res
    }
    
    
    public var body: some View {
        VStack(alignment: .center){
            VStack(alignment: .leading){
                ForEach(Array(methods.enumerated()), id: \.element) { index, method in
                    if(index != methods.count-1){
                        AgreementStepRow(index: index+1, method: method, state: methodsStates[index])
                        AgreementStepLine(isDone: methodsStates[index] == .done ? true : false)
                            .padding()
                            .padding(.leading, 8)
                    }else{
                        AgreementStepRow(index: index+1, method: method, state: methodsStates[index])
                    }
                }
            }
            if isAuthenticationCompleted {
                Button(action: {
                    // Button action code here
                    print("submit")
                    handleSubmission()
                }) {
                    HStack(spacing: 15){
                        Text("DeepLinkAgreementStepsSubmitLabel", bundle: .module)
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                            .foregroundColor(.white)
                        
                        Image(systemName: "line.diagonal.arrow")
                            .font(.title3)
                            .foregroundColor(.white)
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 18)
                    .background{
                        Capsule()
                            .fill(.black)
                    }
                    
                    
                }
                .padding(.top, 30)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: index) {newValue in
            print("called index onChange: \(newValue)")
            if(newValue == methods.count){
                isAuthenticationCompleted = true
            }else{
                authenticateMain()
                
            }
            
            
        }
        .alert(isPresented: $isShowAlert) {
            //                if(alertType == "pin"){
            //                    return Alert(
            //                    title: Text("DeepLinkAgreementStepsInvalidPinTitle"),
            //                    message: Text("DeepLinkAgreementStepsInvalidPinMessage"),
            //                    dismissButton: .default(Text("DeepLinkAgreementStepsInvalidPinDismissButton")))
            //
            //                }else if(alertType == "no_certificate"){
            //                    return Alert(
            //                    title: Text("DeepLinkAgreementStepsNoCertificateFoundTitle"),
            //                    message: Text("DeepLinkAgreementStepsNoCertificateFoundMessage"),
            //                    dismissButton: .default(Text("DeepLinkAgreementStepsNoCertificateFoundButton")))
            
            //                }
            if(alertType == "agreement_send_failed"){
                return Alert(
                    title: Text("DeepLinkAgreementStepsAgreementFailedTitle", bundle: .module),
                    message: Text("DeepLinkAgreementStepsAgreementFailedMessage", bundle: .module),
                    dismissButton: .default(Text("DeepLinkAgreementStepsAgreementFailedButton", bundle: .module)))
                
            }else{
                return Alert(
                    title: Text("DeepLinkAgreementStepsUnknownAlertTitle", bundle: .module),
                    message: Text("DeepLinkAgreementStepsUnknownAlertMessage", bundle: .module),
                    dismissButton: .default(Text("DeepLinkAgreementStepsUnknownAlertButton", bundle: .module)))
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .onAppear{
            reader = IndividualNumberReader(delegate: self)
            Task.detached { @MainActor in
                print("will start on appear main")
                authenticateMain()
            }
        }
        .sheet(isPresented: $isShowSignature) {
            SignatureView(availableTabs: [.draw, .type],
                          onSave: { image in
                
                self.signatureImage = image
                self.methodsStates[index] = .done
                if(index < methodsStates.count-1){
                    self.methodsStates[index+1] = .current
                }
                self.incrementIndexThenCheckIfDone()
                self.isShowSignature = false
                
                //                signatureGroup.leave()
                
            }, onCancel: {
                
            })
            .frame(height: UIScreen.main.bounds.height / 2)
        }
        .sheet(isPresented: $isShowPinField) {
            PasscodeField(description: String(localized: "PasscodeFieldDescriptionForSignature", bundle: .module)){ value in
                print("from PasscodeField, value: \(value)")
                pin = value
                return
            }
        }
        .overlay(
            OverlayView(content: String(localized: "OverlayViewSendingAgreementLabel", bundle: .module))
                .opacity(isOverlayVisible ? 1 : 0) // Control the visibility of the overlay
        )
        .onChange(of: isShowPinField, perform: {newValue in
            if(!newValue){
                if(pin.count == 4){
                    
//                    mncGroup.enter()
                    
                    print("here1")
                    checkIfUserHasCertificate {
                        print("pin valid")
                        getNonceAndComputeSignature()
                    }
                    print("here2")
                    
//                    mncGroup.notify(queue: .global()) {
//                        print("mncGroup: notified")
//                        methodsStates[index] = .done
//                        incrementIndexThenCheckIfDone()
//                        print("mncGroup: notified end: \(index)")
//                        isBlock = false
//                    }
                }
       
            }
            
        })
//        .onChange(of: isShowPinField){
//            if(!isShowPinField){
//                if(pin.count == 4){
//
//                    mncGroup.enter()
//
//                    print("here1")
//                    checkIfUserHasCertificate {
//                        print("pin valid")
//                        getNonceAndComputeSignature()
//                    }
//                    print("here2")
//
//                    mncGroup.notify(queue: .global()) {
//                        print("mncGroup: notified")
//                        methodsStates[index] = .done
//                        incrementIndexThenCheckIfDone()
//                        print("mncGroup: notified end: \(index)")
//                        isBlock = false
//                    }
//                }
//            }
//
//        }
        
    }
    
    func authenticateMain(){
        Task{
            try await Task.sleep(for: .seconds(1))
            await MainActor.run{
                print("called main: \(index)")
                switch methods[index]{
                case .faceid:
                    print("enter authenticateFaceId")
                    authenticateFaceId()
                case .signature:
                    print("enter authenticateSignature")
                    authenticateSignature()
//                case .fingerprint:
//                    print("enter fingerprint")
//                    authenticateFaceId()
                case .mnc:
                    print("enter authenticateMnc")
                    authenticateMnc()
                }
               
            }
        }
        
    }
    
    func authenticateMnc(){
        isBlock = true
        if(pin.count == 4){
            isShowPinField = false
        }else{
            isShowPinField = true
        }
    }
    
    func incrementIndexThenCheckIfDone(){
        index += 1
        print("incrementIndexThenCheckIfDone")
        print(index)
        
        if(index == methods.count){
            print("ready for submission")
            isAuthenticationCompleted = true
        }
    }
    
    func authenticateSignature(){
//        isBlock = true
//        signatureGroup.enter()

        isShowSignature = true
        
//        signatureGroup.notify(queue: .global()) {
//            print("signatureGroup: notified")
//            isBlock = false
//        }
    }
    
    func authenticateFaceId() {
        isBlock = true
        faceIdGroup.enter()
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the app"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    print("success so increment index")
                    methodsStates[index] = .done
                    if(index < methodsStates.count-1){
                        methodsStates[index+1] = .current
                    }
                } else {
                    // Handle authentication failure
                    print("Authentication failed")
                }
                faceIdGroup.leave()
            }
        } else {
            // Device does not support Face ID or Touch ID
            print("Biometric authentication unavailable")
            faceIdGroup.leave()
        }
        
        faceIdGroup.notify(queue: .global()) {
            print("faceIdGroup: notified, index: \(index)")
            incrementIndexThenCheckIfDone()
            isBlock = false
        }
        
    }
    
}

//struct AgreementSteps_Previews: PreviewProvider {
//    static var previews: some View {
//        let clientId: String = "SBPpoJN7a2Pwzfi2q3vKDJQU"
//        let methods =  [AuthMethod.faceid, AuthMethod.mnc, AuthMethod.signature]
//        let methodsStates = [AuthMethodState.done, AuthMethodState.current, AuthMethodState.yet]
//        let agreementModel: AgreementModel = AgreementModel(name: false, birthday: true, age: true, picture: false, sex: true, address: false, phone: false, email: false)
//        AgreementSteps(clientId: clientId, methods: methods, agreementModel: agreementModel)
//    }
//}
