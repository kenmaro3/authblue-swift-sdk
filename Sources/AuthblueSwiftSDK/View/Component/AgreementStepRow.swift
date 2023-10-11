import SwiftUI

public struct AgreementStepRow: View {
    var index: Int
    var method: AuthMethod
    var state: AuthMethodState
    
    public var body: some View {
        HStack(alignment: .center) {
            
            switch method{
            case .faceid:
                CircleSystemImage(hex: state.rawValue, isStroke: state == .done ? false : true, image:Image(systemName: "faceid"))
//            case .fingerprint:
//                CircleSystemImage(hex: state.rawValue, isStroke: state == .done ? false : true, image:Image(systemName: "hand.tap"))
            case .mnc:
                CircleSystemImage(hex: state.rawValue, isStroke: state == .done ? false : true, image:Image(systemName: "creditcard"))
            case .signature:
                CircleSystemImage(hex: state.rawValue, isStroke: state == .done ? false : true, image:Image(systemName: "signature"))
            }
            
            VStack(alignment: .leading){
                Text("DeepLinkAgreementStepRowStepTitle \(index)", bundle: .module)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                switch method{
                case .faceid:
                    Text("AgreementMethodFaceID", bundle: .module)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
//                case .fingerprint:
//                    Text("AgreementMethodFingerPrint")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .padding(.top, 4)
                case .mnc:
                    Text("AgreementMethodMyNumberCard", bundle: .module)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                case .signature:
                    Text("AgreementMethodSignature", bundle: .module)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                }
                
            }
            .padding()
        }
        .padding()
    }
}

struct AgreementStepRow_Previews: PreviewProvider {
    static var previews: some View {
        var index: Int = 1
        var method: AuthMethod = AuthMethod.faceid
        var state: AuthMethodState = AuthMethodState.yet
        AgreementStepRow(index: index, method: method, state: state)
    }
}
