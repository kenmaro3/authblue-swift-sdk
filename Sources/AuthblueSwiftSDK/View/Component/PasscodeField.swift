import SwiftUI

public struct PasscodeField: View {
    
    var description: String
    var maxDigits: Int = 4
    
    @State var pin: String = ""
    @State var showPin = false
    @State var isDisabled = false
    
    @State var isBlock = false
    
    
    //var handler: (String, @escaping (Bool) -> Void) -> Void
    var handler: (String) -> Void
    
    public var body: some View {
        VStack(spacing: 40) {
            Text(description)
                .padding()
            Text("PasscodeFieldLabel", bundle: .module).font(.callout)
                .padding()
            ZStack {
                pinDots
                backgroundField
            }
            .padding()
            showPinStack
        }
        .padding()

        
    }
    
    private var pinDots: some View {
        HStack {
            Spacer()
            ForEach(0..<maxDigits) { index in
                Image(systemName: self.getImageName(at: index))
                    .font(.system(size: 24, weight: .thin, design: .default))
                Spacer()
            }
        }
    }
    
    private var backgroundField: some View {
        let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
            self.pin = newValue
            print("calling submitPin")
            self.submitPin()
        })
        
        return TextField("", text: boundPin, onCommit: submitPin)
      
      // Introspect library can used to make the textField become first resonder on appearing
      // if you decide to add the pod 'Introspect' and import it, comment #50 to #53 and uncomment #55 to #61
      
           .accentColor(.clear)
           .foregroundColor(.clear)
           .keyboardType(.numberPad)
           .disabled(isDisabled)
      
//             .introspectTextField { textField in
//                 textField.tintColor = .clear
//                 textField.textColor = .clear
//                 textField.keyboardType = .numberPad
//                 textField.becomeFirstResponder()
//                 textField.isEnabled = !self.isDisabled
//         }
    }
    
    private var showPinStack: some View {
        HStack {
            Spacer()
            if !pin.isEmpty {
                showPinButton
            }
        }
        .frame(height: 20)
        .padding([.trailing])
    }
    
    private var showPinButton: some View {
        Button(action: {
            self.showPin.toggle()
        }, label: {
            self.showPin ?
                Image(systemName: "eye.slash.fill").foregroundColor(.primary) :
                Image(systemName: "eye.fill").foregroundColor(.primary)
        })
    }
    
    private func submitPin() {
        guard !pin.isEmpty else {
            showPin = false
            return
        }
        
        if pin.count == maxDigits {
            isDisabled = true
            
//            handler(pin) { isSuccess in
//                if isSuccess {
//                    print("pin matched, go to next page, no action to perfrom here")
//                } else {
//                    pin = ""
//                    isDisabled = false
//                    print("this has to called after showing toast why is the failure")
//                }
//            }
            
            if(!isBlock){
                print("from inside")
                handler(pin)
                isBlock = true
       
            }
        }
        
        // this code is never reached under  normal circumstances. If the user pastes a text with count higher than the
        // max digits, we remove the additional characters and make a recursive call.
        if pin.count > maxDigits {
            pin = String(pin.prefix(maxDigits))
            submitPin()
        }
    }
    
    private func getImageName(at index: Int) -> String {
        if index >= self.pin.count {
            return "circle"
        }
        
        if self.showPin {
            return self.pin.digits[index].numberString + ".circle"
        }
        
        return "circle.fill"
    }
}


struct PasscodeField_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeField(description: "this is test description"){_ in
            
        }
    }
}
