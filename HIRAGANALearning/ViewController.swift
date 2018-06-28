//
//  ViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift



class ViewController: UIViewController {
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let card1 = Card()
        card1.id = 0
        card1.word = "き"
        card1.group = 1
        card1.originalDeck = 0
        card1.image = UIImagePNGRepresentation(UIImage(named: "0")!)! as NSData
        
        let card2 = Card()
        card2.id = 1
        card2.word = "やま"
        card2.group = 2
        card2.originalDeck = 1
        card2.image = UIImagePNGRepresentation(UIImage(named: "1")!)! as NSData
        
        let card3 = Card()
        card3.id = 2
        card3.word = "くるま"
        card3.group = 3
        card3.originalDeck = 2
        card3.image = UIImagePNGRepresentation(UIImage(named: "2")!)! as NSData
        
        let card4 = Card()
        card4.id = 3
        card4.word = "にわとり"
        card4.group = 4
        card4.originalDeck = 0
        card4.image = UIImagePNGRepresentation(UIImage(named: "3")!)! as NSData
        
        try! realm.write{
            realm.add(card1, update: true)
            realm.add(card2, update: true)
            realm.add(card3, update: true)
            realm.add(card4, update: true)
        }
        
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
    }

}

