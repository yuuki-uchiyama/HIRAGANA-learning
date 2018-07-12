//
//  CorrectViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation

class CorrectViewController: UIViewController {
    
    @IBOutlet weak var wordFrame: UIView!
    @IBOutlet weak var correctImageView: UIImageView!
    var correctImage: UIImage!
    
    var answerWord :String = ""
    var characterCount = 0
    var readCount = 0
    var toResultBool = false
    var correctCount = 0
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    
    let userDefaults = UserDefaults.standard
    let switchControlTextField:UITextField = UITextField()
    var switchControl = 0
    var decisionSwitch = ""
    var toNextSwitch = ""
    var toPreviousSwitch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        correctImageView.image = correctImage
        
        characterCount = answerWord.count
        for i in 1 ... characterCount{
            let word = UILabel()
            word.frame.size = CGSize(width: wordFrame.frame.size.height, height: wordFrame.frame.size.height)
            word.text = String(answerWord[answerWord.index(answerWord.startIndex, offsetBy: i-1) ..< answerWord.index(answerWord.startIndex, offsetBy: i)])
            word.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 100)
            word.tag = i
            let interval = wordFrame.frame.width / CGFloat(characterCount + 1)
            word.center = CGPoint(x: wordFrame.frame.origin.x + interval * CGFloat(i), y: wordFrame.frame.origin.y + wordFrame.frame.size.height / 2)
            self.view.addSubview(word)
        }
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(readingCharacter))
        self.view.addGestureRecognizer(tapGesture)
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        
        switchControl = userDefaults.integer(forKey: Constants.SwitchKey)
        if switchControl != 0{
            switchControlTextField.frame.origin = CGPoint(x: view.frame.width, y: view.frame.height)
            self.view.addSubview(switchControlTextField)
            switchControlTextField.becomeFirstResponder()
        }
        if switchControl == 1{
            decisionSwitch = userDefaults.string(forKey: Constants.singleDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(readingCharacter), for: .editingChanged)
        }else if switchControl > 1{
            toNextSwitch = userDefaults.string(forKey: Constants.toNextKey)!
            if switchControl == 3{
            toPreviousSwitch = userDefaults.string(forKey: Constants.toPreviousKey)!
            }
            decisionSwitch = userDefaults.string(forKey: Constants.multiDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(readingCharacter), for: .editingChanged)
        }
    }
    
    
    @objc func readingCharacter(){
        if readCount == characterCount{
            if toResultBool{
                performSegue(withIdentifier: "toResult", sender: nil)
            }else{
                switchControlTextField.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true, completion: nil)
                    if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
                        self.backAudioPlayer.play()
                    }
                }
            }
        }else {
            readCount += 1
            let character = self.view.viewWithTag(readCount) as! UILabel
            character.textColor = UIColor.red
            buttonTapAudioPlayer.currentTime = 0
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
                buttonTapAudioPlayer.play()
            }
        }
        if switchControl != 0{
            switchControlTextField.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult"{
            let resultViewController:ResultViewController = segue.destination as! ResultViewController
            resultViewController.correctCount = self.correctCount
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
