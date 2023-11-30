//
//  SearchCategoeyVC.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/27/23.
//

import UIKit
import FirebaseStorage

protocol SearchCategoeyVCProtocol {
    func didFinish(name: String, imageURL: String)
}

class SearchCategoeyVC: UIViewController {
    var delegate: SearchCategoeyVCProtocol?
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var storage = Storage.storage()
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(UINib(nibName: "FollowingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowingCollectionViewCell")
    }
}

extension SearchCategoeyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CategoryModelList.result.list.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingCollectionViewCell", for: indexPath) as! FollowingCollectionViewCell
        let list = CategoryModelList.result.list[indexPath.row]
        
        CasheImage.imageToDirectory(identifier: list.name, imageURL: list.url) { image in
            cell.coverImageView.image = image
        }
        cell.coverImageView.contentMode = .scaleToFill
        cell.coverImageView.layer.cornerRadius = 10
        cell.titleLabel.text = list.name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let result = CategoryModelList.result.list[indexPath.row]
        print("didSelectItemAt", result.name, result.url)
        delegate?.didFinish(name: result.name, imageURL: result.url)
        self.dismiss(animated: true)
        
        
    }
    
    
    
    
    
}

