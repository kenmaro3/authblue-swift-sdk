import SwiftUI

public struct CircleSystemImage: View {
    var hex: String
    var isStroke: Bool
    var image: Image
    public var body: some View {
        ZStack{
            image
                .resizable()
                .frame(width: 32, height: 32)
                .scaledToFit()
                .padding(16)
                .zIndex(1)
            Circle()
                .strokeBorder(isStroke ? .gray : .clear, lineWidth: 2)
                .background(Circle().fill(hex != "-1" ? Color(hex: hex)! : .clear))
                .frame(width: 64, height: 64)
            
            
        }
        
//            .overlay{
//            }
//            .shadow(radius: 2)
            
    }
}

struct CircleSystemImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleSystemImage(hex: "aaaaaa", isStroke: true, image: Image(systemName: "faceid"))
    }
}
