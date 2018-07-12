//
//  ResultViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation

class ResultViewController: UIViewController {
    
    var correctCount = 0
    @IBOutlet weak var correctCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var crackerImageView: UIImageView!
    @IBOutlet weak var oneMoreButton: UIButton!
    @IBOutlet weak var toHomeButton: UIButton!
    
    var backAudioPlayer: AVAudioPlayer!
    var stampAudioPlayer: AVAudioPlayer!
    var fanfareAudioPlayer: AVAudioPlayer!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                crackerImageView.image = UIImage(named: "AmazingMovie")
                fanfareAudioPlayer.play()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onMoreButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
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
