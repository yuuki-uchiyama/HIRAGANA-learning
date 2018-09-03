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
import BWWalkthrough

class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardComButton: UIButton!
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)
    let wordArray = ["き", "やま", "くるま", "にわとり", "いちご", "れもん", "りんご", "らいおん", "もも", "めろん", "みかん", "ふね", "ぶどう", "ぶた", "ひこうき", "せんぷうき", "ばなな", "れいぞうこ", "ねこ", "いぬ", "とら", "とまと", "とうもろこし", "でんしゃ", "たまねぎ", "だいこん", "ぞう", "すいか", "しんかんせん", "さる", "さつまいも", "こあら", "すべりだい", "うさぎ", "くま", "きりん", "きゅうり", "きのこ", "きつね", "うま", "うし", "め", "みみ", "ひ", "は", "て", "じてんしゃ", "くつした", "すいとう", "はぶらし"]

    var buttonTapAudioPlayer: AVAudioPlayer!
    
    var Top :BWWalkthroughViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardComButton.isEnabled = true
        
        WalkThrough()
        
        titleLabel.layer.cornerRadius = 60.0
        titleLabel.clipsToBounds = true
        startButton.layer.cornerRadius = 120.0
        cardButton.layer.cornerRadius = 40.0
        soundButton.layer.cornerRadius = 40.0
        settingButton.layer.cornerRadius = 40.0
        settingButton.titleEdgeInsets.top = 10
        cardComButton.layer.cornerRadius = 30.0
        
        if !UserDefaults.standard.bool(forKey: Constants.defaultSettingKey){
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
            UserDefaults.standard.register(defaults: [Constants.volumeKey: 0.5])
        }
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: Constants.defaultSettingKey){
        WalkThrough()
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
    @IBAction func cardComButton(_ sender: Any) {
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
    
    func WalkThrough(){
        let StoryBoard = UIStoryboard(name: "WalkThrough", bundle: nil)
        Top = StoryBoard.instantiateViewController(withIdentifier: "TOP") as! BWWalkthroughViewController
        let WT1 = StoryBoard.instantiateViewController(withIdentifier: "WT1")
        let WT2 = StoryBoard.instantiateViewController(withIdentifier: "WT2")
        let WT3 = StoryBoard.instantiateViewController(withIdentifier: "WT3")
        let WT4 = StoryBoard.instantiateViewController(withIdentifier: "WT4")
        let WT5 = StoryBoard.instantiateViewController(withIdentifier: "WT5")
        Top.delegate = self
        
        Top.add(viewController: WT1)
        Top.add(viewController: WT2)
        Top.add(viewController: WT3)
        Top.add(viewController: WT4)
        Top.add(viewController: WT5)
        
        self.present(Top, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: Constants.defaultSettingKey)
        AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {(granted: Bool) in})
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        if pageNumber == 4{
            Top.closeButton?.setTitle("OK!", for: .normal)
        }else{
            if Top.closeButton?.titleLabel?.text == "OK!"{
                Top.closeButton?.setTitle("Skip", for: .normal)
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

