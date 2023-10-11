import SwiftUI

public struct AgreementDetailModalView: View {
    @Binding var isPresented: Bool
    let ref_id: String
    let client_name: String
    let user_name: String
    let date: String
    var methods: AgreementMethod
    let content: String
    var agreementModel: AgreementModel
    
    public var body: some View {
        
        NavigationStack{
            
            List{
                Section {
                    if(ref_id != ""){
                        HStack(){
                            Text("AgreementDetailModalRefIdLabel", bundle: .module)
                                .font(.subheadline)
                            Spacer()
                            Text(ref_id)
                                .font(.subheadline)
                        }
                    }
                    HStack(){
                        Text("AgreementDetailModalClientNameLabel", bundle: .module)
                            .font(.subheadline)
                        Spacer()
                        Text(client_name)
                            .font(.subheadline)
                    }
                    
                    HStack(){
                        Text("AgreementDetailModalUserNameLabel", bundle: .module)
                            .font(.subheadline)
                        Spacer()
                        Text(user_name)
                            .font(.subheadline)
                    }
                    if(date != ""){
                        HStack(){
                            Text("AgreementDetailModalDateLabel", bundle: .module)
                                .font(.subheadline)
                            Spacer()
                            Text(date)
                                .font(.subheadline)
                        }
                    }
                } header: {
                    Text("AgreementDetailModalHeaderBasic", bundle: .module)
                }
                
                Section {
                    if(methods.face_id){
                        HStack(){
                            Text("AgreementDetailModalAgreementMethodFaceIdLabel", bundle: .module)
                        }
                    }
                    if(methods.my_number_card){
                        HStack(){
                            Text("AgreementDetailModalAgreementMethodMncLabel", bundle: .module)
                        }
                    }
                    if(methods.signature){
                        HStack(){
                            Text("AgreementDetailModalAgreementMethodSignatureLabel", bundle: .module)
                        }
                    }
                    
                } header: {
                    Text("AgreementDetailModalHeaderAgreementMethod", bundle: .module)
                }
                
                Section {
                    
                    if(agreementModel.name){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoNameLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.birthday){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoBirthdayLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.age){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoAgeLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.sex){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoSexLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.address){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoAddressLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.email){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoEmailLabel", bundle: .module)
                        }
                    }
                    if(agreementModel.phone){
                        HStack(){
                            Text("AgreementDetailModalRequestingInfoPhoneLabel", bundle: .module)
                        }
                    }
                } header: {
                    Text("AgreementDetailModalHeaderRequestingInfo", bundle: .module)
                }
                
                Section {
                    Text(content)
                        .font(.subheadline)
                } header: {
                    Text("AgreementDetailModalHeaderContent", bundle: .module)
                }
            }
            .navigationTitle(String(localized: "AgreementDetailModalTitle", bundle: .module))
        }
    }
}
