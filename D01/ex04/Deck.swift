import Foundation

class Deck : NSObject {
    static let allSpades: [Card] = Value.allValues.map { (num) -> Card in
        return Card(c: Color.Spade, v:num)
    }
    
    static let allDiamonds: [Card] = Value.allValues.map { (num) -> Card in
        return Card(c: Color.Diamond, v:num)
    }
    
    static let allHearts: [Card] = Value.allValues.map { (num) -> Card in
        return Card(c: Color.Heart, v:num)
    }
    
    static let allClubs: [Card] = Value.allValues.map { (num) -> Card in
            return Card(c: Color.Club, v:num)
    }
    
    static let allCards: [Card] = allSpades + allDiamonds + allHearts + allClubs
    
    var cards: [Card] = allCards
    var discard: [Card] = []
    var outs: [Card] = []
    
    init(sort: Bool) {
        if !sort {
            self.cards.shuffle()
        }
        super.init()
    }
    
    override var description : String{
        return "\(self.cards)"
    }
    
    func draw() -> Card? {
        if let first = self.cards.first {
            self.outs.append(first)
            self.cards.remove(at: 0)
            return first
        }
        return nil
    }
    
    func fold(c: Card) {
        var index = 0
        for elem in self.outs{
            if c == elem
            {
                self.discard.append(elem)
                self.outs.remove(at: index)
            }
            index = index + 1
        }
    }
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
