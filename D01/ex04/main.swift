var deckSort = Deck(sort: true)
var deckShuffled = Deck(sort: false)

print(deckSort)
print(deckShuffled)

print(deckSort.draw()!)
print(deckShuffled.draw()!)

print(deckSort.draw()!)
print(deckShuffled.draw()!)
print(deckSort.draw()!)
print(deckShuffled.draw()!)
print(deckSort.draw()!)
print(deckShuffled.draw()!)

print(deckSort.outs)
print(deckShuffled.outs)
