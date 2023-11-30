//
//  Explorer.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/08/28.
//

import Foundation
import UIKit
import Firebase
import AVFoundation



class ExplorerVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let liveResult = LiveResult()
    var liveList: [LiveListModel] = []
    var generator: ACThumbnailGenerator!
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "LiveViewCell", bundle: nil), forCellReuseIdentifier: "LiveViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        liveListUpdate()
        initNavigationBar()
        setLeftBarBT()
        setRightBarBT()
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
//        self.viewDidLoad()
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

    func liveListUpdate() {
        ref.child("FirstTree/LiveList/").observe(DataEventType.value) { DataSnapshot in
            guard let snapData = DataSnapshot.value as? [String:Any] else{return}
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do {
                let decoder = JSONDecoder()
                self.liveList = try decoder.decode([LiveListModel].self, from: data)
                self.liveList = LiveList.result.liveList
                self.liveList = self.liveList.sorted(by: {$0.date > $1.date})
            } catch let error {
                print("get Firebase data error", error)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ExplorerVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        liveList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        330
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveViewCell") as! LiveViewCell
        let list = liveList[indexPath.row]
        cell.hostNameLabel.text = list.hostName
        cell.roomNameLabel.text = list.title
        cell.categoryLabel.text = list.streamCategory
        let cacheKey = NSString(string: list.imageURL)
        if let cacheImage = ImageCachManager.shared.object(forKey: cacheKey) {
            cell.thumbnailView.contentMode = .scaleToFill
            cell.thumbnailView.image = cacheImage
        }else {
            FirebaseStorageManager.downloadImage(urlString: list.imageURL) { image in
                if let image = image {
                    cell.thumbnailView.image = image
                    ImageCachManager.shared.setObject(image, forKey: cacheKey)
                }
            }
        }
        let hostCacheKey = NSString(string: list.hostImage)
        if let image = ImageCachManager.shared.object(forKey: hostCacheKey) {
            print("hostImage cashe")
            cell.hostImage.image = image
        }else {
            guard let urlData = URL(string: list.hostImage) else {return cell}
            if let data = try? Data(contentsOf: urlData) {
                if let image = UIImage(data: data){
                    cell.hostImage.image = image
                    ImageCachManager.shared.setObject(image, forKey: hostCacheKey)
                }
            }
        }
        cell.liveListModel = list
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
                // 화면 전환 애니메이션 설정
        secondViewController.modalTransitionStyle = .coverVertical
                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        secondViewController.modalPresentationStyle = .fullScreen
        self.present(secondViewController, animated: true, completion: nil)
        secondViewController.liveListModel = liveList[indexPath.row]
        
    }
    
    
}

extension ExplorerVC: ACThumbnailGeneratorDelegate {
    func generator(_ generator: ACThumbnailGenerator, didCapture image: UIImage, at position: Double) {
//        thumbnailImages.append(image)
        saveImage.img.thumbnail.append(image)
        let url = generator.streamUrl
        let cacheKey = NSString(string: url.description)
        
        ImageCachManager.shared.setObject(image, forKey: cacheKey)

        
    }
    
}

extension ExplorerVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let visivleCells = tableView.visibleCells as? [LiveViewCell] else{
            return
        }
        guard let firstCell = visivleCells.first else {
            return
        }
        if visivleCells.count == 1 {
            firstCell.livePlay()
            return
        }
        let secondCell = visivleCells[1]
        let firstCellPositionY = tableView.convert(firstCell.frame.origin, to: self.view).y
        if firstCellPositionY > -150 {
            firstCell.livePlay()
            var otherCells = visivleCells
            otherCells.removeFirst()
            otherCells.forEach { cell in
                cell.liveStop()
            }
        } else {
            secondCell.livePlay()
            var otherCells = visivleCells
            otherCells.remove(at: 1)
            otherCells.forEach { cell in
                cell.liveStop()
            }
        }
    }
}
