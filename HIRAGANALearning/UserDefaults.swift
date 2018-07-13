//
//  Constants.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/08.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import Foundation

struct Constants {
    static let defaultSettingKey = "defaultSetting"
    
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

