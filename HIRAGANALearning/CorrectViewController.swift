//
//  CorrectViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class CorrectViewController: UIViewController {
    
    @IBOutlet weak var wordFrame: UIView!
    @IBOutlet weak var correctImageView: UIImageView!
    @IBOutlet weak var toNext: UIImageView!
    @IBOutlet weak var tap: UIImageView!
    
    var tapGesture: UITapGestureRecognizer!
    
    var correctImage: UIImage!
    
    var answerWord :String = ""
    var characterCount = 0
    var readCount = 0
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    
    let userDefaults = UserDefaults.standard
    let switchControlTextField:UITextField = UITextField()
    var switchControl = 0
    var decisionSwitch = ""
    var toNextSwitch = ""
    var toPreviousSwitch = ""
    
    var recordArray: [URL] = []
    var correctArray: [UIImage] = []
    var correctCount = 0
    var toResultBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toNext.isHidden = true
        tap.isHidden = true
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        correctImageView.image = correctImage
        correctImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        characterCount = answerWord.count
        for i in 1 ... characterCount{
            let word = UILabel()
            word.frame.size = CGSize(width: wordFrame.frame.size.height, height: wordFrame.frame.size.height)
            word.text = String(answerWord[answerWord.index(answerWord.startIndex, offsetBy: i-1) ..< answerWord.index(answerWord.startIndex, offsetBy: i)])
            word.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 100 )
            word.adjustsFontSizeToFitWidth = true
            word.textAlignment = NSTextAlignment.center
            word.tag = i
            let interval = wordFrame.frame.width / CGFloat(characterCount + 1)
            word.center = CGPoint(x: wordFrame.frame.origin.x + interval * CGFloat(i), y: wordFrame.frame.origin.y + wordFrame.frame.size.height / 2)
            self.view.addSubview(word)
        }
        
        tapGesture = UITapGestureRecognizer(target:self, action:#selector(readingCharacter))
        self.view.addGestureRecognizer(tapGesture)
        
        switchControl = userDefaults.integer(forKey: Constants.SwitchKey)
        if switchControl != 0{
            switchControlTextField.frame.origin = CGPoint(x: view.frame.width, y: view.frame.height)
            self.view.addSubview(switchControlTextField)
            switchControlTextField.inputAssistantItem.leadingBarButtonGroups.removeAll()
            switchControlTextField.inputAssistantItem.trailingBarButtonGroups.removeAll()
            switchControlTextField.becomeFirstResponder()
        }
        if switchControl == 1{
            decisionSwitch = userDefaults.string(forKey: Constants.singleDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(switchTapped), for: .editingChanged)
        }else if switchControl > 1{
            toNextSwitch = userDefaults.string(forKey: Constants.toNextKey)!
            if switchControl == 3{
            toPreviousSwitch = userDefaults.string(forKey: Constants.toPreviousKey)!
            }
            decisionSwitch = userDefaults.string(forKey: Constants.multiDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(switchTapped), for: .editingChanged)
        }
    }
    
    @objc func readingCharacter(){
        if readCount > characterCount{
        }else if readCount == characterCount{
            readCount += 1
            self.view.removeGestureRecognizer(tapGesture)
            switchControlTextField.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.toResultBool{
                self.performSegue(withIdentifier: "toResult", sender: nil)
            }else{
                self.performSegue(withIdentifier: "toGame", sender: nil)
                }
                if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
                        self.backAudioPlayer.play()
                    }
                }
        }else{
            if readCount == characterCount - 1{
                toNext.isHidden = false
                tap.isHidden = false
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat], animations: {
                    self.tap.alpha = 0.0
                }, completion: nil)
            }
            readCount += 1
            let character = self.view.viewWithTag(readCount) as! UILabel
            character.textColor = UIColor.red
            buttonTapAudioPlayer.currentTime = 0
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
                buttonTapAudioPlayer.play()
            }
        }
    }
    
    @objc func switchTapped(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        if switchControl > 0{
            if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! || (switchControlTextField.text?.lowercased().contains(toNextSwitch))! || (switchControlTextField.text?.lowercased().contains(toPreviousSwitch))! || (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
                switchControlTextField.resignFirstResponder()
                readingCharacter()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.switchControlTextField.becomeFirstResponder()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult"{
            let resultVC:ResultViewController = segue.destination as! ResultViewController
            resultVC.recordArray = self.recordArray
            resultVC.correctArray = self.correctArray
            resultVC.correctCount = self.correctCount
        }
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
