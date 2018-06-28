//
//  EditCardViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import RealmSwift

class EditCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var cardSearchBar: UISearchBar!
    
    let realm = try! Realm()
    var cardArray = try! Realm().objects(Card.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        let nib = UINib(nibName: "cardCollectionViewCell", bundle: nil)
        cardCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
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
    @IBAction func allCard(_ sender: Any) {
        cardArray = realm.objects(Card.self)
        cardCollectionView.reloadData()
    }
    @IBAction func characterCount1(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("group == 1")
        cardCollectionView.reloadData()
    }
    @IBAction func characterCount2(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("group == 2")
        cardCollectionView.reloadData()
    }
    @IBAction func charactercount3(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("group == 3")
        cardCollectionView.reloadData()
    }
    @IBAction func characterCount4(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("group == 4")
        cardCollectionView.reloadData()
    }
    @IBAction func characterCount5(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("group == 5")
        cardCollectionView.reloadData()
    }
    @IBAction func originalDeck1(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("originalDeck == 1")
        cardCollectionView.reloadData()
    }
    @IBAction func originalDeck2(_ sender: Any) {
        cardArray = realm.objects(Card.self).filter("originalDeck == 2")
        cardCollectionView.reloadData()
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
