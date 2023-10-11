import SwiftUI

public struct AgreementStepLine: View {
    var isDone: Bool
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 50, height: 8)
            .rotationEffect(.degrees(90))
            .foregroundColor(isDone ? Color(hex: "63e369") : Color(hex: "dedede"))
    }
}

struct AgreementStepLine_Previews: PreviewProvider {
    static var previews: some View {
        AgreementStepLine(isDone: true)
    }
}
