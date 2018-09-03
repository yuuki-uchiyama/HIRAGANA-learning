//
//  EditDeckViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/20.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import SVProgressHUD

class EditDeckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var deck1Button: UIButton!
    @IBOutlet weak var deck2Button: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self).filter("originalDeck1 = true").sorted(byKeyPath: "id", ascending: true)
    var deleteArray: [Int] = []
    var originalDeck = "originalDeck1"
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    var checkAudioPlayer: AVAudioPlayer!
    var importantAudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        toHomeButton.layer.cornerRadius = 40.0
        deck1Button.layer.cornerRadius = 30.0
        deck2Button.layer.cornerRadius = 30.0
        deleteButton.layer.cornerRadius = 40.0
        deckLabel.layer.cornerRadius = 20.0
        deckLabel.layer.masksToBounds = true
        addButton.layer.cornerRadius = 20.0
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        cardCollectionView.layer.borderColor = UIColor.white.cgColor
        cardCollectionView.layer.borderWidth = 5.0
        cardCollectionView.layer.cornerRadius = 10.0
        cardCollectionView.layer.masksToBounds = true
        
        let nib = UINib(nibName: "deckCollectionViewCell", bundle: nil)
        cardCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        deckSorted()
    }
    
    func deckSorted(){
        cardArray = realm.objects(Card.self).filter("\(originalDeck) = true").sorted(byKeyPath: "id", ascending: true)
        cardCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let returnSize = CGSize(width: 180, height: 195)
        return returnSize
    }
    
    @objc func check(_ sender:UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.cardCollectionView)
        let indexPath = cardCollectionView.indexPathForItem(at: point)

        let cardId = cardArray[indexPath!.row].id

        if sender.isSelected{
            if let delete = deleteArray.index(of: cardId) {
                deleteArray.remove(at: delete)
            }
            sender.isSelected = false
        }else{
            deleteArray.append(cardId)
            sender.isSelected = true
        }
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.checkAudioPlayer.currentTime = 0
            self.checkAudioPlayer.play()
        }
    }
    @IBAction func deleteButton(_ sender: Any) {
        if deleteArray == []{
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showError(withStatus: "カードが選択されていません")
        }else{
            let alertController = UIAlertController(title: "カードをデッキから削除しますか？", message: "カードデータ自体は保持されます", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .destructive, handler:deleteDeck)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            alertController.addAction(OK)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func deleteDeck(alert: UIAlertAction!){
            for addId in deleteArray{
                let deleteCard = realm.objects(Card.self).filter("id == \(addId)")
                try! realm.write {
                    deleteCard.setValue("false", forKey: "\(originalDeck)")
                    realm.add(deleteCard, update: true)
                }
            }
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "カードをデッキから消去しました！")
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.importantAudioPlayer.play()
        }
            cardArray = realm.objects(Card.self).filter("\(originalDeck) = true").sorted(byKeyPath: "id", ascending: true)
            deckSorted()
        }
    
    @IBAction func deck1Button(_ sender: Any) {
        originalDeck = "originalDeck1"
        deckSorted()
        deleteArray = []
        deck1Button.alpha = 1.0
        deck2Button.alpha = 0.5
        deckLabel.text = "オリジナルデッキ1"
        deckLabel.backgroundColor = deck1Button.backgroundColor
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.checkAudioPlayer.currentTime = 0
            self.checkAudioPlayer.play()
        }
    }
    
    @IBAction func deck2Button(_ sender: Any) {
        originalDeck = "originalDeck2"
        deckSorted()
        deleteArray = []
        deck1Button.alpha = 0.5
        deck2Button.alpha = 1.0
        deckLabel.text = "オリジナルデッキ2"
        deckLabel.backgroundColor = deck2Button.backgroundColor
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.checkAudioPlayer.currentTime = 0
            self.checkAudioPlayer.play()
        }
    }
    
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.backAudioPlayer.play()
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.backAudioPlayer.play()
        }
    }
    
    @IBAction func addDeckButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            self.buttonTapAudioPlayer.play()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddDeck"{
            let addDeckVC: addDeckViewController = segue.destination as! addDeckViewController
            addDeckVC.originalDeck = self.originalDeck
            addDeckVC.labelColor = self.deckLabel.backgroundColor
            addDeckVC.labelText = self.deckLabel.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToEditDeck(_ segue:UIStoryboardSegue){
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
