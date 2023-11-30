//
//  LiveSetting.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/20/23.
//

import Foundation
import UIKit
import HaishinKit
import Firebase
import FirebaseStorage

protocol LiveSettingVCProtocol {
    func didFinish(categoryName: String, categoryImage: String, title: String, notificationText: String )
}

class LiveSettingVC: UIViewController {
    var delegate: LiveSettingVCProtocol?
    var storage = Storage.storage()
    var categoryImage: String?
    var categoryName: String?
    var settingBTBool: Bool = false
    @IBOutlet weak var uploadBT: UIButton!
    @IBOutlet weak var cancelBT: UIButton!
    @IBOutlet weak var titleSettingTF: UITextField!
    @IBOutlet weak var notificationSettingTF: UITextField!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var multiCamToggleLabel: UILabel!
    @IBOutlet weak var multiCamToggleSwitch: UISwitch!
    @IBAction func uploadBT(_ sender: Any) {
        let titleText = titleSettingTF.text
        let notificationText = notificationSettingTF.text
        let title = UserDefaults.standard.string(forKey: "title")
        let notification = UserDefaults.standard.string(forKey: "notification")
        let category = UserDefaults.standard.string(forKey: "category")
        if titleText == title, notificationText == notification, categoryName != nil, category == categoryName {
            print("변경점이 없습니다.")
            let alert = UIAlertController(title: "변경점이 없습니다.", message: "test", preferredStyle: .alert)
            let conf = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(conf)
            present(alert, animated: true, completion: nil)
            // 변경점 없음 팝업 메시지
        } else {
            UserDefaults.standard.set(titleText, forKey: "title")
            UserDefaults.standard.set(categoryName, forKey: "category")
            UserDefaults.standard.set(notificationText, forKey: "notification")
            UserDefaults.standard.set(categoryImage, forKey: "categoryImage")
            
            // 변경된 정보 업로드
            if let image = categoryImage {
                delegate?.didFinish(categoryName: categoryName ?? "", categoryImage: image, title: titleText ?? "", notificationText: notificationText ?? "")
            }
            let alert = UIAlertController(title: "저장되었습니다!", message: title, preferredStyle: .alert)
            let conf = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(conf)
            present(alert, animated: true, completion: nil)
            
            if settingBTBool {
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func multiCamToggleSwitch(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: "multiCamToggle")
        } else {
            UserDefaults.standard.setValue(false, forKey: "multiCamToggle")
        }
    }
    
    @IBAction func cancelBT(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will")
    }
    
    override func viewDidLoad() {
        titleSettingTF.delegate = self
        notificationSettingTF.delegate = self
        titleSettingTF.backgroundColor = .darkGray
        notificationSettingTF.backgroundColor = .darkGray
        categoryView.backgroundColor = .darkGray
        categoryView.layer.cornerRadius = 5
        multiCamToggleLabel.text = "멀티카메라"
        multiCamToggleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        multiCamToggleSwitch.onTintColor = .magenta
        let multiCamToggle = UserDefaults.standard.bool(forKey: "multiCamToggle")
        if multiCamToggle {
            multiCamToggleSwitch.isOn = true
        } else {
            multiCamToggleSwitch.isOn = false
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moveCategorySearch(sender: )))
        categoryView.isUserInteractionEnabled = true
        categoryView.addGestureRecognizer(tapGesture)
        cancelBT.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        uploadBT.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        uploadBT.tintColor = .white
        cancelBT.tintColor = .white
        
        if let title = UserDefaults.standard.string(forKey: "title") {
            titleSettingTF.text = title
        }
        if let notification = UserDefaults.standard.string(forKey: "notification") {
            notificationSettingTF.text = notification
        }
        if let categoryName = UserDefaults.standard.string(forKey: "category") {
            self.categoryName = categoryName
            categoryLabel.isHidden = false
            categoryLabel.text = categoryName
        }
        if let categoryImage = UserDefaults.standard.string(forKey: "categoryImage"), let categoryName = UserDefaults.standard.string(forKey: "category")  {
            print("LiveSettingVC viewDidLoad categoryImage load")
            self.categoryImageView.isHidden = false
            self.setCategoryImage(imageURL: categoryImage, categoryName: categoryName)
            self.categoryView.frame.origin.y = 100
            self.categoryImageView.frame.origin.y = 100
            self.categoryName = categoryName
            categoryLabel.isHidden = false
            categoryLabel.text = categoryName
        } else {
//            categoryImageView.isHidden = true
//            categoryLabel.isHidden = true
        }
    }
    
    func setCategoryImage(imageURL: String, categoryName: String) {
        categoryImageView.contentMode = .scaleAspectFill
        categoryImageView.layer.cornerRadius = 5
        CasheImage.imageToDirectory(identifier: categoryName, imageURL: imageURL) { image in
            self.categoryImageView.image = image
            print("CasheImage.imageToDirectory")
        }
        categoryLabel.text = categoryName
    }
    
    @objc func moveCategorySearch(sender: UITapGestureRecognizer) {
        let searchCategoryVC = SearchCategoeyVC(nibName: "SearchCategoeyVC", bundle: nil)
        searchCategoryVC.delegate = self
        self.present(searchCategoryVC, animated: true)
    }
    
}
extension LiveSettingVC: SearchCategoeyVCProtocol {
    func didFinish(name: String, imageURL: String) {
        print("didFinishLiveSetting", imageURL, name)
        setCategoryImage(imageURL: imageURL, categoryName: name)
        self.categoryName = name
        self.categoryImage = imageURL
        CasheImage.imageToDirectory(identifier: name, imageURL: imageURL) { image in
            self.categoryImageView.image = image
        }
    }
    
    
}

extension LiveSettingVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

