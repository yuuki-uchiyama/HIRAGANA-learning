//
//  SlideViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/05.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SlideViewController: SlideMenuController {
    
    var gameView:GameViewController!
    
    override func awakeFromNib() {
        gameView = storyboard?.instantiateViewController(withIdentifier: "Main") as! GameViewController
        let rightVC = storyboard?.instantiateViewController(withIdentifier: "Right")

        mainViewController = gameView
        rightViewController = rightVC
        SlideMenuOptions.panGesturesEnabled = false
        SlideMenuOptions.contentViewDrag = false
        SlideMenuOptions.tapGesturesEnabled = true
        
        super.awakeFromNib()
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
