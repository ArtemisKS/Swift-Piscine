import Foundation

class Card: NSObject {
    
    var color: Color
    var value: Value
    
    init(c: Color, v: Value) {
        self.color = c
        self.value = v
    }
    
    override var description: String {
        return ("Color is \(self.color.rawValue) and value is \(self.value)")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        let obj = object as? Card
        if obj?.color == self.color && obj?.value == self.value {
            return true
        }
        else {
            return false
        }
    }
}
