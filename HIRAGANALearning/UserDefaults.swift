//
//  Constants.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/08.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import Foundation
import UIKit
import Gecco

struct Constants {
    static let defaultSettingKey = "defaultSetting"
    static let choiceLebelTutorialKey = "CLTutorial"
    static let recordTutorialKey = "RecTutorial"
    static let resultTutorialKey = "ResTutorial"
    
    static let volumeKey = "volume"
    
    static let tapSoundKey = "tap"
    static let incorrectSoundKey = "incorrect"
    static let correctSoundKey = "correct"
    
    static let hintSpeadKey = "hintSpead"
    
    static let SwitchKey = "Switch"
    static let cursorSpeedKey = "cursorSpeed"
    static let singleDecisionKey = "singleDecision"
    
    static let toNextKey = "toNext"
    static let toPreviousKey = "toPrevious"
    static let multiDecisionKey = "multiDecision"
    
}

struct Communication{
    static let serviceType : String = "STAPP-HIRAGANA"
}

// ひらがな・カタカナ判定用の拡張func
extension String{
    var isHiragana: Bool {
        let range = "^[ぁ-ゞ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
    var isKatakana: Bool {
        let range = "^[ァ-ヾ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
}

//Geccoに説明用Labelを追加
class AnnotationViewController: SpotlightViewController {
    
    var label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(label)
    }
    
    func updateLabel(text:String, x:CGFloat, y:CGFloat){
        label.textColor = UIColor.white
        label.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 30 )
        label.text = text
        label.numberOfLines = 0 
        label.sizeToFit()
        label.textAlignment = NSTextAlignment.center
        label.center = CGPoint(x: x, y: y)
    }
}

