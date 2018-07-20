//
//  deckCollectionViewCell.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/20.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class deckCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var cardData: Card!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        
        checkButton.imageView?.contentMode = .scaleAspectFit
        checkButton.contentHorizontalAlignment = .fill
        checkButton.contentVerticalAlignment = .fill
        checkButton.setImage(UIImage(named: "CheckOn"), for: .selected)
    }
    
    func setCard(){
        if cardData == nil{
            cardImage.isHidden = true
            word.isHidden = true
        }else{
        cardImage.image = UIImage(data: cardData.image! as Data)
        cardImage.contentMode = UIViewContentMode.scaleAspectFit
        word.text! = cardData.word
        }
        checkButton.isSelected = false
    }
}
