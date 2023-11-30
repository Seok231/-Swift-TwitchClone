//
//  FindLiveTableViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/29.
//

import UIKit

protocol FindListCollectionDelegate: AnyObject {
    func collectionView(collectionviewcell: FindListCollectionViewCell?, index: Int, didTappedInTableViewCell: FindListTableViewCell)
}


class FindListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var findListCollectionView: UICollectionView!
    weak var cellDelegate: FindListCollectionDelegate?
    let liveResult = LiveResult()
    var generator: ACThumbnailGenerator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 스크롤바
        findListCollectionView.showsHorizontalScrollIndicator = false
        findListCollectionView.register(UINib(nibName: "FindListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FindListCollectionViewCell")
        findListCollectionView.dataSource = self
        findListCollectionView.delegate = self
    }
}

extension FindListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        LiveList.result.liveList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = findListCollectionView.dequeueReusableCell(withReuseIdentifier: "FindListCollectionViewCell", for: indexPath) as! FindListCollectionViewCell
        let list = LiveList.result.liveList[indexPath.row]
        CasheImage.thumbnailImage2(imageURL: list.imageURL) { image in
            cell.listImageView.image = image
        }
        let hostImage = CasheImage.hostImage(stringURL: list.hostImage)
        cell.hostNameLabel.text = list.hostName
        cell.roomNameLabel.text = list.title
        cell.categoryLabel.text = list.streamCategory
        cell.hostImageView.image = hostImage
        cell.listImageView.contentMode = .scaleAspectFill
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = findListCollectionView.cellForItem(at: indexPath) as? FindListCollectionViewCell
        
        // table cell 안 collection cell 눌린 정보 가져오기
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 400)
    }
}


