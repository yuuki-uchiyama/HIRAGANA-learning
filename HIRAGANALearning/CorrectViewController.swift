//
//  CorrectViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class CorrectViewController: UIViewController {
    
    var answerWord :String = ""
    var readCount = 0
    var questionCount = 0
    var correctCount = 0
    
    @IBOutlet weak var word1: UILabel!
    @IBOutlet weak var word2: UILabel!
    @IBOutlet weak var word3: UILabel!
    @IBOutlet weak var word4: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCount = answerWord.characters.count
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(readingCharacter))
        self.view.addGestureRecognizer(tapGesture)

    }
    
    
    @objc func readingCharacter(){
        if readCount == 0{
            if questionCount == 10{
                performSegue(withIdentifier: "toCM", sender: nil)
            }else{
            self.dismiss(animated: true, completion: nil)
            }
        }else if readCount == 1 {
            readCount -= 1
            word4.textColor = UIColor.red
        }else if readCount == 2 {
            readCount -= 1
            word3.textColor = UIColor.red
        }else if readCount == 3 {
            readCount -= 1
            word2.textColor = UIColor.red
        }else if readCount ==  4{
            readCount -= 1
            word1.textColor = UIColor.red
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCM"{
            let cmViewController:CMViewController = segue.destination as! CMViewController
            cmViewController.correctCount = self.correctCount
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
