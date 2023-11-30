//
//  FindVC.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/08/31.
//

import Foundation
import UIKit

class FindVC: UIViewController {
    
    @IBOutlet weak var findTableView: UITableView!

    override func viewDidLoad() {
        findTableView.register(UINib(nibName: "FindListTableViewCell", bundle: nil), forCellReuseIdentifier: "FindListTableViewCell")
        findTableView.register(UINib(nibName: "FindTableViewCell", bundle: nil), forCellReuseIdentifier: "FindTableViewCell")
        findTableView.dataSource = self
        findTableView.delegate = self
        findTableView.separatorStyle = .none
        initNavigationBar()
        setLeftBarBT()
        setRightBarBT()
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

extension FindVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let testHeader = ["header1", "header2", "header3", "header4"]
        return testHeader[section]
    }
    //just chatting
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 1
//            return LiveList.result.liveList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = findTableView.dequeueReusableCell(withIdentifier: "FindTableViewCell", for: indexPath) as! FindTableViewCell
            cell.cellDelegate = self
            return cell
            
        default :
            let cell = findTableView.dequeueReusableCell(withIdentifier: "FindListTableViewCell", for: indexPath) as! FindListTableViewCell
            cell.cellDelegate = self
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 290
        default :
            return 260
        }
    }
}

extension FindVC: FindCollectionDelegate, FindListCollectionDelegate {
    
    func collectionView(collectionviewcell: FindListCollectionViewCell?, index: Int, didTappedInTableViewCell: FindListTableViewCell) {
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
        secondViewController.modalTransitionStyle = .coverVertical
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
        secondViewController.liveListModel =  LiveList.result.liveList[index]
    }
    
    func collectionView(collectionviewcell: FindCollectionCell?, index: Int, didTappedInTableViewCell: FindTableViewCell) {
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
        secondViewController.modalTransitionStyle = .coverVertical
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
        secondViewController.liveListModel =  LiveList.result.liveList[index]
        
        
    }
    
}





