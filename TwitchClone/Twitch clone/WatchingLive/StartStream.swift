//
//  StartStream.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/08.
//

import Foundation
import UIKit

class StartStream: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func camLive(_ sender: Any) {
        guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "StreamCam") as? StreamCam else {return}
        secondVC.modalPresentationStyle = .fullScreen
        self.present(secondVC, animated: true)
        
    }
    override func viewDidLoad() {
        
        initNavigationBar()
        setLeftBarBT()
        setRightBarBT()
        tableView.isScrollEnabled = false
        tableView.register(UINib(nibName: "LiveSettingCell", bundle: nil), forCellReuseIdentifier: "LiveSettingCell")
        tableView.register(UINib(nibName: "StartStreamTableViewCell", bundle: nil), forCellReuseIdentifier: "StartStreamTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    private func initNavigationBar() {
        self.navigationController?.setBackgroundColor()
    }
    
    private func setLeftBarBT() {
        let infoBT = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToUserInfo), symbolName: "person.circle.fill")
        
        self.navigationItem.leftBarButtonItem = infoBT
    }
    
    private func setRightBarBT() {
        
        let writeButton = self.navigationItem.makeSFSymbolButton(self, action:#selector(self.pushToMessage),symbolName: "bubble.right")
        let scanQRButton = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToScanQR), symbolName: "tray")
        let notificationButton = self.navigationItem.makeSFSymbolButton(self, action: #selector(self.pushToNotification), symbolName: "dot.radiowaves.left.and.right")
        self.navigationItem.rightBarButtonItems = [notificationButton, scanQRButton, writeButton]
        
    }
    @objc func pushToUserInfo() {
        print("pushToYouserInfo")
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        DispatchQueue.main.async {
            guard let secondVC = mainVC.instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC else {return}
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
        
//        let myTabVC = UIStoryboard.init(name: "Main", bundle: nil)
//        guard let nextVC = myTabVC.instantiateViewController(identifier: "FirsTabbarController") as? FirsTabbarController else {
//            return
//        }
//        nextVC.modalPresentationStyle = .fullScreen
//        self.present(nextVC, animated: true, completion: nil)

        self.dismiss(animated: true)

    }
}

extension StartStream: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return 500
        default :
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StartStreamTableViewCell", for: indexPath) as! StartStreamTableViewCell
            cell.mainLabel.text = "게임 방송하기"
            cell.subLabel.text = "모바일 기기에서 플레이하면서 방송을 진행하세요"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StartStreamTableViewCell", for: indexPath) as! StartStreamTableViewCell
            cell.mainLabel.text = "리얼라이프 방송하기"
            cell.subLabel.text = "어디서든 일상을 방송해 보세요"
            return cell
//        case 2:
//            let settingCell = tableView.dequeueReusableCell(withIdentifier: "LiveSettingCell", for: indexPath) as! LiveSettingCell
//            return settingCell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: "StartStreamTableViewCell", for: indexPath) as! StartStreamTableViewCell
            cell.mainLabel.text = "리얼라이프 방송하기"
            cell.subLabel.text = "어디서든 일상을 방송해 보세요"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        default:
            guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "StreamCam") as? StreamCam else {return}
            secondVC.modalPresentationStyle = .fullScreen
            self.present(secondVC, animated: true)
        }
    }
    
}
