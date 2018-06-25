//
//  CMViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class CMViewController: UIViewController {

    var correctCount = 0
    var timer: Timer!
    @IBOutlet weak var countDownLabel: UILabel!
    var countDownSecond = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)

        // Do any additional setup after loading the view.
    }
    @objc func countDown(){
        if countDownSecond == 1 {
            countDownLabel.text = "OK!!"
            self.timer.invalidate()
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toResultSegue))
            self.view.addGestureRecognizer(tapGesture)
        }else{
            countDownSecond -= 1
            countDownLabel.text = "ちょっとまってね　\(countDownSecond)秒"
        }
        
    }
    
    @objc func toResultSegue(){
        performSegue(withIdentifier: "toResult", sender: nil)
        countDownSecond = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let resultViewController:ResultViewController = segue.destination as! ResultViewController
            resultViewController.correctCount = self.correctCount
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
