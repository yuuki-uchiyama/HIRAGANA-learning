//
//  GameViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit

class GameViewController: UIViewController{
    var image1 = UIImage(named: "1")
    var image2 = UIImage(named: "2")
    var image3 = UIImage(named: "3")
    var image4 = UIImage(named: "4")
    var imageArray = [(UIImage)].self
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var choicesFrame: UIImageView!
    @IBOutlet weak var AnswerFrame: UIImageView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var coverViewButton: UIButton!
    @IBOutlet weak var AnswerWord: UILabel!
    
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    var imageView3 = UIImageView()
    var imageView4 = UIImageView()
    
    var numberOfChoices = 4
    var firstContact = true
    var problemNumber = 0
    var choiceIdArray: [Int] = []

    
    var locationBeforeTouch = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coverView.isHidden = false
        coverViewButton.setTitle("開く", for: .normal)
    }
    
    func cardSelect(){
        let choiceId:Int = Int(arc4random_uniform(4))
        if choiceIdArray.contains(choiceId){
            cardSelect()
        }else{
            choiceIdArray.append(choiceId)
            }
    }
    
    func setChoice(){
        let center = choicesFrame.frame.origin.y + choicesFrame.frame.height/2
        
        for i in 1 ... numberOfChoices{
            let ChoiceId:Int = Int(arc4random_uniform(4))
            if choiceIdArray.contains(ChoiceId){
                choiceIdArray.append(ChoiceId)
                let image = UIImage(named: "\(ChoiceId)")
                let imageView = UIImageView(image: image)
                imageView.tag = i
                let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
                imageView.addGestureRecognizer(panGesture)
                imageView.isUserInteractionEnabled = true
                let imageInterval = choicesFrame.frame.width / CGFloat(numberOfChoices + 1)
                imageView.center = CGPoint(x: choicesFrame.frame.origin.x + imageInterval * CGFloat(i), y: center)
            self.view.addSubview(imageView)
            }
        }
        
//        let panGesture3: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
//        imageView3 = UIImageView(image: image3)
//        imageView3.tag = 3
//        imageView3.addGestureRecognizer(panGesture3)
//        imageView3.isUserInteractionEnabled = true
//        let panGesture2: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
//        imageView2 = UIImageView(image: image2)
//        imageView2.tag = 2
//        imageView2.addGestureRecognizer(panGesture2)
//        imageView2.isUserInteractionEnabled = true
//        let panGesture1: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
//        imageView1 = UIImageView(image: image1)
//        imageView1.tag = 1
//        imageView1.addGestureRecognizer(panGesture1)
//        imageView1.isUserInteractionEnabled = true
//
//        if numberOfChoices == 2{
//            imageView4.center = CGPoint(x: center.x - choicesRange/6, y: center.y)
//            imageView3.center = CGPoint(x: center.x + choicesRange/6, y: center.y)
//            self.view.addSubview(imageView4)
//            self.view.addSubview(imageView3)
//        }else if numberOfChoices == 3{
//            imageView4.center = CGPoint(x: center.x - choicesRange/4, y: center.y)
//            imageView3.center = CGPoint(x: center.x, y: center.y)
//            imageView2.center = CGPoint(x: center.x + choicesRange/4, y: center.y)
//            self.view.addSubview(imageView4)
//            self.view.addSubview(imageView3)
//            self.view.addSubview(imageView2)
//        }else if numberOfChoices == 4{
//            imageView4.center = CGPoint(x: center.x - choicesRange*3/10, y: center.y)
//            imageView3.center = CGPoint(x: center.x - choicesRange/10, y: center.y)
//            imageView2.center = CGPoint(x: center.x + choicesRange/10, y: center.y)
//            imageView1.center = CGPoint(x: center.x + choicesRange*3/10, y:center.y)
//            self.view.addSubview(imageView4)
//            self.view.addSubview(imageView3)
//            self.view.addSubview(imageView2)
//            self.view.addSubview(imageView1)
//        }
    }
    
    @objc func imageMoved(sender: UIPanGestureRecognizer) {
        //移動開始時の位置を記憶
        if sender.state == .began{
            locationBeforeTouch.origin = sender.view!.frame.origin
        }
        //移動処理
        let move:CGPoint = sender.translation(in: view)
        sender.view!.center.x += move.x
        sender.view!.center.y += move.y
        
        sender.setTranslation(CGPoint.zero, in: view)
        
        if sender.state == .ended{
            if AnswerFrame.frame.contains(sender.view!.center){
                if sender.view!.tag == 4{
                    performSegue(withIdentifier: "toCorrect", sender: nil)
                    removeAllImage()
                }else{
                    firstContact = false
                }
            }
            sender.view!.frame.origin = locationBeforeTouch.origin
        }
    }


    @IBAction func handleCoverView(_ sender: Any) {
        if coverView.isHidden == false{
            coverView.isHidden = true
            coverViewButton.setTitle("隠す", for: .normal)
        }else{
            coverView.isHidden = false
            coverViewButton.setTitle("開く", for: .normal)
        }
        
    }
    
    @IBAction func decreaseChoice(_ sender: Any) {
        if numberOfChoices > 2 {
            numberOfChoices -= 1
            removeAllImage()
            setChoice()
        }
    }
    
    @IBAction func increaseChoice(_ sender: Any) {
        if numberOfChoices < 4 {
            numberOfChoices += 1
            removeAllImage()
            setChoice()
        }
    }
    
    func removeAllImage(){
        let subviews = view.subviews
        for subview in subviews {
            if subview.tag >= 1{
            subview.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCorrect"{
        let correctViewController:CorrectViewController = segue.destination as! CorrectViewController
        correctViewController.answerWord = AnswerWord.text!
        problemNumber += 1
        correctViewController.questionCount += problemNumber
            print("問題数：\(problemNumber)")
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
