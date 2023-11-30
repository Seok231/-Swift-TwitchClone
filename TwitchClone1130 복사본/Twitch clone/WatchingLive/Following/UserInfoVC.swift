//
//  UserInfoVC.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/16.
//

import Foundation
import UIKit
import FirebaseAuth

class UserInfoVC: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var testLogOutBT: UIButton!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    
    @IBAction func logOutBT(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        print("signOut")
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
                // 화면 전환 애니메이션 설정
                secondViewController.modalTransitionStyle = .coverVertical
                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
                secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        
        self.navigationItem.title = "계정"
        
        if let userImageURL = Auth.auth().currentUser?.photoURL {
            guard let data = try? Data(contentsOf: userImageURL) else {return}
            if let image = UIImage(data: data){
                DispatchQueue.main.async {
                    self.userImageView.image = image
                }
            }
        }
        
        if let userName = Auth.auth().currentUser?.displayName {
            userNameLabel.text = userName
        }
        
        if let userEmail = Auth.auth().currentUser?.email {
            userEmailLabel.text = userEmail
        }
        
        let fontSize = UIFont.boldSystemFont(ofSize: 20)
        
        userImageView.layer.cornerRadius = 10
        
        userEmailLabel.font = fontSize
        userNameLabel.font = fontSize
        
        
        
        
    }
}
