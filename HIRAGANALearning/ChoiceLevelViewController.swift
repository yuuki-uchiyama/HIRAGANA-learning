//
//  ChoiceLevelViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import Gecco

class ChoiceLevelViewController: UIViewController, SpotlightViewControllerDelegate {
    
    private var spotlightVC: AnnotationViewController!
    var spotIndex = 0
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var level1Button: UIButton!
    @IBOutlet weak var level2Button: UIButton!
    @IBOutlet weak var level3Button: UIButton!
    @IBOutlet weak var level4Button: UIButton!
    @IBOutlet weak var level5Button: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var deck1Button: UIButton!
    @IBOutlet weak var deck2Button: UIButton!
    @IBOutlet weak var hintSpeadSlider: UISlider!
    @IBOutlet weak var buttonView: UIView!
    
    let realm = try! Realm()
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotlightVC = AnnotationViewController()
        spotlightVC.delegate = self
        
        backButton.layer.cornerRadius = 40.0
        cardButton.layer.cornerRadius = 40.0
        level1Button.layer.cornerRadius = 40.0
        level2Button.layer.cornerRadius = 40.0
        level3Button.layer.cornerRadius = 40.0
        level4Button.layer.cornerRadius = 40.0
        level5Button.layer.cornerRadius = 40.0
        allButton.layer.cornerRadius = 40.0
        deck1Button.layer.cornerRadius = 40.0
        deck2Button.layer.cornerRadius = 40.0
        
        hintSpeadSlider.minimumValue = 0.0
        hintSpeadSlider.maximumValue = 1.0
        UserDefaults.standard.register(defaults: [Constants.hintSpeadKey: 0.5])
        hintSpeadSlider.value = UserDefaults.standard.float(forKey: Constants.hintSpeadKey)
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for i in 1 ... 10{
            let paths = FileManager.default.temporaryDirectory
            let url = paths.appendingPathComponent(String(i))
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: Constants.choiceLebelTutorialKey){
        showSpot()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToChoiceLevel(_ segue:UIStoryboardSegue){
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil {
            let slideViewcontroller: SlideViewController = segue.destination as! SlideViewController
            slideViewcontroller.gameView.choiceLevel = Int(segue.identifier!)!
            slideViewcontroller.gameView.hintInterval = Double(hintSpeadSlider.value)
            UserDefaults.standard.set(hintSpeadSlider.value, forKey: Constants.hintSpeadKey)

        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func cardButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let Card = storyboard.instantiateViewController(withIdentifier: "Card")
        self.present(Card, animated: true, completion: nil)
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func level1Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func level2Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func level3Button(_ sender: Any){
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func level4Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func level5Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func allButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func deck1Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func deck2Button(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    
    func showSpot(){
        let spot = self.spotlightVC.spotlightView
        switch spotIndex {
        case 0:
            present(self.spotlightVC, animated: true){
                spot.appear(Spotlight.RoundedRect(center: self.hintSpeadSlider.center, size: self.hintSpeadSlider.frame.size, cornerRadius: 40.0))
            }
            self.spotlightVC.updateLabel(text: "ヒントが出るスピードを調整できます", x: self.hintSpeadSlider.center.x, y: self.hintSpeadSlider.frame.origin.y - 20.0)
        case 1:
            spot.move(Spotlight.RoundedRect(center: self.buttonView.center, size: self.buttonView.frame.size, cornerRadius: 100.0))
            self.spotlightVC.updateLabel(text: "すきな難易度のボタンを押したらスタート！", x: self.buttonView.center.x, y: self.buttonView.frame.origin.y - 20.0)
        case 2:
            self.spotlightVC.dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: Constants.choiceLebelTutorialKey)
        default:
            break
        }
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        spotIndex += 1
        showSpot()
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
