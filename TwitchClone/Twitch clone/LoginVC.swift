//
//  LoginVC.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/17.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseMessaging

class LoginVC: UIViewController {
    
    @IBOutlet weak var googleLoginBT: GIDSignInButton!
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {return}
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { result, error in
                    self.userInfoUpload()
                    guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FirsTabbarController") as? FirsTabbarController else {return}
                    secondViewController.modalTransitionStyle = .coverVertical
                    secondViewController.modalPresentationStyle = .fullScreen
                    self.present(secondViewController, animated: true, completion: nil)
                }
            }
        }

    private func userInfoUpload() {
        if let userEmail = Auth.auth().currentUser?.email, let userPhotoURL = Auth.auth().currentUser?.photoURL, let userName = Auth.auth().currentUser?.displayName, let token = Messaging.messaging().fcmToken {
            
            let photoString = userPhotoURL.absoluteString
            let emailSplit = String(userEmail.split(separator: "@")[0])
            UserInfoModel.user.userEmail = userEmail
            UserInfoModel.user.userEmailSplit = emailSplit
            UserInfoModel.user.userName = userName
            UserInfoModel.user.userPhotoURL = userPhotoURL
            self.creatUser(userEmail: userEmail, emailSplit: emailSplit, userName: userName, userPhotoURL: photoString, token: token)
        }
    }
    
//    private func userInfoCurrency(userEmailSplit: String) {
//        let child = "FirstTree/Users/\(userEmailSplit)/"
//        ref.child(child).getData(completion: { error, DataSnapshot in
//            if DataSnapshot == nil {
////                self.creatUser()
//            }
//        })
//    }
    
    private func creatUser(userEmail: String, emailSplit: String, userName: String, userPhotoURL: String, token: String) {
        
        let value = ["emailSplti" : emailSplit, "email" : userEmail, "photoURL" : userPhotoURL, "name" : userName, "fcmToken" : token]
        ref.child("FirstTree/Users/\(emailSplit)/").setValue(value)
    }
    
    override func viewDidLoad() {
        
        if let email = Auth.auth().currentUser?.email {
            print(email)
            if let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FirsTabbarController") as? FirsTabbarController {
                secondViewController.modalTransitionStyle = .coverVertical
                secondViewController.modalPresentationStyle = .overFullScreen
                self.present(secondViewController, animated: true, completion: nil)
                print("tt")
            }
            
        }
        
        let tapImageViewRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped(tapGestureRecognizer:)))
        //이미지뷰가 상호작용할 수 있게 설정
        googleLoginBT.isUserInteractionEnabled = true
        //이미지뷰에 제스처인식기 연결
        googleLoginBT.addGestureRecognizer(tapImageViewRecognizer)
        
        
    }
}
