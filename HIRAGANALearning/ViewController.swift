//
//  ViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
        
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)
    let wordArray = ["き", "やま", "くるま", "にわとり", "いちご", "れもん", "りんご", "らいおん", "もも", "めろん", "みかん", "ふね", "ぶどう", "ぶた", "ひこうき", "せんぷうき", "ばなな", "れいぞうこ", "ねこ", "いぬ", "とら", "とまと", "とうもろこし", "でんしゃ", "たまねぎ", "だいこん", "ぞう", "すいか", "しんかんせん", "さる", "さつまいも", "こあら", "すべりだい", "うさぎ", "くま", "きりん", "きゅうり", "きのこ", "きつね", "うま", "うし", "め", "みみ", "ひ", "は", "て", "じてんしゃ", "くつした", "すいとう", "はぶらし"]

    var buttonTapAudioPlayer: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = 80.0
        cardButton.layer.cornerRadius = 80.0
        soundButton.layer.cornerRadius = 80.0
        settingButton.layer.cornerRadius = 80.0
        settingButton.titleEdgeInsets.top = 20
        
        if UserDefaults.standard.bool(forKey: Constants.defaultSettingKey){
        }else{
            UserDefaults.standard.set(true, forKey: Constants.defaultSettingKey)
            for i in 0 ... 49{
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
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func cardButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func soundButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func settingButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
    }

}

