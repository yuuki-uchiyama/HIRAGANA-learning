//
//  ResultViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import SVProgressHUD
import Gecco

class ResultViewController: UIViewController, GADInterstitialDelegate, SpotlightViewControllerDelegate {
    
    var interstitial: GADInterstitial!
    
    var recordArray: [URL] = []
    var correctArray: [UIImage] = []
    var correctCount = 0
    var size: CGFloat = 0.0
    
    @IBOutlet weak var correctCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var oneMoreButton: UIButton!
    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var cardCreateField: UIView!
    
    var backAudioPlayer: AVAudioPlayer!
    var stampAudioPlayer: AVAudioPlayer!
    var fanfareAudioPlayer: AVAudioPlayer!
    var recordAudioPlayer: AVAudioPlayer!

    var waitLabel: UILabel! = UILabel()
    
    let userDefaults = UserDefaults.standard
    var switchControl = 0
    var switchControlTextField: UITextField = UITextField()
    var cursor: UIView = UIView()
    var cursorTag = 1
    var singleSwitchTimer :Timer!
    var timeInterval = 0
    var decisionSwitch = ""
    var toNextSwitch = ""
    var toPreviousSwitch = ""
    var cursorPositionArray: [CGPoint] = []
    
    private var spotlightVC: AnnotationViewController!
    var spotIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3240594386716005/3347115625")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        
        oneMoreButton.layer.cornerRadius = 40.0
        toHomeButton.layer.cornerRadius = 40.0
        cardCreateField.layer.cornerRadius = 30.0
        cardCreateField.layer.borderWidth = 10
        cardCreateField.layer.borderColor = UIColor.darkGray.cgColor
        
        size = cardCreateField.frame.size.height / 3.0
        for i in 1 ... correctCount{
            let button = UIButton()
            button.layer.borderColor = UIColor.orange.cgColor
            button.layer.borderWidth = 5
            button.layer.cornerRadius = 10.0
            button.setImage(correctArray[i-1], for: .normal)
            button.frame.size = CGSize(width: size, height: size)
            button.contentMode = UIViewContentMode.scaleAspectFit
            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            if correctCount < 6{
                let interval = cardCreateField.frame.width / CGFloat(correctCount + 1)
                x = cardCreateField.frame.origin.x + interval * CGFloat(i)
                y = cardCreateField.frame.origin.y + cardCreateField.frame.size.height / 2
            }else{
                let lines = Int(ceil(CGFloat(correctCount) / 2.0))
                let interval = cardCreateField.frame.width / CGFloat(lines + 1)
                if i <= lines{
                    x = cardCreateField.frame.origin.x + interval * CGFloat(i)
                    y = cardCreateField.frame.origin.y + cardCreateField.frame.size.height / 3.1
                }else if i > lines{
                    x = cardCreateField.frame.origin.x + interval * CGFloat(i - lines)
                    y = cardCreateField.frame.origin.y + cardCreateField.frame.size.height / 2.9 * 2.0
                }
            }
            button.center = CGPoint(x: x, y: y)
            cursorPositionArray.append(button.center)
            button.tag = i
            button.addTarget(self, action: #selector(playRecord(sender:)), for: .touchUpInside)
            self.view.addSubview(button)
        }
        
        SVProgressHUD.show(withStatus: "ちょっと待ってね")
        
        
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Stamp") {
            stampAudioPlayer = try! AVAudioPlayer(data: asset.data)
            stampAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Fanfare") {
            fanfareAudioPlayer = try! AVAudioPlayer(data: asset.data)
            fanfareAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        
        spotlightVC = AnnotationViewController()
        spotlightVC.delegate = self
        // Do any additional setup after loading the view.
    }
        
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
        SVProgressHUD.dismiss()
    }
    
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        correctCountLabel.text = "\(correctCount)"
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.isRemovedOnCompletion = false
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 2.0
        animation1.toValue = 1.0
        let animation2 = CABasicAnimation(keyPath: "transform.rotation")
        animation2.fromValue = 0.0
        animation2.toValue = Double.pi * 2.0
        animation2.speed = 2.0
        animationGroup.animations = [animation1, animation2]
        correctCountLabel.layer.add(animationGroup, forKey: nil)
        
        if correctCount <= 4{
            stampImageView.image = UIImage(named: "OK")
            stampAudioPlayer.play()
        }else if correctCount <= 6{
            stampImageView.image = UIImage(named: "Good")
            stampAudioPlayer.play()
        }else{
            stampImageView.image = UIImage(named: "VeryGood")
            stampAudioPlayer.play()
            if correctCount > 8{
                fanfareAudioPlayer.play()
            }
        }
        switchController()
        if !userDefaults.bool(forKey: Constants.resultTutorialKey){
            showSpot()
            if switchControl > 0 {
                _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(spotTap), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func playRecord(sender: UIButton){
        do{
            try recordAudioPlayer = AVAudioPlayer(contentsOf: recordArray[sender.tag - 1])
            recordAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey) * 2.0
            recordAudioPlayer.play()
        }catch{
            print("error!")
        }
    }
    
    @IBAction func onMoreButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
        if switchControl == 1{
            singleSwitchTimer.invalidate()
        }
    }
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
        if switchControl == 1{
            singleSwitchTimer.invalidate()
        }
    }
    //    スイッチコントロールの設定
    func switchController(){
        switchControl = userDefaults.integer(forKey: Constants.SwitchKey)
        if switchControl != 0{
            switchControlTextField.frame.origin = CGPoint(x: view.frame.width, y: view.frame.height)
            self.view.addSubview(switchControlTextField)
            switchControlTextField.inputAssistantItem.leadingBarButtonGroups.removeAll()
            switchControlTextField.inputAssistantItem.trailingBarButtonGroups.removeAll()
            switchControlTextField.becomeFirstResponder()
            
            cursor.layer.borderColor = UIColor.yellow.cgColor
            cursor.layer.borderWidth = 9
            cursor.layer.cornerRadius = 20.0
            cursor.frame.size = CGSize(width: size, height: size)
            cursor.center = cursorPositionArray[0]
            cursorTag = 1
            self.view.addSubview(cursor)
        }
        if switchControl == 1{
            timeInterval = userDefaults.integer(forKey: Constants.cursorSpeedKey)
            self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(cursorMove), userInfo: nil, repeats: true)
            decisionSwitch = userDefaults.string(forKey: Constants.singleDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(SwitchDecision), for: .editingChanged)
        }else if switchControl > 1{
            toNextSwitch = userDefaults.string(forKey: Constants.toNextKey)!
            if switchControl == 3{
                toPreviousSwitch = userDefaults.string(forKey: Constants.toPreviousKey)!
            }
            decisionSwitch = userDefaults.string(forKey: Constants.multiDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(multipleSwitches), for: .editingChanged)
        }
    }

    
    @objc func cursorMove(){
        if cursorTag >= correctCount {
            cursorTag = 1
        }else{
            cursorTag += 1
        }
        cursor.center = cursorPositionArray[cursorTag - 1]
    }
    
    @objc func SwitchDecision(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        let key = switchControlTextField.text?.lowercased()
        if (key?.contains(decisionSwitch))!{
            singleSwitchTimer.invalidate()
            let button = self.view.viewWithTag(cursorTag) as! UIButton
            self.playRecord(sender: button)
            self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(cursorMove), userInfo: nil, repeats: true)
            }
        switchControlTextField.text = ""
        }
    
    @objc func multipleSwitches(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        if (switchControlTextField.text?.lowercased().contains(toNextSwitch))! {
            cursorMove()
        }else if (switchControlTextField.text?.lowercased().contains(toPreviousSwitch))!{
            if cursorTag == 1 {
                cursorTag = correctCount
            }else{
                cursorTag -= 1
            }
            cursor.center = cursorPositionArray[cursorTag]
        }
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            let button = self.view.viewWithTag(cursorTag) as! UIButton
            self.playRecord(sender: button)
        }
        switchControlTextField.text = ""
    }
    
    //チュートリアル
    func showSpot(){
            present(self.spotlightVC, animated: true){
                self.spotlightVC.spotlightView.appear(Spotlight.RoundedRect(center: self.cardCreateField.center, size: self.cardCreateField.frame.size, cornerRadius: 20.0))
            }
            self.spotlightVC.updateLabel(text: "ボタンを押すと、録音した声が流れるよ！", x: self.cardCreateField.center.x, y: self.cardCreateField.frame.origin.y - 20.0)
    }
    
    @objc func spotTap(){
        self.spotlightVC.dismiss(animated: true, completion: nil)
                    UserDefaults.standard.set(true, forKey: Constants.recordTutorialKey)

    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        self.spotlightVC.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: Constants.resultTutorialKey)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
