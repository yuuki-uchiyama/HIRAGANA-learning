//
//  cardCollectionViewCell.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/28.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift

class cardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var originalDeck: UILabel!
    
    var cardData: Card!
    
    let realm = try! Realm()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        originalDeck.layer.cornerRadius = 10.0
    }
    
    func setCard(){
        cardImage.image = UIImage(data: cardData.image! as Data)
        word.text! = cardData.word
        if cardData.originalDeck == 0{
            originalDeck.text = ""
        }else if cardData.originalDeck == 1{
            originalDeck.text = "オリジナル　１"
            originalDeck.backgroundColor = UIColor.red
        }else if cardData.originalDeck == 2{
            originalDeck.text = "オリジナル　２"
            originalDeck.backgroundColor = UIColor.blue
        }

    }

}
