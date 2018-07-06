//
//  GameViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/21.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import SlideMenuControllerSwift

class GameViewController: UIViewController, choicesDelegate{

    @IBOutlet weak var choicesFrame: UIImageView!
    @IBOutlet weak var AnswerFrame: UIImageView!
    @IBOutlet weak var AnswerWord: UILabel!
    var correctImageView : UIImageView!
    var correctTag = 0
    var imageViewSize: CGFloat!
    
    var numberOfChoices = 3
    var firstContact = true
    var problemNumber = 0
    var collectCount = 0
    var choiceId: Int!
    var choiceIdArray: [Int] = []
    var cardArray = try! Realm().objects(Card.self)
    var choiceLevel = 0
    var hintDuration = 20.0
    
    var locationBeforeTouch = CGRect()
    
    let rightVC = RightViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightVC.delegate = self
        
        if 2 ... 5 ~= choiceLevel{
        cardArray = try! Realm().objects(Card.self).filter("group = \(choiceLevel)")
        }else if choiceLevel == 6 {
        cardArray = try! Realm().objects(Card.self).filter("originalDeck1 = true")
        }else if choiceLevel == 7{
            cardArray = try! Realm().objects(Card.self).filter("originalDeck2 = true")
        }else if choiceLevel == 8{
            cardArray = try! Realm().objects(Card.self)
        }
        imageViewSize = choicesFrame.frame.size.height * 0.8
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cardArray.count > 4{
        for _ in 0 ... 3{
            cardSelect()
        }
        setCorrect()
        setChoice()
        }
        firstContact = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if cardArray.count < 6{
            popUp()
        }
    }
    
    func popUp(){
        let alertController: UIAlertController = UIAlertController(title: "カードの枚数が足りません", message: "カード５枚以上必要です", preferredStyle: .alert)
        let card = UIAlertAction(title: "カード編集へ", style: .default, handler:{(action: UIAlertAction!) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let storyboard: UIStoryboard = self.storyboard!
                let Card = storyboard.instantiateViewController(withIdentifier: "Card")
                self.present(Card, animated: true, completion: nil)
            }
        })
        let level = UIAlertAction(title: "難易度設定へ", style: .default, handler:{(action: UIAlertAction!) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "unwindToChoiceLevel", sender: nil)
            }
        })
        alertController.addAction(card)
        alertController.addAction(level)
        present(alertController, animated: true, completion: nil)
    }
    
    func cardSelect(){
        let choiceId:Int = Int(arc4random_uniform(UInt32(cardArray.count)))
        if choiceIdArray.contains(choiceId){
            cardSelect()
        }else{
            choiceIdArray.append(choiceId)
            }
    }
    
    func setChoice(){
        let center = choicesFrame.frame.origin.y + choicesFrame.frame.height/2
        
        for i in 0 ... numberOfChoices{
            let image = UIImage(data: cardArray[choiceIdArray[i]].image! as Data)
            let imageView = UIImageView(image: image)
            imageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
            imageView.tag = i
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
            imageView.addGestureRecognizer(panGesture)
            imageView.isUserInteractionEnabled = true
            let imageInterval = choicesFrame.frame.width / CGFloat(numberOfChoices + 2)
            imageView.center = CGPoint(x: choicesFrame.frame.origin.x + imageInterval * CGFloat(i + 1), y: center)
            self.view.addSubview(imageView)
        }
    }
    
    func setCorrect(){
        correctTag = Int(arc4random_uniform(UInt32(numberOfChoices)))
        let correctImage = UIImage(data: cardArray[choiceIdArray[correctTag]].image! as Data)
        correctImageView = UIImageView(image: correctImage)
        correctImageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
        correctImageView.center = AnswerFrame.center
        correctImageView.alpha = 0.0
        UIView.animate(withDuration: hintDuration, delay: 1.0, options: [.curveEaseIn], animations: {
            self.correctImageView.alpha = 1.0
        }, completion: nil)

        self.view.addSubview(correctImageView)
        AnswerWord.text = cardArray[choiceIdArray[correctTag]].word
    }
    
//    ドラッグ移動の機能設定
    @objc func imageMoved(sender: UIPanGestureRecognizer) {
        if sender.state == .began{
            locationBeforeTouch.origin = sender.view!.frame.origin
        }
        let move:CGPoint = sender.translation(in: view)
        sender.view!.center.x += move.x
        sender.view!.center.y += move.y
        
        sender.setTranslation(CGPoint.zero, in: view)
        
        if sender.state == .ended{
            if AnswerFrame.frame.contains(sender.view!.center){
                if sender.view!.tag == correctTag{
                    if firstContact{
                        collectCount += 1
                    }
                    print(collectCount)
                    performSegue(withIdentifier: "toCorrect", sender: nil)
                    choiceIdArray.removeAll()
                    correctTag = 0
                    removeAllImage()
                }else{
                    firstContact = false
                }
            }
            sender.view!.frame.origin = locationBeforeTouch.origin
        }
    }

//設定画面の操作
    @IBAction func handleCoverView(_ sender: Any) {
        self.slideMenuController()?.openRight()
    }
//    デリゲートを作る　→ rightViewにデリゲートを委譲　→ 実行のタイミングや引数を決める


    
    func removeAllImage(){
        let subviews = view.subviews
        for subview in subviews {
            if subview.tag < 100{
            subview.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCorrect"{
        let correctViewController:CorrectViewController = segue.destination as! CorrectViewController
        correctViewController.answerWord = AnswerWord.text!
            correctViewController.correctImage = self.correctImageView.image
        problemNumber += 1
            if problemNumber == 10 {
                correctViewController.toResultBool = true
                correctViewController.correctCount = collectCount
            }
            print("問題数：\(problemNumber)")
        }
    }
    
//    choicesDelegateのデリゲートメソッド（rightVCのボタンタップで起動）
    func decreaseChoices() {
        if self.numberOfChoices > 0 {
            self.numberOfChoices -= 1
            self.removeAllImage()
            self.setChoice()
            rightVC.dismiss(animated: true, completion: nil)
        }
        print("decrease")
    }
    
    func  increaseChoices() {
        if self.numberOfChoices < 3 {
            self.numberOfChoices += 1
            self.removeAllImage()
            self.setChoice()
            rightVC.dismiss(animated: true, completion: nil)
        }
        print("increase")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
