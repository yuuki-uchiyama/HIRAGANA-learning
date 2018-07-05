

import RealmSwift

class Card: Object {

    @objc dynamic var id = 0
    
    @objc dynamic var word = ""
    
    @objc dynamic var group = 0
    
    @objc dynamic var originalDeck1 = false
    
    @objc dynamic var originalDeck2 = false
    
    @objc dynamic var image: NSData?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class CardDTO: Object{
    var id = 0
    var word = ""
    var group = 0
    var originalDeck1 = false
    var originalDeck2 = false
    var image: NSData?
}
