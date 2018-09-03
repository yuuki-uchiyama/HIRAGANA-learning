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
import SVProgressHUD

class CardData{
    var word: String!
    var image: NSData!
    
    init(_ w:String,_ i:NSData){
        word = w
        image = i
    }
}

class GameViewController: UIViewController, choicesDelegate{
    
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var choicesFrame: UIImageView!
    @IBOutlet weak var AnswerFrame: UIImageView!
    @IBOutlet weak var AnswerWord: UILabel!
    
//    問題出現前のview
    var correctAddButton: UIButton!
    var tapGestureImage: UIImageView!
    

    
//    選んでいる絵のタグ
    var choiceTag = 0
    
//    選択肢の数
    var numberOfChoices = 3
    
//    配置関連
    var imageViewSize: CGFloat!
    var imageInterval:CGFloat = 0.0
    var choicePosition:CGPoint!
    
//    正解数・問題数・ご褒美
    var firstContact = true
    var recordArray: [URL] = []
    var correctArray: [UIImage] = []
    var correctCount = 0
    var problemNumber = 0

//  問題選び
    var choiceCount: Int!
    var choiceCountArray: [Int] = []
    var cardArray = try! Realm().objects(Card.self)
    var cardDataArray: [CardData] = []
    var deleteCardArray: [Int] = []
    var choiceCardDataArray: [CardData] = []
    var choiceLevel = 0
    var correctImageView : UIImageView!
    var correctImage: UIImage!
    var correctTag = 0
    var correctNumber = 0
    
//    ヒント
    var hintInterval = 0.0
    var hintTimer: Timer!
    var hintArray: [UIView] = []
    
//    ドラッグ操作
    var locationBeforeTouch = CGRect()
    
//    効果音関連
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
    
    var alertBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCardDataFromRealm()
        
        if cardArray.count < 5{
            alertBool = true
        }else{
            alertBool = false
        }
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if alertBool{
            popUp()
        }
        if cardArray.count >= 5{
            imageViewSize = choicesFrame.frame.size.height * 0.8
            choicePosition = CGPoint(x: choicesFrame.frame.origin.x, y:choicesFrame.frame.origin.y + choicesFrame.frame.height/2)
            firstContact = true
            switchControl = userDefaults.integer(forKey: Constants.SwitchKey)
            setting()
        }
    }

    func popUp(){
        print("popup")
        let alertController: UIAlertController = UIAlertController(title: "カードの枚数が足りません", message: "カードが５枚以上必要です", preferredStyle: .alert)
        let card = UIAlertAction(title: "カード編集へ", style: .default, handler:{(action: UIAlertAction!) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "toCard", sender: nil)
            }
        })
        let level = UIAlertAction(title: "難易度設定へ", style: .default, handler:{(action: UIAlertAction!) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "toChoiceLevel", sender: nil)
            }
        })
        alertController.addAction(card)
        alertController.addAction(level)
        present(alertController, animated: true, completion: nil)
        alertBool = false
    }
    
    func setting(){
        intervalCalculate()
        if cardDataArray.count - deleteCardArray.count < 5{
            deleteCardArray.removeAll()
        }
        if problemNumber > 0{
            print(cardDataArray[correctNumber].word)
            deleteCardArray.append(correctNumber)
        }
        for _ in 0 ... numberOfChoices{
        cardSelect()
        }
        setCorrect()
        setHint()
        setChoice()
        choiceCountArray.removeAll()
        startQuestion()
        switchController()
        print(cardDataArray.count)
        }
    
    
    func intervalCalculate(){
        imageInterval = choicesFrame.frame.width / CGFloat(numberOfChoices + 2)
    }
    
//    ゲームの準備
    func loadCardDataFromRealm(){
        if choiceLevel <= 5{
            cardArray = try! Realm().objects(Card.self).filter("group = \(choiceLevel)")
        }else if choiceLevel == 6 {
            cardArray = try! Realm().objects(Card.self).filter("originalDeck1 = true")
        }else if choiceLevel == 7{
            cardArray = try! Realm().objects(Card.self).filter("originalDeck2 = true")
        }else if choiceLevel == 8{
            cardArray = try! Realm().objects(Card.self)
        }
        cardDataArray = []
        for card in cardArray{
            let cardData = CardData(card.word, card.image!)
            cardDataArray.append(cardData)
        }
    }
    
    func cardSelect(){
        let choiceCount:Int = Int(arc4random_uniform(UInt32(cardArray.count)))
        if choiceCountArray.contains(choiceCount) || deleteCardArray.contains(choiceCount){
            cardSelect()
        }else{
            choiceCountArray.append(choiceCount)
        }
    }
    
    func setCorrect(){
        let random = Int(arc4random_uniform(UInt32(numberOfChoices)))
        correctNumber = choiceCountArray[random]
        let cardData = cardDataArray[correctNumber]
        correctTag = random + 1
        correctImage = UIImage(data: cardData.image! as Data)
        correctImageView = UIImageView(image: correctImage)
        correctImageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
        correctImageView.contentMode = UIViewContentMode.scaleAspectFit
        correctImageView.center = AnswerFrame.center
        self.view.addSubview(correctImageView)
        AnswerWord.text = cardData.word
    }
    
    func setChoice(){
        for i in 0 ... numberOfChoices{
            let cardData = cardDataArray[choiceCountArray[i]]
            let image = UIImage(data: cardData.image! as Data)
            let imageView = UIImageView(image: image)
            imageView.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.tag = i + 1
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target:self, action:#selector(imageMoved(sender: )))
            imageView.addGestureRecognizer(panGesture)
            imageView.isUserInteractionEnabled = true
            imageView.isExclusiveTouch = true
            imageView.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(i + 1), y: choicePosition.y)
            self.view.addSubview(imageView)
        }
    }
    
    func setHint(){
        for i in 0 ... 3599{
            let hintView = UIView()
            let hintViewSize = correctImageView.frame.width / 60
            hintView.backgroundColor = UIColor.lightGray
            hintView.frame.size = CGSize(width: hintViewSize, height: hintViewSize)
            hintView.frame.origin.x = hintViewSize * CGFloat(i % 60)
            hintView.frame.origin.y = hintViewSize * floor(CGFloat(i / 60))
            hintArray.append(hintView)
            correctImageView.addSubview(hintView)
        }
    }
    
    func startQuestion(){
        AnswerWord.isHidden = true
        correctAddButton = UIButton()
        correctAddButton.layer.backgroundColor = UIColor.yellow.cgColor
        correctAddButton.layer.cornerRadius = 150.0
        correctAddButton.frame.size = CGSize(width: 300, height: 300)
        correctAddButton.center = view.center
        correctAddButton.addTarget(self, action: #selector(correctLabelAdded), for: .touchUpInside)
        self.view.addSubview(correctAddButton)
        let tapGesture = UIImage(named: "tapGesture")
        tapGestureImage = UIImageView(image: tapGesture)
        tapGestureImage.frame.origin = view.center
        self.view.addSubview(tapGestureImage)
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
        hintTimer = Timer.scheduledTimer(timeInterval: TimeInterval(hintInterval), target: self, selector: #selector(hint), userInfo: nil, repeats: true)
        scanTimerAdjust()
    }
    
    @objc func hint(){
        for _ in 0 ... 2{
            let hintId = Int(arc4random_uniform(UInt32(hintArray.count)))
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [.curveEaseIn], animations: {
                self.hintArray[hintId].alpha = 0.0
                self.hintArray.remove(at: hintId)
            })
            if hintArray.count == 0{
                self.hintTimer.invalidate()
                break
            }
        }
    }
    
//    ドラッグ移動の機能設定
    @objc func imageMoved(sender: UIPanGestureRecognizer) {
        if sender.state == .began{
            choiceTag = sender.view!.tag
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
                judgment()
            }
            sender.view!.frame.origin = locationBeforeTouch.origin
            if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            dragEndedAudioPlayer.play()
            }
        }
    }
    
    func judgment(){
        if choiceTag == correctTag{
            correctSegue()
        }else{
            firstContact = false
            if UserDefaults.standard.bool(forKey: Constants.incorrectSoundKey) == false{
                incorrectAudioPlayer.play()
                self.scanTimerAdjust()
            }
        }
    }
    
    func correctSegue(){
        hintTimer.invalidate()
        if UserDefaults.standard.bool(forKey: Constants.correctSoundKey) == false{
            correctAudioPlayer.play()
        }
        if firstContact{
            performSegue(withIdentifier: "toRecord", sender: nil)
        }else{
            performSegue(withIdentifier: "toCorrect", sender: nil)
        }
        choiceCountArray.removeAll()
        correctTag = 0
        removeAllImage()
    }

//設定画面の操作
    @IBAction func handleCoverView(_ sender: Any) {
        if switchControl == 1 {
            singleSwitchTimer.invalidate()
        }
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
        if singleSwitchTimer != nil{
            singleSwitchTimer.invalidate()
        }
        if segue.identifier == "toCorrect"{
        let correctViewController:CorrectViewController = segue.destination as! CorrectViewController
        correctViewController.answerWord = AnswerWord.text!
            correctViewController.correctImage = self.correctImage
        problemNumber += 1
            if problemNumber == 10 {
                correctViewController.toResultBool = true
                correctViewController.recordArray = self.recordArray
                correctViewController.correctArray = self.correctArray
                correctViewController.correctCount = self.correctCount
            }
        }else if segue.identifier == "toRecord"{
            correctCount += 1
            problemNumber += 1
            let recordVC: RecordViewController = segue.destination as! RecordViewController
            recordVC.answerWord = AnswerWord.text!
            recordVC.correctImage = self.correctImageView.image
            recordVC.correctCount = self.correctCount
            if problemNumber == 10 {
                recordVC.toResultBool = true
                recordVC.recordArray = self.recordArray
             recordVC.correctArray = self.correctArray
            }
        }
    }
    
//    choicesDelegateのデリゲートメソッド（rightVCのボタンタップで起動）
    func decreaseChoices() {
        if self.numberOfChoices > 1 {
            self.numberOfChoices -= 1
            closeRight()
            self.removeAllImage()
            setting()
        }
    }
    
    func  increaseChoices() {
        if self.numberOfChoices < 3 {
            self.numberOfChoices += 1
            closeRight()
            self.removeAllImage()
            setting()
        }
    }
    func toHome(){
        closeRight()
        performSegue(withIdentifier: "toHome", sender: nil)
    }
    
    func toChoiceLevel(){
        closeRight()
        performSegue(withIdentifier: "toChoiceLevel", sender: nil)
    }
    
    func scanTimerAdjust(){
        if switchControl == 1{
                        self.singleSwitchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(self.cursorMove), userInfo: nil, repeats: true)
            
        }
    }
    
    func switchController(){
        if switchControl != 0{
            switchControlTextField.frame.origin = CGPoint(x: view.frame.width, y: view.frame.height)
            self.view.addSubview(switchControlTextField)
            switchControlTextField.inputAssistantItem.leadingBarButtonGroups.removeAll()
            switchControlTextField.inputAssistantItem.trailingBarButtonGroups.removeAll()
            switchControlTextField.becomeFirstResponder()
            cursor.frame.size = CGSize(width: imageViewSize, height: imageViewSize)
            cursor.layer.borderColor = UIColor.yellow.cgColor
            cursor.layer.borderWidth = 9
            cursor.layer.cornerRadius = 20.0
            cursor.center = CGPoint(x: choicePosition.x + imageInterval, y: choicePosition.y)
            cursorTag = 1
            self.view.addSubview(cursor)
            self.view.insertSubview(cursor, aboveSubview: choicesFrame)
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
            decisionSwitch = userDefaults.string(forKey: Constants.singleDecisionKey)!
            switchControlTextField.addTarget(self, action: #selector(SwitchDecision), for: .editingChanged)
        }else if switchControl > 1{
            toNextSwitch = userDefaults.string(forKey: Constants.toNextKey)!
            if switchControl == 3{
            toPreviousSwitch = userDefaults.string(forKey: Constants.toPreviousKey)!
            }
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
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            switchControlTextField.resignFirstResponder()
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else{
                singleSwitchTimer.invalidate()
                choiceTag = cursorTag
                let cursorChoice = self.view.viewWithTag(cursorTag) as! UIImageView
                let moveDistanceX = correctImageView.center.x - cursorChoice.center.x
                let moveDistanceY = correctImageView.center.y - cursorChoice.center.y
                let originalPosition = cursorChoice.center
                UIView.animate(withDuration: 0.5, animations: {
                    cursorChoice.center = CGPoint(x: originalPosition.x + moveDistanceX, y: originalPosition.y + moveDistanceY)
                }, completion: { finished in
                    self.judgment()
                    UIView.animate(withDuration: 0.3, animations: {
                    cursorChoice.center = originalPosition
                    })
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.switchControlTextField.becomeFirstResponder()
            }
        }
        print(switchControlTextField.text!)
        switchControlTextField.text = ""
    }
    
    @objc func multipleSwitches(){
        if (switchControlTextField.text?.isHiragana)! || (switchControlTextField.text?.isKatakana)!{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "日本語入力をオフにしてください")
        }
        if (switchControlTextField.text?.lowercased().contains(toNextSwitch))! {
            switchControlTextField.resignFirstResponder()
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else if cursorTag > numberOfChoices{
                cursorTag = 1
            }else{
                cursorTag += 1
            }
            cursor.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(cursorTag), y: choicePosition.y)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.switchControlTextField.becomeFirstResponder()
            }
        }else if (switchControlTextField.text?.lowercased().contains(toPreviousSwitch))!{
            switchControlTextField.resignFirstResponder()
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else if cursorTag == 1{
                cursorTag = numberOfChoices + 1
            }else{
                cursorTag -= 1
            }
            cursor.center = CGPoint(x: choicePosition.x + imageInterval * CGFloat(cursorTag), y: choicePosition.y)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.switchControlTextField.becomeFirstResponder()
            }        }
        if (switchControlTextField.text?.lowercased().contains(decisionSwitch))! {
            switchControlTextField.resignFirstResponder()
            if AnswerWord.isHidden{
                correctLabelAdded()
            }else{
                choiceTag = cursorTag
                let cursorChoice = self.view.viewWithTag(cursorTag) as! UIImageView
                let moveDistanceX = correctImageView.center.x - cursorChoice.center.x
                let moveDistanceY = correctImageView.center.y - cursorChoice.center.y
                let originalPosition = cursorChoice.center
                UIView.animate(withDuration: 0.5, animations: {
                    cursorChoice.center = CGPoint(x: originalPosition.x + moveDistanceX, y: originalPosition.y + moveDistanceY)
                }, completion: { finished in
                    self.judgment()
                        UIView.animate(withDuration: 0.3, animations: {
                            cursorChoice.center = originalPosition
                        })
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.switchControlTextField.becomeFirstResponder()
            }
        }
        switchControlTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToGame(_ segue:UIStoryboardSegue){
    }
}
