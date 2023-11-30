//
//  FirestVC.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/14.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import FirebaseMessaging

class FollowingVC: UIViewController {
    
    @IBOutlet weak var playListTableView: UITableView!
    var ref = Database.database().reference()
    let liveResult = LiveResult()
    var liveList:[LiveListModel] = []
    var userFollowingList: [UserFollowing] = []
    var generator: ACThumbnailGenerator!
    let maxImages = 10
    
    override func viewDidLoad() {
        userInfoUpdate()
        liveListUpdate()
        initNavigationBar()
        playListTableView.dataSource = self
        playListTableView.delegate = self
        playListTableView.separatorStyle = .none
        playListTableView.backgroundColor = .black
        playListTableView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingTableViewCell")
        playListTableView.register(UINib(nibName: "FollowingCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingCollectionTableViewCell")
    }
    
    private func userInfoUpdate() {
        if let userEmail = Auth.auth().currentUser?.email, let userPhotoURL = Auth.auth().currentUser?.photoURL, let userName = Auth.auth().currentUser?.displayName {
            
            let emailSplit = String(userEmail.split(separator: "@")[0])
            UserInfoModel.user.userEmail = userEmail
            UserInfoModel.user.userEmailSplit = emailSplit
            UserInfoModel.user.userName = userName
            UserInfoModel.user.userPhotoURL = userPhotoURL
        }else {
            guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
                    secondViewController.modalTransitionStyle = .coverVertical
                    secondViewController.modalPresentationStyle = .fullScreen
                    self.present(secondViewController, animated: true, completion: nil)
        }
    }
    
    func liveListUpdate() {
        ref.child("FirstTree/LiveList").observe(DataEventType.value) { DataSnapshot in
            guard let snapData = DataSnapshot.value as? [String:Any] else{return}
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do {
                let decoder = JSONDecoder()
                LiveList.result.liveList = try decoder.decode([LiveListModel].self, from: data)
                self.liveList = LiveList.result.liveList
                self.liveList = self.liveList.sorted(by: {$0.date > $1.date})
            } catch let error {
                print("get Firebase data error", error)
            }
            DispatchQueue.main.async {
                self.playListTableView.reloadData()
            }
        }
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

extension FollowingVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let testList = ["생방송 채널", "팔로우 중인 카테고리", "추천 채널"]
        return testList[section]
    }
    
    // 글꼴 변경은 Netflix_Clone 참고
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return LiveList.result.liveList.count
        case 1:
            return 1
        default:
            return LiveList.result.liveList.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 110
        case 1:
            return 190
        default:
            return 110
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0, 2:
            let cell = playListTableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
            let list = LiveList.result.liveList[indexPath.row]
            cell.selectionStyle = .none
            cell.hostNameLabel.text = list.hostName
            cell.roomNameLabel.text = list.title
            cell.gameLabel.text = list.streamCategory
            cell.thumbnailView.layer.cornerRadius = 5
            CasheImage.thumbnailImage2(imageURL: list.imageURL) { image in
                if let image = image {
                    cell.thumbnailView.image = image
                }
            }
            let hostImage = CasheImage.hostImage(stringURL: list.hostImage)
            cell.hostImageView.image = hostImage
        return cell
        case 1:
            let collectionViewCell = playListTableView.dequeueReusableCell(withIdentifier: "FollowingCollectionTableViewCell", for: indexPath) as! FollowingCollectionTableViewCell
            collectionViewCell.cellDelegate = self
            collectionViewCell.selectionStyle = .none
            return collectionViewCell
        default:
            let cell = playListTableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0, 2:
            guard let playLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
            playLiveVC.modalTransitionStyle = .crossDissolve
            playLiveVC.modalPresentationStyle = .overFullScreen
            self.present(playLiveVC, animated: true, completion: nil)
            playLiveVC.liveListModel = LiveList.result.liveList[indexPath.row]
        case 1:
            print("a")
        default :
            guard let playLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
            playLiveVC.modalTransitionStyle = .crossDissolve
            playLiveVC.modalPresentationStyle = .overFullScreen
            self.present(playLiveVC, animated: true, completion: nil)
            playLiveVC.liveListModel = LiveList.result.liveList[indexPath.row]
        }
    }
}

extension UIViewController {
    class func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = .white
        
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension FollowingVC: FollowingListVCDelegate {
    
    func collectionView(collectionviewcell: FollowingCollectionViewCell?, index: Int, didTappedInTableViewCell: FollowingCollectionTableViewCell, list: [CategoryModel]) {
        
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowingListVC") as? FollowingListVC else { return }
        self.navigationController?.pushViewController(secondViewController, animated: true)
        secondViewController.followingListModel = list[index]
    }
}
