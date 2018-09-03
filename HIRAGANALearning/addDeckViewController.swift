//
//  addDeckViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/20.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import SVProgressHUD

class addDeckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var decisionButton: UIButton!
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)
    var addArray:[Int] = []
    var originalDeck = ""
    var labelColor: UIColor!
    var labelText: String!
    
    var backAudioPlayer: AVAudioPlayer!
    var checkAudioPlayer: AVAudioPlayer!
    var importantAudioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        decisionButton.layer.cornerRadius = 40.0
        deckLabel.layer.cornerRadius = 10.0
        deckLabel.layer.masksToBounds = true
        deckLabel.text = labelText
        deckLabel.backgroundColor = labelColor
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        cardCollectionView.layer.borderColor = UIColor.white.cgColor
        cardCollectionView.layer.borderWidth = 5.0
        cardCollectionView.layer.cornerRadius = 10.0
        cardCollectionView.layer.masksToBounds = true
        
        let nib = UINib(nibName: "deckCollectionViewCell", bundle: nil)
        cardCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        if let asset = NSDataAsset(name: "Back") {
            backAudioPlayer = try! AVAudioPlayer(data: asset.data)
            backAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Check") {
            checkAudioPlayer = try! AVAudioPlayer(data: asset.data)
            checkAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "Important") {
            importantAudioPlayer = try! AVAudioPlayer(data: asset.data)
            importantAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        
        cardArray = realm.objects(Card.self).filter("\(originalDeck) = false").sorted(byKeyPath: "id", ascending: true)
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! deckCollectionViewCell
        cell.cardData = self.cardArray[indexPath.row]
        cell.setCard()
        cell.checkButton.addTarget(self, action: #selector(check(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    @objc func check(_ sender:UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.cardCollectionView)
        let indexPath = cardCollectionView.indexPathForItem(at: point)
        
        let cardId = cardArray[indexPath!.row].id
        
        if sender.isSelected{
            if let delete = addArray.index(of: cardId) {
                addArray.remove(at: delete)
            }
            sender.isSelected = false
        }else{
            addArray.append(cardId)
            sender.isSelected = true
        }
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.checkAudioPlayer.currentTime = 0
            self.checkAudioPlayer.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let returnSize = CGSize(width: 180, height: 195)
        return returnSize
    }
    
    @IBAction func decisionButton(_ sender: Any) {
        if addArray == []{
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        SVProgressHUD.showError(withStatus: "カードが選択されていません")
        }else{
            let alertController = UIAlertController(title: "カードをデッキに登録しますか？", message: nil, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .destructive, handler:addDeck )
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            alertController.addAction(OK)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }
    func addDeck(alert: UIAlertAction!){
        for addId in addArray{
            let addCard = realm.objects(Card.self).filter("id == \(addId)")
            try! realm.write {
            addCard.setValue("true", forKey: "\(originalDeck)")
            realm.add(addCard, update: true)
            }
        }
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "カードをデッキに登録しました！")
            self.performSegue(withIdentifier: "editDeck", sender: nil)
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.importantAudioPlayer.play()
        }
        }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.performSegue(withIdentifier: "editDeck", sender: nil)
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.backAudioPlayer.play()
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
