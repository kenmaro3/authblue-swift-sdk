//
//  AgreementRequestCard.swift
//  authblue
//
//  Created by Kentaro Mihara on 2023/04/24.
//

import SwiftUI
import Foundation

enum UserInfoIconEnum : String{
    case name = "tag"
    case birthday = "gift"
    //let age: String
    //let picture: String
    case sex = "person.and.arrow.left.and.arrow.right"
    case address = "house"
    case phone = "phone"
    case email = "envelope"
}


public struct AgreementRequestCard: View {
    let client_name: String
    let user_name: String
    var agreementMethods: [AuthMethod]
    let content: String
    var requestingInfo: AgreementModel
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top){
                
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading) {
                        Text("AgreementRequestCardFromTitle", bundle: .module)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(client_name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("AgreementRequestCardToTitle", bundle: .module)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(user_name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 1)
                    }
                    .padding(.top, 4)
                }
                
                
                Spacer()
                
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        Text("AgreementRequestCardAgreementMethodTitle", bundle: .module)
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack{
                            ForEach(agreementMethods, id: \.self){method in
                                Image(systemName: method.rawValue)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.top, 4)
                    
                    VStack(alignment: .leading){
                        Text("AgreementRequestCardRequestingInfoTitle", bundle: .module)
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack{
                            if(requestingInfo.name){
                                Image(systemName: UserInfoIconEnum.name.rawValue)
                            }
                            if(requestingInfo.birthday){
                                Image(systemName: UserInfoIconEnum.birthday.rawValue)
                            }
                            if(requestingInfo.sex){
                                Image(systemName: UserInfoIconEnum.sex.rawValue)
                            }
                            if(requestingInfo.address){
                                Image(systemName: UserInfoIconEnum.address.rawValue)
                            }
                            if(requestingInfo.phone){
                                Image(systemName: UserInfoIconEnum.phone.rawValue)
                            }
                            if(requestingInfo.email){
                                Image(systemName: UserInfoIconEnum.email.rawValue)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.top, 6)
                }
                .padding(.leading, 10)
            }
            
            VStack(alignment: .leading){
                Text("AgreementRequestCardContentTitle", bundle: .module)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(content)
                    .font(.caption2)
                    .foregroundColor(.black)
                    .padding(.top, 2)
            }
            .padding(.top, 10)
            
            HStack{
                VStack(alignment: .leading){
                    Text("AgreementRequestCardDateTitle", bundle: .module)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(DateUtils.getNow())
                        .font(.caption2)
                        .foregroundColor(.black)
                        .padding(.top, 1)
                }
                Spacer()
//                VStack(alignment: .leading){
//                    Text("Ref Code")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Text("PH348F43YEKG")
//                        .font(.caption2)
//                        .foregroundColor(.black)
//                }
            }
            .padding(.top, 10)
        }
        
        .padding()
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .background(.white)
        .cornerRadius(20)
        .clipped()
        .shadow(color: .gray.opacity(0.7), radius: 5)
    }
}

struct AgreementRequestCard_Previews: PreviewProvider {
    static var previews: some View {
        let client_name: String = "TikTok"
        let user_name: String = "Taro Tanaka"
        var methods: [AuthMethod] = [AuthMethod.faceid, AuthMethod.mnc, AuthMethod.signature]
        let content: String = "Transfer your activity log to Facebook for service improvement"
        let agreementModel: AgreementModel = AgreementModel(name: false, birthday: true, age: true, picture: false, sex: true, address: false, phone: false, email: false)
        AgreementRequestCard(
        client_name: client_name, user_name: user_name, agreementMethods: methods, content: content, requestingInfo: agreementModel
        )
    }
}
