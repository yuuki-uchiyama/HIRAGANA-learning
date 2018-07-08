//
//  RightViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/05.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SlideMenuControllerSwift

protocol choicesDelegate {
    func decreaseChoices()
    func increaseChoices()
}

class RightViewController: UIViewController,  SlideMenuControllerDelegate{
    var delegate: choicesDelegate?
    
    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var toChoiceLevelButton: UIButton!
    @IBOutlet weak var tapSound: UIView!
    @IBOutlet weak var incorrectSound: UIView!
    @IBOutlet weak var correctSound: UIView!
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey){
            tapSound.alpha = 0.2
        }else{
            tapSound.alpha = 1.0
        }
        if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey){
            incorrectSound.alpha = 0.2
        }else{
            incorrectSound.alpha = 1.0
        }
        if UserDefaults.standard.bool(forKey: Constants.correctSoundKey){
            correctSound.alpha = 0.2
        }else{
            correctSound.alpha = 1.0
        }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func decreaseChoice(_ sender: Any) {
        self.delegate?.decreaseChoices()
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    
    @IBAction func increaseChoice(_ sender: Any) {
        self.delegate?.increaseChoices()
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func toChoiceLevelButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    
    @IBAction func tapSoundButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey){
            UserDefaults.standard.set(false, forKey: Constants.tapSoundKey)
            tapSound.alpha = 1.0
        }else{
            UserDefaults.standard.set(true, forKey: Constants.tapSoundKey)
            tapSound.alpha = 0.2
        }
    }
    
    @IBAction func incorrectSoundButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey){
            UserDefaults.standard.set(false, forKey: Constants.incorrectSoundKey)
            incorrectSound.alpha = 1.0
        }else{
            UserDefaults.standard.set(true, forKey: Constants.incorrectSoundKey)
            incorrectSound.alpha = 0.2
        }
    }
    
    @IBAction func correctSoundButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.correctSoundKey){
            UserDefaults.standard.set(false, forKey: Constants.correctSoundKey)
        correctSound.alpha = 1.0
        }else{
            UserDefaults.standard.set(true, forKey: Constants.correctSoundKey)
            correctSound.alpha = 0.2
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
