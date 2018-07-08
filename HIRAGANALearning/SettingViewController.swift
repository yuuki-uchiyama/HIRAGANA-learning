//
//  SettingViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation

class SettingViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var tapSound: UIView!
    var tapSoundBool = false
    @IBOutlet weak var incorrectSound: UIView!
    var incorrectSoundBool = false
    @IBOutlet weak var correctSound: UIView!
    var correctSoundBool = false

    var importantAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 40.0
        defaultButton.layer.cornerRadius = 10.0
        
        
        if let asset = NSDataAsset(name: "Important") {
            importantAudioPlayer = try! AVAudioPlayer(data: asset.data)
            importantAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        volumeSlider.value = UserDefaults.standard.float(forKey: Constants.volumeKey)
        
        
        tapSoundBool = UserDefaults.standard.bool(forKey: Constants.tapSoundKey)
        if tapSoundBool{
            tapSound.alpha = 0.2
        }else{
            tapSound.alpha = 1.0
        }
        
        incorrectSoundBool = UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey)
        if incorrectSoundBool{
            incorrectSound.alpha = 0.2
        }else{
            incorrectSound.alpha = 1.0
        }
        
        correctSoundBool = UserDefaults.standard.bool(forKey: Constants.correctSoundKey)
        if correctSoundBool{
            correctSound.alpha = 0.2
        }else{
            correctSound.alpha = 1.0
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        print(volumeSlider.value)
        UserDefaults.standard.set(volumeSlider.value, forKey: Constants.volumeKey)
        UserDefaults.standard.set(tapSoundBool, forKey: Constants.tapSoundKey)
        UserDefaults.standard.set(incorrectSoundBool, forKey: Constants.incorrectSoundKey)
        UserDefaults.standard.set(correctSoundBool, forKey: Constants.correctSoundKey)
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    
    @IBAction func tapSoundButton(_ sender: Any) {
        if tapSoundBool{
            tapSoundBool = false
            tapSound.alpha = 1.0
        }else{
            tapSoundBool = true
            tapSound.alpha = 0.2
        }
    }
    
    @IBAction func incorrectButton(_ sender: Any) {
        if incorrectSoundBool{
            incorrectSoundBool = false
            incorrectSound.alpha = 1.0
        }else{
            incorrectSoundBool = true
            incorrectSound.alpha = 0.2
        }
    }
    
    @IBAction func correctButton(_ sender: Any) {
        if correctSoundBool{
            correctSoundBool = false
            correctSound.alpha = 1.0
        }else{
            correctSoundBool = true
            correctSound.alpha = 0.2
        }
    }
    
    @IBAction func defaultButton(_ sender: Any) {
        volumeSlider.value = 0.5
        tapSoundBool = false
        tapSound.alpha = 1.0
        incorrectSoundBool = false
        incorrectSound.alpha = 1.0
        correctSoundBool = false
        correctSound.alpha = 1.0
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        importantAudioPlayer.play()
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
