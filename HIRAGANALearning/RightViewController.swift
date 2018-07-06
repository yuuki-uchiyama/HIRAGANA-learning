//
//  RightViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/05.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

protocol choicesDelegate {
    func decreaseChoices()
    func increaseChoices()
}

class RightViewController: UIViewController {
    var delegate: choicesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func decreaseChoice(_ sender: Any) {
        self.delegate?.decreaseChoices()
    }
    
    @IBAction func increaseChoice(_ sender: Any) {
        self.delegate?.increaseChoices()
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
