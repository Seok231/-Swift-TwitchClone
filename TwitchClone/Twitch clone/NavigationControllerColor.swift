//
//  NavigationControllerColor.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/14.
//

import Foundation
import UIKit

extension UINavigationController {
    func setBackgroundColor() {
        navigationBar.barTintColor = .black
        navigationBar.isTranslucent = false
    }
    
    
    }
    

class Navigation: UINavigationController {
    
    @objc func pushToUserInfo() {
        print("pushToYouserInfo")
        
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
        print("pushToNotification")
    }
}
    
    


extension UINavigationItem {
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .white
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        return barButtonItem
    }
    
    
    
}

