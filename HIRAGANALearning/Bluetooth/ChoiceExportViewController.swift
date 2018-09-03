//
//  ChoiceExportViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/24.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import MultipeerConnectivity
import SVProgressHUD


class ChoiceExportViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MCNearbyServiceBrowserDelegate {
    
    var imageArray: [NSData] = []
    var wordArray: [String] = []
    var imageDataArray: [Data] = []
    var wordDataArray: [Data] = []
    
    let realm = try! Realm()
    var cardArray: [Card] = []
    
    var myPeerID : MCPeerID!
    var youPeerID : MCPeerID!
    var session : MCSession!
    var browser: MCNearbyServiceBrowser!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var noCardLabel: UILabel!
    
    var checkAudioPlayer: AVAudioPlayer!
    var buttonTapAudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 40.0
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        cardCollectionView.layer.borderColor = UIColor.white.cgColor
        cardCollectionView.layer.borderWidth = 5.0
        cardCollectionView.layer.cornerRadius = 10.0
        cardCollectionView.layer.masksToBounds = true
        
        
        let nib = UINib(nibName: "deckCollectionViewCell", bundle: nil)
        cardCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer : myPeerID)
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Communication.serviceType)
        browser.delegate = self
        
        
        if let asset = NSDataAsset(name: "Check") {
            checkAudioPlayer = try! AVAudioPlayer(data: asset.data)
            checkAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        browser.startBrowsingForPeers()
        SVProgressHUD.show(withStatus: "接続中")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        SVProgressHUD.dismiss()
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        SVProgressHUD.showSuccess(withStatus: "接続完了")
        cancelButton.setTitle("送信完了", for: .normal)
        cardArray = Array(realm.objects(Card.self).filter("id >= 50").sorted(byKeyPath: "id", ascending: true))
        noCardLabel.text = "送信できるカードがありません。\nオリジナルのカードを作成してください。"
        cardCollectionView.reloadData()
        youPeerID = peerID
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        browser.stopBrowsingForPeers()
        SVProgressHUD.showError(withStatus: "受信相手との接続が切れました")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        SVProgressHUD.showError(withStatus: "通信を開始できませんでした")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cardArray == []{
            self.view.bringSubview(toFront: noCardLabel)
            return 0
        }else{
            self.view.sendSubview(toBack: noCardLabel)
            return cardArray.count
        }
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
            if youPeerID != nil{
                let cardImage = cardArray[indexPath!.row].image!
                let imageData = cardImage as Data
                let cardWord = cardArray[indexPath!.row].word
                let wordData = cardWord.data(using: String.Encoding.utf8)!
                print(youPeerID)
                do{
                    try session.send(imageData, toPeers: [youPeerID], with: MCSessionSendDataMode.reliable)
                    do{
                        try session.send(wordData, toPeers: [youPeerID], with: MCSessionSendDataMode.reliable)
                        SVProgressHUD.setMinimumDismissTimeInterval(0)
                        SVProgressHUD.showSuccess(withStatus: "送信完了！")
                        cardArray.remove(at: (indexPath?.row)!)
                        cardCollectionView.reloadData()
                    }catch{
                        SVProgressHUD.setMinimumDismissTimeInterval(0)
                        SVProgressHUD.showError(withStatus: "データを送信できませんでした")
                    }
                }catch{
                    SVProgressHUD.setMinimumDismissTimeInterval(0)
                    SVProgressHUD.showError(withStatus: "データを送信できませんでした")
                }
            }else{
                SVProgressHUD.showError(withStatus: "送信相手が見つかりません")
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let returnSize = CGSize(width: 180, height: 195)
        return returnSize
    }
    
    func noCard(){
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        SVProgressHUD.dismiss()
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            buttonTapAudioPlayer.play()
        }
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
