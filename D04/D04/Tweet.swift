import Foundation

struct Tweet : CustomStringConvertible {
    
    let name : String
    let text : String
    let date : String
    var description: String {
        return "(\(name) : \(text)\n \(date))"
    }
}
