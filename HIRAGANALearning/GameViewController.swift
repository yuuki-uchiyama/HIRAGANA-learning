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
import AVFoundation

class GameViewController: UIViewController, choicesDelegate{
    
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var choicesFrame: UIImageView!
    @IBOutlet weak var AnswerFrame: UIImageView!
    @IBOutlet weak var AnswerWord: UILabel!
    
    var correctAddButton: UIButton!
    var tapGestureImage: UIImageView!
    var correctImageView : UIImageView!
    var correctTag = 0
    var imageViewSize: CGFloat!
    
    var numberOfChoices = 3
    var imageInterval:CGFloat = 0.0
    var choicePosition:CGPoint!
    var firstContact = true
    var problemNumber = 0
    var collectCount = 0
    var choiceId: Int!
    var choiceIdArray: [Int] = []
    var cardArray = try! Realm().objects(Card.self)

    var choiceLevel = 0
    var choiceGroupArray: [Int] = []
    var hintDuration = 0.0
    
    var locationBeforeTouch = CGRect()
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    var dragBeganAudioPlayer: AVAudioPlayer!
    var dragEndedAudioPlayer: AVAudioPlayer!
    var questionAudioPlayer: AVAudioPlayer!
    var correctAudioPlayer: AVAudioPlayer!
    var incorrectAudioPlayer: AVAudioPlayer!
    
    let switchControlTextField: UITextField = UITextField()
    var switchControl = 0
    var cursor: UIView = UIView()
    var cursorTag = 1
    var decisionSwitch = ""
    var singleSwitchTimer :Timer!
    var timeInterval = 0
    var toNextSwitch = ""
    var toPreviousSwitch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choiceLevel <= 5{
        cardArray = try! Realm().objects(Card.self).filter("group = \(choiceLevel)")
        }else if choiceLevel == 6 {
        cardArray = try! Realm().objects(Card.self).filter("originalDeck1 = true")
        }else if choiceLevel == 7{
            cardArray = try! Realm().objects(Card.self).filter("originalDeck2 = true")
        }else if choiceLevel == 8{
            cardArray = try! Realm().objects(Card.self)
        }
        imageViewSize = choicesFrame.frame.size.height * 0.8
        choicePosition = CGPoint(x: choicesFrame.frame.origin.x, y:choicesFrame.frame.origin.y + choicesFrame.frame.height/2)
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Question") {
            questionAudioPlayer = try! AVAudioPlayer(data: asset.data)
            questionAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "DragBegan") {
            dragBeganAudioPlayer = try! AVAudioPlayer(data: asset.data)
            dragBeganAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "DragEnded") {
            dragEndedAudioPlayer = try! AVAudioPlayer(data: asset.data)
            dragEndedAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Correct") {
            correctAudioPlayer = try! AVAudioPlayer(data: asset.data)
            correctAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Incorrect") {
            incorrectAudioPlayer = try! AVAudioPlayer(data: asset.data)
            incorrectAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        intervalCalculate()
        if cardArray.count > 4{

        for _ in 0 ... numberOfChoices{
            cardSelect()
        }
        setCorrect()
        setChoice()
        }
        firstContact = true
        AnswerWord.isHidden = true
        correctAddButton = UIButton()
        correctAddButton.backgroundColor = UIColor.yellow
        correctAddButton.layer.cornerRadius = 150.0
        correctAddButton.frame.size = CGSize(width: 300, height: 300)
        correctAddButton.center = view.center
        correctAddButton.addTarget(self, action: #selector(correctLabelAdded), for: .touchUpInside)
        self.view.addSubview(correctAddButton)
        let tapGesture = UIImage(named: "tapGesture")
        tapGestureImage = UIImageView(image: tapGesture)
        tapGestureImage.frame.origin = view.center
        self.view.addSubview(tapGestureImage)
        
        switchControl = userDefaults.integer(forKey: Constants.SwitchKey)
        switchController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cardArray.count < 5{
            popUp()
        }
    }

    func popUp(){
        let alertController: UIAlertController = UIAlertController(title: "カードの枚数が足りません", message: "カードが５枚以上必要です", preferredStyle: .alert)
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
    
    func intervalCalculate(){
        imageInterval = choicesFrame.frame.width / CGFloat(numberOfChoices + 2)
    }
    
    func setChoice(){
        
        for i in 0 ... numberOfChoices{
            let image = UIImage(data: cardArray[choiceIdArray[i]].image! as Data)
            let imageView = UIImageView(image: image)
            imageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.tag = i + 1
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
            imageView.addGestureRecognizer(panGesture)
            imageView.isUserInteractionEnabled = true
            imageView.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(i + 1), y: choicePosition.y)
            self.view.addSubview(imageView)
        }
    }
    
    func setCorrect(){
        let randomNumber = Int(arc4random_uniform(UInt32(numberOfChoices)))
        correctTag = randomNumber + 1
        let correctImage = UIImage(data: cardArray[choiceIdArray[randomNumber]].image! as Data)
        correctImageView = UIImageView(image: correctImage)
        correctImageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
        correctImageView.contentMode = UIViewContentMode.scaleAspectFit
        correctImageView.center = AnswerFrame.center
        correctImageView.alpha = 0.0

        self.view.addSubview(correctImageView)
        AnswerWord.text = cardArray[choiceIdArray[randomNumber]].word
    }
    
    @objc func correctLabelAdded(){
        correctAddButton.isHidden = true
        tapGestureImage.isHidden = true
        AnswerWord.isHidden = false
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.5
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.isRemovedOnCompletion = false
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 5.0
        animation1.toValue = 1.0
        let animation2 = CABasicAnimation(keyPath: "transform.rotation")
        animation2.fromValue = 0.0
        animation2.toValue = Double.pi * 4.0
        animationGroup.animations = [animation1, animation2]
        AnswerWord.layer.add(animationGroup, forKey: nil)
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            dragEndedAudioPlayer.play()
        }
        UIView.animate(withDuration: hintDuration, delay: 1.0, options: [.curveEaseIn], animations: {
            self.correctImageView.alpha = 1.0
        }, completion: nil)
    }
    
//    ドラッグ移動の機能設定
    @objc func imageMoved(sender: UIPanGestureRecognizer) {
        if sender.state == .began{
            locationBeforeTouch.origin = sender.view!.frame.origin
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            dragBeganAudioPlayer.play()
            }
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
                    if UserDefaults.standard.bool(forKey: Constants.correctSoundKey) == false{
                    correctAudioPlayer.play()
                    }
                    performSegue(withIdentifier: "toCorrect", sender: nil)
                    choiceIdArray.removeAll()
                    correctTag = 0
                    removeAllImage()
                }else{
                    firstContact = false
                    if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey) == false{
                    incorrectAudioPlayer.play()
                    }
                }
            }
            sender.view!.frame.origin = locationBeforeTouch.origin
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            dragEndedAudioPlayer.play()
            }
        }
    }

//設定画面の操作
    @IBAction func handleCoverView(_ sender: Any) {
        self.slideMenuController()?.openRight()
    }
    
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
        if self.numberOfChoices > 1 {
            self.numberOfChoices -= 1
            self.removeAllImage()
            intervalCalculate()
            for _ in 0 ... numberOfChoices{
                cardSelect()
            }
            setCorrect()
            setChoice()
            closeRight()
            switchController()
        }
    }
    
    func  increaseChoices() {
        if self.numberOfChoices < 3 {
            self.numberOfChoices += 1
            self.removeAllImage()
            intervalCalculate()
            for _ in 0 ... numberOfChoices{
                cardSelect()
            }
            setCorrect()
            setChoice()
            closeRight()
            switchController()
        }
    }
    
    func switchController(){
        if switchControl != 0{
            switchControlTextField.frame.origin = CGPoint(x: view.frame.width, y: view.frame.height)
            self.view.addSubview(switchControlTextField)
            switchControlTextField.becomeFirstResponder()
            cursor.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
            cursor.layer.borderColor = UIColor.yellow.cgColor
            cursor.layer.borderWidth = 7.5
            cursor.layer.cornerRadius = 20.0
            cursor.center = CGPoint(x: choicePosition.x + imageInterval, y: choicePosition.y)
            cursorTag = 1
            self.view.addSubview(cursor)
            let switchLabel:UILabel = UILabel()
            switchLabel.frame.size = CGSize(width: 200, height: 30)
            switchLabel.backgroundColor = UIColor.yellow
            switchLabel.frame.origin = self.view.frame.origin
            switchLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 15)
            switchLabel.text = "スイッチコントロール起動中"
            self.view.addSubview(switchLabel)
        }
        if switchControl == 1{
            timeInterval = userDefaults.integer(forKey: Constants.cursorSpeedKey)
            self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(cursorMove), userInfo: nil, repeats: true)
            decisionSwitch = userDefaults.string(forKey: Constants.singleDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(SwitchDecision), for: .editingChanged)
        }else if switchControl > 1{
            toNextSwitch = userDefaults.string(forKey: Constants.toNextKey)!
            toPreviousSwitch = userDefaults.string(forKey: Constants.toPreviousKey)!
            decisionSwitch = userDefaults.string(forKey: Constants.multiDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(multipleSwitches), for: .editingChanged)
        }
    }
    
    @objc func cursorMove(){
        if cursorTag > numberOfChoices{
            cursorTag = 1
        }else{
        cursorTag += 1
        }
        cursor.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(cursorTag), y: choicePosition.y)
    }
    
    @objc func SwitchDecision(){
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else{
                singleSwitchTimer.invalidate()
                let cursorChoice = self.view.viewWithTag(cursorTag) as! UIImageView
                let moveDistanceX = correctImageView.center.x - cursorChoice.center.x
                let moveDistanceY = correctImageView.center.y - cursorChoice.center.y
                let originalPosition = cursorChoice.center
                UIView.animate(withDuration: 0.5, animations: {
                    cursorChoice.center = CGPoint(x: originalPosition.x + moveDistanceX, y: originalPosition.y + moveDistanceY)
                }, completion: { finished in
                    if self.cursorTag == self.correctTag{
                    if self.firstContact{
                        self.collectCount += 1
                    }
                    if UserDefaults.standard.bool(forKey: Constants.correctSoundKey) == false{
                        self.correctAudioPlayer.play()
                    }
                    self.performSegue(withIdentifier: "toCorrect", sender: nil)
                    self.choiceIdArray.removeAll()
                    self.correctTag = 0
                    self.removeAllImage()
                }else{
                    self.firstContact = false
                    if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey) == false{
                        self.incorrectAudioPlayer.play()
                    }
                        UIView.animate(withDuration: 0.3, animations: {
                            cursorChoice.center = originalPosition
                            })
                        self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.cursorMove), userInfo: nil, repeats: true)
                    }
                })
            }
        }
            switchControlTextField.text = ""
        print(correctTag)
        print(cursorTag)
    }
    
    @objc func multipleSwitches(){
        if (switchControlTextField.text?.lowercased().contains(toNextSwitch))! {
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else if cursorTag > numberOfChoices{
                cursorTag = 1
            }else{
                cursorTag += 1
            }
            cursor.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(cursorTag), y: choicePosition.y)
        }else if (switchControlTextField.text?.lowercased().contains(toPreviousSwitch))!{
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else if cursorTag == 1{
                cursorTag = numberOfChoices + 1
            }else{
                cursorTag -= 1
            }
            cursor.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(cursorTag), y: choicePosition.y)
        }
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else{
                let cursorChoice = self.view.viewWithTag(cursorTag) as! UIImageView
                let moveDistanceX = correctImageView.center.x - cursorChoice.center.x
                let moveDistanceY = correctImageView.center.y - cursorChoice.center.y
                let originalPosition = cursorChoice.center
                UIView.animate(withDuration: 0.5, animations: {
                    cursorChoice.center = CGPoint(x: originalPosition.x + moveDistanceX, y: originalPosition.y + moveDistanceY)
                }, completion: { finished in
                    if self.cursorTag == self.correctTag{
                        if self.firstContact{
                            self.collectCount += 1
                        }
                        if UserDefaults.standard.bool(forKey: Constants.correctSoundKey) == false{
                            self.correctAudioPlayer.play()
                        }
                        self.performSegue(withIdentifier: "toCorrect", sender: nil)
                        self.choiceIdArray.removeAll()
                        self.correctTag = 0
                        self.removeAllImage()
                    }else{
                        self.firstContact = false
                        if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey) == false{
                            self.incorrectAudioPlayer.play()
                        }
                        UIView.animate(withDuration: 0.3, animations: {
                            cursorChoice.center = originalPosition
                        })
                    }
                })
            }
        }
        switchControlTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
