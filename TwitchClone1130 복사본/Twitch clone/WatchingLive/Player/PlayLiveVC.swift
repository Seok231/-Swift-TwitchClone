//
//  PlayLiveVC.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/16.
//

// "http://diddbstjr55.shop/hls/.m3u8"

import Foundation
import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import Firebase
import AVKit
import _AVKit_SwiftUI

class PlayLiveVC: UIViewController {

    @IBOutlet weak var volumeBT: UIButton!
    @IBOutlet weak var rotateBT: UIButton!
    @IBOutlet weak var pipBT: UIButton!
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var playStopBT: UIButton!
    @IBOutlet weak var streamInfoLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var followingBT: UIButton!
    @IBOutlet weak var notificationBT: UIButton!
    @IBOutlet weak var playInfoView: UIView!
    @IBOutlet weak var playInfoInView: UIView!
    @IBOutlet weak var playInfoChatLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chattingTableView: UITableView!
    @IBOutlet weak var sendStackView: UIView!
    @IBOutlet weak var sendChatBT: UIButton!
    @IBOutlet weak var settingBT: UIButton!
    
    var followingBool: Bool = false
    var notificationBool: Bool = false
    var chattingList: [ChattingUpdate] = []
    let selfSender = UserInfoModel.user.userEmailSplit
    var playStopBool: Bool = true
    var volume: Bool = false
    let textViewPlaceHolder = "메세지 보내기"
    let liveResult = LiveResult()
    var timer: Timer?
    let ref = Database.database().reference()
    var playInfoViewTab: Bool = true
    private var player = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    private var pipPlayerController: AVPictureInPictureController?
    private var playerController = AVPlayerViewController()
    var blurEffect = UIVisualEffectView()
    var chattingModel: [Chatting] = []
    var liveListModel: LiveListModel? {
        didSet {
            settingPlayerURL()
            settingInfo()
            chattingUpdate()
            setHostImage()
            getUserFollowing()
            getUserNotification()
        }
    }
    @IBAction func followingBT(_ sender: Any) {
        setUserFollowing()
    }
    @IBAction func notificationBT(_ sender: Any) {
        setUserNotification()
    }
    @IBAction func sendChat(_ sender: Any) {
        let user = UserInfoModel.user.userEmailSplit
        if let chatBody = textView.text, textView.text != nil {
            let childName = user + (Int(Date().timeIntervalSince1970)).description
            ref.child("FirstTree/LiveList/\(liveListModel?.hostName ?? "nil")/chatList/\(childName)").setValue(["sender" : user, "body" : chatBody, "date" : (Date().timeIntervalSince1970)] as [String : Any])
            textView.text = nil
        }
        
    }
    @IBAction func settingBT(_ sender: Any) {
        // 미구현
    }
    @IBAction func pipTest(_ sender: Any) {
        guard let isActive = pipPlayerController?.isPictureInPictureActive else {return}
        if isActive {
            pipPlayerController?.stopPictureInPicture()
        } else {
            pipPlayerController?.startPictureInPicture()
        }
    }
    @IBAction func playStop(_ sender: Any) {
        playStopTogle()
    }
    @IBAction func backBT(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func volumeBT(_ sender: Any) {
        volumeSetting()
    }
    @IBAction func rotateBT(_ sender: Any) {
        let url = liveResult.hlsURL(hls: liveListModel?.hls ?? "")
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = TimeInterval(1.0)
        let player2 = AVPlayer(playerItem: playerItem)
        playerController.player = player2
        self.present(playerController, animated: true, completion: nil)
        player2.play()
        timer?.invalidate()
        playStopTogle()
    }
    
    override func viewDidLoad() {
        
        textView.delegate = self
        playView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playViewTap(sender: )))
        playView.addGestureRecognizer(tapGesture)
        playInfoView.backgroundColor = .green
        hostImageView.layer.cornerRadius = 15
        let fontSize25 = UIFont.boldSystemFont(ofSize: 20)
        playInfoChatLabel.text = "채팅"
        playInfoChatLabel.font = fontSize25
        titleLabel.font = fontSize25
        streamInfoLabel.font = UIFont.boldSystemFont(ofSize: 15)
        categoryLabel.font =  UIFont.boldSystemFont(ofSize: 10)
        streamInfoLabel.textColor = .lightGray
        categoryLabel.textColor = .lightGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        playView.addGestureRecognizer(tapGesture)
        
        hostImageView.layer.cornerRadius = hostImageView.frame.height/2
        hostImageView.backgroundColor = .blue
        settingBT.tintColor = .white
        playStopBT.tintColor = .white
        volumeBT.tintColor = .white
        rotateBT.tintColor = .white
        sendChatBT.tintColor = .white
        followingBT.tintColor = .white
        notificationBT.tintColor = .white
        rotateBT.setTitle("", for: .normal)
        settingBT.setTitle("", for: .normal)
        volumeBT.setTitle("", for: .normal)
        followingBT.setTitle("팔로잉", for: .normal)
        notificationBT.setTitle("알림", for: .normal)
        playStopBT.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 40)
        followingBT.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        notificationBT.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        followingBT.configuration?.imagePadding = 5
        notificationBT.configuration?.imagePadding = 5
        followingBT.configuration?.imagePlacement = .top
        notificationBT.configuration?.imagePlacement = .top
        rotateBT.setImage(UIImage(systemName: "plus.viewfinder"), for: .normal)
        volumeBT.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        settingBT.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        followingBT.setImage(UIImage(systemName: "heart"), for: .normal)
        notificationBT.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        chattingTableView.register(UINib(nibName: "ChattingTableViewCell", bundle: nil), forCellReuseIdentifier: "ChattingTableViewCell")
        playInfoView.backgroundColor = .black
        playInfoInView.backgroundColor = .black
        chattingTableView.separatorStyle = .none
        chattingTableView.backgroundColor = .black
        
        textView.delegate = self
        textView.layer.cornerRadius = 5
        textView.textColor = .white
        textView.text = "메세지 보내기"
        player.play()
        playViewInfoTogle()
    }
    func setUserNotification() {
        let userName = UserInfoModel.user.userEmailSplit
        guard let hostName = liveListModel?.hostName else {return}
        if notificationBool {
            notificationBT.setImage(UIImage(systemName: "bell.slash"), for: .normal)
            notificationBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/notification").setValue(false)
        } else {
            notificationBT.setImage(UIImage(systemName: "bell.fill"), for: .normal)
            notificationBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/notification").setValue(true)
        }
    }
    
    func getUserNotification() {
        let userName = UserInfoModel.user.userEmailSplit
        guard let hostName = liveListModel?.hostName else {return}
        ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/notification").getData { error, dataSnap in
            guard error == nil else {
                print("Firebase error")
                print(error!.localizedDescription)
                return;}
            guard let data = dataSnap?.value as? Bool else {
                print("getUserNotification() error")
                return }
            if data{
                self.notificationBT.setImage(UIImage(named: "bell.fill"), for: .normal)
                self.notificationBool = true
            } else {
                self.notificationBT.setImage(UIImage(named: "bell.slash"), for: .normal)
                self.notificationBool = false
            }
        }
    }
    
    func setUserFollowing() {
        let userName = UserInfoModel.user.userEmailSplit
        guard let hostName = liveListModel?.hostName else {return}
        
        if followingBool {
            followingBT.setImage(UIImage(systemName: "heart"), for: .normal)
            notificationBT.setImage(UIImage(systemName: "bell.slash"), for: .normal)
            followingBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/following").setValue(false)
            ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/notification").setValue(false)
        } else {
            followingBT.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            followingBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/following").setValue(true)
        }
    }
    
    func getUserFollowing() {
        let userName = UserInfoModel.user.userEmailSplit
        guard let hostName = liveListModel?.hostName else {return}
        ref.child("FirstTree/Users/\(userName)/following/host/\(hostName)/following").getData { error, snapData in
            guard error == nil else {
                print("Firebase error")
                print(error!.localizedDescription)
                return;
            }
            guard let data = snapData?.value as? Bool else {
                print("error")
                return}
            if data {
                self.followingBT.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self.followingBool = true
            } else {
                self.followingBT.setImage(UIImage(systemName: "heart"), for: .normal)
                self.notificationBT.setImage(UIImage(systemName: "bell.slash"), for: .normal)
                self.followingBool = false
                self.notificationBool = false
            }
        }
    }
    
    func setHostImage() {
        guard let url = liveListModel?.hostImage else {return}
        let hostImage = CasheImage.hostImage(stringURL: url)
        hostImageView.image = hostImage
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        chattingTableView.endEditing(true)
        playView.endEditing(true)
       }

    override func viewWillDisappear(_ animated: Bool) {
        self.player.pause()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
 
    }

    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
            print("keyboard up")
                UIView.animate(
                    withDuration: 1, animations: {
                        self.sendStackView.frame.origin.y -= keyboardRectangle.height
                        self.chattingTableView.frame.origin.y -= keyboardRectangle.height
                        if self.playInfoViewTab == false {
                            self.playViewInfoTogle()
                        }
                    }
                )
        }
    }
    
    @objc func keyboardDown(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
            print("keyboard down")
                UIView.animate(
                    withDuration: 1
                    , animations: {
                        self.sendStackView.frame.origin.y += keyboardRectangle.height
                        self.chattingTableView.frame.origin.y += keyboardRectangle.height
                    }
                )
        }
    }
    
    @objc func playViewTap(sender: UITapGestureRecognizer) {
        playViewInfoTogle()
    }
    
    func playStopTogle() {
        if player.timeControlStatus != .playing {
            player.play()
            playStopBT.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player.pause()
            playStopBT.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func playViewInfoTogle() {
        if playInfoViewTab == true {
            backBT.isHidden = false
            pipBT.isHidden = false
            playStopBT.isHidden = false
            settingBT.isHidden = false
            volumeBT.isHidden = false
            rotateBT.isHidden = false
            var count = 0
            timer = Timer(timeInterval: 1, repeats: true, block: { _ in
                count += 1
                if self.playInfoViewTab == false, count > 4 {
                    self.playViewInfoTogle()
                }
            })
            RunLoop.current.add(timer!, forMode: .common)
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.blurEffect.alpha = 0.3
                    self.playInfoView.frame.origin.y += 140
                    self.view.layoutIfNeeded()
                }
            )
            self.playInfoViewTab = false
            print(playInfoViewTab)
        } else {
            backBT.isHidden = true
            pipBT.isHidden = true
            playStopBT.isHidden = true
            settingBT.isHidden = true
            volumeBT.isHidden = true
            rotateBT.isHidden = true
            timer?.invalidate()
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.blurEffect.alpha = 0
                    self.playInfoView.frame.origin.y -= 140
                    self.view.layoutIfNeeded()
                }
            )
            self.playInfoViewTab = true
            print(playInfoViewTab)
        }
    }

    private func settingInfo() {
        titleLabel.text = liveListModel?.hostName
        streamInfoLabel.text = liveListModel?.title
        categoryLabel.text = liveListModel?.streamCategory
    }
    
    private func settingPlayerURL() {
        let url = liveResult.hlsURL(hls: liveListModel?.hls ?? "")
        print("url",url.description)
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = TimeInterval(1.0)
        player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        playerLayer.frame = playView.bounds
        playerLayer.videoGravity = .resizeAspect
        playView.layer.addSublayer(playerLayer)
        player.play()
        player.volume = 0
        if player.timeControlStatus != .paused {
            print("pause")
            playStopBT.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        if AVPictureInPictureController.isPictureInPictureSupported(){
            pipPlayerController = AVPictureInPictureController(playerLayer: playerLayer)
            pipPlayerController?.delegate = self
        } else {
            print("PiP isn't suppoerted")
        }
        
        blurEffect.effect = UIBlurEffect(style: .dark)
        blurEffect.frame = playView.bounds
        playView.addSubview(blurEffect)
        blurEffect.alpha = 0.3
    }
    
    private func volumeSetting() {
        if volume == false {
            player.volume = 10
            volumeBT.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            volume = true
        } else {
            player.volume = 0
            volumeBT.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            volume = false
        }
    }
    
    // FirstTree/LiveList/\(self.liveListModel?.hls ?? "nil")/chatList/
    func chattingUpdate() {
        if let child = liveListModel?.hostName {
            ref.child("FirstTree/LiveList/\(child)/chatList/").observe(DataEventType.value) { DataSnapshot in
                guard let snapData = DataSnapshot.value as? [String:Any] else{return}
                let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
                do {
                    let decoder = JSONDecoder()
                    self.chattingList = try decoder.decode([ChattingUpdate].self, from: data)
                    self.chattingList = self.chattingList.sorted(by: {$0.date > $1.date})
                } catch let error {
                    print("get Firebase data error", error)
                }
                
                DispatchQueue.main.async {
                    self.chattingTableView.reloadData()
                    
                    // tableView Y축 뒤집기
                    self.chattingTableView.transform = CGAffineTransformMakeScale(1, -1)

                }
            }
        }
    }
}


extension PlayLiveVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chattingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chattingTableView.dequeueReusableCell(withIdentifier: "ChattingTableViewCell", for: indexPath) as! ChattingTableViewCell
        
        cell.contentView.backgroundColor = .black
        cell.selectionStyle = .none
        let selfSender = self.selfSender
        let sender = chattingList[indexPath.row].sender
        let body = chattingList[indexPath.row].body
        
        if selfSender == sender {
            cell.chatLabel.textAlignment = .right
            cell.chatLabel.text = body
            
        } else {
            cell.chatLabel.textAlignment = .left
            let senderBody = "\(sender) : \(body)"
            cell.chatLabel.text = senderBody
        }
        // tableViewCell Y축 뒤집기
        cell.contentView.transform = CGAffineTransformMakeScale(1, -1)
        return cell
    }
}

extension PlayLiveVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == textViewPlaceHolder {
                textView.text = nil
                textView.textColor = .white
            }
        }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
            
        }
    }
}

extension PlayLiveVC: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("willStart")
        self.dismiss(animated: true)
        
    }
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("didStart")
        pipPlayerController?.playerLayer.player?.play()
        
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("error")
    }
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        player.play()
    }
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("didStop")
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("restore")
        completionHandler(true)

    }
}


