

import RealmSwift

class Card: Object {

    @objc dynamic var id = 0
    
    @objc dynamic var word = ""
    
    @objc dynamic var group = 0
    
    @objc dynamic var originalDeck = 0
    
    @objc dynamic var image: NSData?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
