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
    let wordArray = ["き", "やま", "くるま", "にわとり", "いちご", "めろん", "りんご", "らいおん", "もも", "めろん", "みかん", "ふね", "ぶどう", "ぶた", "ひこうき", "ぴあの", "ばなな", "ばいく", "ねこ", "いぬ", "とら", "とまと", "とうもろこし", "でんしゃ", "たまねぎ", "だいこん", "ぞう", "すいか", "しんかんせん", "さる", "さつまいも", "こあら", "けーき", "うさぎ", "くま", "きりん", "きゅうり", "きのこ", "きつね", "うま", "うし", "め", "みみ", "ひ", "は", "て"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ... 45{
        
        let card = Card()
            card.id = i
            card.word = wordArray[i]
            if card.word.count < 5{
                card.group = card.word.count
            }else{
                card.group = 5
            }
            card.originalDeck1 = false
            card.originalDeck2 = false
            card.image = UIImagePNGRepresentation(UIImage(named: "\(i)")!)! as NSData
            try! realm.write{
                realm.add(card, update: true)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
    }

}

