//
//  CorrectViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class CorrectViewController: UIViewController {
    
    @IBOutlet weak var wordFrame: UIView!
    @IBOutlet weak var correctImageView: UIImageView!
    var correctImage: UIImage!
    
    var answerWord :String = ""
    var characterCount = 0
    var readCount = 0
    var toResultBool = false
    var correctCount = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        correctImageView.image = correctImage
        
        characterCount = answerWord.count
        for i in 1 ... characterCount{
            let word = UILabel()
            word.frame.size = CGSize(width: wordFrame.frame.size.height, height: wordFrame.frame.size.height)
            word.text = String(answerWord[answerWord.index(answerWord.startIndex, offsetBy: i-1) ..< answerWord.index(answerWord.startIndex, offsetBy: i)])
            word.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 100)
            word.tag = i
            let interval = wordFrame.frame.width / CGFloat(characterCount + 1)
            word.center = CGPoint(x: wordFrame.frame.origin.x + interval * CGFloat(i), y: wordFrame.frame.origin.y + wordFrame.frame.size.height / 2)
            self.view.addSubview(word)
        }
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(readingCharacter))
        self.view.addGestureRecognizer(tapGesture)

    }
    
    
    @objc func readingCharacter(){
        if readCount == characterCount{
            if toResultBool{
                performSegue(withIdentifier: "toCM", sender: nil)
            }else{
            self.dismiss(animated: true, completion: nil)
            }
        }else {
            readCount += 1
            let character = self.view.viewWithTag(readCount) as! UILabel
            character.textColor = UIColor.red
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
