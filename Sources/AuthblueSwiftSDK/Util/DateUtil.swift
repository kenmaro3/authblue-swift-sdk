import Foundation

class DateUtils{
    static func getNow() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
        return dateFormatter.string(from: dt)
    }
    
    static func formatString(value: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = dateFormatter.date(from: value)
        
        if let date = date{
            // DateFormatter を使用して書式とロケールを指定する
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
            return dateFormatter.string(from: date)
        }else{
            return ""
        }
        
        
    }
}

