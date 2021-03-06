//
//  OperateViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class OperateViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var singleSwitchButton: UIButton!
    @IBOutlet weak var multipleSwitchButton: UIButton!
    @IBOutlet weak var noSwitchButton: UIButton!
    
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    var importantAudioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 40.0
        singleSwitchButton.layer.cornerRadius = 40.0
        multipleSwitchButton.layer.cornerRadius = 40.0
        noSwitchButton.layer.cornerRadius = 100.0

        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Important") {
            importantAudioPlayer = try! AVAudioPlayer(data: asset.data)
            importantAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToOperate(_ segue:UIStoryboardSegue){
        }
    
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func singleSwitchButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func multipleSwitchButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
    }
    @IBAction func noSwitchButton(_ sender: Any) {
        let alertController = UIAlertController(title: "ボタン設定を解除しますか？", message: nil, preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .destructive, handler: {
            (acrion:UIAlertAction) -> Void in
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
                self.importantAudioPlayer.play()
            }
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: Constants.SwitchKey)
            userDefaults.removeObject(forKey: Constants.cursorSpeedKey)
            userDefaults.removeObject(forKey: Constants.singleDecisionKey)
            userDefaults.removeObject(forKey: Constants.toNextKey)
            userDefaults.removeObject(forKey: Constants.toPreviousKey)
            userDefaults.removeObject(forKey: Constants.multiDecisionKey)
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "ボタン操作を解除しました")
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(OK)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
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
