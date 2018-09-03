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
    @IBOutlet weak var originalDeck1: UILabel!
    @IBOutlet weak var originalDeck2: UILabel!
    
    
    var cardData: Card!
    
    let realm = try! Realm()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        originalDeck1.layer.borderColor = UIColor.lightGray.cgColor
        originalDeck1.layer.borderWidth = 1.0
        originalDeck1.layer.cornerRadius = 10.0
        originalDeck1.layer.masksToBounds = true
        
        originalDeck2.layer.borderColor = UIColor.lightGray.cgColor
        originalDeck2.layer.borderWidth = 1.0
        originalDeck2.layer.cornerRadius = 10.0
        originalDeck2.layer.masksToBounds = true
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    
    func setCard(){
        cardImage.image = UIImage(data: cardData.image! as Data)
        cardImage.contentMode = UIViewContentMode.scaleAspectFit

        word.text! = cardData.word
        if cardData.originalDeck1{
            originalDeck1.text = "オリジナル　１"
            originalDeck1.backgroundColor = UIColor.red
        }else{
            originalDeck1.text = ""
        }
        if cardData.originalDeck2{
            originalDeck2.text = "オリジナル　２"
            originalDeck2.backgroundColor = UIColor.blue
        }else{
            originalDeck2.text = ""
        }
    }
}
