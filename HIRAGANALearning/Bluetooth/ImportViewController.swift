//
//  ImportViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/07/24.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SVProgressHUD
import RealmSwift
import AVFoundation


class ImportViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var endButton: UIButton!
    
    
    var imageArray: [NSData] = []
    var wordArray: [String] = []
    let cardArray = try! Realm().objects(Card.self)
    let realm = try! Realm()
    
    var id: Int = 0
    var word: String = ""
    var group: Int = 0
    var image: NSData!

    var myPeerID : MCPeerID!
    var session : MCSession!
    var advertiser : MCNearbyServiceAdvertiser!
    var count = 0
    
    var buttonTapAudioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endButton.layer.cornerRadius = 40.0
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
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Communication.serviceType)
        advertiser.delegate = self
        
        
        if let asset = NSDataAsset(name: "ButtonTap") {
            buttonTapAudioPlayer = try! AVAudioPlayer(data: asset.data)
            buttonTapAudioPlayer.volume = UserDefaults.standard.float(forKey: Constants.volumeKey)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "接続中")
        advertiser.startAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(peerID)
        invitationHandler(true,session)
        SVProgressHUD.dismiss()
        SVProgressHUD.setMinimumDismissTimeInterval(0)
        SVProgressHUD.showSuccess(withStatus: "接続完了")
        endButton.setTitle("受信完了", for: .normal)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        SVProgressHUD.showError(withStatus: "通信を開始できませんでした")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if count == 0{
            let imageData = data as NSData
            imageArray.append(imageData)
            count = 1
        }else if count == 1{
            let wordData = String(data: data, encoding: .utf8)!
            wordArray.append(wordData)
            count = 0
            DispatchQueue.main.async{
                self.cardCollectionView.reloadData()
                }
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "受信完了！")
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    
//    collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! deckCollectionViewCell
        cell.cardImage.image = UIImage(data: imageArray[indexPath.row] as Data)
        cell.cardImage.contentMode = UIViewContentMode.scaleAspectFit
        cell.word.text! = wordArray[indexPath.row]
        cell.checkButton.addTarget(self, action: #selector(check(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    @objc func check(_ sender:UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.cardCollectionView)
        let indexPath = cardCollectionView.indexPathForItem(at: point)
        
        let alertController: UIAlertController = UIAlertController(title: "このカードを削除しますか？", message: "削除したデータはこのiPadには保存されません", preferredStyle: .alert)
        let yes = UIAlertAction(title: "はい", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.wordArray.remove(at: (indexPath?.row)!)
            self.imageArray.remove(at: (indexPath?.row)!)
            SVProgressHUD.setMinimumDismissTimeInterval(0)
            SVProgressHUD.showSuccess(withStatus: "カードを削除しました")
            self.cardCollectionView.reloadData()
        })
        let no = UIAlertAction(title: "いいえ", style: .cancel)
        
        alertController.addAction(yes)
        alertController.addAction(no)
        present(alertController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let returnSize = CGSize(width: 180, height: 195)
        return returnSize
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if wordArray != []{
        for i in 0 ... wordArray.count - 1{
            let card = Card()
            id = cardArray.max(ofProperty: "id")! + 1
            word = wordArray[i]
            image = imageArray[i]
            let characterCount = word.count
            if characterCount < 5{
                group = characterCount
            }else{
                group = 5
            }
            try! realm.write{
                card.id = id
                card.word = word
                card.image = image
                card.group = group
                card.originalDeck1 = false
                card.originalDeck2 = false
                realm.add(card, update: true)
            }
        }
        }
    }
    
    @IBAction func endButton(_ sender: Any) {
        SVProgressHUD.dismiss()
        if UserDefaults.standard.bool(forKey: Constants.tapSoundKey) == false{
            buttonTapAudioPlayer.play()
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
