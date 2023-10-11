
import SwiftUI

public struct TutorialRequest: View {
    public var handler: ((Bool) -> Void)
    
    public init(handler: @escaping ((Bool) -> Void)){
        self.handler = handler
    }
    // MARK: AppStorage
    @AppStorage("authblue_mnc_register_status") var mncRegisterStatus: Bool = true
    
    @AppStorage("authblue_personal_name") var personalName: String = ""
    @AppStorage("authblue_personal_birthday") var personalBirthday: String = ""
    @AppStorage("authblue_personal_age") var personalAge: String = ""
    @AppStorage("authblue_personal_sex") var personalSex: String = ""
    @AppStorage("authblue_personal_address") var personalAddress: String = ""
    @AppStorage("authblue_personal_phone") var personalPhone: String = ""
    @AppStorage("authblue_personal_email") var personalEmail: String = ""
    
    @AppStorage("authblue_dynamic_link_status") var dynamicLinkStatus: Bool = false
    @AppStorage("authblue_dynamic_link_client_id") var dynamicLinkClientId: String = ""
    @AppStorage("authblue_dynamic_link_client_name") var dynamicLinkClientName: String = ""
    
    @AppStorage("authblue_tutorial_finished") var tutorialFinished: Bool = false
    
    
    // MARK: Transition
    @State private var willMoveToHomeScreen = false
    @State private var goToAgreementSteps = false
    @State private var goToAgreementSent = false
    @State private var showModal = false
    
    @State var clientName: String = ""
    @State var clientId: String = ""
    @State var agreementMethods: [AuthMethod] = []
    @State var content: String = ""
    @State var requestingInfo: AgreementModel = .init(name: false, birthday: false, age: false, picture: false, sex: false, address: false, phone: false, email: false)
    
    @State var isUserDataNotReadyForAgreement = false
    @State var isUserCertificateNotReadyForAgreement = false
    @State var isAlertOpen = false
    @State var missingInfoForAgreement: [String] = []
    
    @State var isGoToStepsAvailable = false
    
    /// Animation Properties
    @State private var showView: Bool = false
    @State private var hideWholeView: Bool = false
    
    @State private var showViewSteps: Bool = false
    @State private var hideWholeViewSteps: Bool = false
    
    @State private var hideViewSent: Bool = false
    
    var size: CGSize = .init()
    
    func requestAppStorageSet(){
//        dynamicLinkClientId = Bundle.main.object(forInfoDictionaryKey: "tutorial_client_id") as! String
//        dynamicLinkClientName = Bundle.main.object(forInfoDictionaryKey: "tutorial_client_name") as! String
        dynamicLinkClientId = "testid"
       dynamicLinkClientName = "AUTHBLUEチュートリアル"

    }
    
    
    func deleteAppStorageForDynamicLink(){
        dynamicLinkStatus = false
        dynamicLinkClientName = ""
        dynamicLinkClientId = ""

    }
    
    func checkIfMncCertificateSubmittedIfRequired(){
        isUserCertificateNotReadyForAgreement = false
        let tmp = authMethodListToAgreementMethods(authModelList: agreementMethods)
        if(tmp.my_number_card){
            if(!mncRegisterStatus){
                isUserCertificateNotReadyForAgreement = true
            }
        }
        
    }
    
    func checkIfAppStorageHasEnoughData(){
        missingInfoForAgreement = []
        isUserDataNotReadyForAgreement = false
        if(requestingInfo.name){
            if(personalName==""){
                missingInfoForAgreement.append("name")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.birthday){
            if(personalBirthday==""){
                missingInfoForAgreement.append("birthday")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.age){
            if(personalAge==""){
                missingInfoForAgreement.append("age")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.sex){
            if(personalSex==""){
                missingInfoForAgreement.append("sex")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.address){
            if(personalAddress==""){
                missingInfoForAgreement.append("address")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.phone){
            if(personalPhone==""){
                missingInfoForAgreement.append("phone")
                isUserDataNotReadyForAgreement = true
            }
        }
        if(requestingInfo.email){
            if(personalEmail==""){
                missingInfoForAgreement.append("email")
                isUserDataNotReadyForAgreement = true

            }
        }
        
    }
    
    
    public var body: some View {
        if(goToAgreementSteps){
            GeometryReader{
                let size = $0.size
                VStack(alignment: .leading, spacing: 10){
                    Spacer(minLength: 20)
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("同意を\n実行しましょう")
                            .font(.system(size: 40))
                            .fontWeight(.black)
                        
                        Text("以下のステップに従って送信してください。")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                    }
                    .padding(.leading, 10)
                    .offset(y: showViewSteps ? 0 : size.height/2)
                    .opacity(showViewSteps ? 1 : 0)
                    
                    
                    AgreementSteps(
                        clientId: clientId,
                        methods: agreementMethods,
                        agreementModel: requestingInfo,
                        goToAgreementSteps: $goToAgreementSteps,
                        goToAgreementSent: $goToAgreementSent
                    )
                        .offset(y: showViewSteps ? 0 : size.height/2)
                        .opacity(showViewSteps ? 1 : 0)

                    
                }
                // Back Button
                .overlay(alignment: .topTrailing){
                    Button(action: {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)){
                            hideWholeViewSteps = true

                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            deleteAppStorageForDynamicLink()
                        }
                    }){
                        Text("DeepLinkAgreementCancel", bundle: .module)
                            .fontWeight(.semibold)
                            .frame(width: 120, height: 32)
                            .foregroundColor(Color(.white))
                            .background(Color(hex: "c7c7cc"))
                            .cornerRadius(18)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                }
                .offset(y: hideWholeViewSteps ? size.height/2 : 0)
                .opacity(hideWholeViewSteps ? 0 : 1)

            }
        }else if (goToAgreementSent){
            GeometryReader{
                let size = $0.size
                AgreementSent(handler: handler, size: size, hideViewSent: $hideViewSent)
            }
        }else if(willMoveToHomeScreen){
            Text("this is home")
        }else{
            GeometryReader{
                let size = $0.size
                VStack{
                    
                    GeometryReader{
                        let size = $0.size
                        
                        VStack{
                            
                            HStack{
                                Spacer(minLength: 0)
                                
                                Image("handshake", bundle: .module)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: size.width*0.6, height: size.width*0.6, alignment: .center)
                                    .padding(10)
                                Spacer(minLength: 0)
                            }
                            .offset(y: showView ? 0 : -size.height/2)
                            .opacity(showView ? 1 : 0)
                            .padding(.top, 10)
                            
                            
                            
                            VStack(alignment: .leading, spacing: 10){
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Text("DeepLinkAgreementRequestTitle", bundle: .module)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("DeepLinkAgreementRequestSubTitle", bundle: .module)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                                .padding(.leading, 15)
                                
                                
                                if(tutorialFinished){
                                    AgreementRequestCard(client_name: clientName, user_name: personalName, agreementMethods: agreementMethods, content: content, requestingInfo: requestingInfo)
                                        .padding()
                                        .onTapGesture {
                                            showModal = true
                                        }
                                }else{
                                    AgreementRequestCard(client_name: clientName, user_name: "あなた", agreementMethods: agreementMethods, content: content, requestingInfo: requestingInfo)
                                        .padding()
                                        .onTapGesture {
                                            showModal = true
                                        }
                                    
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    checkIfMncCertificateSubmittedIfRequired()
                                    checkIfAppStorageHasEnoughData()
                                    print("\n\nhere====")
                                    print(isUserDataNotReadyForAgreement)
                                    print(isUserCertificateNotReadyForAgreement)
                                    if(!isUserDataNotReadyForAgreement && !isUserCertificateNotReadyForAgreement){
                                        print("if1")
                                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)){
                                            hideWholeView = true
                                            
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                            goToAgreementSteps = true

                                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)){
                                                showViewSteps = true
                                            }
                                            hideWholeView = false
                                            showView = false
                                            
                                        }
                                    }else{
                                        print("if2")
                                        isAlertOpen = true
                                    }
                                }) {
                                    Text("DeepLinkAgreementToStepButton", bundle: .module)
                                        .fontWeight(.semibold)
                                        .contentTransition(.identity)
                                        .foregroundColor(.white)
                                        .frame(width: size.width*0.4)
                                        .padding(.vertical, 15)
                                        .background{
                                            Capsule()
                                                .fill(.black)
                                        }
                                }
                                .disabled(!isGoToStepsAvailable)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 10)
                                .opacity(isGoToStepsAvailable ? 1 : 0.2)
                            }
                            /// Moving Down
                            .offset(y: showView ? 0 : size.height/2)
                            .frame(maxWidth: .infinity)
                            .opacity(showView ? 1 : 0)
                        }
                        
                        
                        
                    }
                    .alert(isPresented: $isAlertOpen) {
                        if(isUserDataNotReadyForAgreement){
                            return Alert(title: Text("AgreementRequestUserDataNotReadyAlertTitle", bundle: .module),
                                         message: Text("AgreementRequestUserDataNotReadyAlertDescription", bundle: .module),
                                         primaryButton: .default(Text("AgreementRequestUserDataNotReadyAlertPrimaryButtonLabel", bundle: .module)) {
                                // Perform the action when the user taps "Yes"
                                print("Button tapped!")
                                isAlertOpen = false
                                
                            },
                                         secondaryButton: .cancel(Text("AgreementRequestUserDataNotReadyAlertSecondaryButtonLabel", bundle: .module)))
                            
                        }else{
                            return Alert(title: Text("AgreementRequestUserCertificateNotReadyAlertTitle", bundle: .module),
                                         message: Text("AgreementRequestUserCertificateNotReadyAlertDescription", bundle: .module),
                                         primaryButton: .default(Text("AgreementRequestUserCertificateNotReadyAlertPrimaryButtonLabel", bundle: .module)) {
                                // Perform the action when the user taps "Yes"
                                print("Button tapped!")
                                isAlertOpen = false
                                
                            },
                                         secondaryButton: .cancel(Text("AgreementRequestUserCertificateNotReadyAlertSecondaryButtonLabel", bundle: .module)))
                        }
                    }
                }
                .offset(y: hideWholeView ? size.height/2 : 0)
                .opacity(hideWholeView ? 0 : 1)

            }
            .onChange(of: goToAgreementSent) { newValue in
                print("Name changed to \(goToAgreementSent)!")
            }
            
            
            .sheet(isPresented: $showModal) {
                AgreementDetailModalView(
                    isPresented: $showModal,
                    ref_id: "",
                    client_name: clientName,
                    user_name: personalName,
                    date: "",
                    methods: authMethodListToAgreementMethods(authModelList: agreementMethods),
                    content: content,
                    agreementModel: requestingInfo
                )
            }
            // Back Button
            .overlay(alignment: .topTrailing){
                Button(action: {
                    deleteAppStorageForDynamicLink()
                    willMoveToHomeScreen = true
                    goToAgreementSent = false
                    goToAgreementSteps = false
                }){
                    Text("DeepLinkAgreementCancel", bundle: .module)
                        .fontWeight(.semibold)
                        .frame(width: 120, height: 32)
                        .foregroundColor(Color(.white))
                        .background(Color(hex: "c7c7cc"))
                        .cornerRadius(18)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
            }
            
            .onAppear(perform: {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)){
                    showView = true
                }
                
                requestAppStorageSet()
                
                
                APIClient.getTutorialClient(){ result in
                    switch result{
                    case .success(let data):
                        if let res_client_id = data.result?.client_id{
                            clientId = res_client_id
                        }
                        
                        if let res_client_name = data.result?.client_name{
                            clientName = res_client_name
                        }
                        
                        if let res_content = data.result?.content.agreement{
                            content = res_content
                        }
                        
                        if let res_agreement_method = data.result?.agreement_method{
                            let tmp = agreementMethodsToAuthMethodList(agreement_method: res_agreement_method)
                            agreementMethods = tmp
                        }
                        
                        if let res_requesting_info = data.result?.requesting_info{
                            requestingInfo = res_requesting_info
                        }
                        
                        isGoToStepsAvailable = true
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                }
                
            })
            
        }
        
    }
    
}

