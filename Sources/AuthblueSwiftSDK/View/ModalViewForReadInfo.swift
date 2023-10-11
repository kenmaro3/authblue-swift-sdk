import SwiftUI
import TRETJapanNFCReader_MIFARE_IndividualNumber
import SwiftASN1

public struct ModalViewForReadInfoFromMNC: View, IndividualNumberReaderSessionDelegate {
    public var handler: ((UserInfoFromMyNumber) -> Void)
    
    public init(handler: @escaping ((UserInfoFromMyNumber) -> Void)){
        self.handler = handler
    }
    
    
    func cardDataRawToEachInfo(data: TRETJapanNFCReader_MIFARE_IndividualNumber.IndividualNumberCardData){
        
        
        guard var dataRaw = data.raw else{
            return
        }
        dataRaw.removeFirst()
        let fields = TLVField.sequenceOfFields(from: dataRaw)
        let fieldData = fields.first!.value
        let string = String(data: Data(fieldData), encoding: .utf8)
        
        var parsed: ASN1Node
        try! parsed = DER.parse(dataRaw)
        
        guard case .constructed(let children) = parsed.content else {
            return
        }
        var iterator = children.makeIterator()
        var node_header = iterator.next()
        var node_name = iterator.next()
        guard case .primitive(let name_data) = node_name?.content else {
            return
        }
        var name_string_tmp = Array(name_data)
        let name_string = String(decoding: name_string_tmp, as: UTF8.self)
        
        var node_address = iterator.next()
        guard case .primitive(let address_data) = node_address?.content else {
            return
        }
        
        let address_string_tmp = Array(address_data)
        let address_string = String(decoding: address_string_tmp, as: UTF8.self)
        
        var node_birth = iterator.next()
        guard case .primitive(let birth_data) = node_birth?.content else {
            return
        }
        
        var birth_string_tmp = Array(birth_data)
        let birth_string = String(decoding: birth_string_tmp, as: UTF8.self)
        
        var node_sex = iterator.next()
        guard case .primitive(let sex_data) = node_sex?.content else {
            return
        }
        var sex_index_tmp = Array(sex_data)
        let sex_index = String(decoding: sex_index_tmp, as: UTF8.self)
        
        var sex_string = String(localized: "HomeReadInfoSexLabelUnknown", bundle: .module)
        switch(sex_index){
        case "1":
            sex_string = String(localized: "HomeReadInfoSexLabelMan", bundle: .module)
        case "2":
            sex_string = String(localized: "HomeReadInfoSexLabelWoman", bundle: .module)
        case "9":
            sex_string = String(localized: "HomeReadInfoSexLabelNotApplicable", bundle: .module)
        default:
            sex_string = String(localized: "HomeReadInfoSexLabelUnknown", bundle: .module)
        }
        
        setName(name_string)
        setAddress(address_string)
        
        setBirthday(birth_string)
        // 変換
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        //dateFormatter.timeZone = TimeZone(identifier: "Etc/GMT") // 世界標準時
        
        let birthDate = dateFormatter.date(from: birth_string)
        var age_string = "-1"
        if let birthDate{
            let birthDateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: birthDate)
            // 年齢を算出します
            let calendar = Calendar.current
            let now = calendar.dateComponents([.year, .month, .day], from: Date())
            let ageComponents = calendar.dateComponents([.year], from: birthDateComponents, to: now)
            let age = ageComponents.year
            if let age{
                setAge(String(age))
                age_string = String(age)
            }
        }
        
        setSex(sex_string)
        
        var res = UserInfoFromMyNumber(
            name: name_string, address: address_string, birth: birth_string, age: age_string, sex: sex_string
        )
        
        handler(res)
        
    }
    
    public func individualNumberReaderSession(didRead individualNumberCardData: TRETJapanNFCReader_MIFARE_IndividualNumber.IndividualNumberCardData) {
        print("individualNumberReaderSession")
        print(individualNumberCardData)
        
        cardDataRawToEachInfo(data: individualNumberCardData)
        
//        mncGroup.leave()
        
    }
    
    public func japanNFCReaderSession(didInvalidateWithError error: Error) {
        print("japanNFCReaderSession")
        print(error)
    }
    
    @State var reader: IndividualNumberReader!
    @State var isShowPinField: Bool = false
    @State private var pin: String = ""
    
    @State var activateGlassMorphism: Bool = false
    @State var blurView: UIVisualEffectView = .init()
    @State var defaultBlurRadius: CGFloat = 0
    @State var defaultSaturationAmount: CGFloat = 0
    
    @AppStorage("authblue_personal_name") var personalName: String = ""
    
    let mncGroup = DispatchGroup()
    let mncPinGroup = DispatchGroup()
    
    public var body: some View {
        NavigationStack{
            VStack(){
                
                UserNameCellView(
                    activateGlassMorphism: $activateGlassMorphism,
                    blurView: $blurView,
                    defaultBlurRadius: $defaultBlurRadius,
                    defaultSaturationAmount: $defaultSaturationAmount
                )
                    .foregroundColor(.black)
                

            }
            .navigationTitle(String(localized: "HomeSettingsNavigationTitleAbout", bundle: .module))
            .navigationBarItems(
                
                trailing: HStack {
                    Button(action: {
                        loadMncReaderAndPinField()
                        
                    }, label: {
                        HStack(spacing: 15){
                            if(personalName == ""){
                                Text("HomeReadInfoButtonTitleWarning", bundle: .module)
                                    .fontWeight(.semibold)
                                    .contentTransition(.identity)
                                    .foregroundColor(.red)
                            }else{
                                Text("HomeReadInfoButtonTitle", bundle: .module)
                                    .fontWeight(.semibold)
                                    .contentTransition(.identity)
                                    .foregroundColor(.black)
                            
                            }
                            
                            
                            Image(systemName: "gobackward")
                                .font(.title3)
                                .foregroundColor(.black)
                            
                        }
                    })
                })

        }
        .onAppear{
            reader = IndividualNumberReader(delegate: self)
            Task.detached { @MainActor in
                print("will start on appear main")
                //loadMncReaderAndPinField()
            }
        }
        .sheet(isPresented: $isShowPinField) {
            PasscodeField(description: String(localized: "PasscodeFieldDescriptionForGettingInfo", bundle: .module)){ value in
                print("from PasscodeField, value: \(value)")
                isShowPinField = false
                pin = value
//                mncPinGroup.leave()
                loadMncReaderAndPinField()
            }
        }
        
    }
    
    func loadMncReaderAndPinField(){
        if(pin.count != 4){
            isShowPinField = true
//            mncPinGroup.enter()
        }else{
            isShowPinField = false
//            mncPinGroup.enter()
//            mncPinGroup.leave()
        }
        if(!isShowPinField){
            getBasicInfoFromMnc()
        }
        
        
    }
    
    func getBasicInfoFromMnc(){
        let items: [IndividualNumberCardItem] = [.basicInfo]
        
        self.reader.get(items: items, cardInfoInputSupportAppPIN: pin)
        
    }
    
}


public struct UserNameCellView: View {
    // MARK: GlassMorphism Properties
    @Binding var activateGlassMorphism: Bool
    @Binding var blurView: UIVisualEffectView
    @Binding var defaultBlurRadius: CGFloat
    @Binding var defaultSaturationAmount: CGFloat
    
    @AppStorage("authblue_personal_name") var personalName: String = ""
    @AppStorage("authblue_personal_birthday") var personalBirthday: String = ""
    @AppStorage("authblue_personal_age") var personalAge: String = ""
    @AppStorage("authblue_personal_sex") var personalSex: String = ""
    @AppStorage("authblue_personal_address") var personalAddress: String = ""
    @AppStorage("authblue_personal_phone") var personalPhone: String = ""
    @AppStorage("authblue_personal_email") var personalEmail: String = ""
    
    
    
    public var body: some View {
            
            
            VStack(spacing: 12){
                ZStack{
                    Image("logo_color", bundle: .module)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                    GlassMorphicCard()
    
                }
                
                Toggle(NSLocalizedString("AboutUserInfoShowToggleLabel", bundle: .module, comment: ""), isOn: $activateGlassMorphism)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .onChange(of: activateGlassMorphism){newValue in
                        // Change Blur radius and saturation
                        blurView.gaussianBlurRadius = (activateGlassMorphism ? 10 : defaultBlurRadius)
                        blurView.saturationAmount = (activateGlassMorphism ? 1.8 : defaultSaturationAmount)
                    }
                    .padding(15)
                    .padding(.horizontal, 20)
                
                
            }
    }
            // MARK: GlassMorphism Card
        @ViewBuilder
        func GlassMorphicCard()->some View{
            ZStack{
                CustomBlurView(effect: .systemUltraThinMaterialDark){ view in
                    blurView = view
                    if defaultBlurRadius == 0{defaultBlurRadius = view.gaussianBlurRadius}
                    if defaultSaturationAmount == 0{defaultSaturationAmount = view.saturationAmount}
                }
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                // MARK: building glassmorphic card
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.linearGradient(colors: [
                        .white.opacity(0.25),
                        .white.opacity(0.05),
                        .clear
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ).blur(radius: 5)
                
                // MARK: Borders
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(.linearGradient(colors: [
                        .white.opacity(0.6),
                        .clear,
                        .black.opacity(0.2),
                        .black.opacity(0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                    )
            }
            // MARK: Shadow
            .shadow(color: .black.opacity(0.15), radius: 2, x: -4, y: 4)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 4, y: -4)
            .overlay(content: {
                // Card content
                CardContent()
                    .opacity(activateGlassMorphism ? 1 : 0)
                    .animation(.easeIn(duration: 0.2), value: activateGlassMorphism)
            })
            .padding(25)
            .frame(height: 350)
        }
        
        @ViewBuilder
        func CardContent() -> some View{
            VStack(alignment: .leading, spacing: 12){
//                HStack(){
//                    Text("MEMBERSHIP")
//                        .modifier(CustomModifierWithKerning(font: .callout))
//                    Image(systemName: "creditcard")
//                        .foregroundColor(.white)
//                        .font(.system(size: 32))
//
//                }
                HStack(spacing: 8){
                    Text("HomeReadInfoNameLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalName)
                        .modifier(CustomModifier(font: .caption))
                }

                HStack(spacing: 8){
                    Text("HomeReadInfoBirthdayLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalBirthday)
                        .modifier(CustomModifier(font: .caption))
                    
                }

                HStack(spacing: 8){
                    Text("HomeReadInfoAgeLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalAge)
                        .modifier(CustomModifier(font: .caption))
                }

                HStack(spacing: 8){
                    Text("HomeReadInfoSexLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalSex)
                        .modifier(CustomModifier(font: .caption))
                    
                }

                HStack(spacing: 8){
                    Text("HomeReadInfoAddressLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalAddress)
                        .modifier(CustomModifier(font: .caption))
                        .lineLimit(3)
                }
                HStack(spacing: 8){
                    Text("HomeReadInfoEmailLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalEmail)
                        .modifier(CustomModifier(font: .caption))
                        .lineLimit(2)
                    
                }

                HStack(spacing: 8){
                    Text("HomeReadInfoPhoneLabel", bundle: .module)
                        .modifier(CustomModifier(font: .subheadline))
                    Text(personalPhone)
                        .modifier(CustomModifier(font: .caption))
                }
                
            }
            .padding(20)
            .padding(.vertical, 10)
            .blendMode(.overlay)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }

}

