//
//  EditCardViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class EditCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toHomeButton: UIButton!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)
    
    var searchCount = 0
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    var backAudioPlayer: AVAudioPlayer!
    var checkAudioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        toHomeButton.layer.cornerRadius = 40.0
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        searchBar.delegate = self
        
        cardCollectionView.layer.borderColor = UIColor.white.cgColor
        cardCollectionView.layer.borderWidth = 5.0
        cardCollectionView.layer.cornerRadius = 10.0
        cardCollectionView.layer.masksToBounds = true
        
        let nib = UINib(nibName: "cardCollectionViewCell", bundle: nil)
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        search()
        cardCollectionView.reloadData()
    }
    
    func search(){
        if searchCount == 0 && searchBar.text != ""{
            cardArray = realm.objects(Card.self).filter("word contains '\(searchBar.text!)'")
        }else if 1...5 ~= searchCount && searchBar.text == ""{
            cardArray = realm.objects(Card.self).filter("group = \(searchCount)")
        }else if 1...5 ~= searchCount && searchBar.text != ""{
            cardArray = realm.objects(Card.self).filter("group = \(searchCount) and word contains '\(searchBar.text!)'")
        }else if searchCount == 6 && searchBar.text == ""{
            cardArray = realm.objects(Card.self).filter("originalDeck1 = true")
        }else if searchCount == 6 && searchBar.text != ""{
            cardArray = realm.objects(Card.self).filter("originalDeck1 = true and word contains '\(searchBar.text!)'")
        }else if searchCount == 7 && searchBar.text == ""{
            cardArray = realm.objects(Card.self).filter("originalDeck2 = true")
        }else if searchCount == 7 && searchBar.text != ""{
            cardArray = realm.objects(Card.self).filter("originalDeck2 = true and word contains '\(searchBar.text!)'")
        }else{
            cardArray = realm.objects(Card.self)
        }
        cardCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search()
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! cardCollectionViewCell
        cell.cardData = self.cardArray[indexPath.row]
        cell.setCard()
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let returnSize = CGSize(width: 180, height: 270)
        return returnSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        buttonTapAudioPlayer.play()
        }
        performSegue(withIdentifier: "editCardSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCardSegue"{
            let indexPath: IndexPath = self.cardCollectionView.indexPathsForSelectedItems![0]
            let createCardViewController: CreateCardViewController = segue.destination as! CreateCardViewController
            createCardViewController.card = self.cardArray[indexPath.row]
            createCardViewController.newCardBool = false
        }
    }
    
    @IBAction func allCard(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
        checkAudioPlayer.currentTime = 0
        checkAudioPlayer.play()
        }
        searchCount = 0
        search()

    }
    @IBAction func characterCount1(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 1
        search()

    }
    @IBAction func characterCount2(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 2
        search()

    }
    @IBAction func charactercount3(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 3
        search()

    }
    @IBAction func characterCount4(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 4
        search()

    }
    @IBAction func characterCount5(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 5
        search()

    }
    @IBAction func originalDeck1(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 6
        search()

    }
    @IBAction func originalDeck2(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            checkAudioPlayer.currentTime = 0
            checkAudioPlayer.play()
        }
        searchCount = 7
        search()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToEdit(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
    }
    @IBAction func toHomeButton(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            backAudioPlayer.play()
        }
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
