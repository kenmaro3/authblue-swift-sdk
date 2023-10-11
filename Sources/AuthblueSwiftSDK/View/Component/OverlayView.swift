import SwiftUI

public struct OverlayView: View {
    var content: String
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack{
                Text(content)
                    .foregroundColor(.white)
                    .font(.title3)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding(.top, 24)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        var content = "同意を送信しています。"
        OverlayView(content: content)
    }
}
