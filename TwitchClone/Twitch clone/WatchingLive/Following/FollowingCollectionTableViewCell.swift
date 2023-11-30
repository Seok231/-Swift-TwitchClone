//
//  FollowingCollectionTableViewCell.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/16.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVKit

protocol FollowingListVCDelegate: AnyObject {
    func collectionView(collectionviewcell: FollowingCollectionViewCell?, index: Int, didTappedInTableViewCell: FollowingCollectionTableViewCell, list: [CategoryModel])
}

class TestAVPlayerVC: AVPlayerViewController {
    
}


class FollowingCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var ref = Database.database().reference()
    let storage = Storage.storage()
    weak var cellDelegate: FollowingListVCDelegate?
    var categoryList:[CategoryModel] = []
    var categoryListResult:[CategoryModel] = []
    var userFollowingList: [UserFollowing] = []
    var testFollowingList: [UserFollowingList] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.showsHorizontalScrollIndicator = false
        categoryUpdate()
        liveListUpdate2()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FollowingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier : "FollowingCollectionViewCell")
    }
    
    func categoryUpdate() {
        ref.child("FirstTree/GameCategory").observe(DataEventType.value) { DataSnapshot in
            guard let snapData = DataSnapshot.value as? [String:Any] else{return}
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do {
                let decoder = JSONDecoder()
                self.categoryList = try decoder.decode([CategoryModel].self, from: data)
                CategoryModelList.result.list = self.categoryList
            } catch let error {
                print("get Firebase data error", error)
            }
        }
    }
    
    func liveListUpdate2() {
        let userEmailSplit = UserInfoModel.user.userEmailSplit
        ref.child("FirstTree/Users/\(userEmailSplit)/following/category").observe(DataEventType.value) { DataSnapshot in
            guard let snapData = DataSnapshot.value as? [String:Any] else{
                self.collectionView.reloadData()
                return
            }
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do {
                let decoder = JSONDecoder()
                self.userFollowingList = try decoder.decode([UserFollowing].self, from: data)
            } catch let error {
                print("get Firebase data error liveList", error)
            }
            self.categoryList = self.filterCategory()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func filterCategory() -> [CategoryModel] {
        var filteredList: [CategoryModel] = []
        if userFollowingList.count-1 > 0 {
            for i in 0...userFollowingList.count-1 {
                let name = userFollowingList[i].name
                for count in 0...categoryList.count-1 {
                    if categoryList[count].name == name {
                        filteredList.append(categoryList[count])
                    }
                }
            }
        }
        return filteredList
    }
}

extension FollowingCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let list = categoryList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingCollectionViewCell", for: indexPath) as! FollowingCollectionViewCell
        CasheImage.imageToDirectory(identifier: list.name, imageURL: list.url) { image in
            cell.coverImageView.image = image
        }
        cell.coverImageView.contentMode = .scaleToFill
        cell.coverImageView.layer.cornerRadius = 10
        cell.titleLabel.text = list.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? FollowingCollectionViewCell
        let category = self.categoryList
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self, list: category)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
    
    
    
    
}
