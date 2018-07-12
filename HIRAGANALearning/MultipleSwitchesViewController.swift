//
//  MultipleSwitchesViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class MultipleSwitchesViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var decisionButton: UIButton!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var toNextLabel: UILabel!
    @IBOutlet weak var toPreviousLabel: UILabel!
    @IBOutlet weak var toPreviousOutlet: UIButton!
    @IBOutlet weak var thirdSwitchOutlet: UIButton!
    @IBOutlet weak var decisionSwitchLabel: UILabel!
    
    let userDefaults = UserDefaults.standard

    
    var importantAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    
    var alertController: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        toHomeButton.layer.cornerRadius = 40.0
        decisionButton.layer.cornerRadius = 40.0
        switchLabel.layer.cornerRadius = 10.0
        
        thirdSwitchOutlet.setImage(UIImage(named: "CheckOn"), for: .normal)
        thirdSwitchOutlet.setImage(UIImage(named: "CheckOff"), for: .selected)
        if userDefaults.integer(forKey: Constants.SwitchKey) == 3{
            thirdSwitchOutlet.isSelected = true
            toPreviousOutlet.isEnabled = true
            toPreviousOutlet.alpha = 1.0
        }else{
            thirdSwitchOutlet.isSelected = false
            toPreviousOutlet.isEnabled = false
            toPreviousOutlet.alpha = 0.2
        }
        if userDefaults.integer(forKey: Constants.SwitchKey) != 1{
            toNextLabel.text = userDefaults.string(forKey: Constants.toNextKey)
            toPreviousLabel.text = userDefaults.string(forKey: Constants.toPreviousKey)
            decisionSwitchLabel.text = userDefaults.string(forKey: Constants.multiDecisionKey)
        }
        
        if let asset = NSDataAsset(name: "Important") {
            importantAudioPlayer = try! AVAudioPlayer(data: asset.data)
            importantAudioPlayer.volume = userDefaults.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = userDefaults.float(forKey: Constants.volumeKey)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if userDefaults.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func toHomeBuuton(_ sender: Any) {
        if userDefaults.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    
    @IBAction func toNextSwitch(_ sender: Any) {
        alertController = UIAlertController(title: "「次へ」ボタンの設定", message: "使用するキーやスイッチを押してください", preferredStyle: .alert)
        alertController.addTextField{ (textField: UITextField!) -> Void in
            textField.addTarget(self, action: #selector(self.toNextAdded), for: .editingChanged)
        }
        let  cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    @objc func toNextAdded(){
        let text = alertController.textFields?.first?.text?.lowercased()
        toNextLabel.text = text
        alertController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func thirdSwitch(_ sender: Any) {
        if thirdSwitchOutlet.isSelected{
            thirdSwitchOutlet.isSelected = false
            toPreviousOutlet.isEnabled = false
            toPreviousOutlet.alpha = 0.2
        }else{
            thirdSwitchOutlet.isSelected = true
            toPreviousOutlet.isEnabled = true
            toPreviousOutlet.alpha = 1.0
        }
    }
    
    @IBAction func toPreviousSwitch(_ sender: Any) {
        alertController = UIAlertController(title: "「前へ」ボタンの設定", message: "使用するキーやスイッチを押してください", preferredStyle: .alert)
        alertController.addTextField{ (textField: UITextField!) -> Void in
            textField.addTarget(self, action: #selector(self.toPreviousAdded), for: .editingChanged)
        }
        let  cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    @objc func toPreviousAdded(){
        let text = alertController.textFields?.first?.text?.lowercased()
        toPreviousLabel.text = text
        alertController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decisionSwitch(_ sender: Any) {
        alertController = UIAlertController(title: "「決定」ボタンの設定", message: "使用するキーやスイッチを押してください", preferredStyle: .alert)
        alertController.addTextField{ (textField: UITextField!) -> Void in
            textField.addTarget(self, action: #selector(self.decisionAdded), for: .editingChanged)
        }
        let  cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    @objc func decisionAdded(){
        let text = alertController.textFields?.first?.text?.lowercased()
        decisionSwitchLabel.text = text
        alertController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decisionButton(_ sender: Any) {
        let toNext = toNextLabel.text
        let toPrevious = toPreviousLabel.text
        let decision = decisionSwitchLabel.text
        if toNext == nil || toNext == ""{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "「次へ」ボタンが未設定です")
        }else if decision == nil || decision == ""{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "「決定」ボタンが未設定です")
        }else if toNext == decision{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "同じボタンが設定されています")
        }else if toNext!.isHiragana || toNext!.isKatakana || decision!.isHiragana || decision!.isKatakana {
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "ひらがな・カタカナはボタン設定に使用できません")
        }else if thirdSwitchOutlet.isSelected{
            if toPrevious == nil || toPrevious == ""{
                SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "「前へ」ボタンを設定するか、「使用しない」にチェックを入れてください")
            }else if toPrevious == toNext || toPrevious == decision{
                SVProgressHUD.showError(withStatus: "同じボタンが設定されています")
            }else if toPrevious!.isHiragana || toPrevious!.isKatakana{
                SVProgressHUD.setMinimumDismissTimeInterval(0)
                SVProgressHUD.showError(withStatus: "ひらがな・カタカナはボタン設定に使用できません")
            }else{
                if userDefaults.bool(forKey: Constants.tapSoundKey) == false{
                    importantAudioPlayer.play()
                }
                userDefaults.set(toNext, forKey: Constants.toNextKey)
                userDefaults.set(toPrevious, forKey: Constants.toPreviousKey)
                userDefaults.set(decision, forKey: Constants.multiDecisionKey)
                userDefaults.set(3, forKey: Constants.SwitchKey)
                SVProgressHUD.setMinimumDismissTimeInterval(0)
                SVProgressHUD.showSuccess(withStatus: "3つのボタン操作を登録しました")
                self.dismiss(animated: true, completion: nil)
            }
        }else{
        if userDefaults.bool(forKey: Constants.tapSoundKey) == false{
        importantAudioPlayer.play()
            }
            userDefaults.set(toNext, forKey: Constants.toNextKey)
            userDefaults.set(decision, forKey: Constants.multiDecisionKey)
                userDefaults.set(2, forKey: Constants.SwitchKey)
                SVProgressHUD.setMinimumDismissTimeInterval(0)
                SVProgressHUD.showSuccess(withStatus: "2つのボタン操作を登録しました")
                self.dismiss(animated: true, completion: nil)
            }

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
