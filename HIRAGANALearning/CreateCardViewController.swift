//
//  CreateCardViewController.swift
//  HIRAGANALearning
//
//  Created by 内山由基 on 2018/06/22.
//  Copyright © 2018年 yuuki uchiyama. All rights reserved.
//

import UIKit
import CropViewController
import RealmSwift
import SVProgressHUD

class CreateCardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addDeck1Outlet: UIButton!
    @IBOutlet weak var addDeck2Outlet: UIButton!
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var createButtonOutlet: UIButton!
    var newCardBool = true
    
    var card : Card!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popUp)))
        if newCardBool{
            deleteButtonOutlet.setTitle("消去", for: .normal)
            createButtonOutlet.setTitle("作成", for: .normal)
        }else{
            deleteButtonOutlet.setTitle("削除", for: .normal)
            createButtonOutlet.setTitle("修正", for: .normal)
        }
        
        addDeck1Outlet.setImage(UIImage(named: "CheckOff"), for: .normal)
        addDeck1Outlet.setImage(UIImage(named: "CheckOn"), for: .selected)
        addDeck2Outlet.setImage(UIImage(named: "CheckOff"), for: .normal)
        addDeck2Outlet.setImage(UIImage(named: "CheckOn"), for: .selected)
        
        setCard()
        
        print("デバッグ：\(card)")
        


        // Do any additional setup after loading the view.
    }
    
    func setCard(){
        if let image = card.image{
            imageView.image = UIImage(data: image as Data)
        }else{
            imageView.image = nil
        }
        wordTextField.text = card.word
        if card.originalDeck1{
            addDeck1Outlet.isSelected = true
        }
        if card.originalDeck2{
            addDeck2Outlet.isSelected = true
        }
    }

    
    @objc func popUp(){
        let alertController: UIAlertController = UIAlertController(title: "画像を取り込む", message: nil, preferredStyle: .alert)
        let camera = UIAlertAction(title: "カメラから取り込む", style: .default, handler: actionCamera)
        let library = UIAlertAction(title: "写真から取り込む", style: .default, handler: actionLibrary)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)

        alertController.addAction(camera)
        alertController.addAction(library)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }

    func actionCamera(alert: UIAlertAction!){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    func actionLibrary(alert: UIAlertAction!){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let editor = TOCropViewController(image: image)
            editor.delegate = self
            editor.aspectRatioLockEnabled = true
            editor.aspectRatioPreset = TOCropViewControllerAspectRatioPreset(rawValue: 1)!
            editor.aspectRatioPickerButtonHidden = true
            picker.pushViewController(editor, animated: true)
        }
    }
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        imageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addDeck1(_ sender: Any) {
        if addDeck1Outlet.isSelected{
            addDeck1Outlet.isSelected = false
        }else{
            addDeck1Outlet.isSelected = true
        }
    }
    
    @IBAction func addDeck2(_ sender: Any) {
        if addDeck2Outlet.isSelected{
            addDeck2Outlet.isSelected = false
        }else{
            addDeck2Outlet.isSelected = true
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        if newCardBool{
            card.word = ""
            addDeck1Outlet.isSelected = false
            addDeck2Outlet.isSelected = false
            card.image = nil
            setCard()
        }else{
            let alertController: UIAlertController = UIAlertController(title: "「\(card.word)」を削除しますか？", message: "カードリストからデータが削除され、使用できなくなります", preferredStyle: .alert)
            let yes = UIAlertAction(title: "はい", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                try! self.realm.write{
                    self.realm.delete(self.card)
                }
                SVProgressHUD.showSuccess(withStatus: "カードを削除しました")
                self.performSegue(withIdentifier: "unwindToEdit", sender: nil)
            })
            let no = UIAlertAction(title: "いいえ", style: .cancel)
            
            alertController.addAction(yes)
            alertController.addAction(no)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func createButton(_ sender: Any) {
        if wordTextField.text == ""{
            SVProgressHUD.showError(withStatus: "ひらがなが入力されていません")
        }else if (wordTextField.text?.count)! > 10 {
            SVProgressHUD.showError(withStatus: "文字数が多すぎます")
        }else if imageView.image == nil{
            SVProgressHUD.showError(withStatus: "画像が選択されていません")
        }else{
            if newCardBool{
            let sameCardArray = realm.objects(Card.self).filter("word like '\(wordTextField.text!)'")
            if sameCardArray.count == 0{
                cardRegister()
                SVProgressHUD.showSuccess(withStatus: "カードを保存しました！")
                let cardId = card.id + 1
                card = Card()
                card.id += cardId
                setCard()
                }else{
                SVProgressHUD.showError(withStatus: "同じひらがなのカードがあります")
                }
            }else{
                cardRegister()
                SVProgressHUD.showSuccess(withStatus: "カードを修正しました！")
                self.performSegue(withIdentifier: "unwindToEdit", sender: nil)
            }
        }
    }
    
    func cardRegister(){
        try! realm.write {
            card.word = wordTextField.text!
            let characterCount = wordTextField.text?.count
            if characterCount! < 5{
                card.group = characterCount!
            }else{
                card.group = 5
            }
            card.image = UIImagePNGRepresentation(imageView.image!)! as NSData
            if addDeck1Outlet.isSelected{
                card.originalDeck1 = true
            }else{
                card.originalDeck1 = false
            }
            if addDeck2Outlet.isSelected{
                card.originalDeck2 = true
            }else{
                card.originalDeck2 = false
            }
            realm.add(card, update: true)
        }
        print("デバッグ：\(card)")
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToCreateCard(_ segue:UIStoryboardSegue){
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
