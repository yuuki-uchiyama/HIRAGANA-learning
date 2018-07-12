//
//  SingleSwitchViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class SingleSwitchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var decisionButton: UIButton!
    @IBOutlet weak var cursorSpeedTextField: UITextField!
    @IBOutlet weak var decisionSwitchOutlet: UIButton!
    var decisionSwitch = ""
    
    var importantAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    
    var alertController: UIAlertController!
    var cursorSpeedPickerView: UIPickerView = UIPickerView()
    var cursorSpeedArray:[Int] = ([Int])(0...30)
    
    var userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        toHomeButton.layer.cornerRadius = 40.0
        decisionButton.layer.cornerRadius = 40.0
        cursorSpeedTextField.layer.cornerRadius = 60.0
        decisionSwitchOutlet.layer.cornerRadius = 60.0
        
        if let asset = NSDataAsset(name: "Important") {
            importantAudioPlayer = try! AVAudioPlayer(data: asset.data)
            importantAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
            
            cursorSpeedPickerView.dataSource = self
            cursorSpeedPickerView.delegate = self
            
       
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        self.cursorSpeedTextField.inputView = cursorSpeedPickerView
        self.cursorSpeedTextField.inputAccessoryView = toolbar
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        if userDefaults.integer(forKey: Constants.SwitchKey) == 1{
            cursorSpeedTextField.text = String(userDefaults.integer(forKey: Constants.cursorSpeedKey))
            decisionSwitchOutlet.setTitle(userDefaults.string(forKey: Constants.singleDecisionKey), for: .normal)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    
    //pickerViewのaction,dataSource,delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cursorSpeedArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return ""
        }else{
            return String(cursorSpeedArray[row])
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{
            cursorSpeedTextField.text = ""
        }else{
            cursorSpeedTextField.text = String(cursorSpeedArray[row])
        }
    }
    
    @objc func cancel(){
        cursorSpeedTextField.text = ""
        cursorSpeedTextField.endEditing(true)
    }
    @objc func done(){
        cursorSpeedTextField.endEditing(true)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        let text = alertController.textFields?.first?.text!.lowercased()
        decisionSwitchOutlet.setTitle(text, for: .normal)
        alertController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decisionButton(_ sender: Any) {
        let singleDecision = decisionSwitchOutlet.titleLabel?.text
        if cursorSpeedTextField.text == ""{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "「カーソル移動の速さ」が未設定です")
        }else if singleDecision == nil {
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "「決定」ボタンが未設定です")
        }else if singleDecision!.isHiragana || singleDecision!.isKatakana{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "ひらがな・カタカナはボタン設定に使用できません")
        }else{
            if userDefaults.bool(forKey: Constants.tapSoundKey) == false{
                importantAudioPlayer.play()
            }
            userDefaults.set(1, forKey: Constants.SwitchKey)
            userDefaults.set(Int(cursorSpeedTextField.text!), forKey: Constants.cursorSpeedKey)
            userDefaults.set(singleDecision!, forKey: Constants.singleDecisionKey)
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "1ボタン操作を登録しました")
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
