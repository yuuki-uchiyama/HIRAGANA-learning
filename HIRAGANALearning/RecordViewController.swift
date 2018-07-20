//
//  RecordViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/17.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class RecordViewController: UIViewController {
    
    
    @IBOutlet weak var answerLabel: UILabel!
    var answerWord: String!
    @IBOutlet weak var correctImageView: UIImageView!
    var correctImage: UIImage!
    @IBOutlet weak var recordButtonOutlet: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    
    
    let fileManager = FileManager()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var url : URL!
    var timer: Timer!
    var correctCount = 0
    
    var recordArray: [URL] = []
    var correctArray: [UIImage] = []
    var toResultBool = false
    
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
    var cursorSizeArray: [CGSize] = []
    var cursorPositionArray: [CGPoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answerWord
        correctImageView.image = correctImage
        correctImageView.contentMode = UIViewContentMode.scaleAspectFit
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 10.0)
        
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        url = setURL()
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: recordSetting)
        } catch {
            print("初期設定でerror出たよ(-_-;)")
        }
        recordButtonOutlet.setImage(UIImage(named: "Stop"), for: .selected)
        
       switchController()
    }
    
    func setURL() -> URL {
        let paths = FileManager.default.temporaryDirectory
        url = paths.appendingPathComponent(String(correctCount))
        return url
    }
    
    @IBAction func recordButton(_ sender: UIButton) {
        if sender.isSelected{
            timer.invalidate()
            audioRecorder?.stop()
            sender.isSelected = false
        }else{
            progressView.progress = 0
            sender.isSelected = true
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.progressBar), userInfo: nil, repeats: true)
                self.audioRecorder?.record()
            }
        }
    }
    
    @objc func progressBar(){
        progressView.progress += 0.01
        if progressView.progress >= 1{
            timer.invalidate()
            audioRecorder?.stop()
            recordButtonOutlet.isSelected = false
        }
    }
    

    @IBAction func nextButton(_ sender: Any) {
        if recordButtonOutlet.isSelected{
            timer.invalidate()
            audioRecorder?.stop()
            recordButtonOutlet.isSelected = false
        }
        if toResultBool{
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }else{
            self.performSegue(withIdentifier: "unwindToGame", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if switchControl == 1{
            singleSwitchTimer.invalidate()
        }
        if segue.identifier == "unwindToGame"{
        let gameVC: GameViewController = segue.destination as! GameViewController
        gameVC.recordArray.append(self.url)
        gameVC.correctArray.append(self.correctImage)
        }else if segue.identifier == "toResult"{
            recordArray.append(url)
            correctArray.append(correctImage)
            let resultVC:ResultViewController = segue.destination as! ResultViewController
            resultVC.recordArray = self.recordArray
            resultVC.correctArray = self.correctArray
            resultVC.correctCount = self.correctCount
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
            
            cursorSizeArray.append(recordButtonOutlet.frame.size)
            cursorSizeArray.append(nextButtonOutlet.frame.size)
            cursorPositionArray.append(recordButtonOutlet.center)
            cursorPositionArray.append(nextButtonOutlet.center)
            cursor.layer.borderColor = UIColor.yellow.cgColor
            cursor.layer.borderWidth = 9
            cursor.layer.cornerRadius = 20.0
            cursor.frame.size = cursorSizeArray[0]
            cursor.center = cursorPositionArray[0]
            cursorTag = 0
            self.view.addSubview(cursor)
            self.view.insertSubview(cursor, belowSubview: recordButtonOutlet)
            
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
        if cursorTag == 0 {
            cursorTag = 1
        }else{
            cursorTag = 0
        }
        cursor.frame.size = cursorSizeArray[cursorTag]
        cursor.center = cursorPositionArray[cursorTag]
    }
    
    @objc func SwitchDecision(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        let key = switchControlTextField.text?.lowercased()
        if (key?.contains(decisionSwitch))!{
            if cursorTag == 0 {
                if recordButtonOutlet.isSelected{
                    self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.cursorMove), userInfo: nil, repeats: true)
                }else{
                    singleSwitchTimer.invalidate()
                }
                self.recordButton(recordButtonOutlet)
            }else{
                self.nextButton(nextButtonOutlet)
            }
        }
    }
    
    @objc func multipleSwitches(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        if (switchControlTextField.text?.lowercased().contains(toNextSwitch))! {
            cursorMove()
        }else if (switchControlTextField.text?.lowercased().contains(toPreviousSwitch))!{
            cursorMove()
        }
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            if cursorTag == 0{
                self.recordButton(recordButtonOutlet)
            }else{
                self.nextButton(nextButtonOutlet)
            }
        }
        switchControlTextField.text = ""
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
