import SwiftUI

public struct AgreementRow: View {
    @State var flag = true
    
    var title: String = "Name"
    var imageName: String = "tag"
    
    public var body: some View {
        HStack(alignment: .center){
            Toggle(isOn: $flag) {
                
                HStack(alignment: .center){
                    Image(systemName: imageName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(title)
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
            .padding()
            
        }
    }
}

struct AgreementRow_Previews: PreviewProvider {
    static var previews: some View {
        AgreementRow()
    }
}
