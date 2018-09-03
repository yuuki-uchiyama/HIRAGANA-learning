//
//  CommunicationViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/24.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation

class CommunicationViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = 40.0
        importButton.layer.cornerRadius = 80.0
        exportButton.layer.cornerRadius = 80.0
        
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func importButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            buttonTapAudioPlayer.play()
        }
    }
    @IBAction func exportButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            buttonTapAudioPlayer.play()
        }
    }
    
    
    @IBAction func unwindToCom(_ segue: UIStoryboardSegue) {
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
