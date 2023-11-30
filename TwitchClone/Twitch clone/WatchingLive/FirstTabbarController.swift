//
//  FirstTabbarController.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/14.
//

import Foundation
import UIKit



class FirsTabbarController: UITabBarController {
    
    
    override func viewDidLoad() {
        
        
        
        self.tabBar.items?[0].title = "팔로잉"
        self.tabBar.items?[0].image = UIImage(systemName: "heart")
        self.tabBar.items?[0].selectedImage = UIImage(systemName: "heart.fill")
        
        
        self.tabBar.items?[1].title = "찾기"
        self.tabBar.items?[1].image = UIImage(systemName: "safari")
        self.tabBar.items?[1].selectedImage = UIImage(systemName: "safari.fill")
        
        self.tabBar.items?[2].title = "탐색"
        self.tabBar.items?[2].image = UIImage(systemName: "square.on.square")
        self.tabBar.items?[2].selectedImage = UIImage(systemName: "square.on.square.fill")
        
        self.tabBar.items?[3].title = "검색"
        self.tabBar.items?[3].image = UIImage(systemName: "magnifyingglass.circle")
        self.tabBar.items?[3].selectedImage = UIImage(systemName: "magnifyingglass.circle.fill")
        
        
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.iconColor = .gray
        tabBarItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.gray]
        
        tabBarItemAppearance.selected.iconColor = .white
        tabBarItemAppearance.selected.titleTextAttributes = [.foregroundColor : UIColor.white]
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .black
        
        
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.compactInlineLayoutAppearance =
        tabBarItemAppearance
        
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
        
        
        initNavigationBar()
        
        
    }
    
    
    private func initNavigationBar() {
        self.navigationController?.setBackgroundColor()
        setLeftBarBT()
        setRightBarBT()
        
        let backBT = UIBarButtonItem()
        backBT.tintColor = .white
        backBT.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBT
        
    }
    
    private func setLeftBarBT() {
        let infoBT = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToUserInfo), symbolName: "person.circle.fill")
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = infoBT
//        self.navigationItem.leftBarButtonItem = infoBT
    }
    
    private func setRightBarBT() {
        let writeButton = self.navigationItem.makeSFSymbolButton(self, action:#selector(self.pushToMessage),symbolName: "bubble.right")
        let scanQRButton = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToScanQR), symbolName: "tray")
        let notificationButton = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToNotification), symbolName: "dot.radiowaves.left.and.right")
                    
        self.navigationItem.rightBarButtonItems = [notificationButton, scanQRButton, writeButton]
    }
    
    @objc func pushToUserInfo() {
//        print("pushToYouserInfo")
        DispatchQueue.main.async {
            guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC else {return}
            secondVC.modalTransitionStyle = .coverVertical
            secondVC.modalPresentationStyle = .automatic
            self.present(secondVC, animated: true)
        }
    }
    
    @objc func pushToMessage() {
        print("pushToMessage")
        guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "MessageVC") as? MessageVC else {return}
//        secondVC.modalTransitionStyle = .coverVertical
//        secondVC.modalPresentationStyle = .automatic
//        self.present(secondVC, animated: true)
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc func pushToScanQR() {
        print("pushToScanQR")
    }
    @objc func pushToNotification() {
        let streamVC = UIStoryboard.init(name: "StreamMain", bundle: nil)
        guard let nextVC = streamVC.instantiateViewController(identifier: "StreamTabbarController") as? StreamTabbarController else {
            return
        }
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    
}
