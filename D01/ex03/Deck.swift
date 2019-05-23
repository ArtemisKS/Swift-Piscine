import Foundation

class Deck : NSObject
{
    static let allSpades    : [Card] = Value.allValue.map({Card(Color:Color.spades, Value:$0)})
    static let allHearts    : [Card] = Value.allValue.map({Card(Color:Color.hearts, Value:$0)})
    static let allClubs     : [Card] = Value.allValue.map({Card(Color:Color.clubs, Value:$0)})
    static let allDiamonds  : [Card] = Value.allValue.map({Card(Color:Color.diamonds, Value:$0)})
    static let allCard      : [Card] = allSpades + allHearts + allClubs + allDiamonds    
}

extension Array {
    mutating func shuffle() {
        for i in 0..<self.count
        {
            let rand = Int(arc4random_uniform(UInt32(self.count)))
            if rand != i {
                self.swapAt(i, rand)
            }
        }
    }
}

