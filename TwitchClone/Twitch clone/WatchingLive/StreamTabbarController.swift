//
//  StreamTabbarController.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/08.
//

import Foundation
import UIKit

class StreamTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        
        self.tabBar.items?[0].title = "방송"
        self.tabBar.items?[0].image = UIImage(systemName: "video")
        self.tabBar.items?[0].selectedImage = UIImage(systemName: "video.fill")
        
        
        self.tabBar.items?[1].title = "설정"
        self.tabBar.items?[1].image = UIImage(systemName: "gearshape")
        self.tabBar.items?[1].selectedImage = UIImage(systemName: "gearshape.fill")
        

        
        
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
    }
}
