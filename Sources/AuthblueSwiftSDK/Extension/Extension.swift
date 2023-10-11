import Foundation
import UIKit
import CommonCrypto

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
extension String {
    var md5:    String { return digest(string: self, algorithm: .MD5) }
    var sha1:   String { return digest(string: self, algorithm: .SHA1) }
    var sha224: String { return digest(string: self, algorithm: .SHA224) }
    var sha256: String { return digest(string: self, algorithm: .SHA256) }
    var sha384: String { return digest(string: self, algorithm: .SHA384) }
    var sha512: String { return digest(string: self, algorithm: .SHA512) }

    func digest(string: String, algorithm: CryptoAlgorithm) -> String {
        var result: [CUnsignedChar]
        let digestLength = Int(algorithm.digestLength)
        if let cdata = string.cString(using: String.Encoding.utf8) {
            result = Array(repeating: 0, count: digestLength)
            switch algorithm {
            case .MD5:      CC_MD5(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA1:     CC_SHA1(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA224:   CC_SHA224(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA256:   CC_SHA256(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA384:   CC_SHA384(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA512:   CC_SHA512(cdata, CC_LONG(cdata.count-1), &result)
            }
        } else {
            fatalError("Nil returned when processing input strings as UTF8")
        }
        return (0..<digestLength).reduce("") { $0 + String(format: "%02hhx", result[$1])}
    }
    
    
}


extension String {

    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func toAge() -> Int?{
        do{
            let formatter = DateFormatter()//dateFormatterをageの名前に設定
            formatter.dateFormat = "yyyyMMdd"
            let today = Date()
            let birthday = try formatter.date(from: self)
            let myAge = birthday?.timeIntervalSinceNow
            let ageInt = (myAge!)/365/24/60/60*(-1)
            return Int(ageInt)
            
        }catch{
            return nil
        }
        
        
    }
}


extension String {
    
    var digits: [Int] {
        var result = [Int]()
        
        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }
        
        return result
    }
    
}

extension Int {
    
    var numberString: String {
        
        guard self < 10 else { return "0" }
        
        return String(self)
    }
}

import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}


func imageToBase64(image: UIImage) -> String? {
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        return nil
    }
    
    return imageData.base64EncodedString()
}
